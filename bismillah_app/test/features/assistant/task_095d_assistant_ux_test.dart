import 'dart:async';
import 'dart:convert';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/assistant/data/local_source_grounded_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_message.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/assistant_history_repository.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/bismillah_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/services/assistant_query_classifier.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/assistant/presentation/assistant_screen.dart';
import 'package:bismillah_app/features/learn/data/asset_learning_knowledge_repository.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 095D — Asistan UX ve alfa cilası.
///
/// Kapsam: iniş ekranı, soru/cevap sunumu, kaynak satırları, kanonik
/// reddetme durumları, geçmiş ve erişilebilirlik. GERÇEK ağ/AI/Firebase
/// YOKTUR; retrieval ve güvenlik mantığı DEĞİŞMEZ, yalnız sunulur.
const _source = AssistantSourceReference(
  sourceId: 'diyanet-islam-ilmihali',
  articleId: 'art-abdest-nasil-alinir',
  articleSlug: 'abdest-nasil-alinir',
  institution: 'T.C. Diyanet İşleri Başkanlığı',
  title: 'İslam İlmihali',
  sourceType: KnowledgeSourceType.ilmihal,
  sourceLocator: 'V. ABDEST, s. 105-107',
  canonicalUrl: 'https://kuran.diyanet.gov.tr/',
  originalLanguage: 'tr',
  lastVerifiedAt: '2026-07-19',
);

/// Bozuk/eksik künye: eski bir kayıttan çözülmüş, açılabilir hedefi
/// olmayan kaynak. Uydurulmuş bir adres KOYULMAZ.
const _brokenSource = AssistantSourceReference(
  sourceId: 'diyanet-islam-ilmihali',
  articleId: '',
  articleSlug: '',
  institution: 'T.C. Diyanet İşleri Başkanlığı',
  title: 'İslam İlmihali',
  sourceType: KnowledgeSourceType.ilmihal,
  sourceLocator: 'V. ABDEST, s. 105-107',
  canonicalUrl: '',
  originalLanguage: 'tr',
  lastVerifiedAt: '2026-07-19',
);

/// Sabit cevaplı sahte depo — sunum davranışı izole edilir.
class _CannedAssistantRepository implements BismillahAssistantRepository {
  _CannedAssistantRepository(this.response);

  final AssistantResponse response;
  final List<String> asked = [];

  @override
  Future<AssistantResponse> answer(AssistantQuery query) async {
    asked.add(query.text);
    return response;
  }
}

/// Cevabı elde tutan sahte depo — loading ve çift gönderim testleri.
class _HoldingAssistantRepository implements BismillahAssistantRepository {
  final List<Completer<AssistantResponse>> completers = [];
  final List<String> asked = [];

  @override
  Future<AssistantResponse> answer(AssistantQuery query) {
    asked.add(query.text);
    final completer = Completer<AssistantResponse>();
    completers.add(completer);
    return completer.future;
  }
}

/// Her zaman hata fırlatan depo — geçici retrieval hatası.
class _ThrowingAssistantRepository implements BismillahAssistantRepository {
  _ThrowingAssistantRepository({this.recoverAfterFirst = false});

  final bool recoverAfterFirst;
  int calls = 0;

  @override
  Future<AssistantResponse> answer(AssistantQuery query) async {
    calls++;
    if (recoverAfterFirst && calls > 1) {
      return const AssistantResponse(
        answerType: AssistantAnswerType.definition,
        confidence: AssistantConfidence.exact,
        answer: 'Teyemmüm açıklaması.',
        shortSummary: 'Teyemmüm.',
        sourceReferences: [_source],
      );
    }
    throw const FormatException('bozuk içerik');
  }
}

/// Geçmiş deposu sahtesi: yükleme içeriği ve silme sonucu kontrol edilir.
class _FakeHistoryRepository implements AssistantHistoryRepository {
  _FakeHistoryRepository({this.initial = const [], this.clearSucceeds = true});

  final List<AssistantMessage> initial;
  final bool clearSucceeds;
  final List<List<AssistantMessage>> saved = [];
  int clearCalls = 0;

  @override
  Future<List<AssistantMessage>> load() async => initial;

  @override
  ResultFuture<void> save(List<AssistantMessage> messages) async {
    saved.add(messages);
    return const Result.success(null);
  }

  @override
  ResultFuture<void> clear() async {
    clearCalls++;
    return clearSucceeds
        ? const Result.success(null)
        : const Result.failure(StorageFailure());
  }
}

AssistantResponse _grounded() => const AssistantResponse(
  answerType: AssistantAnswerType.stepByStepGuide,
  confidence: AssistantConfidence.exact,
  answer: 'Abdest sırayla alınır.',
  shortSummary: 'Abdest sırayla alınır.',
  steps: ['Niyet et ve besmele çek.', 'Elleri yıka.'],
  sourceReferences: [_source],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const l10n = AppLocalizations(SupportedLocale.tr);

  Future<void> pump(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    BismillahAssistantRepository? repository,
    AssistantHistoryRepository? history,
    Map<String, Object> initialPrefs = const {},
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
    double keyboardInset = 0,
    bool reducedMotion = false,
  }) async {
    SharedPreferences.setMockInitialValues(initialPrefs);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.assistant,
      routes: [
        GoRoute(
          path: AppRoutes.assistant,
          builder: (context, state) => const AssistantScreen(),
        ),
        GoRoute(
          path: '${AppRoutes.learnArticle}/:slug',
          builder: (context, state) => Scaffold(
            body: Text('learn-article:${state.pathParameters['slug']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(locale),
          if (repository != null)
            bismillahAssistantRepositoryProvider.overrideWithValue(repository),
          if (history != null)
            assistantHistoryRepositoryProvider.overrideWithValue(history),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: locale.locale,
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              viewInsets: EdgeInsets.only(bottom: keyboardInset),
              disableAnimations: reducedMotion,
            ),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> ask(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
  }

  // ---------------------------------------------------------------------
  // §1 — İniş ekranı
  // ---------------------------------------------------------------------

  group('§1 — iniş ekranı', () {
    testWidgets('ne yaptığını, kaynağını ve sınırlarını açıklar', (
      tester,
    ) async {
      await pump(tester, repository: _CannedAssistantRepository(_grounded()));

      expect(find.text(l10n.assistantIntroBody), findsOneWidget);
      expect(find.text(l10n.assistantLandingCanTitle), findsOneWidget);
      expect(find.text(l10n.assistantLandingCan1), findsOneWidget);
      expect(find.text(l10n.assistantLandingCan2), findsOneWidget);
      expect(find.text(l10n.assistantLandingCan3), findsOneWidget);
      expect(find.text(l10n.assistantLandingLimitTitle), findsOneWidget);
      // Fetva uyarısı iniş ekranında AÇIKÇA yer alır.
      expect(find.text(l10n.assistantNotMuftiNotice), findsOneWidget);
      expect(find.text(l10n.assistantLandingLocalOnly), findsOneWidget);
    });

    testWidgets('sahte konuşma, referans veya yapay zekâ iddiası yoktur', (
      tester,
    ) async {
      await pump(tester, repository: _CannedAssistantRepository(_grounded()));

      // Hiçbir cevap balonu/kaynak bloğu yok — konuşma boş başlar.
      expect(find.text(l10n.assistantSourcesTitle), findsNothing);
      expect(find.text(l10n.assistantSummaryTitle), findsNothing);
      expect(find.text(l10n.assistantBadgeVerified), findsNothing);
      // Metinlerde "yapay zekâ yapar" iddiası değil, "gönderilmez" sınırı var.
      expect(
        l10n.assistantLandingLocalOnly.toLowerCase(),
        contains('gönderilmez'),
      );
    });

    testWidgets('3-5 örnek soru gösterilir ve hepsi yerelleştirilmiştir', (
      tester,
    ) async {
      await pump(tester, repository: _CannedAssistantRepository(_grounded()));

      final questions = [
        l10n.assistantSuggested1,
        l10n.assistantSuggested2,
        l10n.assistantSuggested3,
        l10n.assistantSuggested4,
        l10n.assistantSuggested5,
      ];
      expect(questions.toSet().length, 5);
      var visible = 0;
      for (final q in questions) {
        if (find.text(q).evaluate().isNotEmpty) {
          visible++;
        }
      }
      expect(visible, greaterThanOrEqualTo(3));
    });

    testWidgets('örnek soruya dokunmak güvenli biçimde gönderir', (
      tester,
    ) async {
      final repo = _CannedAssistantRepository(_grounded());
      await pump(tester, repository: repo);

      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      expect(repo.asked, [l10n.assistantSuggested1]);
      expect(find.text(l10n.assistantSourcesTitle), findsOneWidget);
      // Gönderimden sonra giriş alanı yeniden kullanılabilir.
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    });
  });

  // ---------------------------------------------------------------------
  // §2 — Önerilen sorular retrieval'ın GERÇEKTEN döndürebildiği konulardır
  // ---------------------------------------------------------------------

  group('§2 — önerilen sorular gerçek indeksten cevaplanır', () {
    for (final locale in SupportedLocale.values) {
      test('${locale.name}: beş öneri de kaynaksız duruma düşmez', () async {
        final localized = AppLocalizations(locale);
        final repo = LocalSourceGroundedAssistantRepository(
          AssetLearningKnowledgeRepository(),
          (_) => buildAssistantResponseStrings(localized),
        );
        for (final question in [
          localized.assistantSuggested1,
          localized.assistantSuggested2,
          localized.assistantSuggested3,
          localized.assistantSuggested4,
          localized.assistantSuggested5,
        ]) {
          final response = await repo.answer(
            AssistantQuery(
              id: 'q',
              text: question,
              locale: locale.name,
              createdAt: DateTime(2026, 8, 4),
            ),
          );
          expect(
            response.answerType,
            isNot(AssistantAnswerType.noVerifiedSource),
            reason: '${locale.name} önerisi cevapsız kalıyor: $question',
          );
          expect(
            response.sourceReferences,
            isNotEmpty,
            reason: '${locale.name} önerisi kaynaksız dönüyor: $question',
          );
        }
      });
    }
  });

  // ---------------------------------------------------------------------
  // §3 — Gönderim: kilit, loading, başarı, hata
  // ---------------------------------------------------------------------

  group('§3 — gönderim ve durumlar', () {
    testWidgets('cevap sürerken ikinci gönderim depoya ulaşmaz', (
      tester,
    ) async {
      final holding = _HoldingAssistantRepository();
      await pump(tester, repository: holding);

      await ask(tester, 'Teyemmüm nedir?');
      await tester.pump();

      // Cevap sürerken hem giriş alanı hem gönder aksiyonu kilitlidir.
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      final sendButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(sendButton.onPressed, isNull);

      // Hızlı ikinci dokunuş depoya ULAŞMAZ.
      await tester.tap(find.byIcon(Icons.send_rounded), warnIfMissed: false);
      await tester.pump();
      expect(holding.asked, ['Teyemmüm nedir?']);

      holding.completers.first.complete(_grounded());
      await tester.pumpAndSettle();

      // Cevaptan sonra giriş alanı yeniden kullanılabilir ve boştur.
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(holding.asked.length, 1);
    });

    testWidgets('loading satırı sakin ve canlı bölge olarak bildirilir', (
      tester,
    ) async {
      final holding = _HoldingAssistantRepository();
      await pump(tester, repository: holding);

      await ask(tester, 'Teyemmüm nedir?');
      await tester.pump();

      expect(find.text(l10n.assistantThinking), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);

      holding.completers.first.complete(_grounded());
      await tester.pumpAndSettle();
      expect(find.text(l10n.assistantThinking), findsNothing);
    });

    testWidgets(
      'retrieval hatası: cevap üretilmez, dürüst hata + tekrar dene',
      (tester) async {
        await pump(tester, repository: _ThrowingAssistantRepository());

        await ask(tester, 'Teyemmüm nedir?');
        await tester.pumpAndSettle();

        expect(find.text(l10n.assistantRetrievalFailedTitle), findsOneWidget);
        expect(find.text(l10n.assistantRetry), findsOneWidget);
        // "Kaynak yok" gibi bir DİNÎ sonuç iddia edilmez.
        expect(find.text(l10n.assistantBadgeNoSource), findsNothing);
        expect(find.text(l10n.assistantNoVerifiedSource), findsNothing);
        // Soru görünür kalır ve giriş alanı yeniden kullanılabilir.
        expect(find.text('Teyemmüm nedir?'), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).enabled,
          isTrue,
        );
      },
    );

    testWidgets('tekrar dene aynı soruyu bir kez daha sorar', (tester) async {
      final repo = _ThrowingAssistantRepository(recoverAfterFirst: true);
      await pump(tester, repository: repo);

      await ask(tester, 'Teyemmüm nedir?');
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.assistantRetry));
      await tester.pumpAndSettle();

      expect(repo.calls, 2);
      expect(find.text(l10n.assistantRetrievalFailedTitle), findsNothing);
      // Soru ekranda iki kez GÖRÜNMEZ.
      expect(find.text('Teyemmüm nedir?'), findsOneWidget);
      expect(find.text(l10n.assistantSourcesTitle), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------
  // §4 — Kaynak satırları
  // ---------------------------------------------------------------------

  group('§4 — kaynak sunumu', () {
    testWidgets('geçerli kaynak: künye, locator ve iki çalışan aksiyon', (
      tester,
    ) async {
      await pump(tester, repository: _CannedAssistantRepository(_grounded()));
      await ask(tester, 'Abdest nasıl alınır?');
      await tester.pumpAndSettle();

      expect(
        find.textContaining(l10n.assistantOfficialSourceTag),
        findsWidgets,
      );
      expect(find.text('V. ABDEST, s. 105-107'), findsOneWidget);
      expect(find.text(l10n.learnOpenOfficialPage), findsOneWidget);
      expect(find.text(l10n.assistantReadInLearn), findsOneWidget);
      expect(find.text(l10n.assistantSourceLinkUnavailable), findsNothing);
    });

    testWidgets(
      'bozuk künye: tıklanabilir sahte aksiyon yok, eksiklik yazılı',
      (tester) async {
        await pump(
          tester,
          repository: _CannedAssistantRepository(
            const AssistantResponse(
              answerType: AssistantAnswerType.definition,
              confidence: AssistantConfidence.exact,
              answer: 'Tanım.',
              shortSummary: 'Tanım.',
              sourceReferences: [_brokenSource],
            ),
          ),
        );
        await ask(tester, 'Teyemmüm nedir?');
        await tester.pumpAndSettle();

        // Künye ve locator hâlâ gösterilir — belirsizlik gizlenmez.
        expect(find.text('V. ABDEST, s. 105-107'), findsOneWidget);
        expect(find.text(l10n.assistantSourceLinkUnavailable), findsOneWidget);
        expect(find.text(l10n.learnOpenOfficialPage), findsNothing);
        expect(find.text(l10n.assistantReadInLearn), findsNothing);
      },
    );
  });

  // ---------------------------------------------------------------------
  // §5 — Kanonik reddetme ve kaynaksızlık durumları
  //
  // İki katman ayrı doğrulanır. Sınıflandırma GERÇEK depoyla (varlıklardan
  // okuyan) düz testlerde ölçülür — `testWidgets` sahte saat bölgesinde
  // çalıştığı için gerçek varlık okuması orada tamamlanmaz. Sunum ise
  // kanonik cevap türü başına sahte cevapla ölçülür. Böylece hassasiyet
  // yüklemi presentation'a KOPYALANMAZ; ekran yalnız türü okur.
  // ---------------------------------------------------------------------

  group('§5a — kanonik sınıflar gerçek depoda beklenen türü verir', () {
    Future<AssistantResponse> askReal(String text) {
      final repo = LocalSourceGroundedAssistantRepository(
        AssetLearningKnowledgeRepository(),
        (_) => buildAssistantResponseStrings(l10n),
      );
      return repo.answer(
        AssistantQuery(
          id: 'q',
          text: text,
          locale: 'tr',
          createdAt: DateTime(2026, 8, 4),
        ),
      );
    }

    test('hüküm sorusu → officialFatwaRequired', () async {
      final response = await askReal('Bu davranış caiz midir?');
      expect(response.answerType, AssistantAnswerType.officialFatwaRequired);
      expect(response.shouldOfferOfficialGuidance, isTrue);
    });

    test('kişisel durum → qualifiedGuidanceRequired', () async {
      final response = await askReal(
        'Ben bu şartlarda kredi çektim, günah mı?',
      );
      expect(
        response.answerType,
        AssistantAnswerType.qualifiedGuidanceRequired,
      );
    });

    test(
      'ibadet kuralı → genel bilgi + kişisel hüküm uygulanmaz notu',
      () async {
        final response = await askReal('Kan abdesti bozar mı?');
        expect(response.answerType, AssistantAnswerType.generalSourceSummary);
        expect(response.safetyNotice, l10n.assistantGeneralInfoNotRuling);
      },
    );

    test('kaynak yok → noVerifiedSource ve kaynak künyesi yok', () async {
      final response = await askReal('Blockchain teknolojisi nedir?');
      expect(response.answerType, AssistantAnswerType.noVerifiedSource);
      expect(response.sourceReferences, isEmpty);
    });
  });

  group('§5b — her kanonik durum ekranda ayrı ve açık gösterilir', () {
    Future<void> show(WidgetTester tester, AssistantResponse response) async {
      await pump(tester, repository: _CannedAssistantRepository(response));
      await ask(tester, 'Soru');
      await tester.pumpAndSettle();
    }

    testWidgets('resmî fetva gerekir: kendi rozeti + güvenli sonraki adım', (
      tester,
    ) async {
      await show(
        tester,
        const AssistantResponse(
          answerType: AssistantAnswerType.officialFatwaRequired,
          confidence: AssistantConfidence.insufficient,
          answer: 'Kesin hüküm vermem doğru olmaz.',
          shortSummary: 'Kesin hüküm vermem doğru olmaz.',
          shouldOfferOfficialGuidance: true,
          officialGuidanceUrl: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
        ),
      );

      expect(find.text(l10n.assistantBadgeOfficialFatwa), findsOneWidget);
      expect(find.text(l10n.assistantNextStepGuidance), findsOneWidget);
      expect(find.text(l10n.assistantOfficialGuidanceCta), findsOneWidget);
      // Yeni bir hüküm ya da "doğrulanmış cevap" iddiası yok.
      expect(find.text(l10n.assistantBadgeVerified), findsNothing);
      expect(find.text(l10n.assistantSummaryTitle), findsNothing);
    });

    testWidgets('kişisel durum: yetkiliye danışın rozeti, fetva rozeti değil', (
      tester,
    ) async {
      await show(
        tester,
        const AssistantResponse(
          answerType: AssistantAnswerType.qualifiedGuidanceRequired,
          confidence: AssistantConfidence.insufficient,
          answer: 'Kişisel durum için yetkiliye danışın.',
          shortSummary: 'Kişisel durum için yetkiliye danışın.',
          shouldOfferOfficialGuidance: true,
          officialGuidanceUrl: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
        ),
      );

      expect(find.text(l10n.assistantBadgeGuidance), findsOneWidget);
      expect(find.text(l10n.assistantBadgeOfficialFatwa), findsNothing);
      expect(find.text(l10n.assistantNextStepGuidance), findsOneWidget);
    });

    testWidgets('ibadet kuralı: genel bilgi + hüküm uygulanmaz notu görünür', (
      tester,
    ) async {
      await show(
        tester,
        AssistantResponse(
          answerType: AssistantAnswerType.generalSourceSummary,
          confidence: AssistantConfidence.strong,
          answer: 'İlmihalden genel bilgi.',
          shortSummary: 'İlmihalden genel bilgi.',
          safetyNotice: l10n.assistantGeneralInfoNotRuling,
          sourceReferences: const [_source],
        ),
      );

      expect(find.text(l10n.assistantBadgeGeneral), findsOneWidget);
      expect(find.text(l10n.assistantGeneralInfoNotRuling), findsOneWidget);
      expect(find.text(l10n.assistantSourcesTitle), findsOneWidget);
      // Genel bilgi bir reddetme değildir: yönlendirme metni eklenmez.
      expect(find.text(l10n.assistantNextStepGuidance), findsNothing);
    });

    testWidgets('kaynak yok: kaynaksız rozeti + ne yapılabileceği', (
      tester,
    ) async {
      await show(
        tester,
        AssistantResponse(
          answerType: AssistantAnswerType.noVerifiedSource,
          confidence: AssistantConfidence.insufficient,
          answer: l10n.assistantNoVerifiedSource,
          shortSummary: l10n.assistantNoVerifiedSource,
        ),
      );

      expect(find.text(l10n.assistantBadgeNoSource), findsOneWidget);
      expect(find.text(l10n.assistantNextStepNoSource), findsOneWidget);
      expect(find.text(l10n.assistantSourcesTitle), findsNothing);
      // Belirsizlik gizlenmez: kaynaksızlık metni AYNEN gösterilir.
      expect(find.text(l10n.assistantNoVerifiedSource), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------
  // §6 — Geçmiş
  // ---------------------------------------------------------------------

  group('§6 — geçmiş', () {
    AssistantMessage user(String id, String text, DateTime at) =>
        AssistantMessage(
          id: id,
          role: AssistantRole.user,
          text: text,
          createdAt: at,
        );

    AssistantMessage assistant(String id, String text, DateTime at) =>
        AssistantMessage(
          id: id,
          role: AssistantRole.assistant,
          text: text,
          createdAt: at,
          answerType: AssistantAnswerType.definition,
          sources: const [_source],
        );

    testWidgets('izinli geçmiş okunur biçimde, tarih ve saatiyle çizilir', (
      tester,
    ) async {
      final day = DateTime(2026, 7, 30, 14, 5);
      await pump(
        tester,
        history: _FakeHistoryRepository(
          initial: [
            user('u1', 'Teyemmüm nedir?', day),
            assistant(
              'a1',
              'Teyemmüm, su bulunmadığında yapılan temizliktir.',
              day,
            ),
          ],
        ),
      );

      expect(find.text('Teyemmüm nedir?'), findsOneWidget);
      expect(
        find.text('Teyemmüm, su bulunmadığında yapılan temizliktir.'),
        findsOneWidget,
      );
      // İniş ekranı değil, konuşma gösterilir.
      expect(find.text(l10n.assistantSuggestedTitle), findsNothing);

      final material = MaterialLocalizations.of(
        tester.element(find.byType(TextField)),
      );
      expect(find.text(material.formatMediumDate(day)), findsOneWidget);
      expect(
        find.text(material.formatTimeOfDay(TimeOfDay.fromDateTime(day))),
        findsWidgets,
      );
    });

    testWidgets('geçmişteki kaynak satırı Learn makalesine götürür', (
      tester,
    ) async {
      final day = DateTime(2026, 7, 30, 14, 5);
      await pump(
        tester,
        history: _FakeHistoryRepository(
          initial: [
            user('u1', 'Teyemmüm nedir?', day),
            assistant('a1', 'Kaynaklı açıklama.', day),
          ],
        ),
      );

      await tester.tap(find.text(l10n.assistantReadInLearn));
      await tester.pumpAndSettle();
      expect(find.text('learn-article:abdest-nasil-alinir'), findsOneWidget);
    });

    testWidgets('hassas geçmiş kaydı ekranda GÖSTERİLMEZ', (tester) async {
      const sensitive = 'Bu davranış caiz midir?';
      // Örnek metnin gerçekten hassas sınıfa düştüğü testin kendisinde
      // doğrulanır — aksi hâlde test anlamsız olurdu.
      expect(
        AssistantQueryClassifier.isSensitiveVerdict(
          AssistantQueryClassifier.classify(sensitive),
        ),
        isTrue,
      );

      final day = DateTime(2026, 7, 30, 14, 5);
      final stored = json.encode([
        {
          'id': 'u1',
          'role': 'user',
          'text': sensitive,
          'createdAt': day.toUtc().toIso8601String(),
        },
        {
          'id': 'a1',
          'role': 'assistant',
          'text': 'Hassas cevap.',
          'createdAt': day.toUtc().toIso8601String(),
        },
      ]);

      await pump(
        tester,
        repository: _CannedAssistantRepository(_grounded()),
        initialPrefs: {'bismillah.assistant_history': stored},
      );

      expect(find.text(sensitive), findsNothing);
      expect(find.text('Hassas cevap.'), findsNothing);
      // Gerçek geçmiş boş kaldığı için iniş ekranı görünür.
      expect(find.text(l10n.assistantSuggestedTitle), findsOneWidget);
    });

    testWidgets('hassas soru diske YAZILMAZ', (tester) async {
      await pump(
        tester,
        repository: _CannedAssistantRepository(
          const AssistantResponse(
            answerType: AssistantAnswerType.officialFatwaRequired,
            confidence: AssistantConfidence.insufficient,
            answer: 'Kesin hüküm vermem doğru olmaz.',
            shortSummary: 'Kesin hüküm vermem doğru olmaz.',
          ),
        ),
      );

      await ask(tester, 'Bu davranış caiz midir?');
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('bismillah.assistant_history') ?? '[]';
      expect(raw, isNot(contains('caiz')));
      expect(json.decode(raw), isEmpty);
    });

    testWidgets('temizleme onay ister; iptal edilirse hiçbir şey silinmez', (
      tester,
    ) async {
      final history = _FakeHistoryRepository(
        initial: [user('u1', 'Teyemmüm nedir?', DateTime(2026, 7, 30, 14))],
      );
      await pump(tester, history: history);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      expect(find.text(l10n.assistantClearConfirmTitle), findsOneWidget);

      await tester.tap(find.text(l10n.commonCancel));
      await tester.pumpAndSettle();

      expect(history.clearCalls, 0);
      expect(find.text('Teyemmüm nedir?'), findsOneWidget);
    });

    testWidgets('temizleme başarılı: iniş ekranı + onay mesajı', (
      tester,
    ) async {
      final history = _FakeHistoryRepository(
        initial: [user('u1', 'Teyemmüm nedir?', DateTime(2026, 7, 30, 14))],
      );
      await pump(tester, history: history);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.assistantClearConfirm));
      await tester.pumpAndSettle();

      expect(history.clearCalls, 1);
      expect(find.text(l10n.assistantSuggestedTitle), findsOneWidget);
      expect(find.text(l10n.assistantCleared), findsOneWidget);
      expect(find.text(l10n.assistantClearFailed), findsNothing);
    });

    testWidgets('temizleme başarısız: YANLIŞ başarı mesajı gösterilmez', (
      tester,
    ) async {
      final history = _FakeHistoryRepository(
        initial: [user('u1', 'Teyemmüm nedir?', DateTime(2026, 7, 30, 14))],
        clearSucceeds: false,
      );
      await pump(tester, history: history);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.assistantClearConfirm));
      await tester.pumpAndSettle();

      expect(find.text(l10n.assistantCleared), findsNothing);
      expect(find.text(l10n.assistantClearFailed), findsOneWidget);
      // Geçmiş ekranda DURUR — silindiği izlenimi verilmez.
      expect(find.text('Teyemmüm nedir?'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------
  // §7 — Görsel ve erişilebilirlik
  // ---------------------------------------------------------------------

  group('§7 — görsel ve erişilebilirlik', () {
    for (final locale in SupportedLocale.values) {
      testWidgets(
        '${locale.name}: 360px + 1.5 ölçek + klavye açıkken taşma yok',
        (tester) async {
          await pump(
            tester,
            locale: locale,
            repository: _CannedAssistantRepository(_grounded()),
            size: const Size(360 * 3, 720 * 3),
            textScale: 1.5,
            keyboardInset: 320,
          );

          await ask(tester, 'Abdest');
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          // Klavye açıkken bile giriş alanı ekranda kalır.
          expect(find.byType(TextField), findsOneWidget);
        },
      );
    }

    testWidgets('Arapça: sayfa RTL, latin kaynak künyesi LTR kalır', (
      tester,
    ) async {
      await pump(
        tester,
        locale: SupportedLocale.ar,
        repository: _CannedAssistantRepository(_grounded()),
      );
      await ask(tester, 'الوضوء');
      await tester.pumpAndSettle();

      expect(
        Directionality.of(tester.element(find.byType(TextField))),
        TextDirection.rtl,
      );
      // Latin künye kendi yönünde (LTR) yazılır.
      expect(
        Directionality.of(tester.element(find.text(_source.title))),
        TextDirection.ltr,
      );
    });

    testWidgets('reduced-motion: dönen gösterge yerine sabit işaret', (
      tester,
    ) async {
      final holding = _HoldingAssistantRepository();
      await pump(tester, repository: holding, reducedMotion: true);

      await ask(tester, 'Teyemmüm nedir?');
      await tester.pump();

      expect(find.text(l10n.assistantThinking), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);

      holding.completers.first.complete(_grounded());
      await tester.pumpAndSettle();
    });
  });

  // ---------------------------------------------------------------------
  // §8 — TR/EN/AR anahtar eşitliği
  // ---------------------------------------------------------------------

  group('§8 — yerelleştirme paritesi', () {
    // `_t()` eksik anahtarda İngilizceye düşer; bu yüzden gerçek koruma
    // TR/EN/AR değerlerinin FARKLI olmasıdır (TASK 094 §D ile aynı yöntem).
    const keys = <String Function(AppLocalizations)>[
      _landingCanTitle,
      _landingCan1,
      _landingCan2,
      _landingCan3,
      _landingLimitTitle,
      _landingLocalOnly,
      _badgeOfficialFatwa,
      _nextStepGuidance,
      _nextStepNoSource,
      _sourceLinkUnavailable,
      _retrievalFailedTitle,
      _retrievalFailedBody,
      _retry,
      _clearFailed,
    ];

    test('yeni metinler üç dilde de gerçekten yerelleştirilmiştir', () {
      const tr = AppLocalizations(SupportedLocale.tr);
      const en = AppLocalizations(SupportedLocale.en);
      const ar = AppLocalizations(SupportedLocale.ar);
      final arabic = RegExp(r'[؀-ۿ]');

      for (final key in keys) {
        expect(key(tr).trim(), isNotEmpty);
        expect(key(en).trim(), isNotEmpty);
        expect(key(ar).trim(), isNotEmpty);
        expect(key(tr), isNot(key(en)));
        expect(key(ar), isNot(key(en)));
        expect(key(ar), matches(arabic));
      }
    });

    test('Arapça örnek soru da yerelleştirilmiştir', () {
      const ar = AppLocalizations(SupportedLocale.ar);
      const en = AppLocalizations(SupportedLocale.en);
      expect(ar.assistantSuggested4, isNot(en.assistantSuggested4));
      expect(ar.assistantSuggested4, matches(RegExp(r'[؀-ۿ]')));
    });
  });
}

String _landingCanTitle(AppLocalizations l) => l.assistantLandingCanTitle;
String _landingCan1(AppLocalizations l) => l.assistantLandingCan1;
String _landingCan2(AppLocalizations l) => l.assistantLandingCan2;
String _landingCan3(AppLocalizations l) => l.assistantLandingCan3;
String _landingLimitTitle(AppLocalizations l) => l.assistantLandingLimitTitle;
String _landingLocalOnly(AppLocalizations l) => l.assistantLandingLocalOnly;
String _badgeOfficialFatwa(AppLocalizations l) => l.assistantBadgeOfficialFatwa;
String _nextStepGuidance(AppLocalizations l) => l.assistantNextStepGuidance;
String _nextStepNoSource(AppLocalizations l) => l.assistantNextStepNoSource;
String _sourceLinkUnavailable(AppLocalizations l) =>
    l.assistantSourceLinkUnavailable;
String _retrievalFailedTitle(AppLocalizations l) =>
    l.assistantRetrievalFailedTitle;
String _retrievalFailedBody(AppLocalizations l) =>
    l.assistantRetrievalFailedBody;
String _retry(AppLocalizations l) => l.assistantRetry;
String _clearFailed(AppLocalizations l) => l.assistantClearFailed;
