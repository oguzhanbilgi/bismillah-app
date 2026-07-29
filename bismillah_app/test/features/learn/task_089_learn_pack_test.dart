import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 089 — Kadın / Ahiret / İslam Tarihi paketinin içerik güvencesi.
///
/// Tablo tabanlıdır. Önceki paket süitleri ve
/// `learn_content_integrity_test.dart` TEKRARLANMAZ.
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

  const pack = <String, String>{
    'art-ahiret-nedir': 'cat-afterlife',
    'art-kiyametin-vakti-bilinmez': 'cat-afterlife',
    'art-ahirete-imanin-faydalari': 'cat-afterlife',
    'art-kadinlarin-ilim-talebi': 'cat-women',
    'art-kuranin-yazilmasi-ve-cogaltilmasi': 'cat-history',
  };

  const catalog = LearnDailyPlanCatalog.v1;
  final catalogIds = [for (final e in catalog.entries) e.articleId];

  group('TASK 089 kapsamı', () {
    test('tam olarak beş yeni kimlik eklendi', () {
      expect(pack.length, 5);
      final tr = mapOf('tr');
      for (final id in pack.keys) {
        expect(tr.containsKey(id), isTrue, reason: id);
      }
    });

    test('kategori dağılımı 3 ahiret / 1 kadın / 1 tarih', () {
      final counts = <String, int>{};
      for (final category in pack.values) {
        counts[category] = (counts[category] ?? 0) + 1;
      }
      expect(counts, {'cat-afterlife': 3, 'cat-women': 1, 'cat-history': 1});
    });

    test('hedef kategorilerdeki YAYINLANMIŞ içerik yalnız TASK 089 paketidir',
        () {
      final tr = byLocale['tr']!;
      for (final category in {'cat-afterlife', 'cat-women', 'cat-history'}) {
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

    test('onaylanmayan art-olum-nedir EKLENMEMİŞTİR', () {
      for (final locale in locales) {
        expect(
          mapOf(locale).containsKey('art-olum-nedir'),
          isFalse,
          reason: locale,
        );
      }
    });
  });

  group('locale paritesi (tablo)', () {
    test('beş kimlik üç locale\'de de vardır ve kümeler aynıdır', () {
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
      expect(used, {'diyanet-islam-ilmihali', 'diyanet-hadislerle-islam'});
      for (final id in pack.keys) {
        final article = mapOf('tr')[id]!;
        expect(sourceIds, contains(article.verification!.sourceId));
        expect(article.sourceIds, contains(article.verification!.sourceId));
      }
    });

    test('TASK 089 yeni kaynak kaydı EKLEMEZ', () {
      // Mutlak sayı DONDURULMAZ: kayıt defteri sonraki paketlerle büyüyebilir
      // (TASK 090 `diyanet-vakit-hesaplama` ekledi). Buradaki gerçek iddia,
      // TASK 089'un kendi paketinin TASK 087 sonrası yedi kaynağın dışına
      // ÇIKMAMASIDIR.
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
      for (final id in pack.keys) {
        expect(afterTask087, containsAll(mapOf('tr')[id]!.sourceIds));
      }
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

    String proseTr(String id) => proseOf(mapOf('tr')[id]!).join(' ').toLowerCase();

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

    test('ahiret makaleleri ceza tasviri veya korku dili taşımaz', () {
      const forbidden = [
        'cehennem',
        'azap',
        'kabir azabı',
        'şefaat',
        'mizan',
        'sırat',
        'cennete girer',
      ];
      for (final id in [
        'art-ahiret-nedir',
        'art-kiyametin-vakti-bilinmez',
        'art-ahirete-imanin-faydalari',
      ]) {
        final joined = proseTr(id);
        for (final term in forbidden) {
          expect(joined, isNot(contains(term)), reason: '$id / $term');
        }
      }
    });

    test('kıyamet makalesi tarih, alâmet veya güncel olay iddiası taşımaz', () {
      const forbidden = ['alâmet', 'alamet', 'yıl içinde', 'yakında', 'işaret sayılır'];
      final joined = proseTr('art-kiyametin-vakti-bilinmez');
      for (final term in forbidden) {
        expect(joined, isNot(contains(term)), reason: term);
      }
      // Koruyucu çekirdek iddia korunmalıdır.
      expect(joined, contains('allah'));
    });

    test('kadın makalesi hüküm veya üstünlük iddiası taşımaz', () {
      const forbidden = [
        'mahrem',
        'örtün',
        'yönetim',
        'caiz',
        'haram',
        'üstün',
        'eksik',
        'savaş',
      ];
      final joined = proseTr('art-kadinlarin-ilim-talebi');
      for (final term in forbidden) {
        expect(joined, isNot(contains(term)), reason: term);
      }
    });

    test('tarih makalesi siyasi veya mezhebî yorum taşımaz', () {
      const forbidden = [
        'halifelik hakkı',
        'meşruiyet',
        'mezhep',
        'fetih',
        'savaş',
        'iktidar',
        'fitne',
      ];
      final joined = proseTr('art-kuranin-yazilmasi-ve-cogaltilmasi');
      for (final term in forbidden) {
        expect(joined, isNot(contains(term)), reason: term);
      }
    });

    test('tarih makalesi kaynaktaki yaklaşıklık ifadesini korur', () {
      final joined = proseTr('art-kuranin-yazilmasi-ve-cogaltilmasi');
      expect(joined, contains('yaklaşık'));
      expect(joined, contains('yedi kadar'));
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
    test('plan kataloğu hâlâ 30 giriş ve TASK 089 kimliği içermez', () {
      expect(catalog.entries.length, 30);
      for (final id in pack.keys) {
        expect(catalogIds, isNot(contains(id)), reason: id);
      }
    });

    test('inceleme bekleyen makale hâlâ beklemededir', () {
      // TASK 091 `art-kuran-okumaya-baslangic`'i yayına aldı; beklemedeki
      // kayıt sayısı DONDURULMAZ. Korunan iddia: TASK 089 beklemedeki
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

    test('kütüphane TASK 089 sonrası taban sayıdan küçülmemiştir', () {
      for (final locale in locales) {
        expect(byLocale[locale]!.length, greaterThanOrEqualTo(50),
            reason: locale);
        expect(
          byLocale[locale]!.where((a) => a.isPublished).length,
          greaterThanOrEqualTo(48),
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
