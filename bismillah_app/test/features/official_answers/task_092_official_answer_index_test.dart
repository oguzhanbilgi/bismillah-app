import 'dart:convert';
import 'dart:io';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/assistant/data/local_source_grounded_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/data/asset_learning_knowledge_repository.dart';
import 'package:bismillah_app/features/learn/data/learning_content_parser.dart';
import 'package:bismillah_app/features/learn/domain/entities/knowledge_source.dart';
import 'package:bismillah_app/features/learn/domain/entities/source_verification.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/official_answers/data/asset_official_answer_repository.dart';
import 'package:bismillah_app/features/official_answers/data/official_answer_index_parser.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_index.dart';
import 'package:bismillah_app/features/official_answers/domain/entities/official_answer_record.dart';
import 'package:bismillah_app/features/official_answers/domain/value_objects/official_answer_publication_gate.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resmî cevap / fetva dizini TEMELİ (TASK 092).
///
/// TASK 092 SIFIR üretim kaydı taşır — bu paket, gerçek fetva içeriği
/// yayınlanmadan önce sözleşmenin (id disiplini, yayın kapısı, yayınlanmış-
/// yalnız filtreleme, locale tutarlılığı) DOĞRU çalıştığını kanıtlar.
/// Assistant'a HİÇBİR bağlama yapılmaz (TASK 093'ün kapsamıdır); bu dosya
/// yalnız Assistant'ın MEVCUT güvenli davranışının bozulmadığını (regresyon
/// yok) doğrudan gerçek yol üzerinden kanıtlar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Object? readJson(String path) =>
      json.decode(File(path).readAsStringSync());

  // -------------------------------------------------------------------
  // Üretim asset'leri (sıfır kayıt) — bir kez okunur, testler paylaşır.
  // -------------------------------------------------------------------
  final sources = LearningContentParser.parseSources(
    readJson('assets/content/learn/sources.json'),
  );
  final sourcesById = {for (final s in sources) s.id: s};

  OfficialAnswerIndex loadProductionIndex(String locale) =>
      OfficialAnswerIndexParser.parseIndex(
        readJson('assets/content/official_answers/index_$locale.json'),
        expectedLocale: locale,
        validSources: sourcesById,
      );

  group('Üretim asset\'leri — sıfır kayıt (TASK 092 kapsam sınırı)', () {
    for (final locale in const ['tr', 'en', 'ar']) {
      test('$locale index\'i geçerli parse edilir ve HİÇBİR kayıt içermez', () {
        final index = loadProductionIndex(locale);
        expect(index.schemaVersion, 1);
        expect(index.locale, locale);
        // Henüz üretime alınmış bir kayıt YOK — bu, dinî içerik olmadan
        // kapının test edilebildiğini kanıtlar; büyüyen bir sayıyı
        // dondurmaz.
        expect(
          index.answers,
          isEmpty,
          reason:
              'TASK 092 foundation sıfır üretim kaydıyla teslim edilir; '
              'gerçek fetva TASK 092 kapsamında DEĞİLDİR',
        );
        expect(index.published, isEmpty);
      });
    }

    test('deterministik yükleme: tekrar okuma AYNI (boş) sırayı verir', () {
      final first = loadProductionIndex('tr').answers.map((a) => a.id);
      final second = loadProductionIndex('tr').answers.map((a) => a.id);
      expect(first, second);
    });
  });

  group('id ad alanı ayrımı (Learn "art-" ile ÇAKIŞMAZ)', () {
    test('üretim resmî cevap id\'leri Learn makale id\'leriyle ÇAKIŞMAZ', () {
      final learnIds = <String>{};
      for (final locale in const ['tr', 'en', 'ar']) {
        final articles = LearningContentParser.parseArticles(
          readJson('assets/content/learn/articles_$locale.json'),
          expectedLocale: locale,
        );
        learnIds.addAll(articles.map((a) => a.id));
      }
      expect(learnIds, isNotEmpty);

      final officialIds = <String>{};
      for (final locale in const ['tr', 'en', 'ar']) {
        officialIds.addAll(loadProductionIndex(locale).answers.map((a) => a.id));
      }
      // Boş olsa da niyet açık kalsın diye kesişim EXPLICIT kontrol edilir.
      expect(officialIds.intersection(learnIds), isEmpty);
      for (final id in officialIds) {
        expect(id, startsWith('oa-'));
      }
    });

    test('"art-" önekli bir id resmî cevap kaydı olarak KURULAMAZ', () {
      // Ad alanı ayrımı EMPİRİK değil, YAPISAL olarak zorlanır: bir Learn
      // id'si asla geçerli bir OfficialAnswerRecord id'si olamaz.
      expect(
        () => OfficialAnswerRecord(
          id: 'art-abdest-nasil-alinir',
          topic: 'x',
          summary: 'x',
          sourceId: '',
          reviewStatus: ReviewStatus.draft,
          locale: 'tr',
          isGeneralInformationOnly: false,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Kayıt kurucusu — yapısal doğrulama', () {
    test('boş id/topic/summary REDDEDİLİR', () {
      expect(
        () => OfficialAnswerRecord(
          id: '',
          topic: 'x',
          summary: 'x',
          sourceId: '',
          reviewStatus: ReviewStatus.draft,
          locale: 'tr',
          isGeneralInformationOnly: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => OfficialAnswerRecord(
          id: 'oa-x',
          topic: '',
          summary: 'x',
          sourceId: '',
          reviewStatus: ReviewStatus.draft,
          locale: 'tr',
          isGeneralInformationOnly: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => OfficialAnswerRecord(
          id: 'oa-x',
          topic: 'x',
          summary: '',
          sourceId: '',
          reviewStatus: ReviewStatus.draft,
          locale: 'tr',
          isGeneralInformationOnly: true,
        ),
        throwsArgumentError,
      );
    });

    test('":" içeren id REDDEDİLİR (plan öğesi ayıracıyla çakışır)', () {
      expect(
        () => OfficialAnswerRecord(
          id: 'oa-x:y',
          topic: 'x',
          summary: 'x',
          sourceId: '',
          reviewStatus: ReviewStatus.draft,
          locale: 'tr',
          isGeneralInformationOnly: true,
        ),
        throwsArgumentError,
      );
    });

    test('kaynaksız/doğrulamasız YAYINLANMIŞ kayıt REDDEDİLİR', () {
      expect(
        () => OfficialAnswerRecord(
          id: 'oa-x',
          topic: 'x',
          summary: 'x',
          sourceId: '',
          reviewStatus: ReviewStatus.published,
          locale: 'tr',
          isGeneralInformationOnly: true,
        ),
        throwsArgumentError,
      );
    });

    test('zayıf doğrulama yöntemiyle YAYINLANMIŞ kayıt REDDEDİLİR', () {
      expect(
        () => OfficialAnswerRecord(
          id: 'oa-x',
          topic: 'x',
          summary: 'x',
          sourceId: 'diyanet-din-isleri-yuksek-kurulu',
          reviewStatus: ReviewStatus.published,
          locale: 'tr',
          isGeneralInformationOnly: true,
          sourceUrl:
              'https://kurul.diyanet.gov.tr/tr/fetvalar/test-fixture-oa',
          verification: _urlOnlyVerification(
            'diyanet-din-isleri-yuksek-kurulu',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('doğrulanmamış (draft/pending) kayıt eksik alanla KURULABİLİR', () {
      final draft = OfficialAnswerRecord(
        id: 'oa-x',
        topic: 'x',
        summary: 'x',
        sourceId: '',
        reviewStatus: ReviewStatus.draft,
        locale: 'tr',
        isGeneralInformationOnly: false,
      );
      expect(draft.isPublished, isFalse);
      // Draft kayıt için isGeneralInformationOnly'nin gerçek değeri kapıyı
      // ETKİLEMEZ — kapı YALNIZ `published` için çalışır.
      expect(draft.satisfiesOfficialAnswerGate, isFalse);
    });
  });

  group('Parser — şema ve yapı katılığı', () {
    test('desteklenmeyen schemaVersion REDDEDİLİR', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex({
          'schemaVersion': 99,
          'locale': 'tr',
          'answers': const <Object?>[],
        }, expectedLocale: 'tr', validSources: sourcesById),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('locale uyuşmazlığı REDDEDİLİR', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex({
          'schemaVersion': 1,
          'locale': 'en',
          'answers': const <Object?>[],
        }, expectedLocale: 'tr', validSources: sourcesById),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('kök nesne olmayan (bozuk) veri REDDEDİLİR', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex(
          <Object?>['bozuk'],
          expectedLocale: 'tr',
          validSources: sourcesById,
        ),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('yinelenen id REDDEDİLİR', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex({
          'schemaVersion': 1,
          'locale': 'tr',
          'answers': [_minimalAnswer('oa-dup'), _minimalAnswer('oa-dup')],
        }, expectedLocale: 'tr', validSources: sourcesById),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('"oa-" önekisiz id REDDEDİLİR', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex({
          'schemaVersion': 1,
          'locale': 'tr',
          'answers': [_minimalAnswer('yanlis-onek')],
        }, expectedLocale: 'tr', validSources: sourcesById),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('":" içeren id REDDEDİLİR', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex({
          'schemaVersion': 1,
          'locale': 'tr',
          'answers': [_minimalAnswer('oa-x:y')],
        }, expectedLocale: 'tr', validSources: sourcesById),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('kayıtlı olmayan sourceId REDDEDİLİR', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex(
          {
            'schemaVersion': 1,
            'locale': 'tr',
            'answers': [
              _minimalAnswer('oa-x', sourceId: 'boyle-bir-kaynak-yok'),
            ],
          },
          expectedLocale: 'tr',
          validSources: sourcesById,
        ),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('genel ana sayfa locator KESİN KONUM sayılmaz', () {
      expect(
        () => OfficialAnswerIndexParser.parseIndex(
          {
            'schemaVersion': 1,
            'locale': 'tr',
            'answers': [
              _minimalAnswer(
                'oa-x',
                verification: _validVerification(
                  locator: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
                ),
              ),
            ],
          },
          expectedLocale: 'tr',
          validSources: sourcesById,
        ),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test(
      'sourceLocator BOŞ ise PARSER\'IN genel-ana-sayfa locator kuralınca '
      'REDDEDİLİR (missingSourceLocator gate nedenine HİÇ ULAŞILMAZ)',
      () {
        // Dürüstlük notu (kritik gözden geçirme bulgusu): boş locator, TAM
        // parser yolunda [OfficialAnswerGateIssue.missingSourceLocator]
        // yayın-kapısı nedeniyle DEĞİL, parser'ın kendi
        // `_isGenericHomepageLocator` kuralıyla (boş locator = "genel
        // sayılır") DAHA ERKEN reddedilir — bu ASSERTION mesaj metnini
        // denetleyerek GERÇEK reddediş nedenini kanıtlar. Kapının KENDİSİNİN
        // (parser araya girmeden) `missingSourceLocator`'ı GERÇEKTEN
        // ürettiği ayrı bir testte kanıtlanır (bkz. altta "GATE düzeyinde
        // KANIT").
        try {
          OfficialAnswerIndexParser.parseIndex(
            {
              'schemaVersion': 1,
              'locale': 'tr',
              'answers': [
                _minimalAnswer(
                  'oa-x',
                  verification: _validVerification(locator: ''),
                ),
              ],
            },
            expectedLocale: 'tr',
            validSources: sourcesById,
          );
          fail('ContentSchemaError bekleniyordu ama fırlatılmadı');
        } on ContentSchemaError catch (e) {
          expect(e.message, contains('ana sayfa'));
        }
      },
    );

    test(
      'GATE düzeyinde KANIT: parser araya girmeden DOĞRUDAN kurulan boş '
      'locator\'lı kayıt gerçekten missingSourceLocator üretir',
      () {
        // Parser'ın kendi locator kuralı BURADA bilerek ATLANIR (kayıt
        // JSON'dan değil doğrudan kurulur) — amaç SADECE
        // [OfficialAnswerPublicationGate]'in kendi `missingSourceLocator`
        // kontrolünün GERÇEKTEN çalıştığını kanıtlamaktır.
        final draft = _draftRecordFromAnswerMap(
          _minimalAnswer('oa-x', verification: _validVerification(locator: '')),
        );
        final issues = _gateIssuesFor(draft, sourcesById);
        expect(issues, contains(OfficialAnswerGateIssue.missingSourceLocator));
      },
    );

    test(
      'evidenceSummary BOŞ ise weakSourceVerification NEDENİYLE REDDEDİLİR '
      '(SourceVerification.satisfiesPublicationGate=false)',
      () {
        expect(
          () => OfficialAnswerIndexParser.parseIndex(
            {
              'schemaVersion': 1,
              'locale': 'tr',
              'answers': [
                _minimalAnswer(
                  'oa-x',
                  verification: _validVerification(evidence: ''),
                ),
              ],
            },
            expectedLocale: 'tr',
            validSources: sourcesById,
          ),
          // Kayıt kurucusundaki yayın kapısı reddi parser sınırında TEK bir
          // tipe (ContentSchemaError) sarmalanır — ham ArgumentError data
          // katmanının dışına asla sızmaz (bkz. official_answer_index_parser).
          throwsA(isA<ContentSchemaError>()),
        );

        // GATE düzeyinde KANIT: gerçek neden weakSourceVerification'dır —
        // "missingSourceLocator" ya da başka bir alanla KARIŞTIRILMAZ.
        final draft = _draftRecordFromAnswerMap(
          _minimalAnswer('oa-x', verification: _validVerification(evidence: '')),
        );
        final issues = _gateIssuesFor(draft, sourcesById);
        expect(issues, contains(OfficialAnswerGateIssue.weakSourceVerification));
        expect(
          issues,
          isNot(contains(OfficialAnswerGateIssue.missingSourceLocator)),
        );
      },
    );

    test(
      'tam GEÇERLİ (scholarlyReview + yetkili kaynak) yayınlanmış kayıt '
      'BAŞARIYLA parse edilir',
      () {
        final index = OfficialAnswerIndexParser.parseIndex(
          {
            'schemaVersion': 1,
            'locale': 'tr',
            'answers': [_minimalAnswer('oa-x')],
          },
          expectedLocale: 'tr',
          validSources: sourcesById,
        );
        expect(index.answers.single.isPublished, isTrue);
        expect(index.published, hasLength(1));
      },
    );
  });

  group('Resmî cevap yayın kapısı — OfficialAnswerPublicationGate', () {
    // Kritik gözden geçirme bulgusu: Learn'ün `editorialReview` disiplini
    // resmî cevap/fetva kaydı için YETERSİZDİR. Bu grup, ÖNCEKİ paylaşılan
    // fikstürün (verifiedBy: editorialReview) artık REDDEDİLDİĞİNİ, yalnız
    // AYRI ve DAHA SIKI bir kapının GEÇTİĞİNİ kanıtlar.
    // Not: 'boş sourceLocator' vakası BİLEREK bu tabloda YOKTUR — o vaka TAM
    // parser yolunda missingSourceLocator'a hiç ULAŞMADAN, parser'ın kendi
    // genel-ana-sayfa locator kuralıyla reddedilir; iki farklı kanıt seviyesi
    // (parser mesajı + doğrudan gate) yukarıdaki "Parser — şema ve yapı
    // katılığı" grubunda AYRI AYRI test edilir (bkz. "GATE düzeyinde KANIT").
    final rejectionCases = <String, Map<String, Object?> Function()>{
      'editorialReview ile doğrulanmış YAYINLANMIŞ kayıt REDDEDİLİR': () =>
          _minimalAnswer(
            'oa-gate-editorial',
            verification: _validVerification(verifiedBy: 'editorialReview'),
          ),
      'automatedSourceCheck ile doğrulanmış YAYINLANMIŞ kayıt REDDEDİLİR':
          () => _minimalAnswer(
            'oa-gate-automated',
            verification: _validVerification(
              verifiedBy: 'automatedSourceCheck',
            ),
          ),
      'yetki dışı kaynak (diyanet-islam-ilmihali) üzerine kurulu kayıt '
      'REDDEDİLİR': () => _minimalAnswer(
        'oa-gate-nonauthority',
        sourceId: 'diyanet-islam-ilmihali',
        sourceUrl:
            'https://diniyayinlar.diyanet.gov.tr/Documents/'
            'islam%20ilmihali%2017%20X%2024%20.pdf',
      ),
      'boş sourceUrl REDDEDİLİR': () =>
          _minimalAnswer('oa-gate-nourl', sourceUrl: ''),
      'diyanet dışı alan adındaki sourceUrl REDDEDİLİR': () =>
          _minimalAnswer(
            'oa-gate-baddomain',
            sourceUrl: 'https://example.com/fetvalar/1',
          ),
      'kaynağın kendi bare canonicalUrl\'si (DAHA DERİN DEĞİL) REDDEDİLİR':
          () => _minimalAnswer(
            'oa-gate-notdeeper',
            sourceUrl: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
          ),
      'isGeneralInformationOnly=false REDDEDİLİR': () => _minimalAnswer(
        'oa-gate-personal',
        isGeneralInformationOnly: false,
      ),
    };

    // Her vaka için BEKLENEN tipli gate nedeni — "throws ContentSchemaError"
    // yeterli DEĞİLDİR; tipli [OfficialAnswerGateIssue] enum'u TAM OLARAK
    // bunun için vardır.
    final expectedIssues = <String, OfficialAnswerGateIssue>{
      'editorialReview ile doğrulanmış YAYINLANMIŞ kayıt REDDEDİLİR':
          OfficialAnswerGateIssue.notScholarlyReviewed,
      'automatedSourceCheck ile doğrulanmış YAYINLANMIŞ kayıt REDDEDİLİR':
          OfficialAnswerGateIssue.notScholarlyReviewed,
      'yetki dışı kaynak (diyanet-islam-ilmihali) üzerine kurulu kayıt '
      'REDDEDİLİR': OfficialAnswerGateIssue.unapprovedAuthoritySource,
      'boş sourceUrl REDDEDİLİR': OfficialAnswerGateIssue.missingSourceUrl,
      'diyanet dışı alan adındaki sourceUrl REDDEDİLİR':
          OfficialAnswerGateIssue.invalidSourceUrl,
      'kaynağın kendi bare canonicalUrl\'si (DAHA DERİN DEĞİL) REDDEDİLİR':
          OfficialAnswerGateIssue.sourceUrlNotDeeperThanSource,
      'isGeneralInformationOnly=false REDDEDİLİR':
          OfficialAnswerGateIssue.notGeneralInformationOnly,
    };

    rejectionCases.forEach((description, buildAnswer) {
      test(description, () {
        // 1) TAM parser yolu: kayıt HERHANGİ bir tipli nedenle reddedilir.
        expect(
          () => OfficialAnswerIndexParser.parseIndex(
            {
              'schemaVersion': 1,
              'locale': 'tr',
              'answers': [buildAnswer()],
            },
            expectedLocale: 'tr',
            validSources: sourcesById,
          ),
          throwsA(isA<ContentSchemaError>()),
        );

        // 2) GATE düzeyi: reddedişin İDDİA EDİLEN nedeni GERÇEKTEN üretiliyor
        // mu — testin adı "boş sourceUrl" diyorsa üretilen tipli neden
        // GERÇEKTEN missingSourceUrl OLMALIDIR, başka bir kural ÖNCE
        // ateşleyip adı YALANLAMAMALIDIR.
        final draft = _draftRecordFromAnswerMap(buildAnswer());
        final issues = _gateIssuesFor(draft, sourcesById);
        final expected = expectedIssues[description]!;
        expect(
          issues,
          contains(expected),
          reason:
              '"$description" beklenen tipli nedeni ($expected) ÜRETMEDİ: '
              '$issues',
        );
      });
    });

    test(
      'tam UYUMLU (scholarlyReview) sentetik kayıt kapıyı GEÇER ve '
      'gate.evaluate boş liste döner',
      () {
        final index = OfficialAnswerIndexParser.parseIndex(
          {
            'schemaVersion': 1,
            'locale': 'tr',
            'answers': [_minimalAnswer('oa-gate-compliant')],
          },
          expectedLocale: 'tr',
          validSources: sourcesById,
        );
        final record = index.answers.single;
        expect(record.satisfiesOfficialAnswerGate, isTrue);
        expect(index.published, contains(record));
      },
    );

    test(
      'draft ve scholarlyReviewPending kayıtlar published listesinden '
      'HARİÇ TUTULUR',
      () {
        final index = OfficialAnswerIndexParser.parseIndex({
          'schemaVersion': 1,
          'locale': 'tr',
          'answers': [
            _minimalAnswer('oa-gate-draft', reviewStatus: 'draft'),
            _minimalAnswer(
              'oa-gate-pending',
              reviewStatus: 'scholarlyReviewPending',
            ),
          ],
        }, expectedLocale: 'tr', validSources: sourcesById);
        expect(index.published, isEmpty);
        expect(index.answers, hasLength(2));
      },
    );

    test(
      'yinelenen id REDDEDİLİR (yayın kapısından BAĞIMSIZ, ayrı disiplin)',
      () {
        expect(
          () => OfficialAnswerIndexParser.parseIndex({
            'schemaVersion': 1,
            'locale': 'tr',
            'answers': [
              _minimalAnswer('oa-gate-dup'),
              _minimalAnswer('oa-gate-dup'),
            ],
          }, expectedLocale: 'tr', validSources: sourcesById),
          throwsA(isA<ContentSchemaError>()),
        );
      },
    );

    test(
      'NEGATİF KONTROL: SourceVerification.satisfiesPublicationGate '
      'editorialReview ile HÂLÂ true — Learn kapısı KÜRESEL olarak '
      'sıkılaştırılmadı',
      () {
        const verification = SourceVerification(
          sourceBodyVerified: true,
          sourceId: 'diyanet-islam-ilmihali',
          sourceLocator: 'İslam İlmihali, test bölümü, s. 1',
          evidenceSummary: 'Test amaçlı kanıt özeti.',
          verifiedAt: '2026-07-29',
          verifiedBy: VerifiedBy.editorialReview,
          verificationMethod: VerificationMethod.sourceBodyReview,
        );
        expect(verification.satisfiesPublicationGate, isTrue);
      },
    );

    group('AssetOfficialAnswerRepository — kapıyı geçen fikstür GERÇEKTEN döner', () {
      test(
        'tam uyumlu fikstür getPublished/getById ile GERİ DÖNER',
        () async {
          final repo = AssetOfficialAnswerRepository(
            bundle: _OfficialAnswerFixtureBundle(rootBundle),
          );
          final published = await repo.getPublished('tr');
          expect(
            published.valueOrNull!.map((a) => a.id),
            contains('oa-test-fixture-published'),
          );

          final byId = await repo.getById(
            'tr',
            'oa-test-fixture-published',
          );
          expect(byId.valueOrNull, isNotNull);
          expect(byId.valueOrNull!.satisfiesOfficialAnswerGate, isTrue);
        },
      );

      test(
        'RETRIEVAL SINIRI: yayın kapısını geçemeyen bir kayıt içeren bozuk '
        'asset TÜM locale\'i FAIL-CLOSED yapar — İYİ kayıt bile TEK BAŞINA '
        'SIZMAZ (kısmi/melez bir liste asla dönmez)',
        () async {
          final repo = AssetOfficialAnswerRepository(
            bundle: _GateFailingFixtureBundle(rootBundle),
          );

          final index = await repo.getIndex('tr');
          expect(index.isFailure, isTrue);
          expect(index.failureOrNull, isA<StorageFailure>());
          // Mesaj metni SABİTTİR — ham istisna/kayıt id'si asla sızmaz.
          expect(index.failureOrNull!.messageKey, 'errorStorage');

          final published = await repo.getPublished('tr');
          expect(published.isFailure, isTrue);
          expect(published.valueOrNull, isNull);

          final byId = await repo.getById(
            'tr',
            'oa-gate-failing-fixture-good',
          );
          expect(byId.isFailure, isTrue);
          expect(byId.valueOrNull, isNull);
        },
      );
    });
  });

  group('Locale tutarlılığı — sentetik ayrışma GERÇEKTEN tespit edilir', () {
    Set<String> idsOf(OfficialAnswerIndex index) =>
        index.answers.map((a) => a.id).toSet();

    test('üretimde üç locale AYNI (boş) id kümesini taşır', () {
      final tr = idsOf(loadProductionIndex('tr'));
      final en = idsOf(loadProductionIndex('en'));
      final ar = idsOf(loadProductionIndex('ar'));
      expect(tr, en);
      expect(en, ar);
    });

    test('sentetik AYRIŞAN bir çift farklı id kümesi üretir (vacuous DEĞİL)', () {
      final a = OfficialAnswerIndexParser.parseIndex({
        'schemaVersion': 1,
        'locale': 'tr',
        'answers': [_minimalAnswer('oa-fixture-only-tr', reviewStatus: 'draft')],
      }, expectedLocale: 'tr', validSources: sourcesById);
      final b = OfficialAnswerIndexParser.parseIndex({
        'schemaVersion': 1,
        'locale': 'en',
        'answers': [_minimalAnswer('oa-fixture-only-en', reviewStatus: 'draft')],
      }, expectedLocale: 'en', validSources: sourcesById);

      final idsA = idsOf(a);
      final idsB = idsOf(b);
      // Bu doğrulama GERÇEKTEN ayrışmayı yakalar: iki küme farklıdır ve
      // kesişimleri boştur — üç boş dosyada her zaman geçen bir eşitlik
      // testi DEĞİLDİR.
      expect(idsA, isNot(idsB));
      expect(idsA.intersection(idsB), isEmpty);
    });
  });

  group('AssetOfficialAnswerRepository — asset katmanı', () {
    test('üretim index\'i getIndex/getPublished ile boş döner (crash yok)', () async {
      final repo = AssetOfficialAnswerRepository();
      final index = await repo.getIndex('tr');
      expect(index.valueOrNull?.answers, isEmpty);

      final published = await repo.getPublished('tr');
      expect(published.valueOrNull, isEmpty);
    });

    test('bilinmeyen id → null (Learn\'e ASLA düşülmez, uydurma cevap yok)', () async {
      final repo = AssetOfficialAnswerRepository();
      final result = await repo.getById('tr', 'oa-does-not-exist');
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, isNull);
    });

    group('published-only filtreleme (fikstür)', () {
      late AssetOfficialAnswerRepository repo;

      setUp(() {
        repo = AssetOfficialAnswerRepository(
          bundle: _OfficialAnswerFixtureBundle(rootBundle),
        );
      });

      test('getPublished YALNIZ yayınlanmış kaydı döner', () async {
        final result = await repo.getPublished('tr');
        final ids = result.valueOrNull!.map((a) => a.id);
        expect(ids, contains('oa-test-fixture-published'));
        expect(ids, isNot(contains('oa-test-fixture-draft')));
      });

      test('getById draft/pending kaydı ASLA döndürmez', () async {
        final draft = await repo.getById('tr', 'oa-test-fixture-draft');
        expect(draft.valueOrNull, isNull);

        final published = await repo.getById(
          'tr',
          'oa-test-fixture-published',
        );
        expect(published.valueOrNull, isNotNull);
        expect(published.valueOrNull!.isPublished, isTrue);
      });

      test(
        'deterministik yükleme: BAĞIMSIZ depo örnekleri AYNI sırayı verir',
        () async {
          // Kasıtlı olarak İKİ AYRI depo örneği kullanılır (aynı önbelleği
          // yeniden okumak yerine): bu, sıranın önbellek yapısına değil,
          // asset/dosya sırasına dayandığını kanıtlar.
          final repoA = AssetOfficialAnswerRepository(
            bundle: _OfficialAnswerFixtureBundle(rootBundle),
          );
          final repoB = AssetOfficialAnswerRepository(
            bundle: _OfficialAnswerFixtureBundle(rootBundle),
          );
          final first = (await repoA.getIndex(
            'tr',
          )).valueOrNull!.answers.map((a) => a.id).toList();
          final second = (await repoB.getIndex(
            'tr',
          )).valueOrNull!.answers.map((a) => a.id).toList();
          expect(first, second);
          expect(first, ['oa-test-fixture-published', 'oa-test-fixture-draft']);
        },
      );
    });
  });

  group('Sentetik fikstürler test-yereldir', () {
    test('üretim asset\'leri fikstür id\'lerini İÇERMEZ', () {
      for (final locale in const ['tr', 'en', 'ar']) {
        final ids = loadProductionIndex(locale).answers.map((a) => a.id);
        expect(ids, isNot(contains('oa-test-fixture-published')));
        expect(ids, isNot(contains('oa-test-fixture-draft')));
      }
    });
  });

  group('Assistant — regresyon YOK (TASK 092 hiçbir yere BAĞLANMADI)', () {
    late LocalSourceGroundedAssistantRepository assistantRepo;

    setUp(() {
      final strings = buildAssistantResponseStrings(
        const AppLocalizations(SupportedLocale.tr),
      );
      assistantRepo = LocalSourceGroundedAssistantRepository(
        AssetLearningKnowledgeRepository(),
        (_) => strings,
      );
    });

    test(
      'helal/haram sorusu HÂLÂ officialFatwaRequired + resmî yönlendirme verir',
      () async {
        final response = await assistantRepo.answer(
          AssistantQuery(
            id: 't',
            text: 'Bu davranış caiz midir?',
            locale: 'tr',
            createdAt: DateTime(2026, 7, 29),
          ),
        );
        expect(
          response.answerType,
          AssistantAnswerType.officialFatwaRequired,
        );
        expect(response.shouldOfferOfficialGuidance, isTrue);
      },
    );
  });

  group('Üretim asset\'leri — ham metin de SIFIR kayıt kanıtlar', () {
    test(
      'hiçbir index_*.json dosyasında "oa-" ile başlayan bir id METİN '
      'OLARAK dahi GEÇMEZ',
      () {
        for (final locale in const ['tr', 'en', 'ar']) {
          final raw = File(
            'assets/content/official_answers/index_$locale.json',
          ).readAsStringSync();
          expect(
            raw.contains('"oa-'),
            isFalse,
            reason: '$locale index dosyası bir "oa-" id metni içeriyor',
          );
        }
      },
    );
  });

  group('Mimari sınır — getIndex() yalnız kendi data katmanından çağrılır', () {
    test(
      'lib/ altında official_answers/data DIŞINDA HİÇBİR dosya '
      '".getIndex(" ÇAĞRISI YAPMAZ (sözleşme BİLDİRİMİ hariç)',
      () {
        // ".getIndex(" (başında NOKTA) bir ÇAĞRIYI arar; arayüz
        // dosyasındaki bildirim (`ResultFuture<...> getIndex(...)`) noktasız
        // olduğu için bu taramanın DIŞINDA kalır — bildirim bir kullanım
        // DEĞİLDİR.
        final offenders = <String>[];
        final libDir = Directory('lib');
        for (final entity in libDir.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) {
            continue;
          }
          final normalized = entity.path.replaceAll('\\', '/');
          if (normalized.contains(
            'lib/features/official_answers/data/',
          )) {
            continue;
          }
          final content = entity.readAsStringSync();
          if (content.contains('.getIndex(')) {
            offenders.add(normalized);
          }
        }
        expect(
          offenders,
          isEmpty,
          reason:
              'getIndex() dahili denetim/test amaçlıdır; TASK 092 hiçbir '
              'tüketiciye BAĞLANMAZ: $offenders',
        );
      },
    );
  });

  group('OfficialAnswerPublicationGate — tipli ret nedenleri', () {
    test(
      'tamamen eksik bir kayıt İLGİLİ TÜM tipli nedenleri TEK seferde döner',
      () {
        final record = OfficialAnswerRecord(
          id: 'oa-x',
          topic: 'x',
          summary: 'x',
          sourceId: '',
          reviewStatus: ReviewStatus.draft,
          locale: 'tr',
          isGeneralInformationOnly: false,
        );
        final issues = OfficialAnswerPublicationGate.evaluate(record);
        expect(issues, contains(OfficialAnswerGateIssue.notPublished));
        expect(
          issues,
          contains(OfficialAnswerGateIssue.missingVerification),
        );
        expect(
          issues,
          contains(OfficialAnswerGateIssue.unapprovedAuthoritySource),
        );
        expect(issues, contains(OfficialAnswerGateIssue.missingSourceUrl));
        expect(
          issues,
          contains(OfficialAnswerGateIssue.notGeneralInformationOnly),
        );
      },
    );
  });

  group('Güvenlik değişmezi', () {
    test(
      'HİÇBİR yayınlanmış Learn makalesi contentType: officialFatwa taşımaz',
      () {
        // Composer'ın _firstVerdictCapable kapısı YALNIZ officialFatwa +
        // sourceBodyVerified arar; bu değişmez, o yolu GÜVENLE erişilemez
        // tutar. TASK 092 bu değişmezi BOZMAZ (hiçbir Learn asset'i
        // değiştirilmedi) — burada AYRICA kanıtlanır.
        for (final locale in const ['tr', 'en', 'ar']) {
          final decoded =
              readJson('assets/content/learn/articles_$locale.json')
                  as Map<String, Object?>;
          final articles = decoded['articles']! as List<Object?>;
          for (final raw in articles) {
            final map = raw! as Map<String, Object?>;
            expect(
              map['contentType'],
              isNot('officialFatwa'),
              reason: '${map['id']} ($locale) officialFatwa taşıyor',
            );
          }
        }
      },
    );
  });
}

SourceVerification _urlOnlyVerification(String sourceId) =>
    SourceVerification.urlOnly(sourceId: sourceId, verifiedAt: '2026-07-29');

/// [answerMap] (`_minimalAnswer(...)`'ın döndürdüğü ham JSON) üzerinden,
/// PARSER'IN kendi locator/şema kurallarına HİÇ UĞRAMADAN doğrudan bir
/// [OfficialAnswerRecord] kurar. `reviewStatus` KASITLI OLARAK `draft`
/// tutulur ki kurucunun KENDİ (kaynaksız) yayın-kapısı kontrolü ayrıca
/// devreye GİRMESİN — amaç SADECE [OfficialAnswerPublicationGate.evaluate]'i
/// çözülmüş bir kaynakla DOĞRUDAN çağırıp tipli nedeni gözlemlemektir.
OfficialAnswerRecord _draftRecordFromAnswerMap(Map<String, Object?> map) {
  final verificationMap = map['verification'] as Map<String, Object?>?;
  return OfficialAnswerRecord(
    id: map['id']! as String,
    topic: map['topic']! as String,
    summary: map['summary']! as String,
    sourceId: map['sourceId'] as String? ?? '',
    reviewStatus: ReviewStatus.draft,
    locale: 'tr',
    isGeneralInformationOnly: map['isGeneralInformationOnly']! as bool,
    sourceUrl: map['sourceUrl'] as String? ?? '',
    verification: verificationMap == null
        ? null
        : SourceVerification(
            sourceBodyVerified: verificationMap['sourceBodyVerified'] == true,
            sourceId: verificationMap['sourceId']! as String,
            sourceLocator:
                (verificationMap['sourceLocator'] as String? ?? '').trim(),
            evidenceSummary:
                (verificationMap['evidenceSummary'] as String? ?? '').trim(),
            verifiedAt:
                (verificationMap['verifiedAt'] as String? ?? '').trim(),
            verifiedBy: VerifiedBy.values.byName(
              verificationMap['verifiedBy']! as String,
            ),
            verificationMethod: VerificationMethod.values.byName(
              verificationMap['verificationMethod']! as String,
            ),
            blocker: verificationMap['blocker'] as String?,
          ),
  );
}

/// [record]'un GATE'İNİ, kendi `sourceId`'sinin [sourcesById] içindeki
/// çözümüyle DOĞRUDAN değerlendirir — parser katmanı ARAYA GİRMEZ.
List<OfficialAnswerGateIssue> _gateIssuesFor(
  OfficialAnswerRecord record,
  Map<String, KnowledgeSource> sourcesById,
) => OfficialAnswerPublicationGate.evaluate(
  record,
  source: sourcesById[record.sourceId],
  expectedLocale: 'tr',
);

/// Resmî cevap yayın kapısını GEÇEN geçerli bir doğrulama kaydı.
///
/// ÖNEMLİ: bu, Learn makale testlerindeki `editorialReview` disipliniyle
/// AYNI DEĞİLDİR — [OfficialAnswerPublicationGate] BİLE İSTEYE daha sıkıdır
/// ve `verifiedBy: scholarlyReview` gerektirir (bkz. o dosyadaki gerekçe).
/// `verifiedBy` varsayılanının burada `scholarlyReview` olması, gerçek bir
/// nitelikli incelemenin yapıldığı ANLAMINA GELMEZ — yalnız test fikstürünün
/// kapıyı GEÇECEK şekilde kurulduğu anlamına gelir.
Map<String, Object?> _validVerification({
  String sourceId = 'diyanet-din-isleri-yuksek-kurulu',
  bool bodyVerified = true,
  String locator = 'Din İşleri Yüksek Kurulu Fetvaları, test-fikstür-fetva-1',
  String evidence = 'Test amaçlı kanıt özeti.',
  String verifiedAt = '2026-07-29',
  String verifiedBy = 'scholarlyReview',
  String method = 'sourceBodyReview',
}) => {
  'sourceBodyVerified': bodyVerified,
  'sourceId': sourceId,
  'sourceLocator': locator,
  'evidenceSummary': evidence,
  'verifiedAt': verifiedAt,
  'verifiedBy': verifiedBy,
  'verificationMethod': method,
};

/// Resmî cevap yayın kapısını TAM GEÇEN (compliant) bir JSON fikstürü.
/// Tek tek alanları REDDEDECEK şekilde bozmak için parametreler değiştirilir.
Map<String, Object?> _minimalAnswer(
  String id, {
  String sourceId = 'diyanet-din-isleri-yuksek-kurulu',
  Map<String, Object?>? verification,
  String reviewStatus = 'published',
  String sourceUrl = 'https://kurul.diyanet.gov.tr/tr/fetvalar/test-fixture-oa',
  bool isGeneralInformationOnly = true,
}) => {
  'id': id,
  'topic': 'Test konu',
  'summary': 'Test özet',
  'sourceId': sourceId,
  'reviewStatus': reviewStatus,
  'sourceUrl': sourceUrl,
  'isGeneralInformationOnly': isGeneralInformationOnly,
  'verification': verification ?? _validVerification(sourceId: sourceId),
};

/// Yayınlanmış + taslak bir kaydı `index_tr.json` yerine enjekte eden
/// TEST-YEREL asset fikstürü (üretim JSON'u DEĞİŞTİRİLMEZ).
final class _OfficialAnswerFixtureBundle extends AssetBundle {
  _OfficialAnswerFixtureBundle(this._inner);

  final AssetBundle _inner;

  static const String _indexPathTr =
      'assets/content/official_answers/index_tr.json';

  @override
  Future<ByteData> load(String key) => _inner.load(key);

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key != _indexPathTr) {
      return _inner.loadString(key, cache: cache);
    }
    return json.encode({
      'schemaVersion': 1,
      'locale': 'tr',
      'answers': [
        _minimalAnswer('oa-test-fixture-published'),
        _minimalAnswer('oa-test-fixture-draft', reviewStatus: 'draft')
          ..remove('verification'),
      ],
    });
  }
}

/// Bir GEÇERLİ + bir yayın kapısını GEÇEMEYEN kaydı `index_tr.json` yerine
/// enjekte eden TEST-YEREL fikstür. `OfficialAnswerRecord` kurucusu kapıyı
/// GEÇEMEYEN bir `published` kayıt İNŞA EDEMEZ (bkz. official_answer_record),
/// bu yüzden bozuk kayıt `isGeneralInformationOnly: false` ile üretilir —
/// JSON şema düzeyinde GEÇERLİ ama gate düzeyinde REDDEDİLEN tek alan.
/// Parser bu kaydı ContentSchemaError ile reddeder ve TÜM index yüklemesi
/// FAIL-CLOSED olur: iyi kayıt bile tek başına asla sızmaz.
final class _GateFailingFixtureBundle extends AssetBundle {
  _GateFailingFixtureBundle(this._inner);

  final AssetBundle _inner;

  static const String _indexPathTr =
      'assets/content/official_answers/index_tr.json';

  @override
  Future<ByteData> load(String key) => _inner.load(key);

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key != _indexPathTr) {
      return _inner.loadString(key, cache: cache);
    }
    return json.encode({
      'schemaVersion': 1,
      'locale': 'tr',
      'answers': [
        _minimalAnswer('oa-gate-failing-fixture-good'),
        _minimalAnswer(
          'oa-gate-failing-fixture-bad',
          isGeneralInformationOnly: false,
        ),
      ],
    });
  }
}
