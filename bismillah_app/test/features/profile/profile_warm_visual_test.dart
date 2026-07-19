import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/profile/presentation/profile_placeholder_screen.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile sıcak dönüşümü (TASK 055): tonal ayar grubu, dil satırı ve
/// mevcut route'ların korunması.
void main() {
  Future<GoRouter> pumpProfile(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
  }) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // Gerçek push davranışını doğrulamak için minimal router: profil kökü
    // + iki ayar route'u (ekran GoRouter.push kullanır).
    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfilePlaceholderScreen(),
        ),
        GoRoute(
          path: AppRoutes.languageSettings,
          builder: (context, state) =>
              const Scaffold(body: Text('language-route')),
        ),
        GoRoute(
          path: AppRoutes.subscriptionSettings,
          builder: (context, state) =>
              const Scaffold(body: Text('subscription-route')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appLocaleAtLaunchProvider.overrideWithValue(locale)],
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
    return router;
  }

  group('Ayar grubu', () {
    testWidgets('SettingsSection dil ve abonelik satırlarıyla render eder', (
      tester,
    ) async {
      await pumpProfile(tester);

      expect(find.byType(SettingsSection), findsOneWidget);
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Uygulama dili'), findsOneWidget);
      // Seçili dil KENDİ adıyla görünür.
      expect(find.text('Türkçe'), findsOneWidget);
    });

    testWidgets('dil satırı language settings route\'unu açar', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.text('Uygulama dili'));
      await tester.pumpAndSettle();

      expect(find.text('language-route'), findsOneWidget);
    });

    testWidgets('abonelik satırı mevcut route\'u açar', (tester) async {
      await pumpProfile(tester);

      const l10n = AppLocalizations(SupportedLocale.tr);
      await tester.tap(find.text(l10n.subscriptionSettingsTitle));
      await tester.pumpAndSettle();

      expect(find.text('subscription-route'), findsOneWidget);
    });

    testWidgets('satırlar ekran okuyucuya buton + etiket bildirir', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpProfile(tester);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Uygulama dili, Türkçe')),
        matchesSemantics(
          label: 'Uygulama dili, Türkçe',
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      handle.dispose();
    });
  });

  group('Yerelleştirme ve RTL', () {
    testWidgets('İngilizce locale ayar başlıklarını çevirir', (tester) async {
      await pumpProfile(tester, locale: SupportedLocale.en);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('Arapça locale RTL olur; dil adı kendi yönünde', (
      tester,
    ) async {
      await pumpProfile(tester, locale: SupportedLocale.ar);

      expect(find.text('الإعدادات'), findsOneWidget);
      expect(find.text('لغة التطبيق'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('الإعدادات'))),
        TextDirection.rtl,
      );
    });
  });

  group('Taşma güvenliği', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        await pumpProfile(
          tester,
          locale: locale,
          size: const Size(320 * 3, 720 * 3),
          textScale: 1.5,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
