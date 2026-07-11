import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/data/local/drift_sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 7, 10, 12);
  final now = UtcDateTime(fixedNow);

  late AppDatabase db;
  late DriftSyncQueueRepository queue;

  setUp(() {
    db = createTestDatabase();
    queue = DriftSyncQueueRepository(db, clock: FixedClock(fixedNow));
  });

  tearDown(() async {
    await db.close();
  });

  SyncOperation operation({
    String id = 'op-1',
    String uid = 'user-1',
    SyncEntityType entityType = SyncEntityType.prayerLogDay,
    String entityId = '2026-07-10',
    String payloadHash = 'hash-1',
    UtcDateTime? nextRetryAt,
    int retryCount = 0,
    SyncOperationStatus status = SyncOperationStatus.pending,
    UtcDateTime? createdAt,
  }) {
    final created = createdAt ?? now;
    return SyncOperation(
      operationId: OperationId(id),
      uid: UserId(uid),
      deviceId: DeviceId('device-1'),
      entityType: entityType,
      entityId: EntityId(entityId),
      operationType: SyncOperationType.upsert,
      payloadRef: 'local://x/$entityId',
      payloadHash: payloadHash,
      createdAt: created,
      updatedAt: created,
      status: status,
      idempotencyKey: IdempotencyKey.derive(
        operationId: OperationId(id),
        payloadHash: payloadHash,
      ),
      sensitivityClass: SensitivityClass.high,
      retryCount: retryCount,
      nextRetryAt: nextRetryAt,
    );
  }

  test('SyncOperation mapper round-trip preserves every field', () async {
    final original = operation(
      nextRetryAt: now.add(const Duration(minutes: 5)),
      retryCount: 2,
      status: SyncOperationStatus.failedRetryable,
    );
    await queue.enqueue(original);

    final loaded = (await queue.nextEligible(
      now.add(const Duration(minutes: 6)),
      limit: 1,
    ))
        .valueOrNull!
        .single;
    expect(loaded.operationId, original.operationId);
    expect(loaded.uid, original.uid);
    expect(loaded.deviceId, original.deviceId);
    expect(loaded.entityType, original.entityType);
    expect(loaded.entityId, original.entityId);
    expect(loaded.operationType, original.operationType);
    expect(loaded.payloadRef, original.payloadRef);
    expect(loaded.payloadHash, original.payloadHash);
    expect(loaded.createdAt, original.createdAt);
    expect(loaded.updatedAt, original.updatedAt);
    expect(loaded.retryCount, original.retryCount);
    expect(loaded.nextRetryAt, original.nextRetryAt);
    expect(loaded.status, original.status);
    expect(loaded.idempotencyKey, original.idempotencyKey);
    expect(loaded.sensitivityClass, original.sensitivityClass);
  });

  test('nextEligible honours domain eligibility rules', () async {
    // Hemen uygun (daha eski createdAt → yaş sıralamasında önce).
    await queue.enqueue(operation(
      id: 'op-ready',
      entityId: 'e-1',
      createdAt: UtcDateTime(fixedNow.subtract(const Duration(minutes: 1))),
    ));
    // Backoff gelecekte — uygun değil.
    await queue.enqueue(operation(
      id: 'op-backoff',
      entityId: 'e-2',
      status: SyncOperationStatus.failedRetryable,
      nextRetryAt: now.add(const Duration(hours: 1)),
    ));
    // Quarantine eşiği aşılmış — asla uygun değil.
    await queue.enqueue(operation(
      id: 'op-exhausted',
      entityId: 'e-3',
      status: SyncOperationStatus.failedRetryable,
      retryCount: SyncOperation.maxRetryCount + 1,
    ));

    final nowEligible =
        (await queue.nextEligible(now, limit: 10)).valueOrNull!;
    expect([for (final op in nowEligible) op.operationId.value], ['op-ready']);

    final laterEligible = (await queue.nextEligible(
      now.add(const Duration(hours: 2)),
      limit: 10,
    ))
        .valueOrNull!;
    expect(
      [for (final op in laterEligible) op.operationId.value],
      ['op-ready', 'op-backoff'],
    );
  });

  test('priority ordering: worship data before settings/attribution',
      () async {
    await queue.enqueue(operation(
      id: 'op-settings',
      entityType: SyncEntityType.settings,
      entityId: 'settings',
    ));
    await queue.enqueue(operation(
      id: 'op-attribution',
      entityType: SyncEntityType.attribution,
      entityId: 'attribution',
    ));
    await queue.enqueue(operation(id: 'op-prayer', entityId: '2026-07-10'));

    final ops = (await queue.nextEligible(now, limit: 10)).valueOrNull!;
    expect(
      [for (final op in ops) op.operationId.value],
      ['op-prayer', 'op-settings', 'op-attribution'],
    );
  });

  test('markFailedRetryable increments retry accounting and gates by backoff',
      () async {
    await queue.enqueue(operation());
    await queue.markFailedRetryable(
      OperationId('op-1'),
      nextRetryAt: now.add(const Duration(minutes: 30)),
      errorClass: 'unavailable',
    );

    expect((await queue.nextEligible(now, limit: 10)).valueOrNull, isEmpty);
    final later = (await queue.nextEligible(
      now.add(const Duration(minutes: 31)),
      limit: 10,
    ))
        .valueOrNull!;
    expect(later.single.retryCount, 1);
    expect(later.single.status, SyncOperationStatus.failedRetryable);
    expect(later.single.lastErrorCode, 'unavailable');
  });

  test('markAcked deletes the op immediately (queue never bloats)', () async {
    await queue.enqueue(operation());
    await queue.markAcked(OperationId('op-1'));
    expect((await queue.pendingCount()).valueOrNull, 0);
    expect(await db.select(db.syncOperations).get(), isEmpty);
  });

  test('quarantine keeps the op but blocks it from the batch', () async {
    await queue.enqueue(operation());
    await queue.quarantine(OperationId('op-1'), errorClass: 'permissionDenied');

    expect((await queue.nextEligible(now, limit: 10)).valueOrNull, isEmpty);
    final row = await db.select(db.syncOperations).getSingle();
    expect(row.status, SyncOperationStatus.quarantined);
    expect(row.lastErrorCode, 'permissionDenied');
  });

  test('recoverInFlight returns interrupted ops to pending (§27-1)', () async {
    await queue.enqueue(operation());
    // SyncEngine henüz yok: inFlight durumu test tarafından kurulur.
    await db
        .update(db.syncOperations)
        .write(const SyncOperationsCompanion(
          status: Value(SyncOperationStatus.inFlight),
        ));
    expect((await queue.nextEligible(now, limit: 10)).valueOrNull, isEmpty);

    await queue.recoverInFlight();
    final recovered = (await queue.nextEligible(now, limit: 10)).valueOrNull!;
    expect(recovered.single.status, SyncOperationStatus.pending);
  });

  test('cancelAll marks the whole queue cancelled (account deletion path)',
      () async {
    await queue.enqueue(operation(id: 'op-1', entityId: 'e-1'));
    await queue.enqueue(operation(id: 'op-2', entityId: 'e-2'));
    await queue.cancelAll();

    expect((await queue.pendingCount()).valueOrNull, 0);
    final rows = await db.select(db.syncOperations).get();
    expect(rows, hasLength(2));
    expect(
      rows.every((r) => r.status == SyncOperationStatus.cancelled),
      isTrue,
    );
  });

  test('pendingCount can filter by entity type', () async {
    await queue.enqueue(operation(id: 'op-1', entityId: 'e-1'));
    await queue.enqueue(operation(
      id: 'op-2',
      entityType: SyncEntityType.settings,
      entityId: 'settings',
    ));

    expect((await queue.pendingCount()).valueOrNull, 2);
    expect(
      (await queue.pendingCount(entityType: SyncEntityType.prayerLogDay))
          .valueOrNull,
      1,
    );
  });

  group('remapUid (TASK 018 — placeholder → gerçek uid)', () {
    test('moves old-uid rows to the target uid; matching rows untouched, '
        'entity ids and prayer data preserved', () async {
      // TASK 016–017 placeholder döneminden kalan satır + güncel satır.
      await queue.enqueue(operation(
        id: 'op-old',
        uid: 'placeholder-local-user',
        entityId: 'e-old',
      ));
      await queue.enqueue(operation(
        id: 'op-current',
        uid: 'real-uid',
        entityId: 'e-current',
      ));
      // Namaz verisi remap'ten etkilenmemeli (uid kolonu bile yok).
      await db.into(db.prayerLogDays).insert(
            PrayerLogDaysCompanion.insert(
              dayKey: '2026-07-10',
              deviceId: 'device-1',
              updatedAt: now,
            ),
          );

      final result = await queue.remapUid(to: UserId('real-uid'));
      expect(result.valueOrNull, 1); // yalnız eski satır taşındı

      final rows = await db.select(db.syncOperations).get();
      expect(rows.every((r) => r.uid == 'real-uid'), isTrue);
      final old = rows.singleWhere((r) => r.operationId == 'op-old');
      expect(old.entityId, 'e-old'); // entity kimliği DEĞİŞMEDİ
      expect(await db.select(db.prayerLogDays).get(), hasLength(1));
    });

    test('is idempotent: second run touches zero rows', () async {
      await queue.enqueue(operation(
        id: 'op-old',
        uid: 'placeholder-local-user',
      ));

      expect(
        (await queue.remapUid(to: UserId('real-uid'))).valueOrNull,
        1,
      );
      expect(
        (await queue.remapUid(to: UserId('real-uid'))).valueOrNull,
        0,
      );
    });
  });

  test('enums persist by stable NAME, never by index', () async {
    await queue.enqueue(operation());
    final raw = await db
        .customSelect(
          'SELECT entity_type, operation_type, status, sensitivity_class '
          'FROM sync_operations',
        )
        .getSingle();
    expect(raw.read<String>('entity_type'), 'prayerLogDay');
    expect(raw.read<String>('operation_type'), 'upsert');
    expect(raw.read<String>('status'), 'pending');
    expect(raw.read<String>('sensitivity_class'), 'high');
  });
}
