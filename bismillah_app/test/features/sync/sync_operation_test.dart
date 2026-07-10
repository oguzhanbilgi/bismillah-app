import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = UtcDateTime(DateTime.utc(2026, 7, 8, 12));
  final operationId = OperationId('op-1');

  SyncOperation operation({
    String payloadRef = 'isar://prayerLogDay/2026-07-08',
    String payloadHash = 'hash-1',
    SyncOperationStatus status = SyncOperationStatus.pending,
    SensitivityClass sensitivityClass = SensitivityClass.high,
    int retryCount = 0,
    UtcDateTime? nextRetryAt,
  }) {
    return SyncOperation(
      operationId: operationId,
      uid: UserId('user-1'),
      deviceId: DeviceId('device-1'),
      entityType: SyncEntityType.prayerLogDay,
      entityId: EntityId('2026-07-08'),
      operationType: SyncOperationType.upsert,
      payloadRef: payloadRef,
      payloadHash: payloadHash,
      createdAt: createdAt,
      updatedAt: createdAt,
      status: status,
      idempotencyKey: IdempotencyKey.derive(
        operationId: operationId,
        payloadHash: payloadHash,
      ),
      sensitivityClass: sensitivityClass,
      retryCount: retryCount,
      nextRetryAt: nextRetryAt,
    );
  }

  test('rejects empty payloadRef and payloadHash', () {
    expect(() => operation(payloadRef: '  '), throwsArgumentError);
    expect(() => operation(payloadHash: ''), throwsArgumentError);
  });

  test('restricted payload can never enter the queue', () {
    expect(
      () => operation(sensitivityClass: SensitivityClass.restricted),
      throwsArgumentError,
    );
  });

  test('pending op without backoff is eligible for retry', () {
    expect(operation().isEligibleForRetry(createdAt), isTrue);
  });

  test('backoff gate: eligible only after nextRetryAt', () {
    final op = operation(
      status: SyncOperationStatus.failedRetryable,
      retryCount: 2,
      nextRetryAt: createdAt.add(const Duration(minutes: 5)),
    );
    expect(op.isEligibleForRetry(createdAt), isFalse);
    expect(
      op.isEligibleForRetry(createdAt.add(const Duration(minutes: 5))),
      isTrue,
    );
  });

  test('terminal statuses and quarantine threshold block retry', () {
    expect(
      operation(status: SyncOperationStatus.acked).isEligibleForRetry(createdAt),
      isFalse,
    );
    expect(
      operation(status: SyncOperationStatus.quarantined)
          .isEligibleForRetry(createdAt),
      isFalse,
    );
    expect(
      operation(
        status: SyncOperationStatus.failedRetryable,
        retryCount: SyncOperation.maxRetryCount + 1,
      ).isEligibleForRetry(createdAt),
      isFalse,
    );
  });

  test('idempotency key derives from operationId and payloadHash', () {
    expect(operation().idempotencyKey.value, 'op-1:hash-1');
  });
}
