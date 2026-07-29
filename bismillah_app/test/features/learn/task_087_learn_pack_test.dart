import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 087 — Hadis / Siyer / Peygamberler paketinin içerik güvencesi.
///
/// Tablo tabanlıdır: her locale-alan kombinasyonu için ayrı test YAZILMAZ.
/// Mevcut `learn_content_integrity_test.dart` kuralları TEKRARLANMAZ; burada
/// yalnız TASK 087'ye özgü sınırlar doğrulanır.
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

  /// TASK 087'nin eklediği dokuz kimlik ve beklenen kategorileri.
  const pack = <String, String>{
    'art-hadis-ve-sunnet-nedir': 'cat-hadith',
    'art-ilim-ve-hidayet-yagmuru': 'cat-hadith',
    'art-hayvanlara-merhamet': 'cat-hadith',
    'art-hilful-fudul': 'cat-seerah',
    'art-kabe-hakemligi': 'cat-seerah',
    'art-veda-hacci-ve-hutbesi': 'cat-seerah',
    'art-peygamber-kimdir': 'cat-prophets',
    'art-peygamberlerin-sifatlari': 'cat-prophets',
    'art-kuranda-adi-gecen-peygamberler': 'cat-prophets',
  };

  const targetCategories = ['cat-hadith', 'cat-seerah', 'cat-prophets'];

  /// TASK 087 ÖNCESİ yayında olan içerik (TASK 082 kataloğu) — bu görevde
  /// değiştirilmemiş olmalıdır.
  const catalog = LearnDailyPlanCatalog.v1;
  final catalogIds = [for (final e in catalog.entries) e.articleId];

  /// TASK 091'e ait, hâlâ beklemede kalması gereken içerik.
  ///
  /// TASK 091 `art-kuran-okumaya-baslangic`'i inceleyip yayına aldı; geriye
  /// nitelikli ilmî inceleme bekleyen tek kayıt kaldı. Buradaki iddia
  /// TASK 087'nin bu kayda DOKUNMAMASIDIR — beklemedeki kayıt sayısı
  /// dondurulmaz.
  const stillPendingIds = ['art-dua-adabi'];

  group('TASK 087 kapsamı', () {
    test('tam olarak dokuz yeni kimlik eklendi', () {
      expect(pack.length, 9);
      final tr = mapOf('tr');
      for (final id in pack.keys) {
        expect(tr.containsKey(id), isTrue, reason: id);
      }
    });

    test('hedef kategorilerin her biri tam olarak 3 yayınlanmış içerik taşır',
        () {
      final tr = byLocale['tr']!;
      for (final category in targetCategories) {
        final published = tr.where(
          (a) => a.categoryId == category && a.isPublished,
        );
        expect(published.length, 3, reason: category);
      }
    });

    test('hedef kategorilerdeki yayınlanmış içerik YALNIZ TASK 087 paketidir',
        () {
      final tr = byLocale['tr']!;
      for (final category in targetCategories) {
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

    test('paket dışındaki kategorilere içerik EKLENMEDİ', () {
      final tr = mapOf('tr');
      for (final entry in pack.entries) {
        expect(tr[entry.key]!.categoryId, entry.value, reason: entry.key);
      }
    });

    test('dokuz kimlik tekildir', () {
      expect(pack.keys.toSet().length, 9);
    });
  });

  group('locale paritesi (tablo)', () {
    test('dokuz kimlik üç locale\'de de vardır', () {
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

    test('kategori ataması üç locale\'de aynıdır', () {
      for (final id in pack.keys) {
        final assigned = {
          for (final locale in locales) mapOf(locale)[id]!.categoryId,
        };
        expect(assigned.length, 1, reason: '$id: $assigned');
        expect(assigned.single, pack[id], reason: id);
      }
    });

    test('yayın durumu üç locale\'de aynıdır', () {
      for (final id in pack.keys) {
        final statuses = {
          for (final locale in locales) mapOf(locale)[id]!.reviewStatus,
        };
        expect(statuses.length, 1, reason: '$id: $statuses');
        expect(statuses.single, ReviewStatus.published, reason: id);
      }
    });

    test('dokuz makale de YAYINDADIR ve hiçbiri inceleme beklemiyor', () {
      for (final locale in locales) {
        for (final id in pack.keys) {
          final article = mapOf(locale)[id]!;
          expect(article.isPublished, isTrue, reason: '$locale/$id');
          expect(
            article.reviewStatus,
            isNot(ReviewStatus.scholarlyReviewPending),
            reason: '$locale/$id',
          );
        }
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

    test('başlık ve özet her locale\'de gerçekten farklıdır', () {
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
    test('her makale sourceBodyReview ile doğrulanmıştır', () {
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

    test('her makale KESİN konum (locator) taşır', () {
      final pageOrVolume = RegExp(r's\.\s?\d{1,4}');
      for (final id in pack.keys) {
        final v = mapOf('tr')[id]!.verification!;
        expect(v.sourceLocator.trim(), isNotEmpty, reason: id);
        expect(
          pageOrVolume.hasMatch(v.sourceLocator),
          isTrue,
          reason: '$id locator sayfa taşımıyor: ${v.sourceLocator}',
        );
      }
    });

    test('locator ÇIPLAK bir URL değildir', () {
      for (final id in pack.keys) {
        final locator = mapOf('tr')[id]!.verification!.sourceLocator;
        expect(locator.contains(RegExp(r'\s')), isTrue, reason: id);
      }
    });

    test('her makale kanıt özeti ve doğrulama tarihi taşır', () {
      for (final id in pack.keys) {
        final v = mapOf('tr')[id]!.verification!;
        expect(v.evidenceSummary.trim(), isNotEmpty, reason: id);
        expect(v.verifiedAt.trim(), isNotEmpty, reason: id);
        expect(mapOf('tr')[id]!.reviewedAt, isNotNull, reason: id);
      }
    });

    test('doğrulama kayıtlı resmî bir kaynağa çözümlenir', () {
      for (final id in pack.keys) {
        final article = mapOf('tr')[id]!;
        final v = article.verification!;
        expect(sourceIds, contains(v.sourceId), reason: id);
        expect(article.sourceIds, contains(v.sourceId), reason: id);
      }
    });

    test('paket YALNIZ üç beklenen kaynağı kullanır', () {
      final used = {
        for (final id in pack.keys) mapOf('tr')[id]!.verification!.sourceId,
      };
      expect(used, {
        'diyanet-hadislerle-islam',
        'diyanet-hz-muhammedin-hayati',
        'diyanet-islam-ilmihali',
      });
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

    test('yeni siyer kaynağı resmî künye taşır', () {
      final source = sources.firstWhere(
        (s) => s.id == 'diyanet-hz-muhammedin-hayati',
      );
      expect(source.isOfficial, isTrue);
      expect(source.institution, contains('Diyanet'));
      expect(source.originalLanguage, 'tr');
      expect(source.lastVerifiedAt, isNotEmpty);
      // Baskı/seri künyesi açıkça kayıtlıdır (çocuk yayınları serisi).
      expect(source.publicationInfo, contains('16. Baskı'));
      expect(source.publicationInfo, contains('Çocuk Kitapları'));
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

    test('paket kişisel hüküm/fetva içeriği olarak işaretlenmemiştir', () {
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
        expect(
          all.map((a) => a.slug).toSet().length,
          all.length,
          reason: locale,
        );
      }
    });

    test('yeni makaleler beginnerPathOrder ALMAZ (mevcut yol bozulmaz)', () {
      for (final id in pack.keys) {
        expect(mapOf('tr')[id]!.beginnerPathOrder, isNull, reason: id);
      }
    });
  });

  group('TASK 082 sınırı', () {
    test('plan kataloğu hâlâ tam olarak 30 giriş taşır', () {
      expect(catalog.entries.length, 30);
      expect(LearnDailyPlanCatalog.requiredEntryCount, 30);
    });

    test('dokuz yeni kimlik plan kataloğuna GİRMEMİŞTİR', () {
      for (final id in pack.keys) {
        expect(catalogIds, isNot(contains(id)), reason: id);
      }
    });

    test('katalogdaki 30 kimlik hâlâ yayında ve doğrulanmıştır', () {
      final tr = mapOf('tr');
      for (final id in catalogIds) {
        final article = tr[id];
        expect(article, isNotNull, reason: id);
        expect(article!.isPublished, isTrue, reason: id);
        expect(article.isSourceBodyVerified, isTrue, reason: id);
      }
    });

    test('katalog kimlikleri TASK 087 kategorilerinden gelmez', () {
      final tr = mapOf('tr');
      for (final id in catalogIds) {
        expect(
          targetCategories,
          isNot(contains(tr[id]!.categoryId)),
          reason: id,
        );
      }
    });
  });

  group('mevcut içeriğe dokunulmadı', () {
    test('inceleme bekleyen iki makale hâlâ beklemededir', () {
      for (final locale in locales) {
        final map = mapOf(locale);
        for (final id in stillPendingIds) {
          final article = map[id];
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

    test('kütüphane TASK 087 sonrası taban sayıdan küçülmemiştir', () {
      // Kütüphane sonraki Learn paketleriyle BÜYÜR (TASK 088+); bu yüzden
      // mutlak toplam değil, TASK 087 tabanı doğrulanır.
      for (final locale in locales) {
        expect(byLocale[locale]!.length, greaterThanOrEqualTo(41),
            reason: locale);
        final published = byLocale[locale]!.where((a) => a.isPublished);
        expect(published.length, greaterThanOrEqualTo(39), reason: locale);
      }
    });

    test('TASK 087 paketinin dokuz makalesi hâlâ yayındadır', () {
      for (final locale in locales) {
        final map = mapOf(locale);
        for (final id in pack.keys) {
          final article = map[id];
          expect(article, isNotNull, reason: '$locale/$id');
          expect(article!.isPublished, isTrue, reason: '$locale/$id');
          expect(article.isSourceBodyVerified, isTrue, reason: '$locale/$id');
        }
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
