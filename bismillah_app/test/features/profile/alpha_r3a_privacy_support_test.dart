import 'dart:io';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/router/app_routes.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/profile/application/profile_providers.dart';
import 'package:bismillah_app/features/profile/domain/support_contact.dart';
import 'package:bismillah_app/features/profile/presentation/privacy_data_screen.dart';
import 'package:bismillah_app/features/profile/presentation/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_database.dart';

/// ALPHA-R3A — gizlilik politikası yüzeyleri ve destek yolu.
///
/// Bu testler metnin DOĞRU olduğunu değil, DÜRÜST olduğunu kanıtlar:
/// mutlak "hiçbir veri cihazdan çıkmaz" iddiası yoktur, kaldırma/veri
/// temizleme sonucu açıkça yazılıdır, dış yapay zekâ kullanılmadığı
/// söylenir ve Firebase/ağ kullanımı gizlenmez.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tr = AppLocalizations(SupportedLocale.tr);
  const en = AppLocalizations(SupportedLocale.en);
  const ar = AppLocalizations(SupportedLocale.ar);
  const locales = <AppLocalizations>[tr, en, ar];

  // ---------------------------------------------------------------------
  // 1) Kanonik politika dosyası
  // ---------------------------------------------------------------------

  group('canonical policy document', () {
    final file = File('../docs/legal/PRIVACY_POLICY.md');

    test('exists and is tracked at a stable documentation path', () {
      expect(file.existsSync(), isTrue);
    });

    test('carries the single canonical support address', () {
      expect(file.readAsStringSync(), contains(SupportContact.email));
    });

    test('discloses every real network destination', () {
      final text = file.readAsStringSync();
      for (final needle in ['MP3Quran.net', 'Firebase', 'Tanzil', 'QuranEnc']) {
        expect(text, contains(needle), reason: 'missing disclosure: $needle');
      }
    });

    test(
      'states the uninstall / clear-data consequence in all three languages',
      () {
        final text = file.readAsStringSync();
        expect(text, contains('kalıcı olarak silinir'));
        expect(text, contains('permanently deleted'));
        expect(text, contains('نهائيًا'));
      },
    );

    test('makes no absolute or unearned claim', () {
      final text = file.readAsStringSync().toLowerCase();
      const forbidden = <String>[
        'encrypted cloud backup',
        'şifreli bulut yedekleme',
        'no data is collected',
        'hiçbir veri toplanmaz',
        'hiçbir veri toplamıyoruz',
        'account sync is available',
        'diyanet onaylı',
        'approved by diyanet',
      ];
      for (final claim in forbidden) {
        expect(text, isNot(contains(claim)), reason: 'forbidden claim: $claim');
      }
    });
  });

  // ---------------------------------------------------------------------
  // 2) Yerelleştirme — TR/EN/AR eşliği ve dürüst ifade
  // ---------------------------------------------------------------------

  group('policy localization', () {
    List<String> policyStrings(AppLocalizations l) => [
      l.privacyPolicyTitle,
      l.privacyPolicySummaryBody,
      l.privacyPolicyStoredBody,
      l.privacyPolicyAssistantBody,
      l.privacyPolicyCloudBody,
      l.privacyPolicyPermissionsBody,
      l.privacyPolicyNetworkBody,
      l.privacyPolicyNoTrackingBody,
      l.privacyPolicyChildrenBody,
      l.privacyPolicyControlBody,
      l.privacyNoCloudBody,
      l.privacyAssistantOnDevice,
      l.supportContactAction,
      l.supportEmailUnavailable,
    ];

    test('every policy string is present in all three locales', () {
      for (final l in locales) {
        for (final value in policyStrings(l)) {
          expect(value.trim(), isNotEmpty);
        }
      }
    });

    test('locales are genuinely distinct, not an English fallback', () {
      // `_t()` İngilizceye düşer; bu yüzden EŞİTLİK sessiz eksik anahtar
      // demektir ve gerçek regresyon koruması budur.
      for (var i = 0; i < policyStrings(en).length; i++) {
        expect(policyStrings(tr)[i], isNot(policyStrings(en)[i]));
        expect(policyStrings(ar)[i], isNot(policyStrings(en)[i]));
      }
    });

    test('Arabic policy text is written in Arabic script', () {
      final arabic = RegExp(r'[؀-ۿ]');
      for (final value in policyStrings(ar)) {
        expect(arabic.hasMatch(value), isTrue, reason: value);
      }
    });

    test('local-first is stated without an absolute no-network claim', () {
      expect(tr.privacyPolicySummaryBody, contains('anlamına gelmez'));
      expect(en.privacyPolicySummaryBody, contains('does not mean'));
      expect(ar.privacyPolicySummaryBody, contains('لا يعني'));
    });

    test('no cloud backup / account sync is claimed', () {
      expect(tr.privacyPolicyCloudBody, contains('bulut'));
      expect(en.privacyPolicyCloudBody, contains('no active cloud backup'));
      expect(ar.privacyPolicyCloudBody, contains('سحابي'));
    });

    test('uninstall and data clearing are disclosed in the summary card', () {
      expect(tr.privacyNoCloudBody, contains('kaldırırsan'));
      expect(tr.privacyNoCloudBody, contains('temizlersen'));
      expect(en.privacyNoCloudBody, contains('uninstall'));
      expect(en.privacyNoCloudBody, contains('clear'));
      expect(ar.privacyNoCloudBody, contains('أزلت'));
    });

    test('external generative AI is explicitly ruled out', () {
      expect(tr.privacyPolicyAssistantBody, contains('yapay zekâ'));
      expect(en.privacyPolicyAssistantBody, contains('generative-AI'));
      expect(ar.privacyPolicyAssistantBody, contains('ذكاء اصطناعي'));
    });

    test('sensitive Assistant queries are stated as not stored', () {
      expect(tr.privacyAssistantSensitive, contains('saklanmaz'));
      expect(en.privacyAssistantSensitive, contains('not stored'));
      expect(ar.privacyAssistantSensitive, contains('لا تُحفظ'));
    });

    test('Firebase and streamed audio are named, not hidden', () {
      for (final l in locales) {
        expect(l.privacyPolicyNetworkBody, contains('Firebase'));
        expect(l.privacyPolicyNetworkBody, contains('Google'));
        expect(l.privacyPolicyNetworkBody, contains('MP3Quran.net'));
      }
    });

    test(
      'no advertising, analytics or payment system is claimed as active',
      () {
        expect(en.privacyPolicyNoTrackingBody, contains('No advertising SDK'));
        expect(en.privacyPolicyNoTrackingBody, contains('crash-reporting'));
        expect(en.privacyPolicyNoTrackingBody, contains('No payment'));
      },
    );

    test('children-specific collection is not claimed', () {
      expect(en.privacyPolicyChildrenBody, contains('children-specific'));
      expect(tr.privacyPolicyChildrenBody, contains('çocuklara özel'));
    });
  });

  // ---------------------------------------------------------------------
  // 3) Destek yolu — mailto sözleşmesi
  // ---------------------------------------------------------------------

  group('support contact contract', () {
    test(
      'mailto targets the canonical address with an identifying subject',
      () {
        final uri = SupportContact.mailtoUri;
        expect(uri.scheme, 'mailto');
        expect(uri.path, SupportContact.email);
        expect(uri.queryParameters['subject'], SupportContact.subject);
        expect(SupportContact.subject.toLowerCase(), contains('bismillah'));
        expect(SupportContact.subject.toLowerCase(), contains('alpha'));
      },
    );

    test('no private app or user data is prefilled', () {
      final query = SupportContact.mailtoUri.query;
      expect(query.contains('body='), isFalse);
      expect(SupportContact.mailtoUri.queryParameters.keys, ['subject']);
    });
  });

  // ---------------------------------------------------------------------
  // 4) Ekranlar
  // ---------------------------------------------------------------------

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    SupportedLocale locale = SupportedLocale.tr,
    SupportContactService? supportService,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'bismillah.app_locale': locale.name,
    });
    await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: AppRoutes.profilePrivacy,
      routes: [
        GoRoute(
          path: AppRoutes.profilePrivacy,
          builder: (context, state) => screen,
          routes: [
            GoRoute(
              path: 'policy',
              builder: (context, state) => const PrivacyPolicyScreen(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.onboardingWelcome,
          builder: (context, state) => const Scaffold(body: Text('onboarding')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryAppDatabaseOverride(),
          if (supportService != null)
            supportContactServiceProvider.overrideWithValue(supportService),
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
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('privacy summary screen', () {
    testWidgets('shows the no-cloud warning and the uninstall consequence', (
      tester,
    ) async {
      await pumpScreen(tester, const PrivacyDataScreen());
      expect(find.text(tr.privacyNoCloudTitle), findsOneWidget);
      expect(find.text(tr.privacyNoCloudBody), findsOneWidget);
    });

    testWidgets('states on-device Assistant processing', (tester) async {
      await pumpScreen(tester, const PrivacyDataScreen());
      expect(find.text(tr.privacyAssistantOnDevice), findsOneWidget);
      expect(find.text(tr.privacyAssistantSensitive), findsOneWidget);
    });

    testWidgets('names Firebase in the network group', (tester) async {
      await pumpScreen(tester, const PrivacyDataScreen());
      expect(find.text(tr.privacyNetworkFirebase), findsOneWidget);
    });

    testWidgets('offers the full policy and a support action', (tester) async {
      await pumpScreen(tester, const PrivacyDataScreen());
      expect(find.text(tr.privacyOpenFullPolicy), findsOneWidget);
      expect(find.text(tr.supportContactAction), findsOneWidget);
    });

    testWidgets('opens the full policy from the summary', (tester) async {
      await pumpScreen(tester, const PrivacyDataScreen());
      await tester.ensureVisible(find.text(tr.privacyOpenFullPolicy));
      await tester.tap(find.text(tr.privacyOpenFullPolicy));
      await tester.pumpAndSettle();
      expect(find.text(tr.privacyPolicySummaryTitle), findsOneWidget);
    });
  });

  group('privacy policy screen', () {
    testWidgets('renders every policy section', (tester) async {
      await pumpScreen(tester, const PrivacyPolicyScreen());
      expect(find.text(tr.privacyPolicySummaryTitle), findsOneWidget);
      expect(find.text(tr.privacyPolicyCloudTitle), findsOneWidget);
      expect(find.text(tr.privacyPolicyNoTrackingTitle), findsOneWidget);
    });

    testWidgets('resolves RTL under Arabic and keeps the address LTR', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const PrivacyPolicyScreen(),
        locale: SupportedLocale.ar,
      );
      final scope = tester.element(find.text(ar.privacyPolicySummaryTitle));
      expect(Directionality.of(scope), TextDirection.rtl);

      final address = tester.element(find.text(SupportContact.email));
      expect(Directionality.of(address), TextDirection.ltr);
    });
  });

  group('support action', () {
    testWidgets('opening the email composer shows no failure message', (
      tester,
    ) async {
      final service = _FakeSupportContactService(result: true);
      await pumpScreen(
        tester,
        const PrivacyDataScreen(),
        supportService: service,
      );
      await tester.ensureVisible(find.text(tr.supportContactAction));
      await tester.tap(find.text(tr.supportContactAction));
      await tester.pumpAndSettle();

      expect(service.calls, 1);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('falls back to an honest message containing the address', (
      tester,
    ) async {
      final service = _FakeSupportContactService(result: false);
      await pumpScreen(
        tester,
        const PrivacyDataScreen(),
        supportService: service,
      );
      await tester.ensureVisible(find.text(tr.supportContactAction));
      await tester.tap(find.text(tr.supportContactAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(service.calls, 1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining(SupportContact.email, findRichText: true),
        findsWidgets,
      );
    });
  });
}

final class _FakeSupportContactService implements SupportContactService {
  _FakeSupportContactService({required this.result});

  final bool result;
  int calls = 0;

  @override
  Future<bool> openSupportEmail() async {
    calls += 1;
    return result;
  }
}
