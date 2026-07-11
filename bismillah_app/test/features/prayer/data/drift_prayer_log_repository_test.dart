import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/data/local/drift_prayer_log_repository.dart';
import 'package:bismillah_app/features/prayer/data/mappers/prayer_log_day_mapper.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/sync/data/local/drift_sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 10, 12);
  final t1 = UtcDateTime(DateTime.utc(2026, 7, 10, 5, 30, 12, 345, 678));

  late AppDatabase db;
  late DriftSyncQueueRepository syncQueue;
  late DriftPrayerLogRepository repository;
  var operationCounter = 0;

  DriftPrayerLogRepository buildRepository({
    String Function()? operationIdFactory,
  }) {
    return DriftPrayerLogRepository(
      db,
      syncQueue: syncQueue,
      currentUserId: () => UserId('user-1'),
      operationIdFactory:
          operationIdFactory ?? () => 'op-${operationCounter++}',
      clock: FixedClock(fixedNow),
    );
  }

  setUp(() {
    db = createTestDatabase();
    syncQueue = DriftSyncQueueRepository(db, clock: FixedClock(fixedNow));
    repository = buildRepository();
  });

  tearDown(() async {
    await db.close();
  });

  PrayerLogDay day({List<PrayerEntry>? entries, String dayKey = '2026-07-10'}) {
    return PrayerLogDay(
      dayKey: DayKey(dayKey),
      deviceId: DeviceId('device-1'),
      updatedAt: t1,
      entries: entries ??
          [
            PrayerEntry(
              prayerName: PrayerName.fajr,
              status: PrayerCompletionStatus.onTime,
              loggedAt: t1,
            ),
            const PrayerEntry(
              prayerName: PrayerName.dhuhr,
              status: PrayerCompletionStatus.none,
            ),
          ],
    );
  }

  test('PrayerLogDay mapper round-trip preserves every field', () async {
    final original = day();
    final save = await repository.saveDay(original);
    expect(save.isSuccess, isTrue);

    final loaded = (await repository.getDay(original.dayKey)).valueOrNull;
    expect(loaded, isNotNull);
    expect(loaded!.dayKey, original.dayKey);
    expect(loaded.deviceId, original.deviceId);
    expect(loaded.updatedAt, original.updatedAt); // mikrosaniye korunur
    expect(loaded.entries, original.entries); // PrayerEntry == değer eşitliği
  });

  test('saveDay writes log AND enqueues sync op in one transaction',
      () async {
    await repository.saveDay(day());

    final pending = (await syncQueue.pendingCount()).valueOrNull;
    expect(pending, 1);

    final ops = (await syncQueue.nextEligible(
      UtcDateTime(fixedNow),
      limit: 10,
    ))
        .valueOrNull!;
    expect(ops, hasLength(1));
    final op = ops.single;
    expect(op.entityType, SyncEntityType.prayerLogDay);
    expect(op.entityId.value, '2026-07-10');
    expect(op.operationType, SyncOperationType.upsert);
    expect(op.uid.value, 'user-1');
    expect(op.payloadRef, 'local://prayer_log_days/2026-07-10');
    expect(op.payloadHash, isNotEmpty);
    expect(op.status, SyncOperationStatus.pending);
  });

  test('re-saving the same day coalesces to a single queue op', () async {
    await repository.saveDay(day());
    final firstOp = (await syncQueue.nextEligible(
      UtcDateTime(fixedNow),
      limit: 10,
    ))
        .valueOrNull!
        .single;

    // Aynı güne yeni içerik: op birleştirilir, hash tazelenir.
    await repository.saveDay(
      day(
        entries: [
          PrayerEntry(
            prayerName: PrayerName.fajr,
            status: PrayerCompletionStatus.onTime,
            loggedAt: t1,
          ),
          PrayerEntry(
            prayerName: PrayerName.dhuhr,
            status: PrayerCompletionStatus.late,
            loggedAt: t1,
          ),
        ],
      ),
    );

    expect((await syncQueue.pendingCount()).valueOrNull, 1);
    final secondOp = (await syncQueue.nextEligible(
      UtcDateTime(fixedNow),
      limit: 10,
    ))
        .valueOrNull!
        .single;
    expect(secondOp.operationId, firstOp.operationId); // op korunur
    expect(secondOp.payloadHash, isNot(firstOp.payloadHash)); // içerik yeni
    expect(
      secondOp.idempotencyKey.value,
      '${firstOp.operationId.value}:${secondOp.payloadHash}',
    );
  });

  test(
      'transaction rollback: failure between log write and enqueue leaves '
      'NO partial state', () async {
    final failing = buildRepository(
      operationIdFactory: () => throw const _SimulatedFailure(),
    );

    final result = await failing.saveDay(day());
    expect(result.isFailure, isTrue);

    // Ne gün belgesi ne kuyruk kaydı kalmış olmalı.
    expect((await repository.getDay(DayKey('2026-07-10'))).valueOrNull, isNull);
    expect((await syncQueue.pendingCount()).valueOrNull, 0);
    final rawDays = await db.select(db.prayerLogDays).get();
    final rawEntries = await db.select(db.prayerEntries).get();
    expect(rawDays, isEmpty);
    expect(rawEntries, isEmpty);
  });

  test('watchDay emits the aggregate after save', () async {
    final key = DayKey('2026-07-10');
    final emitted = repository.watchDay(key).firstWhere((d) => d != null);
    await repository.saveDay(day());
    final value = await emitted;
    expect(value!.dayKey, key);
    expect(value.completedCount, 1);
  });

  test('getRange returns days ordered chronologically', () async {
    await repository.saveDay(day(dayKey: '2026-07-11'));
    await repository.saveDay(day(dayKey: '2026-07-09'));
    await repository.saveDay(day(dayKey: '2026-07-10'));

    final range = (await repository.getRange(
      DayKey('2026-07-09'),
      DayKey('2026-07-10'),
    ))
        .valueOrNull!;
    expect([for (final d in range) d.dayKey.value],
        ['2026-07-09', '2026-07-10']);
    expect(range.first.entries, hasLength(2));
  });

  test('enums persist by stable NAME, never by index', () async {
    await repository.saveDay(day());
    final raw = await db
        .customSelect(
          'SELECT prayer_name, status FROM prayer_entries ORDER BY prayer_name',
        )
        .get();
    final stored = {
      for (final row in raw)
        row.read<String>('prayer_name'): row.read<String>('status'),
    };
    expect(stored, {'fajr': 'onTime', 'dhuhr': 'none'});
  });

  test('payloadHash is canonical: entry order does not change it', () {
    final a = day(
      entries: [
        PrayerEntry(
          prayerName: PrayerName.fajr,
          status: PrayerCompletionStatus.onTime,
          loggedAt: t1,
        ),
        const PrayerEntry(
          prayerName: PrayerName.asr,
          status: PrayerCompletionStatus.none,
        ),
      ],
    );
    final b = day(
      entries: [
        const PrayerEntry(
          prayerName: PrayerName.asr,
          status: PrayerCompletionStatus.none,
        ),
        PrayerEntry(
          prayerName: PrayerName.fajr,
          status: PrayerCompletionStatus.onTime,
          loggedAt: t1,
        ),
      ],
    );
    expect(
      PrayerLogDayMapper.payloadHash(a),
      PrayerLogDayMapper.payloadHash(b),
    );
  });
}

/// Yazma ile enqueue arasında patlayan simüle hata (rollback kanıtı).
final class _SimulatedFailure implements Exception {
  const _SimulatedFailure();
}
