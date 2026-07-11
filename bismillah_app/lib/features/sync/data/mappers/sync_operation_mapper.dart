import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:drift/drift.dart';

/// `SyncOperation` domain ↔ Drift satırı eşlemesi.
///
/// Doğrulamanın otoritesi domain constructor'dır: boş `payloadRef`/
/// `payloadHash` veya Restricted `sensitivityClass` taşıyan satır
/// domain nesnesine dönüşemez (10 §11, §19). Enum'lar kararlı isimle
/// saklanır — dönüşüm `textEnum` ile tip güvenlidir.
abstract final class SyncOperationMapper {
  static SyncOperation toDomain(SyncOperationRow row) {
    return SyncOperation(
      operationId: OperationId(row.operationId),
      uid: UserId(row.uid),
      deviceId: DeviceId(row.deviceId),
      entityType: row.entityType,
      entityId: EntityId(row.entityId),
      operationType: row.operationType,
      payloadRef: row.payloadRef,
      payloadHash: row.payloadHash,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      status: row.status,
      idempotencyKey: IdempotencyKey(row.idempotencyKey),
      sensitivityClass: row.sensitivityClass,
      retryCount: row.retryCount,
      nextRetryAt: row.nextRetryAt,
      lastErrorCode: row.lastErrorCode,
    );
  }

  static SyncOperationsCompanion toCompanion(SyncOperation operation) {
    return SyncOperationsCompanion.insert(
      operationId: operation.operationId.value,
      uid: operation.uid.value,
      deviceId: operation.deviceId.value,
      entityType: operation.entityType,
      entityId: operation.entityId.value,
      operationType: operation.operationType,
      payloadRef: operation.payloadRef,
      payloadHash: operation.payloadHash,
      createdAt: operation.createdAt,
      updatedAt: operation.updatedAt,
      status: operation.status,
      idempotencyKey: operation.idempotencyKey.value,
      sensitivityClass: operation.sensitivityClass,
      retryCount: Value(operation.retryCount),
      nextRetryAt: Value(operation.nextRetryAt),
      lastErrorCode: Value(operation.lastErrorCode),
    );
  }
}
