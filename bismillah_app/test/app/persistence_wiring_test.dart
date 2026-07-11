import 'package:bismillah_app/app/app_providers.dart';
import 'package:bismillah_app/core/session/session_providers.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/data/local/drift_prayer_log_repository.dart';
import 'package:bismillah_app/features/prayer/data/prayer_data_providers.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/repositories/prayer_log_repository.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:bismillah_app/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';
import '../helpers/test_session.dart';

/// TASK 015 DI bağlama testleri: provider grafiği gerçek in-memory Drift
/// DB ile uçtan uca çalışır; UI/domain hiçbir Drift tipi görmez.
void main() {
  ProviderContainer buildContainer({
    String userId = testUserIdValue,
    List<Override> extraOverrides = const [],
  }) {
    final container = ProviderContainer(
      overrides: [
        inMemoryAppDatabaseOverride(),
        ...testSessionOverrides(userId: userId),
        ...extraOverrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  PrayerLogDay sampleDay(ProviderContainer container) {
    return PrayerLogDay(
      dayKey: DayKey('2026-07-11'),
      deviceId: container.read(currentDeviceIdProvider),
      updatedAt: UtcDateTime(DateTime.utc(2026, 7, 11, 6)),
      entries: [
        PrayerEntry(
          prayerName: PrayerName.fajr,
          status: PrayerCompletionStatus.onTime,
          loggedAt: UtcDateTime(DateTime.utc(2026, 7, 11, 5, 30)),
        ),
      ],
    );
  }

  test('appDatabaseProvider is overridable and backs localDatabaseProvider',
      () {
    final container = buildContainer();
    final db = container.read(appDatabaseProvider);
    expect(identical(container.read(localDatabaseProvider), db), isTrue);
  });

  test('repository providers resolve to interface types (Drift hidden)', () {
    final container = buildContainer();
    final prayerRepo = container.read(prayerLogRepositoryProvider);
    final syncRepo = container.read(syncQueueRepositoryProvider);

    expect(prayerRepo, isA<PrayerLogRepository>());
    expect(prayerRepo, isA<DriftPrayerLogRepository>());
    expect(syncRepo, isA<SyncQueueRepository>());
    // Arayüz ve somut provider aynı örneği paylaşır (tek kuyruk).
    expect(
      identical(syncRepo, container.read(driftSyncQueueRepositoryProvider)),
      isTrue,
    );
  });

  test('prayer repository from provider saves and reads through in-memory DB',
      () async {
    final container = buildContainer();
    final repo = container.read(prayerLogRepositoryProvider);
    final day = sampleDay(container);

    expect((await repo.saveDay(day)).isSuccess, isTrue);

    final loaded = (await repo.getDay(day.dayKey)).valueOrNull;
    expect(loaded, isNotNull);
    expect(loaded!.entries, day.entries);
  });

  test('sync queue from provider records the enqueued op with session uid',
      () async {
    final container = buildContainer();
    await container.read(prayerLogRepositoryProvider).saveDay(
          sampleDay(container),
        );

    final queue = container.read(syncQueueRepositoryProvider);
    expect((await queue.pendingCount()).valueOrNull, 1);

    final ops = (await queue.nextEligible(
      UtcDateTime(DateTime.now().toUtc().add(const Duration(minutes: 1))),
      limit: 10,
    ))
        .valueOrNull!;
    expect(ops.single.uid, container.read(currentUserIdProvider));
  });

  test('currentUserIdProvider override flows into new writes', () async {
    final container = buildContainer(userId: 'override-user');
    await container.read(prayerLogRepositoryProvider).saveDay(
          sampleDay(container),
        );

    final ops = (await container.read(syncQueueRepositoryProvider).nextEligible(
      UtcDateTime(DateTime.now().toUtc().add(const Duration(minutes: 1))),
      limit: 10,
    ))
        .valueOrNull!;
    expect(ops.single.uid.value, 'override-user');
  });

  test('disposing the container closes the database (no leaks)', () async {
    final container = ProviderContainer(
      overrides: [inMemoryAppDatabaseOverride()],
    );
    final db = container.read(appDatabaseProvider);
    await db.initialize();
    expect(db.isInitialized, isTrue);

    container.dispose();
    expect(db.isInitialized, isFalse);
  });
}
