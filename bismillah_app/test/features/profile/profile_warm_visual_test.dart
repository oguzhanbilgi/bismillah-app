import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/profile/presentation/profile_screen.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/shared/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile ayar/veri merkezi (TASK 058): bölümler render eder, Namaz/Kur'an/
/// Öğren kısayolları doğru route'a gider, premium/abonelik satırı
/// GÖSTERİLMEZ, tüm satırlar gerçek bir hedefe gider.
void main() {
  Widget marker(String label) => Scaffold(body: Text(label));

  Future<void> pumpProfile(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
  }) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.profile,
      routes: [
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.languageSettings,
          builder: (context, state) => marker('language-route'),
        ),
        GoRoute(
          path: AppRoutes.prayer,
          builder: (context, state) => marker('prayer-route'),
        ),
        GoRoute(
          path: AppRoutes.prayerHistory,
          builder: (context, state) => marker('prayer-history-route'),
        ),
        GoRoute(
          path: AppRoutes.quran,
          builder: (context, state) => marker('quran-route'),
        ),
        GoRoute(
          path: AppRoutes.quranBookmarks,
          builder: (context, state) => marker('quran-bookmarks-route'),
        ),
        GoRoute(
          path: AppRoutes.learn,
          builder: (context, state) => marker('learn-route'),
        ),
        GoRoute(
          path: AppRoutes.profilePrivacy,
          builder: (context, state) => marker('privacy-route'),
        ),
        GoRoute(
          path: AppRoutes.profileSources,
          builder: (context, state) => marker('sources-route'),
        ),
        GoRoute(
          path: AppRoutes.profileAbout,
          builder: (context, state) => marker('about-route'),
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
  }

  group('Bölüm yapısı', () {
    testWidgets('Uygulama/Namaz/Kur\'an/Öğren/Destek bölümleri render eder', (
      tester,
    ) async {
      await pumpProfile(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);

      expect(find.byType(SettingsSection), findsNWidgets(5));
      expect(find.text(l10n.profileAppSection), findsOneWidget);
      expect(find.text(l10n.profilePrayerSection), findsOneWidget);
      expect(find.text(l10n.profileQuranSection), findsOneWidget);
      expect(find.text(l10n.profileLearnSection), findsOneWidget);
      expect(find.text(l10n.profileSupportSection), findsOneWidget);
      // Kişisel yolculuk alanı da görünür.
      expect(find.text(l10n.profileJourneySection), findsOneWidget);
    });

    testWidgets('premium/abonelik satırı GÖSTERİLMEZ', (tester) async {
      await pumpProfile(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);

      expect(find.text(l10n.subscriptionSettingsTitle), findsNothing);
      expect(find.text(l10n.premiumTitle), findsNothing);
    });

    testWidgets('Öğren sayaçları hard-code değil, boş durumda 0', (
      tester,
    ) async {
      await pumpProfile(tester);
      const l10n = AppLocalizations(SupportedLocale.tr);

      expect(find.text(l10n.profileLearnLastReadEmpty), findsOneWidget);
      // Kaydedilen/tamamlanan sayacı boş ilerlemede 0.
      expect(find.text('0'), findsNWidgets(2));
    });
  });

  group('Kısayol yönlendirmeleri', () {
    Future<void> tapAndExpect(
      WidgetTester tester,
      String rowText,
      String route,
    ) async {
      await pumpProfile(tester);
      await tester.tap(find.text(rowText));
      await tester.pumpAndSettle();
      expect(find.text(route), findsOneWidget);
    }

    testWidgets('dil satırı language route açar', (tester) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(tester, l10n.settingsLanguageTitle, 'language-route');
    });

    testWidgets('namaz vakitleri Prayer route açar', (tester) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(tester, l10n.profilePrayerTimesRow, 'prayer-route');
    });

    testWidgets('namaz takibi Prayer history route açar', (tester) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(
        tester,
        l10n.profilePrayerTrackingRow,
        'prayer-history-route',
      );
    });

    testWidgets('Kur\'an tercihleri Quran route açar', (tester) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(
        tester,
        l10n.profileQuranPreferencesRow,
        'quran-route',
      );
    });

    testWidgets('kaydedilen ayetler Quran bookmarks route açar', (
      tester,
    ) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(
        tester,
        l10n.profileQuranSavedRow,
        'quran-bookmarks-route',
      );
    });

    testWidgets('kaydedilen makaleler Learn route açar', (tester) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(tester, l10n.profileLearnSavedRow, 'learn-route');
    });

    testWidgets('gizlilik satırı privacy route açar', (tester) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(
        tester,
        l10n.settingsPrivacyDataTitle,
        'privacy-route',
      );
    });

    testWidgets('hakkında satırı about route açar', (tester) async {
      const l10n = AppLocalizations(SupportedLocale.tr);
      await tapAndExpect(tester, l10n.profileAboutRow, 'about-route');
    });
  });

  group('Erişilebilirlik ve yerelleştirme', () {
    testWidgets('dil satırı ekran okuyucuya buton + etiket bildirir', (
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

    testWidgets('İngilizce bölüm başlıklarını çevirir', (tester) async {
      await pumpProfile(tester, locale: SupportedLocale.en);
      expect(find.text('App'), findsOneWidget);
      expect(find.text('Prayer'), findsOneWidget);
      expect(find.text('Support & app'), findsOneWidget);
    });

    testWidgets('Arapça RTL olur', (tester) async {
      await pumpProfile(tester, locale: SupportedLocale.ar);
      const l10n = AppLocalizations(SupportedLocale.ar);
      expect(find.text(l10n.profileAppSection), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text(l10n.profileAppSection))),
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
