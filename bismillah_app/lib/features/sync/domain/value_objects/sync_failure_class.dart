import 'dart:async' show TimeoutException;

/// Gizlilik-güvenli yerel hata SINIFLANDIRMASI (TASK 073; 10_DATA_MODEL §11
/// "lastErrorCode yalnız hata kovası taşır" kuralının somut enum'u).
///
/// KALICI olarak yalnız KARARLI enum ADI saklanır (`SyncOperations.
/// lastErrorCode`). Ham exception mesajı, stack trace, URL, token, payload,
/// entity/operation ID veya UID hiçbir katmanda saklanmaz/loglanmaz.
enum SyncFailureClass {
  /// Geçici ağ hatası (timeout, bağlantı kopması).
  transientNetwork,

  /// Uzak servis geçici olarak erişilemez (5xx benzeri).
  serviceUnavailable,

  /// Kimlik henüz hazır değil (anonim auth beklemede) — YAVAŞ tekrar.
  authenticationUnavailable,

  /// Yetki reddi — kalıcı; tekrar denemek anlamsız.
  permissionDenied,

  /// Doğrulama hatası — kalıcı.
  validation,

  /// Bozuk/çözümlenemeyen operasyon — kalıcı.
  malformedOperation,

  /// `payloadRef` hedefi lokal DB'de yok — kalıcı (kaynak kayıt silinmiş).
  missingPayload,

  /// Sahiplik uyuşmazlığı — kalıcı; asla başka kimlik altında denenmez.
  ownershipMismatch,

  /// Sınıflandırılamayan hata — sınırlı sayıda temkinli tekrar.
  unknownRetryable,

  /// Sınıflandırılamayan ve tekrar edilemez kabul edilen hata.
  unknownPermanent;

  /// Kalıcı (tekrar denenmez, doğrudan quarantine) sınıflar.
  bool get isPermanent => switch (this) {
    permissionDenied ||
    validation ||
    malformedOperation ||
    missingPayload ||
    ownershipMismatch ||
    unknownPermanent => true,
    _ => false,
  };
}

/// Yerel exception → [SyncFailureClass] eşleyicisi.
///
/// YALNIZ tip bilgisine bakar — mesaj içeriği okunmaz, saklanmaz,
/// loglanmaz. Ağ/Firebase'e ihtiyaç duymadan test edilebilir. Uzak uç
/// (consumer) henüz olmadığından kapsam bilinçli olarak dar tutulur;
/// consumer görevi kendi adapter'ında bu sınıfa MAP eder.
abstract final class SyncFailureClassifier {
  static SyncFailureClass classify(Object error) => switch (error) {
    TimeoutException() => SyncFailureClass.transientNetwork,
    FormatException() => SyncFailureClass.malformedOperation,
    ArgumentError() => SyncFailureClass.validation,
    StateError() => SyncFailureClass.validation,
    _ => SyncFailureClass.unknownRetryable,
  };
}
