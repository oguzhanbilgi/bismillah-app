import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';

/// Çözülmemiş en eski kuyruk kaydının KABA yaş kovası — kesin zaman damgası
/// diagnostics üzerinden ASLA sızmaz (ibadet eylem zamanı çıkarımı yasak).
enum SyncQueueAgeBucket {
  none,
  under1Hour,
  under1Day,
  under7Days,
  over7Days,
  over30Days,
}

/// Gizlilik-güvenli kuyruk teşhis özeti (TASK 073) — YALNIZ iç temel.
///
/// Bilinçli olarak İÇERMEZ: payload, payloadRef, entity/operation ID,
/// idempotency key, ham UID, hata metni, kesin zaman damgası, namaz/Kur'an
/// verisi. Sahiplik yalnız SAYI olarak raporlanır (`local-` önekli lokal
/// fallback kimlik vs. gerçek auth kimliği).
final class SyncQueueDiagnostics {
  const SyncQueueDiagnostics({
    required this.total,
    required this.byStatus,
    required this.eligibleNow,
    required this.retryWaiting,
    required this.quarantined,
    required this.cancelled,
    required this.staleInFlight,
    required this.oldestUnresolvedAge,
    required this.authenticatedOwnerCount,
    required this.localFallbackOwnerCount,
  });

  final int total;
  final Map<SyncOperationStatus, int> byStatus;

  /// Şu an denenebilir (domain uygunluk kuralına göre) kayıt sayısı.
  final int eligibleNow;

  /// Backoff bekleyen (outstanding ama şu an uygun olmayan) kayıt sayısı.
  final int retryWaiting;

  final int quarantined;
  final int cancelled;

  /// Bayat `inFlight` (eşik aşımı) kayıt sayısı.
  final int staleInFlight;

  final SyncQueueAgeBucket oldestUnresolvedAge;

  /// Gerçek (auth) kimliğe ait kayıt sayısı.
  final int authenticatedOwnerCount;

  /// `local-` önekli fallback kimliğe ait kayıt sayısı.
  final int localFallbackOwnerCount;

  /// Aynı kuyrukta iki sahiplik türü birden varsa uyarı (remap beklemede
  /// olabilir) — UID değeri döndürülmez.
  bool get hasMixedOwnership =>
      authenticatedOwnerCount > 0 && localFallbackOwnerCount > 0;

  @override
  String toString() =>
      'SyncQueueDiagnostics(total: $total, eligibleNow: $eligibleNow, '
      'retryWaiting: $retryWaiting, quarantined: $quarantined, '
      'cancelled: $cancelled, staleInFlight: $staleInFlight, '
      'oldestUnresolvedAge: ${oldestUnresolvedAge.name}, '
      'owners: auth=$authenticatedOwnerCount/local=$localFallbackOwnerCount, '
      'mixedOwnership: $hasMixedOwnership)';
}
