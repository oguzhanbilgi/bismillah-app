/// Sync kuyruğu enum'ları (10_DATA_MODEL §11).
library;

/// Kuyruk operasyon tipleri.
enum SyncOperationType {
  upsert,
  patch,
  delete,
  tombstone,
  entitlementRefresh,
  contentRefresh,
}

/// Kuyruk kaydı durumları. `acked` op anında silinir (kuyruk şişmez);
/// `quarantined` kuyruğu bloklamaz; `cancelled` yalnız hesap silme
/// akışında kullanılır.
enum SyncOperationStatus {
  pending,
  inFlight,
  acked,
  failedRetryable,
  quarantined,
  cancelled,
}

/// Sync hedef entity tipleri (10_DATA_MODEL §11 `entityType`).
enum SyncEntityType {
  prayerLogDay,
  dailyPlan,
  quranProgress,
  dhikrSessionDay,
  duaFavorite,
  achievement,
  settings,
  profile,
  assistantMessage,
  attribution,
}
