import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/profile/presentation/privacy_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_database.dart';

/// Gizlilik & veri ekranı + sıfırlama akışı (TASK 058 §6/§7).
///
/// Learn-only sıfırlama yalnız Learn verisini siler; tam sıfırlama iki
/// onay olmadan çalışmaz, dil korunur ve uygulama onboarding'e döner.
/// GERÇEK kullanıcı verisiyle çalışılmaz — SharedPreferences mock'lanır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const l10n = AppLocalizations(SupportedLocale.tr);

  Map<String, Object> seed() => {
    'bismillah.app_locale': 'tr',
    'bismillah.learn_bookmarked_ids': ['art-a'],
    'bismillah.learn_completed_ids': ['art-b'],
    'bismillah.quran_translation': 'turkish',
    'bismillah.onboarding_completed': true,
  };

  Future<SharedPreferences> pump(
    WidgetTester tester, {
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
  }) async {
    SharedPreferences.setMockInitialValues(seed());
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.profilePrivacy,
      routes: [
        GoRoute(
          path: AppRoutes.profilePrivacy,
          builder: (context, state) => const PrivacyDataScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboardingWelcome,
          builder: (context, state) =>
              const Scaffold(body: Text('onboarding-welcome')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [inMemoryAppDatabaseOverride()],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          locale: SupportedLocale.tr.locale,
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
    return prefs;
  }

  testWidgets('yerel/hesaplanan/ağ bölümlerini ve notu gösterir', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text(l10n.privacyLocalTitle), findsOneWidget);
    expect(find.text(l10n.privacyComputedTitle), findsOneWidget);
    expect(find.text(l10n.privacyNetworkTitle), findsOneWidget);
    expect(find.text(l10n.privacyNote), findsOneWidget);
  });

  testWidgets('Learn-only sıfırlama yalnız Learn verisini siler', (
    tester,
  ) async {
    final prefs = await pump(tester);

    await tester.tap(find.text(l10n.resetLearningTitle));
    await tester.pumpAndSettle();
    // Onay diyaloğu — "Öğrenme verilerini sıfırla" onay düğmesi.
    await tester.tap(find.text(l10n.resetLearningTitle).last);
    await tester.pumpAndSettle();

    await prefs.reload();
    // Learn verisi gitti.
    expect(prefs.get('bismillah.learn_bookmarked_ids'), isNull);
    expect(prefs.get('bismillah.learn_completed_ids'), isNull);
    // Diğer veriler korunur.
    expect(prefs.get('bismillah.quran_translation'), 'turkish');
    expect(prefs.get('bismillah.onboarding_completed'), true);
    expect(prefs.get('bismillah.app_locale'), 'tr');
    expect(find.text(l10n.resetLearningDone), findsOneWidget);
  });

  testWidgets('tam sıfırlama TEK onayla çalışmaz (ikinci adımda iptal)', (
    tester,
  ) async {
    final prefs = await pump(tester);

    await tester.tap(find.text(l10n.resetAllTitle));
    await tester.pumpAndSettle();
    // Aşama 1: devam et.
    await tester.tap(find.text(l10n.resetAllStep1Continue));
    await tester.pumpAndSettle();
    // Aşama 2: iptal — hiçbir veri silinmemeli.
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pumpAndSettle();

    await prefs.reload();
    expect(prefs.get('bismillah.quran_translation'), 'turkish');
    expect(prefs.get('bismillah.onboarding_completed'), true);
    expect(prefs.get('bismillah.learn_bookmarked_ids'), ['art-a']);
    // Onboarding'e YÖNLENDİRİLMEDİ.
    expect(find.text('onboarding-welcome'), findsNothing);
  });

  testWidgets(
    'tam sıfırlama iki onayla dili koruyup diğer veriyi siler + onboarding',
    (tester) async {
      final prefs = await pump(tester);

      await tester.tap(find.text(l10n.resetAllTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.resetAllStep1Continue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.resetAllConfirm));
      await tester.pumpAndSettle();

      await prefs.reload();
      // Dil korunur, geri kalan silinir.
      expect(prefs.get('bismillah.app_locale'), 'tr');
      expect(prefs.get('bismillah.quran_translation'), isNull);
      expect(prefs.get('bismillah.onboarding_completed'), isNull);
      expect(prefs.get('bismillah.learn_bookmarked_ids'), isNull);
      // Onboarding'e güvenli dönüş.
      expect(find.text('onboarding-welcome'), findsOneWidget);
    },
  );

  group('Yerelleştirme ve taşma', () {
    for (final size in [
      const Size(1080, 2400),
      const Size(320 * 3, 1200 * 3),
    ]) {
      testWidgets('${size.width ~/ 3}px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        await pump(tester, size: size, textScale: 1.5);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
