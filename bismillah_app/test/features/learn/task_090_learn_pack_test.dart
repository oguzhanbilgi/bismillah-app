import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 090 — Mezhepler / İslam takvimi paketinin içerik güvencesi.
///
/// Tablo tabanlıdır. Önceki paket süitleri ve
/// `learn_content_integrity_test.dart` TEKRARLANMAZ.
void main() {
  Object? readJson(String name) =>
      json.decode(File('assets/content/learn/$name').readAsStringSync());

  final rawSources =
      (readJson('sources.json')! as Map<String, Object?>)['sources']!
          as List<Object?>;
  final sources = LearningContentParser.parseSources(readJson('sources.json'));
  final sourceIds = {for (final s in sources) s.id};

  const locales = ['tr', 'en', 'ar'];
  final byLocale = {
    for (final locale in locales)
      locale: LearningContentParser.parseArticles(
        readJson('articles_$locale.json'),
        expectedLocale: locale,
        validSourceIds: sourceIds,
      ),
  };

  Map<String, LearningArticle> mapOf(String locale) => {
    for (final a in byLocale[locale]!) a.id: a,
  };

  const pack = <String, String>{
    'art-mezhep-nedir': 'cat-madhhabs',
    'art-dini-hukumlerin-kaynaklari': 'cat-madhhabs',
    'art-amelde-mezhepler': 'cat-madhhabs',
    'art-hicri-takvim-nedir': 'cat-calendar',
    'art-hicri-aylar-ve-yil-uzunlugu': 'cat-calendar',
    'art-hicri-takvimin-baslangici': 'cat-calendar',
  };

  const madhhabIds = [
    'art-mezhep-nedir',
    'art-dini-hukumlerin-kaynaklari',
    'art-amelde-mezhepler',
  ];
  const calendarIds = [
    'art-hicri-takvim-nedir',
    'art-hicri-aylar-ve-yil-uzunlugu',
    'art-hicri-takvimin-baslangici',
  ];

  const newSourceId = 'diyanet-vakit-hesaplama';

  const catalog = LearnDailyPlanCatalog.v1;
  final catalogIds = [for (final e in catalog.entries) e.articleId];

  Iterable<String> proseOf(LearningArticle a) sync* {
    yield a.title;
    yield a.summary;
    for (final s in a.sections) {
      if (s.text != null) yield s.text!;
      yield* s.items;
    }
  }

  String proseTr(String id) => proseOf(mapOf('tr')[id]!).join(' ').toLowerCase();

  group('TASK 090 kapsamı', () {
    test('tam olarak altı yeni kimlik eklendi', () {
      expect(pack.length, 6);
      final tr = mapOf('tr');
      for (final id in pack.keys) {
        expect(tr.containsKey(id), isTrue, reason: id);
      }
    });

    test('kategori dağılımı 3 mezhep / 3 takvim', () {
      final counts = <String, int>{};
      for (final category in pack.values) {
        counts[category] = (counts[category] ?? 0) + 1;
      }
      expect(counts, {'cat-madhhabs': 3, 'cat-calendar': 3});
    });

    test('hedef kategorilerdeki YAYINLANMIŞ içerik yalnız TASK 090 paketidir',
        () {
      final tr = byLocale['tr']!;
      for (final category in {'cat-madhhabs', 'cat-calendar'}) {
        final ids = {
          for (final a in tr)
            if (a.categoryId == category && a.isPublished) a.id,
        };
        final expected = {
          for (final e in pack.entries)
            if (e.value == category) e.key,
        };
        expect(ids, expected, reason: category);
      }
    });

    test('inceleme bekleyen adaylar EKLENMEMİŞTİR', () {
      // Gate'te SCHOLARLY REVIEW REQUIRED olarak işaretlenen dört aday
      // TASK 090 kapsamına ALINMADI; kategoriyi doldurmak için hassas
      // içerik yayımlanmaz.
      const blocked = [
        'art-gorus-farkliliklari-nasil-olusur',
        'art-itikadi-ve-ameli-mezhep-ayrimi',
        'art-takvim-ve-resmi-dini-gun-tespiti',
        'art-aylarin-sayisi-on-ikidir',
      ];
      for (final locale in locales) {
        for (final id in blocked) {
          expect(mapOf(locale).containsKey(id), isFalse, reason: '$locale/$id');
        }
      }
    });

    test('YİRMİ kategorinin tamamı artık yayınlanmış içerik taşır', () {
      final categoryIds = [
        for (final c in LearningContentParser.parseCategories(
          readJson('categories.json'),
          'tr',
        ))
          c.id,
      ];
      expect(categoryIds.length, 20);
      final populated = {
        for (final a in byLocale['tr']!)
          if (a.isPublished) a.categoryId,
      };
      for (final id in categoryIds) {
        expect(populated, contains(id), reason: '$id hâlâ boş');
      }
    });
  });

  group('locale paritesi (tablo)', () {
    test('altı kimlik üç locale\'de de vardır ve kümeler aynıdır', () {
      final tr = mapOf('tr').keys.toSet();
      for (final locale in locales) {
        final ids = mapOf(locale).keys.toSet();
        for (final id in pack.keys) {
          expect(ids, contains(id), reason: '$locale eksik: $id');
        }
        expect(ids, tr, reason: locale);
      }
    });

    test('kategori, yayın ve inceleme durumu üç locale\'de aynıdır', () {
      for (final id in pack.keys) {
        final categories = {
          for (final locale in locales) mapOf(locale)[id]!.categoryId,
        };
        final statuses = {
          for (final locale in locales) mapOf(locale)[id]!.reviewStatus,
        };
        expect(categories.length, 1, reason: id);
        expect(categories.single, pack[id], reason: id);
        expect(statuses.single, ReviewStatus.published, reason: id);
      }
    });

    test('Türkçe özgün, EN/AR açıklayıcı çeviri olarak işaretli', () {
      for (final id in pack.keys) {
        expect(
          mapOf('tr')[id]!.translationStatus,
          LearningTranslationStatus.original,
          reason: id,
        );
        for (final locale in ['en', 'ar']) {
          expect(
            mapOf(locale)[id]!.translationStatus,
            LearningTranslationStatus.explanatoryTranslation,
            reason: '$locale/$id',
          );
        }
      }
    });

    test('başlıklar üç locale\'de farklıdır ve Arapça Latin harf taşımaz', () {
      final latin = RegExp(r'[A-Za-z]');
      for (final id in pack.keys) {
        final titles = {
          for (final locale in locales) mapOf(locale)[id]!.title,
        };
        expect(titles.length, 3, reason: id);
        final ar = mapOf('ar')[id]!;
        expect(latin.hasMatch(ar.title), isFalse, reason: id);
        expect(latin.hasMatch(ar.summary), isFalse, reason: id);
      }
    });
  });

  group('kaynak doğrulama', () {
    test('her makale sourceBodyReview + editorialReview taşır', () {
      for (final locale in locales) {
        for (final id in pack.keys) {
          final v = mapOf(locale)[id]!.verification!;
          expect(v.sourceBodyVerified, isTrue, reason: '$locale/$id');
          expect(
            v.verificationMethod,
            VerificationMethod.sourceBodyReview,
            reason: '$locale/$id',
          );
          expect(v.verifiedBy, VerifiedBy.editorialReview, reason: '$locale/$id');
        }
      }
    });

    test('her makale KESİN konum, kanıt ve tarih taşır', () {
      for (final id in pack.keys) {
        final article = mapOf('tr')[id]!;
        final v = article.verification!;
        expect(v.sourceLocator.contains(RegExp(r'\s')), isTrue, reason: id);
        expect(v.evidenceSummary.trim(), isNotEmpty, reason: id);
        expect(v.verifiedAt.trim(), isNotEmpty, reason: id);
        expect(article.reviewedAt, isNotNull, reason: id);
      }
    });

    test('mezhep makaleleri İlmihal locator\'ı ile basılı SAYFA taşır', () {
      final pageRef = RegExp(r's\.\s?\d{1,4}');
      for (final id in madhhabIds) {
        final v = mapOf('tr')[id]!.verification!;
        expect(v.sourceId, 'diyanet-islam-ilmihali', reason: id);
        expect(v.sourceLocator, contains('İslam İlmihali'), reason: id);
        expect(pageRef.hasMatch(v.sourceLocator), isTrue,
            reason: '$id: ${v.sourceLocator}');
      }
    });

    test('takvim makaleleri yeni kaynağa ve BÖLÜM başlığına dayanır', () {
      for (final id in calendarIds) {
        final article = mapOf('tr')[id]!;
        final v = article.verification!;
        expect(v.sourceId, newSourceId, reason: id);
        expect(article.sourceIds, contains(newSourceId), reason: id);
        // Locator, sayfanın kendi bölüm başlığını göstermelidir — yalın bir
        // ana sayfa adresi değil.
        expect(v.sourceLocator, contains('Hicriden'), reason: id);
        expect(v.sourceLocator, contains('Hicri Takvim Hakkında Açıklama'),
            reason: id);
        expect(v.sourceLocator.startsWith('http'), isFalse, reason: id);
      }
    });

    test('paket yalnız üç kayıtlı kaynağı kullanır', () {
      final used = <String>{
        for (final id in pack.keys) ...mapOf('tr')[id]!.sourceIds,
      };
      expect(used, {
        'diyanet-islam-ilmihali',
        newSourceId,
        'diyanet-hz-muhammedin-hayati',
      });
      for (final id in pack.keys) {
        final article = mapOf('tr')[id]!;
        expect(sourceIds, contains(article.verification!.sourceId));
        expect(article.sourceIds, contains(article.verification!.sourceId));
      }
    });

    test('TASK 090 TEK yeni kaynak kaydı ekler', () {
      const afterTask087 = <String>{
        'diyanet-islam-ilmihali',
        'diyanet-kuran-portali',
        'diyanet-kuran-yolu-tefsiri',
        'diyanet-hadislerle-islam',
        'diyanet-din-isleri-yuksek-kurulu',
        'diyanet-dini-soru-hizmetleri',
        'diyanet-hz-muhammedin-hayati',
      };
      expect(sourceIds, containsAll(afterTask087));
      expect(sourceIds, contains(newSourceId));
      expect(sourceIds.difference(afterTask087), {newSourceId});
    });

    test('yeni kaynak resmî alan adında ve TAM künyelidir', () {
      final source = sources.firstWhere((s) => s.id == newSourceId);
      expect(OfficialSourceDomains.isAllowed(source.canonicalUrl), isTrue);
      expect(source.canonicalUrl, startsWith('https://www2.diyanet.gov.tr/'));
      expect(source.institution, contains('Diyanet'));
      expect(source.isOfficial, isTrue);
      expect(source.originalLanguage, 'tr');
      expect(source.accessedAt, isNotEmpty);
      expect(source.lastVerifiedAt, isNotEmpty);
      expect(source.usageNotes, contains('özgün özet'));
      // Diyanet onayı İDDİA EDİLMEZ.
      expect(source.usageNotes, contains('onayı olduğu ileri sürülmez'));
    });

    test('yeni kaynakta OLMAYAN künye uydurulmamıştır', () {
      final raw =
          rawSources.cast<Map<String, Object?>>().firstWhere(
            (s) => s['id'] == newSourceId,
          );
      // Şemada bulunmayan alanlar icat edilmemelidir.
      for (final invented in ['author', 'edition', 'isbn', 'publishedAt']) {
        expect(raw.containsKey(invented), isFalse, reason: invented);
      }
      // Bir internet sayfası olduğu ve künye taşımadığı AÇIKÇA kayıtlıdır.
      final info = raw['publicationInfo']! as String;
      expect(info, contains('internet hizmetidir'));
      expect(info, contains('künyesi'));
    });

    test('TÜM kaynak alan adları diyanet.gov.tr altındadır', () {
      for (final source in sources) {
        expect(
          OfficialSourceDomains.isAllowed(source.canonicalUrl),
          isTrue,
          reason: source.id,
        );
      }
    });
  });

  group('içerik güvenliği — mezhepler', () {
    test('üstünlük, sapkınlık veya bidat dili taşımaz', () {
      const forbidden = [
        'daha üstün',
        'en üstün',
        'tek doğru',
        'sapık',
        'bidat',
        'bid\'at',
        'kâfir',
        'küfür',
        'ehl-i sünnet',
        'ehl-i bidat',
        'mutezile',
        'selefiyye',
        'maturidi',
        'eşari',
      ];
      for (final id in madhhabIds) {
        final joined = proseTr(id);
        for (final term in forbidden) {
          expect(joined, isNot(contains(term)), reason: '$id / $term');
        }
      }
    });

    test('kişisel hüküm, fetva veya mezhep seçimi yönlendirmesi yoktur', () {
      const forbidden = [
        'fetva',
        'caizdir',
        'caiz değildir',
        'haramdır',
        'helaldir',
        'şu mezhebi seç',
        'takip etmelisin',
        'uymalısın',
      ];
      for (final id in madhhabIds) {
        final joined = proseTr(id);
        for (final term in forbidden) {
          expect(joined, isNot(contains(term)), reason: '$id / $term');
        }
      }
    });

    test('siyasi olay ve etnik köken tahmini DIŞARIDA bırakıldı', () {
      const forbidden = [
        'hapis',
        'dayak',
        'işkence',
        'kadılık',
        'halife',
        'büyük ihtimalle',
      ];
      final joined = proseTr('art-amelde-mezhepler');
      for (final term in forbidden) {
        expect(joined, isNot(contains(term)), reason: term);
      }
    });

    test('kaynağın kendi "yaygın" çerçevesi KORUNUR', () {
      final joined = proseTr('art-amelde-mezhepler');
      expect(joined, contains('yaygın'));
      // Dört mezhep de anılır.
      for (final name in ['hanefî', 'şâfiî', 'mâlikî', 'hanbelî']) {
        expect(joined, contains(name), reason: name);
      }
    });

    test('görüş farkı GİZLENMEZ ve doğrulanmış kayda dayanır', () {
      const id = 'art-dini-hukumlerin-kaynaklari';
      for (final locale in locales) {
        final article = mapOf(locale)[id]!;
        expect(
          article.sections.any(
            (s) => s.type == LearningSectionType.differenceOfOpinion,
          ),
          isTrue,
          reason: locale,
        );
        expect(article.isSourceBodyVerified, isTrue, reason: locale);
      }
      expect(proseTr(id), contains('tartışmalı'));
    });

    test('kaynak hiyerarşisi çekirdek iddiası korunur', () {
      final joined = proseTr('art-dini-hukumlerin-kaynaklari');
      for (final term in ['kitap', 'sünnet', 'icma', 'kıyas']) {
        expect(joined, contains(term), reason: term);
      }
    });
  });

  group('içerik güvenliği — takvim', () {
    test('mübarek gün/gece, hilal ve resmî tespit dili taşımaz', () {
      const forbidden = [
        'hilal',
        'rü\'yet',
        'ruyet',
        'kandil',
        'kadir gecesi',
        'berat',
        'regaib',
        'mirac',
        'bayram',
        'sevap',
        'fazilet',
        'burç',
        'fal',
      ];
      for (final id in calendarIds) {
        final joined = proseTr(id);
        for (final term in forbidden) {
          expect(joined, isNot(contains(term)), reason: '$id / $term');
        }
      }
    });

    test('uygulamanın dinî tarih belirlemediği AÇIKÇA yazılıdır', () {
      expect(
        proseTr('art-hicri-takvim-nedir'),
        contains('resmî tarihini belirlemez'),
      );
    });

    test('sahip düzeltmesi: KESİN milâdî karşılık hiçbir yerde geçmez', () {
      // Bağlayıcı sahip kararı: kaynağın verdiği kesin milâdî dönüşüm
      // tarihleri yayımlanan içerikte YER ALMAZ ve başka bir kesin milâdî
      // tarihle DEĞİŞTİRİLMEZ.
      const forbidden = ['16 temmuz', '20 eylül', '622', '621'];
      for (final locale in locales) {
        for (final id in calendarIds) {
          final article = mapOf(locale)[id]!;
          final v = article.verification!;
          final joined = [
            ...proseOf(article),
            v.sourceLocator,
            v.evidenceSummary,
          ].join(' ').toLowerCase();
          for (final term in forbidden) {
            expect(joined, isNot(contains(term)), reason: '$locale/$id/$term');
          }
        }
      }
    });

    test('takvimin çekirdek iddiaları korunur', () {
      expect(proseTr('art-hicri-takvim-nedir'), contains('hicret'));
      final months = proseTr('art-hicri-aylar-ve-yil-uzunlugu');
      for (final month in [
        'muharrem',
        'safer',
        'recep',
        'ramazan',
        'zilhicce',
      ]) {
        expect(months, contains(month), reason: month);
      }
      expect(months, contains('354'));
      final start = proseTr('art-hicri-takvimin-baslangici');
      expect(start, contains('muharrem'));
      expect(start, contains('17'));
    });
  });

  group('genel içerik güvencesi', () {
    test('kullanıcı metninde ham kimlik veya kaynak anahtarı GÖRÜNMEZ', () {
      for (final locale in locales) {
        for (final id in pack.keys) {
          for (final text in proseOf(mapOf(locale)[id]!)) {
            expect(text.contains('art-'), isFalse, reason: '$locale/$id');
            expect(text.contains('cat-'), isFalse, reason: '$locale/$id');
            expect(text.contains('diyanet-'), isFalse, reason: '$locale/$id');
          }
        }
      }
    });

    test('zorunlu metin alanları boş değildir', () {
      for (final locale in locales) {
        for (final id in pack.keys) {
          final a = mapOf(locale)[id]!;
          expect(a.title.trim(), isNotEmpty, reason: '$locale/$id');
          expect(a.summary.trim(), isNotEmpty, reason: '$locale/$id');
          expect(a.sections, isNotEmpty, reason: '$locale/$id');
          expect(a.estimatedMinutes, greaterThan(0), reason: '$locale/$id');
          for (final text in proseOf(a)) {
            expect(text.trim(), isNotEmpty, reason: '$locale/$id');
          }
        }
      }
    });

    test('hiçbir makale resmî fetva olarak işaretlenmemiştir', () {
      for (final id in pack.keys) {
        expect(
          mapOf('tr')[id]!.contentType,
          isNot(LearningContentType.officialFatwa),
          reason: id,
        );
      }
    });

    test('kimlik ve slug her locale içinde tekildir', () {
      for (final locale in locales) {
        final all = byLocale[locale]!;
        expect(all.map((a) => a.id).toSet().length, all.length, reason: locale);
        expect(all.map((a) => a.slug).toSet().length, all.length,
            reason: locale);
      }
    });

    test('yeni makaleler beginnerPathOrder ALMAZ', () {
      for (final id in pack.keys) {
        expect(mapOf('tr')[id]!.beginnerPathOrder, isNull, reason: id);
      }
    });
  });

  group('önceki görev sınırları', () {
    test('plan kataloğu hâlâ 30 giriş ve TASK 090 kimliği içermez', () {
      expect(catalog.entries.length, 30);
      for (final id in pack.keys) {
        expect(catalogIds, isNot(contains(id)), reason: id);
      }
    });

    test('inceleme bekleyen makale hâlâ beklemededir', () {
      // TASK 091 `art-kuran-okumaya-baslangic`'i yayına aldı; beklemedeki
      // kayıt sayısı DONDURULMAZ. Korunan iddia: TASK 090 beklemedeki
      // içeriğe dokunmamıştır.
      for (final locale in locales) {
        for (final id in ['art-dua-adabi']) {
          final article = mapOf(locale)[id];
          expect(article, isNotNull, reason: '$locale/$id');
          expect(article!.isPublished, isFalse, reason: '$locale/$id');
          expect(
            article.reviewStatus,
            ReviewStatus.scholarlyReviewPending,
            reason: '$locale/$id',
          );
        }
      }
    });

    test('kütüphane TASK 090 sonrası taban sayıdan küçülmemiştir', () {
      for (final locale in locales) {
        expect(byLocale[locale]!.length, greaterThanOrEqualTo(56),
            reason: locale);
        expect(
          byLocale[locale]!.where((a) => a.isPublished).length,
          greaterThanOrEqualTo(54),
          reason: locale,
        );
      }
    });

    test('çapraz locale tutarlılığı parser kuralını geçer', () {
      expect(
        () => LearningContentParser.validateLocaleConsistency(
          canonical: byLocale['tr']!,
          translations: {'en': byLocale['en']!, 'ar': byLocale['ar']!},
        ),
        returnsNormally,
      );
    });
  });
}
