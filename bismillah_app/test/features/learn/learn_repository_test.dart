import 'package:bismillah_app/features/learn/data/asset_learning_knowledge_repository.dart';
import 'package:bismillah_app/features/learn/data/learning_search_normalizer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bilgi tabanı deposu ve offline arama (TASK 056 §14).
///
/// Gerçek ağ ve Firebase KULLANILMAZ — depo tamamen asset tabanlıdır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Arama normalizasyonu', () {
    test('Türkçe harfler katlanır', () {
      // Kullanıcı aksansız yazsa da içerik bulunmalıdır.
      expect(
        LearningSearchNormalizer.normalize('Gusül'),
        LearningSearchNormalizer.normalize('gusul'),
      );
      expect(
        LearningSearchNormalizer.normalize('İman'),
        LearningSearchNormalizer.normalize('iman'),
      );
      expect(
        LearningSearchNormalizer.normalize('Tövbe'),
        LearningSearchNormalizer.normalize('tovbe'),
      );
    });

    test("kesme işareti yok sayılır: kuran ↔ kur'an", () {
      expect(
        LearningSearchNormalizer.normalize("Kur'an"),
        LearningSearchNormalizer.normalize('kuran'),
      );
    });

    test('Arapça hareke ve elif varyantları normalize edilir', () {
      expect(
        LearningSearchNormalizer.normalize('القرآن'),
        LearningSearchNormalizer.normalize('القران'),
      );
      // Hareke kaldırılır.
      expect(
        LearningSearchNormalizer.normalize('الصَّلاة'),
        LearningSearchNormalizer.normalize('الصلاة'),
      );
    });

    test('boş sorgu eşleşme üretmez', () {
      expect(LearningSearchNormalizer.matches('', ['abdest']), isFalse);
      expect(LearningSearchNormalizer.matches('   ', ['abdest']), isFalse);
    });
  });

  group('AssetLearningKnowledgeRepository', () {
    late AssetLearningKnowledgeRepository repository;

    setUp(() {
      repository = AssetLearningKnowledgeRepository();
    });

    test('kategoriler yayınlanmış içerik sayısıyla döner', () async {
      final result = await repository.getCategories('tr');
      final categories = result.valueOrNull;

      expect(categories, isNotNull);
      expect(categories!.length, 20);

      // Dolu ve boş kategoriler dürüstçe ayrışır.
      final purity = categories.firstWhere(
        (c) => c.category.id == 'cat-purity',
      );
      expect(purity.publishedCount, greaterThan(0));
      expect(purity.isEmpty, isFalse);

      // Boş kategori örneği SABİT KODLANMAZ: Learn kütüphanesi her paketle
      // büyüdüğü için hangi kategorinin boş kaldığı zamanla değişir.
      final empty = categories.firstWhere(
        (c) => c.publishedCount == 0,
        orElse: () => throw StateError(
          'Boş kategori kalmadı; bu testin dürüst-boş güvencesi '
          'yeniden tasarlanmalıdır',
        ),
      );
      expect(empty.isEmpty, isTrue);
    });

    test('kategori içerikleri filtrelenir ve sıralanır', () async {
      final result = await repository.getArticlesByCategory('tr', 'cat-purity');
      final articles = result.valueOrNull;

      expect(articles, isNotNull);
      expect(articles, isNotEmpty);
      expect(articles!.every((a) => a.categoryId == 'cat-purity'), isTrue);
      // Kolaydan derine sıralama.
      for (var i = 1; i < articles.length; i++) {
        expect(
          articles[i - 1].difficulty.index <= articles[i].difficulty.index,
          isTrue,
        );
      }
    });

    test('slug ile içerik çözülür ve bölümleri taşır', () async {
      // Kaynak gövdesi DOĞRULANMIŞ bir makale seçilir (TASK 056A).
      final result = await repository.getArticleBySlug(
        'tr',
        'abdesti-bozan-durumlar',
      );
      final article = result.valueOrNull;

      expect(article, isNotNull);
      expect(article!.title, 'Abdesti bozan durumlar');
      expect(article.isSourceBodyVerified, isTrue);
      expect(article.sections, isNotEmpty);
      expect(article.sourceIds, isNotEmpty);
      expect(article.isPublished, isTrue);
    });

    test('bilinmeyen slug null döner (crash yok)', () async {
      final result = await repository.getArticleBySlug(
        'tr',
        'boyle-bir-sey-yok',
      );
      expect(result.valueOrNull, isNull);
    });

    test('başlık ve alias üzerinden arama çalışır', () async {
      // Başlık (yalnız yayınlanmış = doğrulanmış içerik aranır).
      final byTitle = (await repository.search('tr', 'abdest')).valueOrNull;
      expect(byTitle, isNotEmpty);
      expect(byTitle!.any((a) => a.slug == 'abdesti-bozan-durumlar'), isTrue);

      // Alias/keyword üzerinden eşleşme.
      final byAlias = (await repository.search(
        'tr',
        'toprakla abdest',
      )).valueOrNull;
      expect(byAlias!.any((a) => a.slug == 'teyemmum-nedir'), isTrue);

      // Türkçe normalizasyon: "sehadet" → "Kelime-i şehadet".
      final byFolded = (await repository.search('tr', 'sehadet')).valueOrNull;
      expect(byFolded!.any((a) => a.slug == 'kelime-i-sehadet'), isTrue);

      // Kesme işareti: "kuran" → "Kur'an nedir?".
      final byQuran = (await repository.search('tr', 'kuran')).valueOrNull;
      expect(byQuran!.any((a) => a.slug == 'kuran-nedir'), isTrue);
    });

    test('kategori adı üzerinden de aranabilir', () async {
      final results = (await repository.search('tr', 'Namaz')).valueOrNull;
      expect(results, isNotEmpty);
    });

    test('eşleşmeyen sorgu BOŞ liste döner', () async {
      final results = (await repository.search('tr', 'zzzzqqq')).valueOrNull;
      expect(results, isEmpty);
    });

    test('tek harflik sorgu her şeyi getirmez', () async {
      final results = (await repository.search('tr', 'a')).valueOrNull;
      expect(results, isEmpty);
    });

    test('Arapça locale Arapça içerik döner', () async {
      final article = (await repository.getArticleBySlug(
        'ar',
        'ma-hu-al-tayammum',
      )).valueOrNull;

      expect(article, isNotNull);
      expect(article!.title, 'ما هو التيمم؟');
      // Arapça arama da çalışır.
      final results = (await repository.search('ar', 'التيمم')).valueOrNull;
      expect(results, isNotEmpty);
    });

    test('yeni başlayanlar yolu sıralı döner', () async {
      final path = (await repository.getBeginnerPath('tr')).valueOrNull;
      expect(path, isNotEmpty);
      for (var i = 1; i < path!.length; i++) {
        expect(
          path[i - 1].beginnerPathOrder! < path[i].beginnerPathOrder!,
          isTrue,
        );
      }
    });

    test('kaynak künyeleri içerikten çözülür', () async {
      final article = (await repository.getArticleBySlug(
        'tr',
        'abdesti-bozan-durumlar',
      )).valueOrNull;
      final sources = (await repository.getSourcesForArticle(
        article!,
      )).valueOrNull;

      expect(sources, isNotEmpty);
      expect(sources!.first.institution, contains('Diyanet'));
      expect(sources.first.originalLanguage, 'tr');
    });

    test('desteklenmeyen locale Türkçeye düşer', () async {
      final article = (await repository.getArticleBySlug(
        'de',
        'abdesti-bozan-durumlar',
      )).valueOrNull;
      expect(article, isNotNull);
    });

    test('cache: ikinci okuma asset\'i yeniden PARSE ETMEZ', () async {
      var loadCount = 0;
      final counting = AssetLearningKnowledgeRepository(
        bundle: _CountingBundle(onLoad: () => loadCount++),
      );

      await counting.getArticlesByCategory('tr', 'cat-purity');
      final afterFirst = loadCount;
      expect(afterFirst, greaterThan(0));

      await counting.getArticlesByCategory('tr', 'cat-prayer');
      await counting.getArticleBySlug('tr', 'abdesti-bozan-durumlar');
      await counting.search('tr', 'abdest');

      // Sonraki erişimler cache'ten karşılanır.
      expect(loadCount, afterFirst);
    });

    // -----------------------------------------------------------------
    // TASK 056A: yayın kapısının RUNTIME etkisi
    // -----------------------------------------------------------------

    test("kaynak gövdesi doğrulanmamış içerik RUNTIME'DA GÖRÜNMEZ", () async {
      // TASK 057: "Dua adabı" ve "Kur'an okumaya başlangıç" kaynak gövdesi
      // okunamadığı için pending; hiçbir okuma yolundan sızmamalıdır.
      expect(
        (await repository.getArticleBySlug('tr', 'dua-adabi')).valueOrNull,
        isNull,
      );
      expect(
        (await repository.getArticleBySlug(
          'tr',
          'kuran-okumaya-baslangic',
        )).valueOrNull,
        isNull,
      );

      final dua = (await repository.getArticlesByCategory(
        'tr',
        'cat-dua',
      )).valueOrNull!;
      expect(dua.any((a) => a.slug == 'dua-adabi'), isFalse);

      final search = (await repository.search('tr', 'dua adabi')).valueOrNull!;
      expect(search.any((a) => a.slug == 'dua-adabi'), isFalse);
    });

    test('görünen HER içerik kaynak gövdesi doğrulanmış olmalıdır', () async {
      for (final locale in ['tr', 'en', 'ar']) {
        final categories = (await repository.getCategories(
          locale,
        )).valueOrNull!;
        for (final summary in categories) {
          final articles = (await repository.getArticlesByCategory(
            locale,
            summary.category.id,
          )).valueOrNull!;
          for (final article in articles) {
            expect(
              article.isSourceBodyVerified,
              isTrue,
              reason: '$locale/${article.id} doğrulanmadan görünüyor',
            );
            expect(article.isPublished, isTrue);
            expect(article.verification!.sourceLocator, isNotEmpty);
            expect(article.verification!.evidenceSummary, isNotEmpty);
          }
        }
      }
    });

    test('Türkçe kanonik PENDING ise en/ar sürümü de GÖRÜNMEZ', () async {
      // art-dua-adabi Türkçede pending → çevirileri de kapalı.
      expect(
        (await repository.getArticleBySlug(
          'en',
          'etiquette-of-supplication',
        )).valueOrNull,
        isNull,
      );
      expect(
        (await repository.getArticleBySlug('ar', 'adab-al-dua')).valueOrNull,
        isNull,
      );
    });

    test('üç locale AYNI yayın kümesini gösterir', () async {
      Future<Set<String>> publishedIds(String locale) async {
        final categories = (await repository.getCategories(
          locale,
        )).valueOrNull!;
        final ids = <String>{};
        for (final summary in categories) {
          final articles = (await repository.getArticlesByCategory(
            locale,
            summary.category.id,
          )).valueOrNull!;
          ids.addAll(articles.map((a) => a.id));
        }
        return ids;
      }

      final tr = await publishedIds('tr');
      expect(tr, isNotEmpty);
      expect(await publishedIds('en'), tr);
      expect(await publishedIds('ar'), tr);
    });

    // -----------------------------------------------------------------
    // TASK 057: genişletilmiş kütüphane araması ve kategori dağılımı
    // -----------------------------------------------------------------

    test('yeni ibadet kategorileri içerik döndürür', () async {
      for (final entry in {
        'cat-fasting': 'oruc-kimlere-farzdir',
        'cat-zakat': 'zekatin-sartlari',
        'cat-hajj': 'hac-kimlere-farzdir',
      }.entries) {
        final articles = (await repository.getArticlesByCategory(
          'tr',
          entry.key,
        )).valueOrNull!;
        expect(articles, isNotEmpty, reason: entry.key);
        expect(
          articles.any((a) => a.slug == entry.value),
          isTrue,
          reason: entry.key,
        );
      }
    });

    test('namaz / abdest / oruç / zekât aramaları sonuç verir', () async {
      for (final query in ['namaz', 'abdest', 'oruc', 'zekat']) {
        final results = (await repository.search('tr', query)).valueOrNull!;
        expect(results, isNotEmpty, reason: 'sorgu: $query');
      }
    });

    test('Türkçe aksan katlama yeni içerikte de çalışır', () async {
      // "zekat" yazımı "Zekât" başlığını bulmalı.
      final zakat = (await repository.search('tr', 'zekat')).valueOrNull!;
      expect(zakat.any((a) => a.slug == 'zekatin-sartlari'), isTrue);
      // "gusul" yazımı "Guslün..." içeriğini bulmalı.
      final ghusl = (await repository.search('tr', 'gusul')).valueOrNull!;
      expect(ghusl, isNotEmpty);
    });

    test(
      'İngilizce alias ve Arapça normalizasyon yeni içerikte çalışır',
      () async {
        final en = (await repository.search('en', 'zakat')).valueOrNull!;
        expect(en.any((a) => a.slug == 'conditions-of-zakat'), isTrue);

        final ar = (await repository.search('ar', 'الزكاة')).valueOrNull!;
        expect(ar, isNotEmpty);
      },
    );

    test('ilgili makale referansları çözülebilir', () async {
      final article = (await repository.getArticleBySlug(
        'tr',
        'zekatin-sartlari',
      )).valueOrNull!;
      expect(article.relatedArticleIds, isNotEmpty);

      final related = (await repository.getArticlesByIds(
        'tr',
        article.relatedArticleIds,
      )).valueOrNull!;
      // Yayında olmayan ilgili içerik sessizce atlanır; kalanlar çözülür.
      expect(related, isNotEmpty);
      expect(related.every((a) => a.isPublished), isTrue);
    });

    test('asset okunamazsa sakin failure döner (crash yok)', () async {
      final broken = AssetLearningKnowledgeRepository(bundle: _FailingBundle());
      final result = await broken.getCategories('tr');
      expect(result.isSuccess, isFalse);
      expect(result.valueOrNull, isNull);
    });

    test('bozuk JSON sakin failure döner', () async {
      final broken = AssetLearningKnowledgeRepository(
        bundle: _StaticBundle('{ not valid json'),
      );
      final result = await broken.getCategories('tr');
      expect(result.isSuccess, isFalse);
    });
  });
}

/// Gerçek asset'i okuyan ama yükleme sayısını sayan bundle.
final class _CountingBundle extends CachingAssetBundle {
  _CountingBundle({required this.onLoad});

  final void Function() onLoad;

  @override
  Future<ByteData> load(String key) {
    onLoad();
    return rootBundle.load(key);
  }
}

final class _FailingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw Exception('asset unavailable');
}

final class _StaticBundle extends CachingAssetBundle {
  _StaticBundle(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.view(Uint8List.fromList(content.codeUnits).buffer);
}
