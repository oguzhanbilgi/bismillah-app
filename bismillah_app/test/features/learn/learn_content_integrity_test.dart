import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bilgi tabanı veri bütünlüğü (TASK 056 §14).
///
/// Bu testler asset dosyalarını DOĞRUDAN okur: geçersiz içerik commit
/// edilirse test kırmızıya döner ve yanlış dinî bilgi yayına çıkamaz.
void main() {
  Object? readJson(String name) =>
      json.decode(File('assets/content/learn/$name').readAsStringSync());

  final sources = LearningContentParser.parseSources(readJson('sources.json'));
  final sourceIds = {for (final source in sources) source.id};

  group('Kaynak kayıtları', () {
    test('kaynaklar parse edilir ve tekildir', () {
      expect(sources, isNotEmpty);
      expect(sourceIds.length, sources.length);
    });

    test('TÜM kaynak URL\'leri izin verilen resmî alan adındadır', () {
      for (final source in sources) {
        expect(
          OfficialSourceDomains.isAllowed(source.canonicalUrl),
          isTrue,
          reason: '${source.id} resmî olmayan alan adı kullanıyor',
        );
      }
    });

    test('kaynaklar resmî kurum, künye ve doğrulama tarihi taşır', () {
      for (final source in sources) {
        expect(source.isOfficial, isTrue, reason: source.id);
        expect(source.institution, contains('Diyanet'));
        expect(source.lastVerifiedAt, isNotEmpty);
        expect(source.accessedAt, isNotEmpty);
        // Orijinal kaynak dili Türkçedir — çeviri uyarısının dayanağı.
        expect(source.originalLanguage, 'tr');
      }
    });

    test('görev listesindeki altı resmî kaynak da kayıtlıdır', () {
      expect(
        sourceIds,
        containsAll(<String>{
          'diyanet-islam-ilmihali',
          'diyanet-kuran-portali',
          'diyanet-kuran-yolu-tefsiri',
          'diyanet-hadislerle-islam',
          'diyanet-din-isleri-yuksek-kurulu',
          'diyanet-dini-soru-hizmetleri',
        }),
      );
    });

    test('resmî olmayan alan adı REDDEDİLİR', () {
      // Son ek benzerliği ile atlatma denemesi de reddedilmelidir.
      expect(
        OfficialSourceDomains.isAllowed('https://notdiyanet.gov.tr/x'),
        isFalse,
      );
      expect(OfficialSourceDomains.isAllowed('https://example.com/'), isFalse);
      expect(
        OfficialSourceDomains.isAllowed('http://kurul.diyanet.gov.tr/'),
        isFalse,
      );
      expect(
        OfficialSourceDomains.isAllowed('https://kurul.diyanet.gov.tr/'),
        isTrue,
      );
    });
  });

  group('Kategoriler', () {
    test('20 ana kategori üç locale için de çözülür', () {
      for (final locale in ['tr', 'en', 'ar']) {
        final categories = LearningContentParser.parseCategories(
          readJson('categories.json'),
          locale,
        );
        expect(categories.length, 20, reason: locale);
        // Id ve slug tekilliği parser tarafından zorlanır; sıralama da net.
        expect(
          categories.map((c) => c.sortOrder).toList(),
          List.generate(20, (i) => i + 1),
        );
        for (final category in categories) {
          expect(category.title.trim(), isNotEmpty, reason: category.id);
          expect(category.shortDescription.trim(), isNotEmpty);
        }
      }
    });

    test('kategori başlıkları diller arasında gerçekten farklıdır', () {
      final tr = LearningContentParser.parseCategories(
        readJson('categories.json'),
        'tr',
      );
      final en = LearningContentParser.parseCategories(
        readJson('categories.json'),
        'en',
      );
      final ar = LearningContentParser.parseCategories(
        readJson('categories.json'),
        'ar',
      );
      expect(en.first.title, isNot(tr.first.title));
      expect(ar.first.title, isNot(tr.first.title));
      // Arapça başlık Latin harf içermemelidir.
      expect(RegExp(r'[A-Za-z]').hasMatch(ar.first.title), isFalse);
    });
  });

  group('İçerik katalogları', () {
    final categoryIds = {
      for (final c in LearningContentParser.parseCategories(
        readJson('categories.json'),
        'tr',
      ))
        c.id,
    };

    for (final locale in ['tr', 'en', 'ar']) {
      test('$locale kataloğu parse edilir ve çapraz doğrulanır', () {
        final articles = LearningContentParser.parseArticles(
          readJson('articles_$locale.json'),
          expectedLocale: locale,
          validSourceIds: sourceIds,
          validCategoryIds: categoryIds,
        );
        // TASK 056 §5: en az 16 çekirdek içerik.
        expect(articles.length, greaterThanOrEqualTo(16), reason: locale);
      });
    }

    test('üç locale AYNI içerik id kümesini taşır', () {
      final byLocale = {
        for (final locale in ['tr', 'en', 'ar'])
          locale: LearningContentParser.parseArticles(
            readJson('articles_$locale.json'),
            expectedLocale: locale,
          ).map((a) => a.id).toSet(),
      };
      expect(byLocale['en'], byLocale['tr']);
      expect(byLocale['ar'], byLocale['tr']);
    });

    test('yayınlanan HER içerik kaynak ve reviewedAt taşır', () {
      for (final locale in ['tr', 'en', 'ar']) {
        final articles = LearningContentParser.parseArticles(
          readJson('articles_$locale.json'),
          expectedLocale: locale,
        );
        for (final article in articles.where((a) => a.isPublished)) {
          expect(
            article.sourceIds,
            isNotEmpty,
            reason: '$locale/${article.id}',
          );
          expect(
            article.reviewedAt,
            isNotNull,
            reason: '$locale/${article.id}',
          );
          expect(article.sections, isNotEmpty);
          expect(article.estimatedMinutes, greaterThan(0));
        }
      }
    });

    test(
      'Türkçe içerik özgün, diğerleri açıklayıcı çeviri olarak işaretli',
      () {
        final tr = LearningContentParser.parseArticles(
          readJson('articles_tr.json'),
          expectedLocale: 'tr',
        );
        for (final article in tr) {
          expect(article.translationStatus, LearningTranslationStatus.original);
        }
        for (final locale in ['en', 'ar']) {
          final articles = LearningContentParser.parseArticles(
            readJson('articles_$locale.json'),
            expectedLocale: locale,
          );
          for (final article in articles) {
            expect(
              article.translationStatus,
              LearningTranslationStatus.explanatoryTranslation,
              reason: '$locale/${article.id}',
            );
          }
        }
      },
    );

    test('görüş farkı olan konularda fark AÇIKÇA belirtilir', () {
      final tr = LearningContentParser.parseArticles(
        readJson('articles_tr.json'),
        expectedLocale: 'tr',
      );
      // Mezhep farkı bilinen konular gizlenmemelidir.
      for (final slug in ['abdestin-farzlari', 'gusul-nasil-alinir']) {
        final article = tr.firstWhere((a) => a.slug == slug);
        final hasDifferenceSection = article.sections.any(
          (s) => s.type == LearningSectionType.differenceOfOpinion,
        );
        expect(
          hasDifferenceSection || article.differenceNote != null,
          isTrue,
          reason: '$slug için görüş farkı notu yok',
        );
      }
    });

    test('hassas içerik yetkili mercie yönlendirir', () {
      final tr = LearningContentParser.parseArticles(
        readJson('articles_tr.json'),
        expectedLocale: 'tr',
      );
      final guided = tr.where((a) => a.requiresQualifiedGuidance);
      expect(guided, isNotEmpty);
      for (final article in guided) {
        expect(article.guidanceMessage, isNotNull);
        // Yönlendirme adresi de resmî alan doğrulamasından geçer.
        expect(
          OfficialSourceDomains.isAllowed(article.officialQuestionUrl!),
          isTrue,
        );
      }
    });

    test('yeni başlayanlar yolu kesintisiz sıralıdır', () {
      final tr = LearningContentParser.parseArticles(
        readJson('articles_tr.json'),
        expectedLocale: 'tr',
      );
      final orders =
          tr
              .where((a) => a.beginnerPathOrder != null)
              .map((a) => a.beginnerPathOrder!)
              .toList()
            ..sort();
      expect(orders, isNotEmpty);
      // Tekrarsız ve 1'den başlayan kesintisiz dizi.
      expect(orders.toSet().length, orders.length);
      expect(orders, List.generate(orders.length, (i) => i + 1));
    });
  });

  group('Parser doğrulama sertliği', () {
    test('yinelenen içerik id\'si REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle('dup'),
            _minimalArticle('dup'),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('kırık kaynak referansı REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles(
          {
            'schemaVersion': 1,
            'locale': 'tr',
            'articles': <Map<String, Object?>>[
              _minimalArticle('a', sourceIds: const ['yok-boyle-kaynak']),
            ],
          },
          expectedLocale: 'tr',
          validSourceIds: const {'gecerli'},
        ),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('kırık relatedArticleIds REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': [
            _minimalArticle('a', related: ['yok']),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('kaynaksız YAYINLANMIŞ içerik REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle('a', sourceIds: const <String>[]),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('desteklenmeyen şema sürümü REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 99,
          'locale': 'tr',
          'articles': const <Object?>[],
        }, expectedLocale: 'tr'),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    // -----------------------------------------------------------------
    // TASK 056A: YAYIN KAPISI
    // -----------------------------------------------------------------

    test('yalnız URL doğrulaması yayın için YETERLİ DEĞİLDİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle(
              'a',
              verification: _validVerification(
                bodyVerified: false,
                locator: '',
                evidence: '',
                method: 'urlExistenceCheck',
              ),
            ),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('sourceLocator BOŞ ise published REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle('a', verification: _validVerification(locator: '')),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('evidenceSummary BOŞ ise published REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle(
              'a',
              verification: _validVerification(evidence: ''),
            ),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('verifiedAt BOŞ ise published REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle(
              'a',
              verification: _validVerification(verifiedAt: ''),
            ),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('doğrulama kaydı OLMAYAN published içerik REDDEDİLİR', () {
      final article = _minimalArticle('a')..remove('verification');
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[article],
        }, expectedLocale: 'tr'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('doğrulama, içeriğin kaynakları DIŞINDAKİ bir kaynağa dayanamaz', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle(
              'a',
              verification: _validVerification(sourceId: 'baska-kaynak'),
            ),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('genel fetva ANA SAYFASI kesin konum sayılmaz', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'tr',
          'articles': <Map<String, Object?>>[
            _minimalArticle(
              'a',
              verification: _validVerification(
                locator: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
              ),
            ),
          ],
        }, expectedLocale: 'tr'),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('doğrulanmamış içerik PENDING olarak parse EDİLEBİLİR', () {
      // Kapı yalnız `published` için serttir; pending içerik veri
      // katmanında yaşar ama runtime'da GÖSTERİLMEZ.
      final articles = LearningContentParser.parseArticles({
        'schemaVersion': 1,
        'locale': 'tr',
        'articles': <Map<String, Object?>>[
          _minimalArticle(
            'a',
            reviewStatus: 'scholarlyReviewPending',
            verification: _validVerification(
              bodyVerified: false,
              locator: '',
              evidence: '',
              method: 'urlExistenceCheck',
            ),
          ),
        ],
      }, expectedLocale: 'tr');
      expect(articles.single.isPublished, isFalse);
      expect(articles.single.isSourceBodyVerified, isFalse);
    });

    test('locale uyuşmazlığı REDDEDİLİR', () {
      expect(
        () => LearningContentParser.parseArticles({
          'schemaVersion': 1,
          'locale': 'en',
          'articles': const <Object?>[],
        }, expectedLocale: 'tr'),
        throwsA(isA<ContentSchemaError>()),
      );
    });
  });
}

/// Yayın kapısını GEÇEN geçerli bir doğrulama kaydı.
Map<String, Object?> _validVerification({
  String sourceId = 'diyanet-islam-ilmihali',
  bool bodyVerified = true,
  String locator = 'İslam İlmihali (34. Baskı, 2019), V. ABDEST, s. 110',
  String evidence = 'İlgili bölüm makaledeki iddiayı desteklemektedir.',
  String verifiedAt = '2026-07-19',
  String method = 'sourceBodyReview',
}) => {
  'sourceBodyVerified': bodyVerified,
  'sourceId': sourceId,
  'sourceLocator': locator,
  'evidenceSummary': evidence,
  'verifiedAt': verifiedAt,
  'verifiedBy': 'editorialReview',
  'verificationMethod': method,
};

Map<String, Object?> _minimalArticle(
  String id, {
  List<String> sourceIds = const ['diyanet-islam-ilmihali'],
  List<String> related = const [],
  Map<String, Object?>? verification,
  String reviewStatus = 'published',
}) => {
  'id': id,
  'slug': 'slug-$id',
  'categoryId': 'cat-basics',
  'title': 'Başlık',
  'summary': 'Özet',
  'contentType': 'generalTeaching',
  'difficulty': 'beginner',
  'estimatedMinutes': 3,
  'keywords': const <String>[],
  'sections': [
    {'type': 'paragraph', 'text': 'Metin'},
  ],
  'sourceIds': sourceIds,
  'reviewedAt': '2026-07-19',
  'reviewStatus': reviewStatus,
  'translationStatus': 'original',
  'relatedArticleIds': related,
  'verification': verification ?? _validVerification(),
};
