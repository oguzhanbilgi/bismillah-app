import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';

/// Kalıcı sync kuyruğu sözleşmesi (10_DATA_MODEL §10–12).
///
/// YALNIZ sözleşme — SyncEngine, Firestore yazımı ve kuyruk kalıcılığı
/// sonraki görevlerdedir. Kuyruk kuralları (§11): aynı entity için
/// bekleyen op'lar birleştirilir; `acked` op anında silinir; migration
/// sırasında bekleyen op'lar KORUNUR (kuyruk drop'u veri kaybıdır, yasak).
abstract interface class SyncQueueRepository {
  /// Op'u kuyruğa ekler; aynı `entityType+entityId` için bekleyen op
  /// varsa birleştirir (yeni op yaratılmaz, updatedAt tazelenir).
  ResultFuture<void> enqueue(SyncOperation operation);

  /// Şimdi denenebilir op'ları öncelik sırasıyla döner
  /// (ibadet kayıtları > ayarlar > attribution; §12-3).
  ResultFuture<List<SyncOperation>> nextEligible(
    UtcDateTime now, {
    required int limit,
  });

  /// Başarılı push: op silinir (acked kuyrukta tutulmaz).
  ResultFuture<void> markAcked(OperationId operationId);

  /// Geçici hata: retry muhasebesi güncellenir.
  ResultFuture<void> markFailedRetryable(
    OperationId operationId, {
    required UtcDateTime nextRetryAt,
    required String errorClass,
  });

  /// Kalıcı hata: kuyruğu bloklamadan ayrılır.
  ResultFuture<void> quarantine(
    OperationId operationId, {
    required String errorClass,
  });

  /// Hesap silme akışı: TÜM op'lar cancelled (§12-7).
  ResultFuture<void> cancelAll();

  /// Açılış kurtarması: `inFlight` op'lar `pending`e döner (§27-1).
  ResultFuture<void> recoverInFlight();

  ResultFuture<int> pendingCount({SyncEntityType? entityType});
}
