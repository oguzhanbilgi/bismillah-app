import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 088 — Dua / Aile / Helal paketinin içerik güvencesi.
///
/// Tablo tabanlıdır. `learn_content_integrity_test.dart` ve TASK 087 süiti
/// TEKRARLANMAZ; burada yalnız TASK 088'e özgü sınırlar doğrulanır.
void main() {
  Object? readJson(String name) =>
      json.decode(File('assets/content/learn/$name').readAsStringSync());

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

  /// TASK 088'in eklediği dört kimlik ve beklenen kategorileri.
  const pack = <String, String>{
    'art-dua-nedir': 'cat-dua',
    'art-ailenin-onemi': 'cat-family',
    'art-anne-babaya-saygi-ve-nezaket': 'cat-family',
    'art-helal-ve-haram-nedir': 'cat-halal',
  };

  /// TASK 091'e ait; TASK 088 bu kayda DOKUNMAZ.
  const duaPendingId = 'art-dua-adabi';

  const catalog = LearnDailyPlanCatalog.v1;
  final catalogIds = [for (final e in catalog.entries) e.articleId];

  group('TASK 088 kapsamı', () {
    test('tam olarak dört yeni kimlik eklendi', () {
      expect(pack.length, 4);
      final tr = mapOf('tr');
      for (final id in pack.keys) {
        expect(tr.containsKey(id), isTrue, reason: id);
      }
    });

    test('kategori dağılımı 1 dua / 2 aile / 1 helal', () {
      final counts = <String, int>{};
      for (final category in pack.values) {
        counts[category] = (counts[category] ?? 0) + 1;
      }
      expect(counts, {'cat-dua': 1, 'cat-family': 2, 'cat-halal': 1});
    });

    test('her makale beklenen kategoridedir', () {
      final tr = mapOf('tr');
      for (final entry in pack.entries) {
        expect(tr[entry.key]!.categoryId, entry.value, reason: entry.key);
      }
    });

    test('hedef kategorilerdeki YAYINLANMIŞ içerik yalnız TASK 088 paketidir',
        () {
      final tr = byLocale['tr']!;
      for (final category in {'cat-dua', 'cat-family', 'cat-halal'}) {
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

    test('dört kimlik tekildir', () {
      expect(pack.keys.toSet().length, 4);
    });
  });

  group('locale paritesi (tablo)', () {
    test('dört kimlik üç locale\'de de vardır', () {
      for (final locale in locales) {
        final ids = mapOf(locale).keys.toSet();
        for (final id in pack.keys) {
          expect(ids, contains(id), reason: '$locale eksik: $id');
        }
      }
    });

    test('üç locale BİREBİR aynı kimlik kümesini taşır', () {
      final tr = mapOf('tr').keys.toSet();
      for (final locale in ['en', 'ar']) {
        expect(mapOf(locale).keys.toSet(), tr, reason: locale);
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
        expect(statuses.length, 1, reason: id);
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

    test('başlıklar üç locale\'de gerçekten farklıdır', () {
      for (final id in pack.keys) {
        final titles = {
          for (final locale in locales) mapOf(locale)[id]!.title,
        };
        expect(titles.length, 3, reason: '$id başlıkları çevrilmemiş');
      }
    });

    test('Arapça metin Latin harf taşımaz', () {
      final latin = RegExp(r'[A-Za-z]');
      for (final id in pack.keys) {
        final article = mapOf('ar')[id]!;
        expect(latin.hasMatch(article.title), isFalse, reason: id);
        expect(latin.hasMatch(article.summary), isFalse, reason: id);
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
          expect(
            v.verifiedBy,
            VerifiedBy.editorialReview,
            reason: '$locale/$id',
          );
        }
      }
    });

    test('her makale KESİN konum, kanıt ve tarih taşır', () {
      final pageRef = RegExp(r's\.\s?\d{1,4}');
      for (final id in pack.keys) {
        final article = mapOf('tr')[id]!;
        final v = article.verification!;
        expect(pageRef.hasMatch(v.sourceLocator), isTrue,
            reason: '$id: ${v.sourceLocator}');
        expect(v.sourceLocator.contains(RegExp(r'\s')), isTrue, reason: id);
        expect(v.evidenceSummary.trim(), isNotEmpty, reason: id);
        expect(v.verifiedAt.trim(), isNotEmpty, reason: id);
        expect(article.reviewedAt, isNotNull, reason: id);
      }
    });

    test('paket yalnız iki kayıtlı kaynağı kullanır', () {
      final used = {
        for (final id in pack.keys) mapOf('tr')[id]!.verification!.sourceId,
      };
      expect(used, {'diyanet-hadislerle-islam', 'diyanet-islam-ilmihali'});
      for (final id in pack.keys) {
        final article = mapOf('tr')[id]!;
        expect(sourceIds, contains(article.verification!.sourceId));
        expect(article.sourceIds, contains(article.verification!.sourceId));
      }
    });

    test('TASK 088 yeni kaynak kaydı EKLEMEZ', () {
      expect(sources.length, 7, reason: 'TASK 087 sonrası kaynak sayısı');
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

  group('içerik güvenliği', () {
    Iterable<String> proseOf(LearningArticle a) sync* {
      yield a.title;
      yield a.summary;
      for (final s in a.sections) {
        if (s.text != null) yield s.text!;
        yield* s.items;
      }
    }

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

    test('helal makalesi tanımları kaynağa AÇIKÇA atfeder', () {
      final tr = mapOf('tr')['art-helal-ve-haram-nedir']!;
      final joined = proseOf(tr).join(' ');
      expect(joined, contains('İslam İlmihali'));
    });

    test('helal makalesi ürün, katkı, finans veya sertifika adı geçirmez', () {
      const forbidden = [
        'katkı maddesi',
        'sertifika',
        'faiz',
        'kredi',
        'domuz',
        'şarap',
        'mezhep',
      ];
      final joined = proseOf(mapOf('tr')['art-helal-ve-haram-nedir']!).join(' ');
      for (final term in forbidden) {
        expect(joined.toLowerCase(), isNot(contains(term)), reason: term);
      }
    });

    test('dua makalesi garanti kabul veya özel vakit iddiası taşımaz', () {
      const forbidden = [
        'mutlaka verir',
        'kabul edilir',
        'arefe',
        'cuma saati',
        'gece yarısı',
        'sevap',
      ];
      final joined = proseOf(mapOf('tr')['art-dua-nedir']!).join(' ');
      for (final term in forbidden) {
        expect(joined.toLowerCase(), isNot(contains(term)), reason: term);
      }
    });

    test('aile makaleleri hukuki/maddi yükümlülük iddiası taşımaz', () {
      const forbidden = ['miras', 'nafaka', 'boşan', 'velayet', 'nikâh'];
      for (final id in ['art-ailenin-onemi', 'art-anne-babaya-saygi-ve-nezaket']) {
        final joined = proseOf(mapOf('tr')[id]!).join(' ');
        for (final term in forbidden) {
          expect(joined.toLowerCase(), isNot(contains(term)),
              reason: '$id / $term');
        }
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

  group('TASK 091 ve TASK 082 sınırları', () {
    test('art-dua-adabi hâlâ inceleme beklemededir', () {
      for (final locale in locales) {
        final article = mapOf(locale)[duaPendingId];
        expect(article, isNotNull, reason: locale);
        expect(article!.isPublished, isFalse, reason: locale);
        expect(
          article.reviewStatus,
          ReviewStatus.scholarlyReviewPending,
          reason: locale,
        );
      }
    });

    test('cat-dua hem yayınlanmış hem bekleyen kayıt taşır', () {
      final dua = byLocale['tr']!.where((a) => a.categoryId == 'cat-dua');
      expect(dua.where((a) => a.isPublished).length, 1);
      expect(dua.where((a) => !a.isPublished).length, 1);
    });

    test('plan kataloğu hâlâ 30 giriş ve TASK 088 kimliği içermez', () {
      expect(catalog.entries.length, 30);
      for (final id in pack.keys) {
        expect(catalogIds, isNot(contains(id)), reason: id);
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
