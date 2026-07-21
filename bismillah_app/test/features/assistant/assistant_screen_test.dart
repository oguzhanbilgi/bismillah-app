import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_source_reference.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/bismillah_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/assistant/presentation/assistant_screen.dart';
import 'package:bismillah_app/features/learn/application/learn_providers.dart';
import 'package:bismillah_app/features/learn/domain/services/external_link_service.dart';
import 'package:bismillah_app/features/learn/domain/value_objects/knowledge_enums.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bismillah Asistanı ekranı (TASK 059 §11/§17).
///
/// UI davranışı izole edilir: asistan deposu SAHTE canned cevaplarla
/// override edilir (asset I/O yok → deterministik). Gerçek retrieval/güvenlik
/// ayrı `assistant_repository_test.dart`'ta doğrulanır. GERÇEK tarayıcı/ağ/AI
/// YOKTUR.
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

const _related = AssistantRelatedArticle(
  id: 'art-abdest-nasil-alinir',
  slug: 'abdest-nasil-alinir',
  title: 'Abdest nasıl alınır?',
);

class _FakeAssistantRepository implements BismillahAssistantRepository {
  @override
  Future<AssistantResponse> answer(AssistantQuery query) async {
    final t = query.text.toLowerCase();
    if (t.contains('caiz')) {
      return const AssistantResponse(
        answerType: AssistantAnswerType.officialFatwaRequired,
        confidence: AssistantConfidence.insufficient,
        answer: 'Kesin hüküm vermem doğru olmaz.',
        shortSummary: 'Kesin hüküm vermem doğru olmaz.',
        shouldOfferOfficialGuidance: true,
        officialGuidanceUrl: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
        relatedArticles: [_related],
      );
    }
    if (t.contains('durumum') || t.contains('ben ')) {
      return const AssistantResponse(
        answerType: AssistantAnswerType.qualifiedGuidanceRequired,
        confidence: AssistantConfidence.insufficient,
        answer: 'Kişisel durum için yetkiliye danışın.',
        shortSummary: 'Kişisel durum için yetkiliye danışın.',
        safetyNotice: 'Bu genel bilgidir; kişisel duruma hüküm uygulamaz.',
        shouldOfferOfficialGuidance: true,
        officialGuidanceUrl: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
        relatedArticles: [_related],
      );
    }
    if (t.contains('blockchain')) {
      return const AssistantResponse(
        answerType: AssistantAnswerType.noVerifiedSource,
        confidence: AssistantConfidence.insufficient,
        answer: 'Doğrulanmış kaynak yok.',
        shortSummary: 'Doğrulanmış kaynak yok.',
        relatedArticles: [_related],
      );
    }
    if (t.contains('abdest')) {
      return const AssistantResponse(
        answerType: AssistantAnswerType.stepByStepGuide,
        confidence: AssistantConfidence.exact,
        answer: 'Abdest sırayla alınır.',
        shortSummary: 'Abdest sırayla alınır.',
        steps: ['Niyet et ve besmele çek.', 'Elleri yıka.'],
        keyPoints: ['Sıra önemlidir.'],
        practicalAction: 'Namazdan önce abdest al.',
        sourceReferences: [_source],
        relatedArticles: [_related],
      );
    }
    return const AssistantResponse(
      answerType: AssistantAnswerType.definition,
      confidence: AssistantConfidence.exact,
      answer: 'Teyemmüm, su bulunmadığında yapılan temizliktir.',
      shortSummary: 'Teyemmüm nedir?',
      sourceReferences: [_source],
      relatedArticles: [_related],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    ExternalLinkService? linkService,
    BismillahAssistantRepository? repository,
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
  }) async {
    SharedPreferences.setMockInitialValues({});
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
          bismillahAssistantRepositoryProvider.overrideWithValue(
            repository ?? _FakeAssistantRepository(),
          ),
          if (linkService != null)
            externalLinkServiceProvider.overrideWithValue(linkService),
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
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  const l10n = AppLocalizations(SupportedLocale.tr);

  group('Boş durum', () {
    testWidgets('başlık, uyarı ve önerilen sorular', (tester) async {
      await pump(tester);

      expect(find.text(l10n.assistantIntroBody), findsOneWidget);
      expect(find.text(l10n.assistantNotMuftiNotice), findsOneWidget);
      expect(find.text(l10n.assistantSuggested1), findsOneWidget);
      expect(find.text(l10n.assistantSuggested3), findsOneWidget);
    });
  });

  group('Sohbet', () {
    testWidgets('önerilen soru gönderilir; adımlı cevap + kaynak kartı', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      expect(find.text(l10n.assistantStepsTitle), findsOneWidget);
      expect(find.text(l10n.assistantSourcesTitle), findsOneWidget);
      expect(find.textContaining('Diyanet'), findsWidgets);
      expect(find.text(l10n.learnOpenOfficialPage), findsWidgets);
      expect(find.text(l10n.assistantReadInLearn), findsWidgets);
    });

    testWidgets('yazıp gönderince input temizlenir + cevap gelir', (
      tester,
    ) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'Teyemmüm nedir?');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text(l10n.assistantBadgeGeneral), findsWidgets);
    });

    testWidgets('boş mesajda gönder butonu kilitli', (tester) async {
      await pump(tester);
      final sendButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.send_rounded),
          matching: find.byType(IconButton),
        ),
      );
      expect(sendButton.onPressed, isNull);
    });

    testWidgets('kaynağı olmayan soru → doğrulanmış kaynak yok durumu', (
      tester,
    ) async {
      await pump(tester);

      await tester.enterText(
        find.byType(TextField),
        'Blockchain teknolojisi nedir?',
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text(l10n.assistantBadgeNoSource), findsOneWidget);
      expect(find.text(l10n.assistantSourcesTitle), findsNothing);
    });

    testWidgets('hüküm sorusu → yetkiliye danışın + resmî yönlendirme', (
      tester,
    ) async {
      await pump(tester);

      await tester.enterText(find.byType(TextField), 'Bu davranış caiz midir?');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text(l10n.assistantBadgeGuidance), findsOneWidget);
      expect(find.text(l10n.assistantOfficialGuidanceCta), findsOneWidget);
    });
  });

  group('Resmî kaynak açma', () {
    testWidgets('başarısızsa adres panoya kopyalanır + snackbar', (
      tester,
    ) async {
      final clipboard = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pump(tester, linkService: _FakeLinkService(succeeds: false));
      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.learnOpenOfficialPage).first);
      await tester.pumpAndSettle();

      expect(clipboard, contains('https://kuran.diyanet.gov.tr/'));
      expect(find.text(l10n.sourcesOpenFailed), findsOneWidget);
    });

    testWidgets('başarılıysa kopya fallback göstermez', (tester) async {
      final service = _FakeLinkService(succeeds: true);
      await pump(tester, linkService: service);
      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.learnOpenOfficialPage).first);
      await tester.pumpAndSettle();

      expect(service.calls, isNotEmpty);
      expect(find.text(l10n.sourcesOpenFailed), findsNothing);
    });
  });

  group('Learn navigasyonu', () {
    testWidgets('"Learn\'de oku" ilgili makaleye gider', (tester) async {
      await pump(tester);
      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.assistantReadInLearn).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('learn-article:'), findsOneWidget);
    });
  });

  group('Konuşmayı temizle', () {
    testWidgets('onay sonrası empty state döner', (tester) async {
      await pump(tester);
      await tester.tap(find.text(l10n.assistantSuggested3));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.assistantClearConfirm));
      await tester.pumpAndSettle();

      expect(find.text(l10n.assistantSuggestedTitle), findsOneWidget);
    });
  });

  group('Erişilebilirlik / RTL / taşma', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        await pump(
          tester,
          locale: locale,
          size: const Size(320 * 3, 720 * 3),
          textScale: 1.5,
        );
        // Bir soru gönder + kartı da 320px'de doğrula.
        await tester.tap(
          find.text(AppLocalizations(locale).assistantSuggested1),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('Arapça RTL yönü', (tester) async {
      await pump(tester, locale: SupportedLocale.ar);
      expect(
        Directionality.of(tester.element(find.byType(TextField))),
        TextDirection.rtl,
      );
    });
  });

  // -- TASK 060 cilası -------------------------------------------------------

  group('Empty state hiyerarşisi', () {
    testWidgets('başlık, uyarı ve en az 3 önerilen soru görünür', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text(l10n.assistantSuggestedTitle), findsOneWidget);
      // 5 öneri kayıtlı; ilk viewport'ta en az 3'ü görünür olmalı.
      var visible = 0;
      for (final q in [
        l10n.assistantSuggested1,
        l10n.assistantSuggested2,
        l10n.assistantSuggested3,
        l10n.assistantSuggested4,
        l10n.assistantSuggested5,
      ]) {
        if (find.text(q).evaluate().isNotEmpty) {
          visible++;
        }
      }
      expect(visible, greaterThanOrEqualTo(3));
    });
  });

  group('Composer', () {
    testWidgets('input en fazla 5 satıra genişler', (tester) async {
      await pump(tester);
      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 5);
    });
  });

  group('Loading', () {
    testWidgets('gönderimde input kilitli + loading semantics', (tester) async {
      final holding = _HoldingAssistantRepository();
      await pump(tester, repository: holding);

      await tester.enterText(find.byType(TextField), 'Teyemmüm nedir?');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      // Loading durumu görünür + input devre dışı.
      expect(find.text(l10n.assistantThinking), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      // Loading satırı ekran okuyucuya canlı bölge (liveRegion) + etiketle
      // bildirilir.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.liveRegion ?? false) &&
              w.properties.label == l10n.assistantThinking,
        ),
        findsOneWidget,
      );

      // Cevap gelince loading yerini cevaba bırakır.
      holding.completer.complete(
        const AssistantResponse(
          answerType: AssistantAnswerType.definition,
          confidence: AssistantConfidence.exact,
          answer: 'Teyemmüm açıklaması.',
          shortSummary: 'Teyemmüm.',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.assistantThinking), findsNothing);
    });
  });

  group('Cevap hiyerarşisi', () {
    testWidgets('bölümler ayrı görünür + adımlar numaralı', (tester) async {
      await pump(tester);
      await tester.tap(find.text(l10n.assistantSuggested1)); // abdest
      await tester.pumpAndSettle();

      expect(find.text(l10n.assistantSummaryTitle), findsOneWidget);
      expect(find.text(l10n.assistantStepsTitle), findsOneWidget);
      expect(find.text(l10n.assistantKeyPointsTitle), findsOneWidget);
      expect(find.text(l10n.assistantPracticalTitle), findsOneWidget);
      expect(find.text(l10n.assistantSourcesTitle), findsOneWidget);
      expect(find.text(l10n.assistantRelatedTitle), findsOneWidget);
      // Numaralı adımlar.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('kaynak kartı: resmî etiket, locator ve son doğrulama', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(l10n.assistantOfficialSourceTag),
        findsWidgets,
      );
      expect(find.textContaining('V. ABDEST, s. 105-107'), findsOneWidget);
      expect(find.textContaining('2026-07-19'), findsOneWidget);
    });
  });

  group('Kişisel durum görünümü', () {
    testWidgets('qualifiedGuidance rozeti + güvenlik notu + yönlendirme', (
      tester,
    ) async {
      await pump(tester);
      await tester.enterText(find.byType(TextField), 'Benim durumum ne olur?');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text(l10n.assistantBadgeGuidance), findsOneWidget);
      expect(find.text(l10n.assistantOfficialGuidanceCta), findsOneWidget);
      expect(
        find.textContaining('kişisel duruma hüküm uygulamaz'),
        findsOneWidget,
      );
    });
  });

  group('Scroll davranışı', () {
    testWidgets('yeni cevap gelince otomatik aşağı kaydırır', (tester) async {
      // Kısa viewport: içerik taşsın.
      await pump(tester, size: const Size(360, 560));
      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      final position = tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position;
      expect(position.pixels, greaterThan(0));
    });

    testWidgets('kullanıcı yukarı kaydırınca zorla aşağı çekilmez', (
      tester,
    ) async {
      await pump(tester, size: const Size(360, 560));
      await tester.tap(find.text(l10n.assistantSuggested1));
      await tester.pumpAndSettle();

      final state = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      state.position.jumpTo(0);
      await tester.pump();
      // Yeni mesaj yokken konum korunur.
      expect(state.position.pixels, 0);
    });
  });
}

/// Cevabı elde tutan sahte depo — loading durumunu deterministik test eder.
class _HoldingAssistantRepository implements BismillahAssistantRepository {
  final Completer<AssistantResponse> completer = Completer();

  @override
  Future<AssistantResponse> answer(AssistantQuery query) => completer.future;
}

class _FakeLinkService implements ExternalLinkService {
  _FakeLinkService({required this.succeeds});
  final bool succeeds;
  final List<String> calls = [];

  @override
  Future<bool> openOfficialSource(String url) async {
    calls.add(url);
    return succeeds;
  }
}
