import 'package:bismillah_app/app/bismillah_app.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/data/mappers/prayer_log_day_mapper.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer/presentation/prayer_screen.dart';
import 'package:bismillah_app/features/today/presentation/today_screen.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_daily_reflection.dart';
import 'package:bismillah_app/features/today/presentation/widgets/today_prayer_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_prayer_times.dart';
import '../../../helpers/test_reminders.dart';
import '../../../helpers/test_session.dart';
import '../../../helpers/widget_test_utils.dart';

/// TASK 017 ekran testleri: Today özeti + Prayer sekmesine CTA navigasyonu.
/// Tam uygulama kabuğu (router + shell) gerçek in-memory Drift ile pump'lanır.
void main() {
  final fixedLocalNow = DateTime(2026, 7, 11, 9, 30);
  const todayKey = '2026-07-11';

  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // Türkçe metin assertion'ları için cihaz locale'i TR'ye sabitlenir.
    tester.platformDispatcher.localeTestValue = const Locale('tr', 'TR');
    tester.platformDispatcher.localesTestValue = const [Locale('tr', 'TR')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);

    // Uzun viewport: Prayer sekmesinde vakit + hatırlatıcı kartları eklendikten
    // sonra namaz satırları aynı frame'de kurulsun (lazy ListView).
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
          fakeLocationOverride(),
          ...fakeReminderOverrides(),
          ...testSessionOverrides(),
        ],
        child: const BismillahApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> seedDay(List<PrayerName> completed) async {
    final now = UtcDateTime(fixedLocalNow.toUtc());
    final day = PrayerLogDay(
      dayKey: DayKey(todayKey),
      deviceId: DeviceId('device-1'),
      updatedAt: now,
      entries: [
        for (final name in completed)
          PrayerEntry(
            prayerName: name,
            status: PrayerCompletionStatus.onTime,
            loggedAt: now,
          ),
      ],
    );
    await db
        .into(db.prayerLogDays)
        .insertOnConflictUpdate(PrayerLogDayMapper.toDayCompanion(day));
    for (final companion in PrayerLogDayMapper.toEntryCompanions(day)) {
      await db.into(db.prayerEntries).insert(companion);
    }
  }

  testWidgets('Today renders summary card with 0/5 and trust note', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(TodayScreen), findsOneWidget);
    expect(find.byType(TodayPrayerSummaryCard), findsOneWidget);
    // RDX-02A: sabit "Bugünün ritmi" yerini vakte duyarlı karşılama aldı.
    // Sabit saat 09:30 ve konum izni YOK → yerel-saat yedeği → sabah.
    expect(find.text('Hayırlı sabahlar'), findsOneWidget);
    expect(find.text('Bugünün ritmi'), findsNothing);
    // Ekran başlığı olarak ne 'Bugün' ne 'Günüm' görünür; 'Günüm' YALNIZ
    // alt navigasyon etiketidir.
    expect(find.text('Bugün'), findsNothing);
    expect(find.text('Günüm'), findsOneWidget);
    expect(find.text('Bugünün namaz takibi'), findsOneWidget);
    expect(find.text('0/5 tamamlandı'), findsOneWidget);
    // Özet kartı + sıradaki namaz kartı (TASK 023, izin yokken davet CTA'sı).
    expect(find.text('Namazlara git'), findsNWidgets(2));
    // RDX-02B: teknik depolama alt bilgisi Today'den KALDIRILDI (aynı bilgi
    // Namaz ve Gizlilik ekranlarında duruyor); yerini günün sakin kapanış
    // cümlesi aldı.
    expect(find.text('Kayıtların cihazında saklanır.'), findsNothing);
    expect(find.byType(TodayDailyReflection), findsOneWidget);

    await unmountAndFlushDriftTimers(tester);
  });

  testWidgets('Today shows persisted progress from the shared DB', (
    tester,
  ) async {
    await seedDay([PrayerName.fajr, PrayerName.dhuhr]);
    await pumpApp(tester);

    expect(find.text('2/5 tamamlandı'), findsOneWidget);

    await unmountAndFlushDriftTimers(tester);
  });

  testWidgets('CTA navigates to Prayer tab; marking there updates Today', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('0/5 tamamlandı'), findsOneWidget);

    // CTA → Prayer sekmesi
    await tester.tap(find.text('Namazlara git').first);
    await tester.pumpAndSettle();
    expect(find.byType(PrayerScreen), findsOneWidget);

    // Prayer'da bir vakit işaretle
    await tester.tap(find.text('İşaretle').first);
    await tester.pumpAndSettle();
    expect(find.text('Tamamlandı'), findsOneWidget);

    // Today'e dön: özet AYNI lokal durumdan güncellenmiş olmalı
    await tester.tap(find.text('Günüm'));
    await tester.pumpAndSettle();
    expect(find.text('1/5 tamamlandı'), findsOneWidget);

    await unmountAndFlushDriftTimers(tester);
  });
}
