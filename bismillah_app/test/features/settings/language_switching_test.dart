import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/settings/domain/repositories/app_locale_repository.dart';
import 'package:bismillah_app/features/settings/presentation/language_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeAppLocaleRepository implements AppLocaleRepository {
  SupportedLocale? stored;

  @override
  ResultFuture<SupportedLocale?> loadLocale() async => Result.success(stored);

  @override
  ResultFuture<void> saveLocale(SupportedLocale locale) async {
    stored = locale;
    return const Result.success(null);
  }
}

/// `MaterialApp`'i gerçek uygulamadaki gibi `appLocaleProvider`'a bağlayan
/// harness — dil değişiminin ağacı yerinde yeniden çizdiğini doğrular.
class _LocaleHost extends ConsumerWidget {
  const _LocaleHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    return MaterialApp(
      theme: AppTheme.light(),
      locale: locale.locale,
      supportedLocales: SupportedLocale.locales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );
  }
}

Future<void> _pumpLanguageSettings(
  WidgetTester tester, {
  SupportedLocale launchLocale = SupportedLocale.tr,
  _FakeAppLocaleRepository? repository,
  double textScale = 1.0,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appLocaleAtLaunchProvider.overrideWithValue(launchLocale),
        appLocaleRepositoryProvider.overrideWithValue(
          repository ?? _FakeAppLocaleRepository(),
        ),
      ],
      child: _LocaleHost(
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const LanguageSettingsScreen(),
        ),
      ),
    ),
  );
  // Localization delegate'leri ilk frame'de hazır olmaz.
  await tester.pumpAndSettle();
}

void main() {
  group('Language Settings ekranı', () {
    testWidgets('üç dil de KENDİ adıyla listelenir', (tester) async {
      await _pumpLanguageSettings(tester);

      expect(find.text('Türkçe'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('başlangıçta seçili dil işaretlidir', (tester) async {
      await _pumpLanguageSettings(tester, launchLocale: SupportedLocale.tr);

      // Türkçe seçili → onay ikonu ve "Seçili" etiketi tek kez görünür.
      expect(find.text('Seçili'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('English seçilince açık ekran RESTART olmadan İngilizce olur', (
      tester,
    ) async {
      final repo = _FakeAppLocaleRepository();
      await _pumpLanguageSettings(tester, repository: repo);

      expect(find.text('Uygulama dili'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Aynı ağaç, yeni dil — navigasyon veya yeniden başlatma YOK.
      expect(find.text('App language'), findsOneWidget);
      expect(find.text('Uygulama dili'), findsNothing);
      expect(find.text('Selected'), findsOneWidget);
      // Onay mesajı da yeni dilde.
      expect(find.text('App language updated.'), findsOneWidget);
      expect(repo.stored, SupportedLocale.en);
    });

    testWidgets('العربية seçilince arayüz Arapça ve yön RTL olur', (
      tester,
    ) async {
      await _pumpLanguageSettings(tester);

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(find.text('لغة التطبيق'), findsOneWidget);
      expect(find.text('محددة'), findsOneWidget);

      final direction = Directionality.of(
        tester.element(find.text('لغة التطبيق').first),
      );
      expect(direction, TextDirection.rtl);
    });

    testWidgets('Arapçadan Türkçeye geri dönülebilir', (tester) async {
      await _pumpLanguageSettings(tester, launchLocale: SupportedLocale.ar);

      expect(find.text('لغة التطبيق'), findsOneWidget);

      await tester.tap(find.text('Türkçe'));
      await tester.pumpAndSettle();

      expect(find.text('Uygulama dili'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('Uygulama dili').first)),
        TextDirection.ltr,
      );
    });

    testWidgets('meal dili notu her dilde gösterilir', (tester) async {
      await _pumpLanguageSettings(tester);
      expect(find.textContaining('Kur\'an meali'), findsOneWidget);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Quran translation'), findsOneWidget);
    });
  });

  group('Language Settings taşma/erişilebilirlik', () {
    testWidgets('dar ekran + 1.5 metin ölçeğinde taşma yok', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pumpLanguageSettings(tester, textScale: 1.5);

      // Taşma varsa pump sırasında exception yakalanır.
      expect(tester.takeException(), isNull);
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('Arapça locale + 1.5 ölçekte de taşma yok', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await _pumpLanguageSettings(
        tester,
        launchLocale: SupportedLocale.ar,
        textScale: 1.5,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('her dil seçeneği ekran okuyucuya seçili durumunu bildirir', (
      tester,
    ) async {
      await _pumpLanguageSettings(tester, launchLocale: SupportedLocale.en);

      // Handle test GÖVDESİ içinde dispose edilir: addTearDown, framework'ün
      // "handle sızdı" doğrulamasından SONRA çalışır.
      final handle = tester.ensureSemantics();

      expect(
        tester.getSemantics(find.bySemanticsLabel('English')),
        matchesSemantics(
          label: 'English',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      // Seçili olmayan dil de erişilebilir ve seçili DEĞİL olarak bildirilir.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Türkçe')),
        matchesSemantics(
          label: 'Türkçe',
          isButton: true,
          isSelected: false,
          hasSelectedState: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );

      handle.dispose();
    });
  });
}
