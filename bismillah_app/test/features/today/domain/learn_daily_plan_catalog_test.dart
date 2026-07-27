import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/learning_article.dart';
import 'package:bismillah_app/features/today/domain/value_objects/learn_daily_plan_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// Learn plan kataloğunun GERÇEK içerik asset'lerine karşı doğrulanması
/// (TASK 082).
///
/// Katalog yalnız **yayınlanmış ve kaynak gövdesi doğrulanmış** makale
/// kimlikleri taşıyabilir. Bir makale yayından çıkarsa, silinirse, bir
/// locale'den düşerse veya kaynak doğrulaması kaybolursa bu testler
/// KIRILIR — yanlış veya doğrulanmamış içerik plana giremez.
void main() {
  Object? readJson(String name) =>
      json.decode(File('assets/content/learn/$name').readAsStringSync());

  final sources = LearningContentParser.parseSources(readJson('sources.json'));
  final sourceIds = {for (final source in sources) source.id};

  List<LearningArticle> articlesFor(String locale) =>
      LearningContentParser.parseArticles(
        readJson('articles_$locale.json'),
        expectedLocale: locale,
        validSourceIds: sourceIds,
      );

  const locales = ['tr', 'en', 'ar'];
  final byLocale = {for (final locale in locales) locale: articlesFor(locale)};

  /// Plana girmeye UYGUN makaleler: yayınlanmış + kaynak gövdesi
  /// doğrulanmış + doğrulama kaydı yayın kapısını geçiyor.
  bool isEligible(LearningArticle article) =>
      article.isPublished &&
      article.isSourceBodyVerified &&
      (article.verification?.satisfiesPublicationGate ?? false) &&
      article.sourceIds.isNotEmpty;

  Map<String, LearningArticle> eligibleById(String locale) => {
    for (final article in byLocale[locale]!)
      if (isEligible(article)) article.id: article,
  };

  final eligibleTr = eligibleById('tr');
  const catalog = LearnDailyPlanCatalog.v1;
  final catalogIds = [for (final entry in catalog.entries) entry.articleId];

  group('içerik uygunluk kapısı', () {
    test('her locale tam olarak 30 uygun makale taşır', () {
      for (final locale in locales) {
        expect(
          eligibleById(locale).length,
          LearnDailyPlanCatalog.requiredEntryCount,
          reason: locale,
        );
      }
    });

    test('uygun olmayan makaleler yayında DEĞİLDİR', () {
      for (final locale in locales) {
        final ineligible = byLocale[locale]!.where((a) => !isEligible(a));
        for (final article in ineligible) {
          expect(article.isPublished, isFalse, reason: '$locale/${article.id}');
        }
      }
    });

    test('yayınlanmamış içerik katalogda YOKTUR', () {
      final pendingIds = {
        for (final article in byLocale['tr']!)
          if (!article.isPublished) article.id,
      };
      expect(pendingIds, isNotEmpty, reason: 'gerçek bir dışlama olmalı');
      for (final id in pendingIds) {
        expect(catalogIds, isNot(contains(id)));
      }
    });

    test('her uygun makale kaynak gövdesi doğrulanmıştır', () {
      for (final locale in locales) {
        for (final article in eligibleById(locale).values) {
          final verification = article.verification!;
          expect(verification.sourceBodyVerified, isTrue, reason: article.id);
          expect(verification.sourceLocator.trim(), isNotEmpty);
          expect(verification.evidenceSummary.trim(), isNotEmpty);
          expect(verification.verifiedAt.trim(), isNotEmpty);
          expect(
            verification.verificationMethod.isStrongerThanUrlCheck,
            isTrue,
            reason: article.id,
          );
          expect(article.sourceIds, contains(verification.sourceId));
        }
      }
    });

    test('doğrulama yalnız kayıtlı resmî kaynaklara dayanır', () {
      for (final article in eligibleTr.values) {
        expect(sourceIds, contains(article.verification!.sourceId));
      }
    });

    test('yayınlanan makale reviewedAt taşır', () {
      for (final article in eligibleTr.values) {
        expect(article.reviewedAt, isNotNull);
        expect(article.reviewedAt!.trim(), isNotEmpty);
      }
    });
  });

  group('locale kimlik eşitliği', () {
    test('TR/EN/AR aynı uygun kimlik kümesini taşır', () {
      final tr = eligibleById('tr').keys.toSet();
      for (final locale in ['en', 'ar']) {
        expect(eligibleById(locale).keys.toSet(), tr, reason: locale);
      }
    });

    test('seçilen her kimlik üç locale\'de de vardır', () {
      for (final locale in locales) {
        final ids = eligibleById(locale).keys.toSet();
        for (final id in catalogIds) {
          expect(ids, contains(id), reason: '$locale eksik: $id');
        }
      }
    });

    test('hiçbir locale seçilen bir makaleyi kaybetmemiştir', () {
      for (final locale in locales) {
        final all = {for (final a in byLocale[locale]!) a.id};
        expect(all.containsAll(catalogIds), isTrue, reason: locale);
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

    test('katalog locale\'den bağımsızdır (aynı sıra, aynı kimlikler)', () {
      // Katalog derleme zamanı sabitidir: locale parametresi almaz,
      // yerelleştirilmiş metne dokunmaz.
      for (final locale in locales) {
        final localized = eligibleById(locale);
        expect(
          [for (final id in catalogIds) localized[id]!.id],
          catalogIds,
          reason: locale,
        );
      }
    });
  });

  group('üretim kataloğu', () {
    test('tam olarak 30 giriş', () {
      expect(catalog.entries.length, 30);
      expect(LearnDailyPlanCatalog.requiredEntryCount, 30);
    });

    test('yapısal doğrulama temiz', () {
      expect(catalog.validate(), isNull);
      expect(catalog.isValid, isTrue);
    });

    test('makale kimlikleri tekil (tekrar YOK)', () {
      expect(catalogIds.toSet().length, catalogIds.length);
    });

    test('şablon kimlikleri tekil', () {
      final templateIds = [for (final e in catalog.entries) e.templateId];
      expect(templateIds.toSet().length, templateIds.length);
    });

    test('katalog YALNIZ uygun kimliklerden oluşur', () {
      for (final id in catalogIds) {
        expect(eligibleTr.keys, contains(id));
      }
    });

    test('katalog uygun kimliklerin TAMAMINI kapsar', () {
      expect(catalogIds.toSet(), eligibleTr.keys.toSet());
    });

    test('sayıyı tutturmak için makale çoğaltılmamıştır', () {
      expect(catalogIds.length, eligibleTr.length);
    });
  });

  group('katalog sırası determinizmi', () {
    test('giriş 0 ve giriş 29 sabittir', () {
      expect(catalog.entries.first.articleId, 'art-islam-nedir');
      expect(catalog.entries.last.articleId, 'art-kurban-nedir');
    });

    test('sıra tekrarlı okumada değişmez', () {
      for (var i = 0; i < 20; i++) {
        expect([
          for (final e in LearnDailyPlanCatalog.v1.entries) e.articleId,
        ], catalogIds);
      }
    });

    test('0–10 mevcut beginnerPathOrder alanını izler (kaynak destekli)', () {
      final ordered =
          eligibleTr.values.where((a) => a.beginnerPathOrder != null).toList()
            ..sort(
              (a, b) => a.beginnerPathOrder!.compareTo(b.beginnerPathOrder!),
            );
      expect(ordered.length, 11);
      expect(catalogIds.take(11).toList(), [for (final a in ordered) a.id]);
    });

    test('yayında olmayan beginnerPathOrder üyeleri atlanmıştır', () {
      final pendingOrders = [
        for (final a in byLocale['tr']!)
          if (!a.isPublished && a.beginnerPathOrder != null)
            a.beginnerPathOrder,
      ];
      expect(pendingOrders, containsAll(<int>[11, 12]));
    });

    test('sıra asset JSON dosya sırasına EŞİT DEĞİLDİR', () {
      final assetOrder = [
        for (final a in byLocale['tr']!)
          if (isEligible(a)) a.id,
      ];
      expect(assetOrder.length, catalogIds.length);
      expect(
        catalogIds,
        isNot(assetOrder),
        reason: 'plan sırasını dosya sırası TANIMLAMAZ',
      );
    });

    test('sıra yerelleştirilmiş başlık sıralamasına EŞİT DEĞİLDİR', () {
      for (final locale in locales) {
        final byTitle = eligibleById(locale).values.toList()
          ..sort((a, b) => a.title.compareTo(b.title));
        expect(
          catalogIds,
          isNot([for (final a in byTitle) a.id]),
          reason: locale,
        );
      }
    });

    test('sıra locale\'e göre DEĞİŞMEZ', () {
      // Aynı katalog üç locale için de aynı indeks→kimlik eşlemesini verir.
      for (final locale in locales) {
        final resolved = eligibleById(locale);
        for (var i = 0; i < catalogIds.length; i++) {
          expect(resolved[catalogIds[i]]!.id, catalogIds[i], reason: locale);
        }
      }
    });

    test('eşdeğer katalog değerleri eşittir', () {
      final copy = LearnDailyPlanCatalog(
        entries: [for (final id in catalogIds) LearnPlanCatalogEntry(id)],
      );
      expect(copy.entries, catalog.entries);
      expect(copy.validate(), isNull);
    });
  });

  group('şablon kimliği kuralı', () {
    test('learn_article_<articleId> biçimindedir', () {
      for (final entry in catalog.entries) {
        expect(entry.templateId, 'learn_article_${entry.articleId}');
        expect(entry.templateId, startsWith('learn_article_'));
      }
    });

    test('kayıpsızdır — makale kimliği aynen korunur', () {
      for (final entry in catalog.entries) {
        expect(
          entry.templateId.substring(
            LearnDailyPlanCatalog.templateIdPrefix.length,
          ),
          entry.articleId,
        );
      }
    });

    test('nihai kimlik ayırıcısı içermez (çakışma güvenliği)', () {
      for (final entry in catalog.entries) {
        expect(entry.templateId, isNot(contains(':')));
      }
    });

    test('yerelleştirilmiş metin veya başlık taşımaz', () {
      final titles = {for (final a in eligibleTr.values) a.title};
      for (final entry in catalog.entries) {
        expect(titles, isNot(contains(entry.templateId)));
        expect(
          entry.templateId,
          isNot(matches(RegExp(r'[çğıöşüÇĞİÖŞÜ؀-ۿ\s]'))),
        );
      }
    });

    test('zaman/UID/cihaz verisi taşımaz', () {
      for (final entry in catalog.entries) {
        expect(entry.templateId, isNot(matches(RegExp(r'\d{4}-\d{2}-\d{2}'))));
        expect(entry.templateId, isNot(contains('uid')));
        expect(entry.templateId, isNot(contains('device')));
      }
    });
  });

  group('bozuk katalog reddi', () {
    LearnDailyPlanCatalog withIds(List<String> ids) => LearnDailyPlanCatalog(
      entries: [for (final id in ids) LearnPlanCatalogEntry(id)],
    );

    test('29 giriş reddedilir', () {
      expect(
        withIds(catalogIds.take(29).toList()).validate(),
        LearnPlanCatalogIssue.entryCountMismatch,
      );
    });

    test('31 giriş reddedilir', () {
      expect(
        withIds([...catalogIds, 'art-islam-nedir-2']).validate(),
        LearnPlanCatalogIssue.entryCountMismatch,
      );
    });

    test('boş katalog reddedilir', () {
      expect(
        withIds(const []).validate(),
        LearnPlanCatalogIssue.entryCountMismatch,
      );
    });

    test('tekrar eden makale kimliği reddedilir', () {
      final duplicated = [...catalogIds]..[29] = catalogIds.first;
      expect(
        withIds(duplicated).validate(),
        LearnPlanCatalogIssue.duplicateArticleId,
      );
    });

    test('boş makale kimliği reddedilir', () {
      final blank = [...catalogIds]..[5] = '   ';
      expect(withIds(blank).validate(), LearnPlanCatalogIssue.blankArticleId);
    });

    test('ayırıcı içeren makale kimliği reddedilir', () {
      final unsafe = [...catalogIds]..[5] = 'art:unsafe';
      expect(withIds(unsafe).validate(), LearnPlanCatalogIssue.unsafeArticleId);
    });

    test('doğrulama sonucu ham içerik/metin taşımaz', () {
      final rendered = LearnPlanCatalogIssue.values
          .map((i) => i.name)
          .join(' ');
      for (final forbidden in ['art-', 'İslam', 'http', 'assets', 'C:\\']) {
        expect(rendered, isNot(contains(forbidden)));
      }
    });
  });
}
