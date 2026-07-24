import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_queue_diagnostics.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_failure_class.dart';

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

  /// Hata kaydının POLİTİKALI hali (TASK 073): attempt TAM BİR KEZ artar,
  /// [SyncRetryPolicy] kararına göre `failedRetryable + nextRetryAt` veya
  /// `quarantined` yazılır — tek transaction. Ham hata detayı saklanmaz;
  /// yalnız [failureClass] kararlı adı `lastErrorCode`a yazılır. Terminal
  /// (acked/quarantined/cancelled) veya mevcut olmayan kayıtta güvenle
  /// no-op'tur (geçersiz geçiş reddi).
  ResultFuture<void> recordFailure(
    OperationId operationId, {
    required SyncFailureClass failureClass,
    required UtcDateTime now,
  });

  /// Terminal kayıtların SINIRLI budaması (TASK 073): yalnız `quarantined`
  /// ve `cancelled` kayıtlar, `updatedAt` saklama penceresini
  /// (30 gün) aştıysa silinir. `pending`/`failedRetryable`/`inFlight` ASLA
  /// yaşa göre budanmaz (`acked` zaten anında silinir — §11). Idempotent;
  /// dönen değer silinen satır sayısıdır (yalnız güvenli sayaç).
  ResultFuture<int> pruneTerminal({required UtcDateTime now});

  /// Uzun oturumlarda bayat `inFlight` kurtarması (TASK 073): `updatedAt`
  /// eşiği aşan `inFlight` kayıtlar `pending`e döner (attempt metadata'sı
  /// korunur). Açılış kurtarması [recoverInFlight]'tan ayrıdır. Idempotent;
  /// dönen değer kurtarılan satır sayısıdır.
  ResultFuture<int> recoverStaleInFlight({required UtcDateTime now});

  /// Gizlilik-güvenli kuyruk teşhisi (TASK 073) — yalnız sayılar ve kaba
  /// yaş kovası; payload/ID/UID/hata metni İÇERMEZ.
  ResultFuture<SyncQueueDiagnostics> diagnostics({required UtcDateTime now});

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
