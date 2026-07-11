import 'package:bismillah_app/app/app_bootstrap.dart';
import 'package:bismillah_app/app/app_providers.dart';
import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/data/sync_data_providers.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_database.dart';

/// TASK 015 bootstrap testleri: lokal kalıcılık açılışta hazırlanır,
/// hiçbir ağ/sync-engine işi başlatılmaz (06 §8 — bootstrap ağ beklemez).
void main() {
  final now = UtcDateTime(DateTime.utc(2026, 7, 11, 12));

  SyncOperation pendingOperation() {
    return SyncOperation(
      operationId: OperationId('op-1'),
      uid: UserId('user-1'),
      deviceId: DeviceId('device-1'),
      entityType: SyncEntityType.prayerLogDay,
      entityId: EntityId('2026-07-11'),
      operationType: SyncOperationType.upsert,
      payloadRef: 'local://prayer_log_days/2026-07-11',
      payloadHash: 'hash-1',
      createdAt: now,
      updatedAt: now,
      status: SyncOperationStatus.pending,
      idempotencyKey: IdempotencyKey.derive(
        operationId: OperationId('op-1'),
        payloadHash: 'hash-1',
      ),
      sensitivityClass: SensitivityClass.high,
    );
  }

  test(
      'initializeLocalPersistence opens the DB and recovers interrupted '
      'inFlight ops — no network work involved', () async {
    final container = ProviderContainer(
      overrides: [inMemoryAppDatabaseOverride()],
    );
    addTearDown(container.dispose);

    // Önceki oturumda yarım kalmış bir op simüle edilir (§27-1).
    final db = container.read(appDatabaseProvider);
    final queue = container.read(syncQueueRepositoryProvider);
    await queue.enqueue(pendingOperation());
    await db.update(db.syncOperations).write(
          const SyncOperationsCompanion(
            status: Value(SyncOperationStatus.inFlight),
          ),
        );
    expect((await queue.nextEligible(now, limit: 10)).valueOrNull, isEmpty);

    await initializeLocalPersistence(container);

    expect(container.read(localDatabaseProvider).isInitialized, isTrue);
    final recovered = (await queue.nextEligible(now, limit: 10)).valueOrNull!;
    expect(recovered.single.status, SyncOperationStatus.pending);
  });

  test('inFlight recovery failure does NOT block startup (non-fatal)',
      () async {
    final container = ProviderContainer(
      overrides: [
        inMemoryAppDatabaseOverride(),
        syncQueueRepositoryProvider.overrideWithValue(
          _AlwaysFailingSyncQueueRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Fırlatmadan tamamlanmalı — kuyruk sonraki denemede toparlanır.
    await initializeLocalPersistence(container);
    expect(container.read(localDatabaseProvider).isInitialized, isTrue);
  });

  test('unopenable database IS fatal: bootstrap error propagates', () async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          final db = createTestDatabase();
          // Kapatılmış DB, açılamayan DB'yi simüle eder.
          db.close();
          return db;
        }),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      initializeLocalPersistence(container),
      throwsA(anything),
    );
  });
}

/// recoverInFlight dahil her çağrısı başarısız olan sahte kuyruk —
/// bootstrap'ın non-fatal davranışını kanıtlamak için.
final class _AlwaysFailingSyncQueueRepository implements SyncQueueRepository {
  static const Result<Never> _failure = Result.failure(StorageFailure());

  @override
  ResultFuture<void> enqueue(SyncOperation operation) async => _failure;

  @override
  ResultFuture<List<SyncOperation>> nextEligible(
    UtcDateTime now, {
    required int limit,
  }) async =>
      _failure;

  @override
  ResultFuture<void> markAcked(OperationId operationId) async => _failure;

  @override
  ResultFuture<void> markFailedRetryable(
    OperationId operationId, {
    required UtcDateTime nextRetryAt,
    required String errorClass,
  }) async =>
      _failure;

  @override
  ResultFuture<void> quarantine(
    OperationId operationId, {
    required String errorClass,
  }) async =>
      _failure;

  @override
  ResultFuture<void> cancelAll() async => _failure;

  @override
  ResultFuture<void> recoverInFlight() async => _failure;

  @override
  ResultFuture<int> pendingCount({SyncEntityType? entityType}) async =>
      _failure;
}
