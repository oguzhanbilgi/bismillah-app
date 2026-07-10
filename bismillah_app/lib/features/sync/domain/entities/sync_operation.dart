import 'package:bismillah_app/core/domain/classified.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';

/// Bekleyen sync işi (10_DATA_MODEL §11) — YALNIZ domain nesnesi.
///
/// Sync engine, Firestore yazımı ve kuyruk kalıcılığı bu görevde YOKTUR.
/// `payloadRef` Isar'daki güncel kayda referanstır — payload KOPYALANMAZ
/// (tek doğruluk kaynağı korunur; push anında güncel hâl okunur).
/// Tombstone op'ları ack'e kadar hedef kaydın soft-deleted hâlde
/// sorgulanabilir kalmasını gerektirir (§11 hardening).
final class SyncOperation implements Classified {
  SyncOperation({
    required this.operationId,
    required this.uid,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payloadRef,
    required this.payloadHash,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.idempotencyKey,
    required this.sensitivityClass,
    this.retryCount = 0,
    this.nextRetryAt,
    this.lastErrorCode,
  }) {
    if (payloadRef.trim().isEmpty) {
      throw ArgumentError.value(payloadRef, 'payloadRef', 'Boş olamaz');
    }
    if (payloadHash.trim().isEmpty) {
      throw ArgumentError.value(payloadHash, 'payloadHash', 'Boş olamaz');
    }
    if (retryCount < 0) {
      throw ArgumentError.value(retryCount, 'retryCount', 'Negatif olamaz');
    }
    if (sensitivityClass == SensitivityClass.restricted) {
      throw ArgumentError.value(
        sensitivityClass,
        'sensitivityClass',
        'Restricted veri hiçbir katmanda saklanamaz — kuyruğa giremez',
      );
    }
  }

  /// Quarantine eşiği (10_DATA_MODEL §12-9 — *varsayım*).
  static const int maxRetryCount = 8;

  final OperationId operationId;

  /// Sahip kullanıcı (linking remap'inde güncellenir).
  final UserId uid;

  final DeviceId deviceId;
  final SyncEntityType entityType;

  /// Hedef belge anahtarı (dayKey/duaId/uuid…).
  final EntityId entityId;

  final SyncOperationType operationType;

  /// Isar'daki güncel kayda referans — payload kopyası DEĞİL.
  final String payloadRef;

  /// Gönderim anındaki içerik hash'i (idempotency + değişiklik tespiti).
  final String payloadHash;

  final UtcDateTime createdAt;
  final UtcDateTime updatedAt;
  final int retryCount;

  /// Backoff hedefi (üstel + jitter; §12-8).
  final UtcDateTime? nextRetryAt;

  final SyncOperationStatus status;

  /// Son hata SINIFI (kova) — ham hata mesajı loglanmaz.
  final String? lastErrorCode;

  final IdempotencyKey idempotencyKey;

  /// Payload'ın hassasiyet sınıfı — kuyruk gözlemlenebilirliğinde
  /// payload'suz raporlama için (§11).
  @override
  final SensitivityClass sensitivityClass;

  /// Bu op şimdi denenebilir mi? (SyncEngine batch seçimi, §12-3.)
  ///
  /// `pending` ve backoff süresi dolmuş `failedRetryable` op'lar uygundur;
  /// quarantine eşiğini aşmış op denenemez.
  bool isEligibleForRetry(UtcDateTime now) {
    final retryableStatus =
        status == SyncOperationStatus.pending ||
        status == SyncOperationStatus.failedRetryable;
    if (!retryableStatus || retryCount > maxRetryCount) {
      return false;
    }
    final retryAt = nextRetryAt;
    return retryAt == null || !retryAt.isAfter(now);
  }

  /// Retry muhasebesi için sınırlı kopya (durum makinesi alanları).
  SyncOperation copyWith({
    SyncOperationStatus? status,
    int? retryCount,
    UtcDateTime? nextRetryAt,
    UtcDateTime? updatedAt,
    String? lastErrorCode,
  }) {
    return SyncOperation(
      operationId: operationId,
      uid: uid,
      deviceId: deviceId,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payloadRef: payloadRef,
      payloadHash: payloadHash,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      idempotencyKey: idempotencyKey,
      sensitivityClass: sensitivityClass,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
    );
  }
}
