import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/data/prayer_data_providers.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_controller.dart';
import 'package:bismillah_app/features/today/application/today_prayer_summary_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_session.dart';

/// TASK 017 controller testleri: Today özeti Prayer dilimiyle AYNI lokal
/// kaynağı okur (gerçek in-memory Drift; ayrı kayıt sistemi YOK).
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

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        ...testSessionOverrides(),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  PrayerLogDay dayWith(List<PrayerName> completed) {
    final now = UtcDateTime(fixedLocalNow.toUtc());
    return PrayerLogDay(
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
  }

  test('no prayer log yet → 0/5, calm default', () async {
    final container = buildContainer();
    final state = await container.read(
      todayPrayerSummaryControllerProvider.future,
    );

    expect(state.dayKey, DayKey(todayKey));
    expect(state.completedCount, 0);
    expect(TodayPrayerSummaryState.totalCount, 5);
    expect(state.progress, 0);
  });

  test('counts completed prayers from the shared repository', () async {
    final container = buildContainer();
    await container
        .read(prayerLogRepositoryProvider)
        .saveDay(dayWith([PrayerName.fajr, PrayerName.dhuhr]));

    final state = await container.read(
      todayPrayerSummaryControllerProvider.future,
    );
    expect(state.completedCount, 2);
    expect(state.progress, closeTo(0.4, 0.0001));
  });

  test('updates when the repository changes AFTER initial load', () async {
    final container = buildContainer();
    final initial = await container.read(
      todayPrayerSummaryControllerProvider.future,
    );
    expect(initial.completedCount, 0);

    // Prayer sekmesindeki yazımı simüle et: aynı repository'ye kaydet.
    await container
        .read(prayerLogRepositoryProvider)
        .saveDay(dayWith([PrayerName.fajr, PrayerName.asr, PrayerName.isha]));
    // watchDay akışının emisyonunu bekle (gerçek async).
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final updated =
        container.read(todayPrayerSummaryControllerProvider).value!;
    expect(updated.completedCount, 3);
  });

  test('Today layer is read-only: building it writes nothing', () async {
    final container = buildContainer();
    await container.read(todayPrayerSummaryControllerProvider.future);

    // Ne gün belgesi oluştu ne sync op kuyruğa girdi.
    final day = (await container
            .read(prayerLogRepositoryProvider)
            .getDay(DayKey(todayKey)))
        .valueOrNull;
    expect(day, isNull);
    expect(
      (await container.read(syncQueueRepositoryProvider).pendingCount())
          .valueOrNull,
      0,
    );
  });
}
