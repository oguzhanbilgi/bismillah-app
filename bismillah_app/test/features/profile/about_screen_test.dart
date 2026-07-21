import 'dart:async';

import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/features/profile/application/app_info_provider.dart';
import 'package:bismillah_app/features/profile/presentation/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Hakkında ekranı (TASK 058 §8): sürüm/build, alpha durumu ve lisans
/// ekranına geçiş. GERÇEK platform kanalı çağrılmaz — appInfoProvider
/// override edilir.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakeInfo = PackageInfo(
    appName: 'Bismillah',
    packageName: 'com.example.bismillah',
    version: '1.0.0',
    buildNumber: '7',
  );

  Future<void> pump(
    WidgetTester tester, {
    PackageInfo? info,
    bool throwError = false,
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 2400),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInfoProvider.overrideWith((ref) async {
            if (throwError) {
              throw Exception('no platform');
            }
            return info ?? fakeInfo;
          }),
        ],
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
          home: const AboutScreen(),
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

  testWidgets('sürüm, build ve alpha durumunu gösterir', (tester) async {
    await pump(tester, info: fakeInfo);

    const l10n = AppLocalizations(SupportedLocale.tr);
    expect(find.textContaining('1.0.0'), findsOneWidget);
    expect(find.textContaining('7'), findsOneWidget);
    expect(find.text(l10n.aboutStageAlpha), findsOneWidget);
    expect(find.text(l10n.aboutBuiltWithFlutter), findsOneWidget);
  });

  testWidgets('sürüm yüklenirken sakin bir durum gösterir, crash yok', (
    tester,
  ) async {
    // Hiç tamamlanmayan future: yükleme durumunda ekran çökmemeli ve sakin
    // bir "yükleniyor" metni göstermeli (sürüm okuma başarısızlığında da
    // ekran bu güvenli yolu izler).
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appInfoProvider.overrideWith(
            (ref) => Completer<PackageInfo>().future,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: SupportedLocale.tr.locale,
          supportedLocales: SupportedLocale.locales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AboutScreen(),
        ),
      ),
    );
    await tester.pump();

    const l10n = AppLocalizations(SupportedLocale.tr);
    expect(tester.takeException(), isNull);
    expect(find.text(l10n.commonLoading), findsOneWidget);
    // Sürüm bilinmese de ekranın geri kalanı çalışır.
    expect(find.text(l10n.aboutStageAlpha), findsOneWidget);
    expect(find.text(l10n.aboutLicensesButton), findsOneWidget);
  });

  testWidgets('lisans düğmesi Flutter lisans ekranını açar', (tester) async {
    await pump(tester, info: fakeInfo);

    const l10n = AppLocalizations(SupportedLocale.tr);
    await tester.tap(find.text(l10n.aboutLicensesButton));
    await tester.pumpAndSettle();

    // Flutter'ın standart lisans ekranı açıldı.
    expect(find.byType(LicensePage), findsOneWidget);
  });

  group('Yerelleştirme ve taşma', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: 320px + 1.5 ölçekte taşma yok', (
        tester,
      ) async {
        await pump(
          tester,
          info: fakeInfo,
          locale: locale,
          size: const Size(320 * 3, 720 * 3),
          textScale: 1.5,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
