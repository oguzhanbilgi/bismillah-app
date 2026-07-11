import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/session/session_providers.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/application/prayer_log_controller.dart';
import 'package:bismillah_app/features/prayer/data/prayer_data_providers.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/repositories/prayer_log_repository.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/test_session.dart';

/// TASK 016 controller testleri — gerçek in-memory Drift DB ile uçtan uca
/// (mock DB yok); kimlik ve saat provider override'larıyla sabitlenir.
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

  ProviderContainer buildContainer({List<Override> extraOverrides = const []}) {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        ...testSessionOverrides(),
        ...extraOverrides,
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('initial state: today dayKey, five prayers all unmarked, calm empty',
      () async {
    final container = buildContainer();
    final state =
        await container.read(prayerLogControllerProvider.future);

    expect(state.dayKey, DayKey(todayKey));
    expect(state.saveIssue, isFalse);
    expect(state.completedCount, 0);
    for (final name in PrayerName.values) {
      expect(state.isCompleted(name), isFalse);
    }
  });

  test('toggle marks a prayer as completed (onTime) in state', () async {
    final container = buildContainer();
    final controller = container.read(prayerLogControllerProvider.notifier);
    await container.read(prayerLogControllerProvider.future);

    await controller.toggle(PrayerName.fajr);

    final state = container.read(prayerLogControllerProvider).value!;
    expect(state.isCompleted(PrayerName.fajr), isTrue);
    expect(
      state.day.entryFor(PrayerName.fajr)!.status,
      PrayerCompletionStatus.onTime,
    );
    expect(state.isCompleted(PrayerName.dhuhr), isFalse);
  });

  test('toggle again undoes via explicit undone tombstone', () async {
    final container = buildContainer();
    final controller = container.read(prayerLogControllerProvider.notifier);
    await container.read(prayerLogControllerProvider.future);

    await controller.toggle(PrayerName.fajr);
    await controller.toggle(PrayerName.fajr);

    final state = container.read(prayerLogControllerProvider).value!;
    expect(state.isCompleted(PrayerName.fajr), isFalse);
    final entry = state.day.entryFor(PrayerName.fajr)!;
    expect(entry.status, PrayerCompletionStatus.none);
    expect(entry.undone, isTrue); // açık geri alma — sessiz silme değil
  });

  test('toggle persists through the real repository (in-memory Drift)',
      () async {
    final container = buildContainer();
    final controller = container.read(prayerLogControllerProvider.notifier);
    await container.read(prayerLogControllerProvider.future);

    await controller.toggle(PrayerName.maghrib);

    final persisted = (await container
            .read(prayerLogRepositoryProvider)
            .getDay(DayKey(todayKey)))
        .valueOrNull;
    expect(persisted, isNotNull);
    expect(
      persisted!.entryFor(PrayerName.maghrib)!.status,
      PrayerCompletionStatus.onTime,
    );
    expect(persisted.deviceId,
        container.read(currentDeviceIdProvider)); // cihaz meta verisi
  });

  test('toggle enqueues a SyncOperation in the same save flow', () async {
    final container = buildContainer();
    final controller = container.read(prayerLogControllerProvider.notifier);
    await container.read(prayerLogControllerProvider.future);

    await controller.toggle(PrayerName.asr);

    final queue = container.read(syncQueueRepositoryProvider);
    expect((await queue.pendingCount()).valueOrNull, 1);
    final op = (await queue.nextEligible(
      UtcDateTime(fixedLocalNow.toUtc()),
      limit: 10,
    ))
        .valueOrNull!
        .single;
    expect(op.entityType, SyncEntityType.prayerLogDay);
    expect(op.entityId.value, todayKey);
    expect(op.uid, container.read(currentUserIdProvider));

    // Geri alma da aynı güne yazar: kuyruk birleştirir, op sayısı artmaz.
    await controller.toggle(PrayerName.asr);
    expect((await queue.pendingCount()).valueOrNull, 1);
  });

  test('recreated controller reloads persisted state from disk', () async {
    final first = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        ...testSessionOverrides(),
      ],
    );
    await first.read(prayerLogControllerProvider.future);
    await first
        .read(prayerLogControllerProvider.notifier)
        .toggle(PrayerName.isha);
    first.dispose();

    // Aynı DB, yeni container/controller — kalıcı durum geri okunur.
    final second = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(fixedLocalNow)),
        ...testSessionOverrides(),
      ],
    );
    addTearDown(second.dispose);
    final state = await second.read(prayerLogControllerProvider.future);
    expect(state.isCompleted(PrayerName.isha), isTrue);
  });

  test('save failure keeps previous state and raises calm saveIssue flag',
      () async {
    final container = buildContainer(
      extraOverrides: [
        prayerLogRepositoryProvider.overrideWithValue(
          _SaveAlwaysFailsRepository(),
        ),
      ],
    );
    final controller = container.read(prayerLogControllerProvider.notifier);
    await container.read(prayerLogControllerProvider.future);

    await controller.toggle(PrayerName.fajr);

    final state = container.read(prayerLogControllerProvider).value!;
    expect(state.saveIssue, isTrue);
    expect(state.isCompleted(PrayerName.fajr), isFalse); // önceki durum korunur
  });
}

/// Okuma boş/başarılı, yazma daima başarısız — sakin hata yolunu test eder.
final class _SaveAlwaysFailsRepository implements PrayerLogRepository {
  @override
  ResultFuture<PrayerLogDay?> getDay(DayKey dayKey) async =>
      const Result.success(null);

  @override
  Stream<PrayerLogDay?> watchDay(DayKey dayKey) => const Stream.empty();

  @override
  ResultFuture<void> saveDay(PrayerLogDay day) async =>
      const Result.failure(StorageFailure());

  @override
  ResultFuture<List<PrayerLogDay>> getRange(DayKey from, DayKey to) async =>
      const Result.success([]);
}
