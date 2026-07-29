import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 091 — inceleme bekleyen Learn içeriklerinin sonucu.
///
/// `art-kuran-okumaya-baslangic` İslam İlmihali s. 58'e dayandırılarak
/// yeniden yazıldı ve yayına alındı; `art-dua-adabi` nitelikli ilmî inceleme
/// beklediği için BEKLEMEDE kaldı ve öne çıkarılmaktan çıkarıldı.
///
/// Önceki paket süitleri ve `learn_content_integrity_test.dart`
/// TEKRARLANMAZ.
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

  const quranId = 'art-kuran-okumaya-baslangic';
  const duaId = 'art-dua-adabi';

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

  String prose(String locale, String id) =>
      proseOf(mapOf(locale)[id]!).join(' ').toLowerCase();

  group('art-kuran-okumaya-baslangic — yeniden yazım', () {
    test('kimlik, kategori ve beginnerPathOrder KORUNDU', () {
      for (final locale in locales) {
        final a = mapOf(locale)[quranId];
        expect(a, isNotNull, reason: locale);
        expect(a!.categoryId, 'cat-quran-learning', reason: locale);
        expect(a.beginnerPathOrder, 11, reason: locale);
      }
    });

    test('artık yayınlanmıştır', () {
      for (final locale in locales) {
        final a = mapOf(locale)[quranId]!;
        expect(a.reviewStatus, ReviewStatus.published, reason: locale);
        expect(a.isPublished, isTrue, reason: locale);
      }
    });

    test('kaynak diyanet-islam-ilmihali\'dir', () {
      for (final locale in locales) {
        final a = mapOf(locale)[quranId]!;
        expect(a.sourceIds, ['diyanet-islam-ilmihali'], reason: locale);
        expect(
          a.verification!.sourceId,
          'diyanet-islam-ilmihali',
          reason: locale,
        );
      }
    });

    test('diyanet-kuran-portali artık bu makaleyi BESLEMEZ', () {
      for (final locale in locales) {
        final a = mapOf(locale)[quranId]!;
        expect(a.sourceIds, isNot(contains('diyanet-kuran-portali')),
            reason: locale);
        expect(a.verification!.sourceId, isNot('diyanet-kuran-portali'),
            reason: locale);
      }
      // Kayıt SİLİNMEZ: resmî Kur'an başvuru adresi olarak kayıtlı kalır.
      expect(sourceIds, contains('diyanet-kuran-portali'));
    });

    test('locator s. 58 ve bölüm başlığını gösterir', () {
      for (final locale in locales) {
        final v = mapOf(locale)[quranId]!.verification!;
        expect(v.sourceLocator, contains('s. 58'), reason: locale);
        expect(v.sourceLocator, contains('İslam İlmihali'), reason: locale);
        expect(v.sourceLocator, contains('Kur\'an-ı Kerim\'i Öğrenmek'),
            reason: locale);
        expect(v.sourceLocator.startsWith('http'), isFalse, reason: locale);
      }
    });

    test('yayın kapısı alanları doldurulmuş, blocker kaldırılmıştır', () {
      for (final locale in locales) {
        final v = mapOf(locale)[quranId]!.verification!;
        expect(v.sourceBodyVerified, isTrue, reason: locale);
        expect(v.verificationMethod, VerificationMethod.sourceBodyReview,
            reason: locale);
        expect(v.verifiedBy, VerifiedBy.editorialReview, reason: locale);
        expect(v.evidenceSummary.trim(), isNotEmpty, reason: locale);
        expect(v.verifiedAt.trim(), isNotEmpty, reason: locale);
        expect(v.blocker, isNull, reason: locale);
        expect(v.satisfiesPublicationGate, isTrue, reason: locale);
      }
    });

    test('contentType ilmihalKnowledge\'dır', () {
      for (final locale in locales) {
        expect(
          mapOf(locale)[quranId]!.contentType,
          LearningContentType.ilmihalKnowledge,
          reason: locale,
        );
      }
    });

    test('yeni başlık üç locale\'de de vardır ve farklıdır', () {
      expect(mapOf('tr')[quranId]!.title, 'Kur\'an\'ı öğrenmek ne demektir?');
      expect(
        mapOf('en')[quranId]!.title,
        'What does learning the Qur\'an mean?',
      );
      expect(mapOf('ar')[quranId]!.title, 'ما معنى تعلّم القرآن؟');
      final titles = {for (final l in locales) mapOf(l)[quranId]!.title};
      expect(titles.length, 3);
      // Arapça başlık ve özet Latin harf taşımaz.
      final latin = RegExp(r'[A-Za-z]');
      expect(latin.hasMatch(mapOf('ar')[quranId]!.title), isFalse);
      expect(latin.hasMatch(mapOf('ar')[quranId]!.summary), isFalse);
    });

    test('desteklenmeyen beş adımlı liste TAMAMEN kaldırıldı', () {
      for (final locale in locales) {
        final a = mapOf(locale)[quranId]!;
        expect(
          a.sections.any((s) => s.type == LearningSectionType.steps),
          isFalse,
          reason: '$locale: steps bloğu kalmamalı',
        );
        for (final s in a.sections) {
          expect(s.items, isEmpty, reason: locale);
        }
      }
      const removedTr = ['elif', 'hareke', 'kurstan', 'öğreticiden destek'];
      for (final term in removedTr) {
        expect(prose('tr', quranId), isNot(contains(term)), reason: term);
      }
      const removedEn = ['arabic letters', 'vowel marks', 'short chapters'];
      for (final term in removedEn) {
        expect(prose('en', quranId), isNot(contains(term)), reason: term);
      }
    });

    test('fazilet, ödül ve "farzdır" iddiaları YOKTUR', () {
      const forbiddenTr = [
        'en hayırlınız',
        'övül',
        'fazilet',
        'sevap',
        'farzdır',
        'sahih değildir',
        'mutluluğa götüren',
        'en yücesi',
        'ezberl',
      ];
      for (final term in forbiddenTr) {
        expect(prose('tr', quranId), isNot(contains(term)), reason: term);
      }
      const forbiddenEn = ['obligatory', 'reward', 'merit', 'best of you'];
      for (final term in forbiddenEn) {
        expect(prose('en', quranId), isNot(contains(term)), reason: term);
      }
    });

    test('hız, ustalık, program veya günlük miktar iddiası YOKTUR', () {
      const forbidden = [
        'hızlı',
        'günde',
        'her gün',
        'hatim',
        'ustalaş',
        'program öner',
        'kaç haftada',
      ];
      for (final term in forbidden) {
        expect(prose('tr', quranId), isNot(contains(term)), reason: term);
      }
    });

    test('TR/EN/AR aynı daraltılmış anlamı taşır', () {
      // Çekirdek iddialar üç locale'de de bulunmalıdır.
      expect(prose('tr', quranId), contains('okumasını öğrenmek'));
      expect(prose('tr', quranId), contains('manasını anlamaya çalışmak'));
      expect(prose('tr', quranId), contains('tecvid'));
      expect(prose('en', quranId), contains('learning to read'));
      expect(prose('en', quranId), contains('understand its meaning'));
      expect(prose('en', quranId), contains('tajwid'));
      expect(prose('ar', quranId), contains('تعلّم قراءته'));
      expect(prose('ar', quranId), contains('فهم معناه'));
      expect(prose('ar', quranId), contains('التجويد'));
      // Yapı da aynıdır: bölüm sayısı ve türleri örtüşür.
      final shapes = {
        for (final l in locales)
          [for (final s in mapOf(l)[quranId]!.sections) s.type.name].join(','),
      };
      expect(shapes.length, 1, reason: 'bölüm yapısı locale\'ler arasında aynı');
      expect(shapes.single, 'paragraph,keyPoint,paragraph,paragraph,paragraph');
    });

    test('kaynak metni yerine AÇIKLAMA sunar — kişisel hüküm vermez', () {
      const forbidden = ['yapmalısın', 'zorundasın', 'gerekir ki sen', 'şart koş'];
      for (final term in forbidden) {
        expect(prose('tr', quranId), isNot(contains(term)), reason: term);
      }
      // Kişisel sorular yetkili mercie yönlendirilir.
      expect(prose('tr', quranId), contains('yetkili resmî merci'));
    });
  });

  group('art-dua-adabi — beklemede kalır', () {
    test('üç locale\'de de scholarlyReviewPending\'dir', () {
      for (final locale in locales) {
        final a = mapOf(locale)[duaId];
        expect(a, isNotNull, reason: locale);
        expect(a!.reviewStatus, ReviewStatus.scholarlyReviewPending,
            reason: locale);
        expect(a.isPublished, isFalse, reason: locale);
      }
    });

    test('isFeatured üç locale\'de de FALSE\'tur', () {
      for (final locale in locales) {
        expect(mapOf(locale)[duaId]!.isFeatured, isFalse, reason: locale);
      }
    });

    test('gövdesi, kaynağı ve locator\'ı DEĞİŞTİRİLMEMİŞTİR', () {
      for (final locale in locales) {
        final a = mapOf(locale)[duaId]!;
        expect(a.sourceIds, [
          'diyanet-hadislerle-islam',
          'diyanet-islam-ilmihali',
        ], reason: locale);
        final v = a.verification!;
        expect(v.sourceBodyVerified, isFalse, reason: locale);
        expect(v.sourceLocator, isEmpty, reason: locale);
        expect(v.evidenceSummary, isEmpty, reason: locale);
        expect(v.verificationMethod, VerificationMethod.urlExistenceCheck,
            reason: locale);
        // Kaydedilmiş engel notu KORUNUR — gövde onaylanmamıştır.
        expect(v.blocker, isNotNull, reason: locale);
        expect(v.satisfiesPublicationGate, isFalse, reason: locale);
      }
      // Beklemedeki içerik beginnerPath sırasını da korur.
      expect(mapOf('tr')[duaId]!.beginnerPathOrder, 12);
    });
  });

  group('yayın ve öne çıkarma yüzeyleri', () {
    test('hiçbir locale\'de öne çıkarılmış ama yayınlanmamış kayıt YOKTUR', () {
      for (final locale in locales) {
        final leaking = [
          for (final a in byLocale[locale]!)
            if (a.isFeatured && !a.isPublished) a.id,
        ];
        expect(leaking, isEmpty, reason: locale);
      }
    });

    test('beklemedeki kayıt plan kataloğuna giremez', () {
      for (final locale in locales) {
        for (final a in byLocale[locale]!) {
          if (!a.isPublished) {
            expect(catalogIds, isNot(contains(a.id)), reason: '$locale/${a.id}');
          }
        }
      }
    });
  });

  group('değişmeyen sınırlar', () {
    test('LearnDailyPlanCatalog.v1 hâlâ tam 30 giriştir ve değişmemiştir', () {
      expect(catalog.entries.length, 30);
      expect(catalogIds.toSet().length, 30);
      expect(catalogIds.first, 'art-islam-nedir');
      expect(catalogIds.last, 'art-kurban-nedir');
      // TASK 091 hiçbir kimliği katalog'a EKLEMEZ.
      expect(catalogIds, isNot(contains(duaId)));
      expect(catalogIds, isNot(contains(quranId)));
    });

    test('locale başına 56 kayıt / 55 yayınlanmış / 1 beklemede', () {
      for (final locale in locales) {
        final all = byLocale[locale]!;
        expect(all.length, 56, reason: locale);
        expect(all.where((a) => a.isPublished).length, 55, reason: locale);
        expect(
          all
              .where(
                (a) => a.reviewStatus == ReviewStatus.scholarlyReviewPending,
              )
              .length,
          1,
          reason: locale,
        );
      }
    });

    test('20 kategorinin tamamı hâlâ yayınlanmış içerik taşır', () {
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
        expect(populated, contains(id), reason: id);
      }
    });

    test('kaynak defteri korunur — hiçbir kayıt silinmemiştir', () {
      expect(
        sourceIds,
        containsAll(<String>{
          'diyanet-islam-ilmihali',
          'diyanet-kuran-portali',
          'diyanet-kuran-yolu-tefsiri',
          'diyanet-hadislerle-islam',
          'diyanet-din-isleri-yuksek-kurulu',
          'diyanet-dini-soru-hizmetleri',
          'diyanet-hz-muhammedin-hayati',
          'diyanet-vakit-hesaplama',
        }),
      );
    });

    test('beginnerPath sırası kesintisizdir', () {
      final orders =
          [
            for (final a in byLocale['tr']!)
              if (a.beginnerPathOrder != null) a.beginnerPathOrder!,
          ]..sort();
      expect(orders, List.generate(orders.length, (i) => i + 1));
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
