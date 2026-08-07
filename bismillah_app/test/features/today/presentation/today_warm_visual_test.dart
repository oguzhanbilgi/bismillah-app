import 'package:bismillah_app/app/localization/app_localizations.dart';
import 'package:bismillah_app/app/localization/supported_locale.dart';
import 'package:bismillah_app/app/theme/app_theme.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/settings/application/app_locale_controller.dart';
import 'package:bismillah_app/features/today/presentation/today_screen.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_next_prayer_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_prayer_summary_card.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_spiritual_hero.dart';
import 'package:bismillah_app/shared/islamic/mosque_silhouette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_prayer_times.dart';
import '../../../helpers/test_reminders.dart';
import '../../../helpers/test_session.dart';
import '../../../helpers/widget_test_utils.dart';

/// Today sıcak görsel sistemi (TASK 054).
///
/// Ekran GoRouter'sız, doğrudan pump'lanır: bu testin konusu görsel sistem
/// ve yerelleştirmedir, navigasyon değil. Gerçek ağ/ses KULLANILMAZ.
void main() {
  final fixedLocalNow = DateTime(2026, 7, 11, 9, 30);

  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpToday(
    WidgetTester tester, {
    SupportedLocale locale = SupportedLocale.tr,
    Size size = const Size(1080, 3200),
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          fakeLocationOverride(),
          ...fakeReminderOverrides(),
          ...testSessionOverrides(),
          appLocaleAtLaunchProvider.overrideWithValue(locale),
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
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: const TodayScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Today görsel hiyerarşisi', () {
    testWidgets('sıradaki namaz ve günlük özet birlikte render eder', (
      tester,
    ) async {
      await pumpToday(tester);

      // RDX-01C2: motive edici büyük hero Today hiyerarşisinden ÇIKARILDI —
      // onaylanan referansta yok ve ilk viewport'u dolduruyordu. Widget
      // silinmedi; yalnız bu ekranda kullanılmıyor.
      expect(find.byType(TodaySpiritualHero), findsNothing);
      expect(find.byType(TodayNextPrayerCard), findsOneWidget);
      expect(find.byType(TodayPrayerSummaryCard), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('sıradaki namaz kartı günlük özetin ÜSTÜNDE gelir', (
      tester,
    ) async {
      await pumpToday(tester);

      // TASK 054 hiyerarşisi: "şimdi ne var?" sorusu önce cevaplanır.
      final nextTop = tester.getTopLeft(find.byType(TodayNextPrayerCard)).dy;
      final summaryTop = tester
          .getTopLeft(find.byType(TodayPrayerSummaryCard))
          .dy;
      expect(nextTop, lessThan(summaryTop));

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('"Bugünkü yolculuğun" bölüm başlığı görünür', (tester) async {
      await pumpToday(tester);

      expect(find.text('Bugünkü yolculuğun'), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('dekoratif cami ufku Today ekranını DOLDURMAZ', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpToday(tester);

      // Ufuk illüstrasyonu hero ile birlikte geldiği için Today'de artık
      // çizilmiyor. Dekoratif olma sözleşmesi widget'ın KENDİ testinde
      // (`today_spiritual_uplift_test`) korunuyor.
      expect(find.byType(MosqueHorizonIllustration), findsNothing);
      handle.dispose();

      await unmountAndFlushDriftTimers(tester);
    });
  });

  group('Today yerelleştirme', () {
    testWidgets('Türkçe karşılama ve bölüm başlıkları', (tester) async {
      await pumpToday(tester);

      // RDX-01C2: hero başlığı Today'den çıktığı için yerelleştirme kanıtı
      // ekranın KENDİ metinlerine bağlandı — karşılama satırı ve bölüm
      // başlığı. Amaç değişmedi: Today her locale'de kendi dilinde çizilir.
      // RDX-02A: karşılama artık vakte duyarlı (09:30 + izin yok → sabah).
      expect(find.text('Hayırlı sabahlar'), findsOneWidget);
      expect(find.text('Bugünkü yolculuğun'), findsOneWidget);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('İngilizce locale tüm yeni metinleri çevirir', (tester) async {
      await pumpToday(tester, locale: SupportedLocale.en);

      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('Today’s journey'), findsOneWidget);
      expect(find.text('Bugünkü yolculuğun'), findsNothing);
      expect(find.text('Hayırlı sabahlar'), findsNothing);

      await unmountAndFlushDriftTimers(tester);
    });

    testWidgets('Arapça locale RTL ve Arapça metin verir', (tester) async {
      await pumpToday(tester, locale: SupportedLocale.ar);

      expect(find.text('رحلتك اليوم'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('رحلتك اليوم'))),
        TextDirection.rtl,
      );

      await unmountAndFlushDriftTimers(tester);
    });
  });

  group('Taşma güvenliği', () {
    for (final locale in SupportedLocale.values) {
      for (final scale in const [1.0, 1.3, 1.5]) {
        testWidgets('${locale.name} @${scale}x: 320px ekranda taşma yok', (
          tester,
        ) async {
          await pumpToday(
            tester,
            locale: locale,
            size: const Size(320 * 3, 720 * 3),
            textScale: scale,
          );

          expect(tester.takeException(), isNull);

          await unmountAndFlushDriftTimers(tester);
        });
      }
    }
  });
}
