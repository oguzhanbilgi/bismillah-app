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

      final empty = categories.firstWhere(
        (c) => c.category.id == 'cat-history',
      );
      expect(empty.publishedCount, 0);
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
      final result = await repository.getArticleBySlug(
        'tr',
        'abdest-nasil-alinir',
      );
      final article = result.valueOrNull;

      expect(article, isNotNull);
      expect(article!.title, 'Abdest nasıl alınır?');
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
      // Başlık.
      final byTitle = (await repository.search('tr', 'abdest')).valueOrNull;
      expect(byTitle, isNotEmpty);
      expect(byTitle!.any((a) => a.slug == 'abdest-nasil-alinir'), isTrue);

      // Alias/keyword: "aptes" yazımı da bulmalı.
      final byAlias = (await repository.search('tr', 'aptes')).valueOrNull;
      expect(byAlias!.any((a) => a.slug == 'abdest-nasil-alinir'), isTrue);

      // Türkçe normalizasyon: "gusul" → "Gusül".
      final byFolded = (await repository.search('tr', 'gusul')).valueOrNull;
      expect(byFolded!.any((a) => a.slug == 'gusul-nasil-alinir'), isTrue);

      // Kesme işareti: "kuran" → "Kur'an nedir?".
      final byQuran = (await repository.search('tr', 'kuran')).valueOrNull;
      expect(byQuran!.any((a) => a.slug == 'kuran-nedir'), isTrue);

      // "tövbe" yazımı "tevbe" içeriğini bulur.
      final byTawba = (await repository.search('tr', 'tövbe')).valueOrNull;
      expect(byTawba!.any((a) => a.slug == 'tevbe-ve-umit'), isTrue);
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
        'kayfa-yutawadda',
      )).valueOrNull;

      expect(article, isNotNull);
      expect(article!.title, 'كيف يُتوضّأ؟');
      // Arapça arama da çalışır.
      final results = (await repository.search('ar', 'الوضوء')).valueOrNull;
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
        'abdest-nasil-alinir',
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
        'abdest-nasil-alinir',
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
      await counting.getArticleBySlug('tr', 'abdest-nasil-alinir');
      await counting.search('tr', 'abdest');

      // Sonraki erişimler cache'ten karşılanır.
      expect(loadCount, afterFirst);
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
