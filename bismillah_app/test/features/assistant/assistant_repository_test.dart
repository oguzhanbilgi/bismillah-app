import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/assistant/data/local_source_grounded_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/learn/data/asset_learning_knowledge_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kaynağa dayalı asistan — gerçek doğrulanmış içerik üzerinden güvenlik ve
/// cevap oluşturma (TASK 059 §2/§9/§17). GERÇEK ağ/AI/Firebase YOKTUR.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalSourceGroundedAssistantRepository repo;

  setUp(() {
    final strings = buildAssistantResponseStrings(
      const AppLocalizations(SupportedLocale.tr),
    );
    repo = LocalSourceGroundedAssistantRepository(
      AssetLearningKnowledgeRepository(),
      (_) => strings,
    );
  });

  Future<AssistantResponse> ask(String text, {String locale = 'tr'}) =>
      repo.answer(
        AssistantQuery(
          id: 't',
          text: text,
          locale: locale,
          createdAt: DateTime(2026, 7, 20),
        ),
      );

  group('How-to', () {
    test(
      'abdest sorusu adım bloklarını ve exact locator kaynağını verir',
      () async {
        final r = await ask('Abdest nasıl alınır?');

        expect(r.answerType, AssistantAnswerType.stepByStepGuide);
        expect(r.confidence, AssistantConfidence.exact);
        expect(r.steps, isNotEmpty);
        expect(r.sourceReferences, isNotEmpty);
        // Exact source locator kaynak kartında (boş değil).
        expect(r.sourceReferences.first.sourceLocator.trim(), isNotEmpty);
        expect(r.sourceReferences.first.institution, contains('Diyanet'));
      },
    );
  });

  group('Tanım', () {
    test('teyemmüm nedir → definition + özet', () async {
      final r = await ask('Teyemmüm nedir?');
      expect(r.answerType, AssistantAnswerType.definition);
      expect(r.shortSummary.trim(), isNotEmpty);
      expect(r.sourceReferences, isNotEmpty);
    });
  });

  group('Hassas hüküm güvenliği', () {
    test(
      'doğrulanmış fatwa yoksa caiz sorusu officialFatwaRequired verir',
      () async {
        final r = await ask('Bu davranış caiz midir?');

        expect(r.answerType, AssistantAnswerType.officialFatwaRequired);
        expect(r.shouldOfferOfficialGuidance, isTrue);
        // Yönlendirme URL'si kaynak modelinden gelir (tahmin değil).
        expect(r.officialGuidanceUrl, isNotNull);
        expect(r.officialGuidanceUrl, startsWith('https://'));
        expect(r.officialGuidanceUrl, contains('diyanet.gov.tr'));
      },
    );

    test('caiz sorusuna "caizdir/haramdır" gibi YENİ hüküm üretmez', () async {
      final r = await ask('Kredi kartı kullanmak caiz mi?');
      final text = '${r.answer} ${r.shortSummary}'.toLowerCase();
      expect(text.contains('caizdir'), isFalse);
      expect(text.contains('haramdır'), isFalse);
      expect(r.answerType, isNot(AssistantAnswerType.directVerifiedAnswer));
    });

    test('kişisel olayda kişisel hüküm verilmez', () async {
      final r = await ask('Ben bu şartlarda kredi çektim, günah mı?');
      expect(r.answerType, AssistantAnswerType.qualifiedGuidanceRequired);
      expect(r.shouldOfferOfficialGuidance, isTrue);
    });
  });

  group('Kaynak yok', () {
    test('doğrulanmış kaynak yoksa ayet/hadis/fetva üretmez', () async {
      final r = await ask('Blockchain teknolojisi nedir?');
      expect(r.answerType, AssistantAnswerType.noVerifiedSource);
      expect(r.sourceReferences, isEmpty);
      // Cevap yalnız sabit güvenli metindir (uydurma içerik yok).
      final strings = buildAssistantResponseStrings(
        const AppLocalizations(SupportedLocale.tr),
      );
      expect(r.answer, strings.noVerifiedSource);
    });
  });

  group('Yayın/doğrulama garantileri', () {
    test('pending içerik retrieval sonucuna girmez', () async {
      // art-kuran-okumaya-baslangic PENDING'tir (TASK 057).
      final r = await ask("Kur'an okumaya başlangıç");
      final ids = [
        for (final s in r.sourceReferences) s.articleId,
        ...r.relatedArticles.map((a) => a.id),
      ];
      expect(ids, isNot(contains('art-kuran-okumaya-baslangic')));
    });

    test(
      'grounded kaynakların hepsi exact locator taşır (sourceBodyVerified)',
      () async {
        final r = await ask('Abdestin farzları nelerdir?');
        for (final source in r.sourceReferences) {
          expect(source.sourceLocator.trim(), isNotEmpty);
          expect(source.lastVerifiedAt.trim(), isNotEmpty);
        }
      },
    );

    test('en fazla 3 ilgili makale', () async {
      final r = await ask('namaz');
      expect(r.relatedArticles.length, lessThanOrEqualTo(3));
    });
  });
}
