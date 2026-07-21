import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/profile/application/profile_providers.dart';
import 'package:bismillah_app/features/profile/data/url_launcher_app_source_link_service.dart';
import 'package:bismillah_app/features/profile/domain/app_source_link_service.dart';
import 'package:bismillah_app/features/profile/domain/app_source_reference.dart';
import 'package:bismillah_app/features/profile/presentation/content_sources_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// İçerik kaynakları ekranı + bağlantı servisi (TASK 058 §5).
///
/// GERÇEK tarayıcı/pano çağrılmaz: servis override edilir, pano platform
/// kanalı sahte handler ile yakalanır.
class _FakeSourceLinkService implements AppSourceLinkService {
  _FakeSourceLinkService({required this.succeeds});

  final bool succeeds;
  final List<String> calls = [];

  @override
  Future<bool> openSource(String url) async {
    calls.add(url);
    return succeeds;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pump(
    WidgetTester tester, {
    required AppSourceLinkService service,
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appSourceLinkServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: locale.locale,
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ContentSourcesScreen(),
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

  group('AppSourceDomains allowlist', () {
    test('altyapı ve Diyanet host\'ları GEÇER', () {
      expect(AppSourceDomains.isAllowed('https://tanzil.net'), isTrue);
      expect(
        AppSourceDomains.isAllowed('https://quranenc.com/tr/browse/x'),
        isTrue,
      );
      expect(AppSourceDomains.isAllowed('https://mp3quran.net'), isTrue);
      expect(
        AppSourceDomains.isAllowed('https://kuran.diyanet.gov.tr/'),
        isTrue,
      );
    });

    test('HTTPS dışı ve sahte host reddedilir', () {
      expect(AppSourceDomains.isAllowed('http://tanzil.net'), isFalse);
      expect(
        AppSourceDomains.isAllowed('https://tanzil.net.evil.com'),
        isFalse,
      );
      expect(AppSourceDomains.isAllowed('https://nottanzil.net'), isFalse);
      expect(AppSourceDomains.isAllowed(''), isFalse);
    });

    test('kayıtlı tüm kaynak URL\'leri allowlist\'ten GEÇER', () {
      for (final source in kAppSourceReferences) {
        expect(
          AppSourceDomains.isAllowed(source.canonicalUrl),
          isTrue,
          reason: source.name,
        );
      }
    });
  });

  group('UrlLauncherAppSourceLinkService', () {
    test('izinli adres tarayıcıya iletilir', () async {
      final calls = <Uri>[];
      final service = UrlLauncherAppSourceLinkService(
        launcher: (uri) async {
          calls.add(uri);
          return true;
        },
      );
      expect(await service.openSource('https://tanzil.net'), isTrue);
      expect(calls.single.host, 'tanzil.net');
    });

    test('izinsiz adres tarayıcı çağırmadan false döner', () async {
      final calls = <Uri>[];
      final service = UrlLauncherAppSourceLinkService(
        launcher: (uri) async {
          calls.add(uri);
          return true;
        },
      );
      expect(await service.openSource('https://evil.com'), isFalse);
      expect(calls, isEmpty);
    });

    test('platform istisnası yutulur — crash yok', () async {
      final service = UrlLauncherAppSourceLinkService(
        launcher: (uri) async =>
            throw PlatformException(code: 'ACTIVITY_NOT_FOUND'),
      );
      expect(await service.openSource('https://mp3quran.net'), isFalse);
    });
  });

  group('Ekran', () {
    testWidgets('yedi kaynağı ve içerik politikasını gösterir', (tester) async {
      await pump(tester, service: _FakeSourceLinkService(succeeds: true));

      const l10n = AppLocalizations(SupportedLocale.tr);
      for (final source in kAppSourceReferences) {
        expect(find.text(source.name), findsOneWidget);
      }
      expect(find.text(l10n.sourcesPolicyTitle), findsOneWidget);
      expect(find.text(l10n.sourcesPolicyNoEndorsement), findsOneWidget);
      expect(find.text(l10n.sourcesPolicyFatwa), findsOneWidget);
    });

    testWidgets('açma başarılıysa snackbar/copy fallback göstermez', (
      tester,
    ) async {
      final service = _FakeSourceLinkService(succeeds: true);
      await pump(tester, service: service);

      const l10n = AppLocalizations(SupportedLocale.tr);
      await tester.tap(find.text(l10n.learnOpenOfficialPage).first);
      await tester.pumpAndSettle();

      expect(service.calls, isNotEmpty);
      expect(find.text(l10n.sourcesOpenFailed), findsNothing);
    });

    testWidgets('açma başarısızsa adres panoya kopyalanır + snackbar', (
      tester,
    ) async {
      // Pano platform kanalını yakala.
      final clipboardWrites = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboardWrites.add((call.arguments as Map)['text'] as String);
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

      final service = _FakeSourceLinkService(succeeds: false);
      await pump(tester, service: service);

      const l10n = AppLocalizations(SupportedLocale.tr);
      await tester.tap(find.text(l10n.learnOpenOfficialPage).first);
      await tester.pumpAndSettle();

      // İlk kaynak Tanzil — adresi panoya yazılmış olmalı.
      expect(clipboardWrites, contains('https://tanzil.net'));
      expect(find.text(l10n.sourcesOpenFailed), findsOneWidget);
    });
  });

  group('Yerelleştirme ve taşma', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        await pump(
          tester,
          service: _FakeSourceLinkService(succeeds: true),
          locale: locale,
          size: const Size(320 * 3, 720 * 3),
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
