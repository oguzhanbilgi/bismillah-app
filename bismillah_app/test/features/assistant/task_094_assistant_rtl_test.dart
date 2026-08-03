import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/assistant/application/assistant_providers.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_query.dart';
import 'package:bismillah_app/features/assistant/domain/entities/assistant_response.dart';
import 'package:bismillah_app/features/assistant/domain/repositories/bismillah_assistant_repository.dart';
import 'package:bismillah_app/features/assistant/domain/value_objects/assistant_enums.dart';
import 'package:bismillah_app/features/assistant/presentation/assistant_screen.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TASK 094 §D — Asistan yüzeyinin Arapça/RTL doğrulaması.
///
/// En riskli yüzeyler seçildi: soru/cevap düzeni, KAYNAK satırı (Arapça
/// arayüzde LATİN künye), ve reddetme/kaynaksızlık durumları. Testler
/// yalnız "render oldu" demez; YÖN ve HİZA davranışını doğrular.
///
/// Depo sahtedir: gerçek retrieval/asset G/Ç yok → deterministik.
class _FakeAssistantRepository implements BismillahAssistantRepository {
  @override
  Future<AssistantResponse> answer(AssistantQuery query) async {
    final text = query.text.toLowerCase();
    if (text.contains('blockchain')) {
      return const AssistantResponse(
        answerType: AssistantAnswerType.noVerifiedSource,
        confidence: AssistantConfidence.insufficient,
        answer: 'لم أجد مصدراً مُتحقَّقاً منه.',
        shortSummary: 'لم أجد مصدراً مُتحقَّقاً منه.',
      );
    }
    if (text.contains('caiz') || text.contains('يجوز')) {
      return const AssistantResponse(
        answerType: AssistantAnswerType.officialFatwaRequired,
        confidence: AssistantConfidence.insufficient,
        answer: 'لا يصحّ أن أقدّم جواباً قاطعاً.',
        shortSummary: 'لا يصحّ أن أقدّم جواباً قاطعاً.',
        shouldOfferOfficialGuidance: true,
        officialGuidanceUrl: 'https://kurul.diyanet.gov.tr/tr/fetvalar',
      );
    }
    return const AssistantResponse(
      answerType: AssistantAnswerType.definition,
      confidence: AssistantConfidence.exact,
      answer: 'التيمّم طهارة عند فقد الماء.',
      shortSummary: 'ما هو التيمّم؟',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.ar,
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
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(locale),
          bismillahAssistantRepositoryProvider.overrideWithValue(
            _FakeAssistantRepository(),
          ),
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

  Future<void> ask(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    // Gönder düğmesi metin girilene kadar PASİFTİR; araya bir kare
    // gerekmezse dokunuş sessizce hiçbir şey yapmaz.
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
  }

  group('§D — Asistan sayfa yönü', () {
    testWidgets('Arapça locale ekranı RTL yapar', (tester) async {
      await pump(tester);
      expect(
        Directionality.of(tester.element(find.byType(AssistantScreen))),
        TextDirection.rtl,
      );
    });

    testWidgets('Türkçe locale LTR kalır (kontrol)', (tester) async {
      await pump(tester, locale: SupportedLocale.tr);
      expect(
        Directionality.of(tester.element(find.byType(AssistantScreen))),
        TextDirection.ltr,
      );
    });
  });

  group('§D — soru/cevap düzeni RTL', () {
    testWidgets('kullanıcı ve asistan balonları RTL yönü altında çizilir', (
      tester,
    ) async {
      await pump(tester);
      await ask(tester, 'ما هو التيمّم؟');

      final answer = find.text('التيمّم طهارة عند فقد الماء.');
      expect(answer, findsOneWidget);
      expect(Directionality.of(tester.element(answer)), TextDirection.rtl);
    });

    // Aynı balon iki yönde ZIT tarafta durmalıdır. Sabit `right` hizası
    // kullanılsaydı RTL'de de sağda kalırdı; bu iki test birlikte
    // mantıksal (start/end) hizanın kullanıldığını kanıtlar.
    const question = 'ما هو التيمّم؟';

    testWidgets('LTR: kullanıcı balonu SAĞDA (son taraf)', (tester) async {
      await pump(tester, locale: SupportedLocale.tr);
      await ask(tester, question);

      final screenWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(
        tester.getCenter(find.text(question)).dx,
        greaterThan(screenWidth / 2),
      );
    });

    testWidgets('RTL: aynı balon SOLA aynalanır (son taraf)', (tester) async {
      await pump(tester, locale: SupportedLocale.ar);
      await ask(tester, question);

      final screenWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      expect(
        tester.getCenter(find.text(question)).dx,
        lessThan(screenWidth / 2),
        reason: 'RTL kullanıcı balonu aynalanmamış (sabit hiza şüphesi)',
      );
    });
  });

  group('§D — reddetme ve kaynaksızlık durumları RTL', () {
    testWidgets('kaynaksızlık cevabı RTL altında gösterilir', (tester) async {
      await pump(tester);
      await ask(tester, 'blockchain');

      final refusal = find.text('لم أجد مصدراً مُتحقَّقاً منه.');
      expect(refusal, findsOneWidget);
      expect(Directionality.of(tester.element(refusal)), TextDirection.rtl);
    });

    testWidgets('resmî fetva yönlendirmesi RTL altında gösterilir', (
      tester,
    ) async {
      await pump(tester);
      await ask(tester, 'هل يجوز هذا؟');

      final refusal = find.text('لا يصحّ أن أقدّم جواباً قاطعاً.');
      expect(refusal, findsOneWidget);
      expect(Directionality.of(tester.element(refusal)), TextDirection.rtl);
    });
  });

  group('§D — erişilebilirlik: büyük yazı ölçeği', () {
    testWidgets('RTL + 1.5 ölçekte dar ekranda taşma yok', (tester) async {
      await pump(tester, size: const Size(320 * 3, 720 * 3), textScale: 1.5);
      await ask(tester, 'ما هو التيمّم؟');

      expect(tester.takeException(), isNull);
    });
  });
}
