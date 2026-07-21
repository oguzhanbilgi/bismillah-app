import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/settings/domain/repositories/app_locale_repository.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_spiritual_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global UI + RTL doğrulaması (TASK 053 §9).
///
/// Gerçek ağ/ses KULLANILMAZ; golden framework EKLENMEZ. Yalnız yön,
/// çeviri ve taşma davranışı doğrulanır.
final class _InMemoryAppLocaleRepository implements AppLocaleRepository {
  SupportedLocale? _stored;

  @override
  ResultFuture<SupportedLocale?> loadLocale() async => Result.success(_stored);

  @override
  ResultFuture<void> saveLocale(SupportedLocale locale) async {
    _stored = locale;
    return const Result.success(null);
  }
}

class _LocaleHost extends ConsumerWidget {
  const _LocaleHost({required this.child, this.textScale = 1.0});

  final Widget child;
  final double textScale;

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
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required SupportedLocale locale,
  double textScale = 1.0,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appLocaleAtLaunchProvider.overrideWithValue(locale)],
      child: _LocaleHost(textScale: textScale, child: child),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Today hero üç dilde', () {
    testWidgets('Türkçe locale Türkçe hero gösterir', (tester) async {
      await _pump(
        tester,
        const TodaySpiritualHero(),
        locale: SupportedLocale.tr,
      );

      expect(find.text('Bugün yeniden başlayabilirsin'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.text('Bugün yeniden başlayabilirsin')),
        ),
        TextDirection.ltr,
      );
    });

    testWidgets('İngilizce locale İngilizce hero gösterir', (tester) async {
      await _pump(
        tester,
        const TodaySpiritualHero(),
        locale: SupportedLocale.en,
      );

      expect(find.text('You can begin again today'), findsOneWidget);
      expect(find.text('Bugün yeniden başlayabilirsin'), findsNothing);
    });

    testWidgets('Arapça locale Arapça hero ve RTL yön verir', (tester) async {
      await _pump(
        tester,
        const TodaySpiritualHero(),
        locale: SupportedLocale.ar,
      );

      expect(find.text('يمكنك أن تبدأ من جديد اليوم'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.text('يمكنك أن تبدأ من جديد اليوم')),
        ),
        TextDirection.rtl,
      );
    });
  });

  group('Taşma güvenliği', () {
    for (final locale in SupportedLocale.values) {
      testWidgets('${locale.name}: dar ekran + 1.5 ölçekte hero taşmaz', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320 * 3, 640 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await _pump(
          tester,
          TodaySpiritualHero(onSeeTodaysPlan: () {}),
          locale: locale,
          textScale: 1.5,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Dil değişimi açık ağacı yerinde günceller', () {
    testWidgets('hero, restart olmadan tr → ar → en izler', (tester) async {
      final container = ProviderContainer(
        overrides: [
          appLocaleAtLaunchProvider.overrideWithValue(SupportedLocale.tr),
          // Bellek içi depo: gerçek SharedPreferences kanalı FakeAsync
          // altında tamamlanamaz ve `select()` await'i asılı kalırdı.
          appLocaleRepositoryProvider.overrideWithValue(
            _InMemoryAppLocaleRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const _LocaleHost(child: TodaySpiritualHero()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bugün yeniden başlayabilirsin'), findsOneWidget);

      await container
          .read(appLocaleProvider.notifier)
          .select(SupportedLocale.ar);
      await tester.pumpAndSettle();
      expect(find.text('يمكنك أن تبدأ من جديد اليوم'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.text('يمكنك أن تبدأ من جديد اليوم')),
        ),
        TextDirection.rtl,
      );

      await container
          .read(appLocaleProvider.notifier)
          .select(SupportedLocale.en);
      await tester.pumpAndSettle();
      expect(find.text('You can begin again today'), findsOneWidget);
      expect(
        Directionality.of(
          tester.element(find.text('You can begin again today')),
        ),
        TextDirection.ltr,
      );
    });
  });
}
