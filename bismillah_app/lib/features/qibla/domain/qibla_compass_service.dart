/// Pusula (yön sensörü) sözleşmesi — paket/platform bağımsız (TASK 095).
///
/// Uygulama ve arayüz katmanları YALNIZ bu arayüzü görür; `EventChannel`,
/// `SensorManager` veya herhangi bir eklenti tipi bu dosyanın dışına
/// sızmaz. Testler gerçek sensör yerine belirlenimci sahte akış enjekte
/// eder — birim testinde fiziksel pusula doğruluğu ÖLÇÜLMEZ.
abstract interface class QiblaCompassService {
  /// Cihazın yön okumalarını yayınlar.
  ///
  /// Konum, manyetik sapma (declination) düzeltmesi için gereklidir:
  /// yayınlanan yön **gerçek kuzeye** görelidir, çünkü kıble kerterizi de
  /// gerçek kuzeye göre hesaplanır. Sapma uygulanamazsa okuma
  /// [QiblaHeadingConfidence.unreliable] ile işaretlenir, sessizce
  /// manyetik yön doğru yönmüş gibi sunulmaz.
  ///
  /// Sensör hiç yoksa akış tek bir [QiblaCompassUnsupported] yayınlayıp
  /// kapanır; hata fırlatmaz.
  Stream<QiblaCompassEvent> headings({
    required double latitude,
    required double longitude,
  });
}

/// Pusula akışının tipli olayları.
sealed class QiblaCompassEvent {
  const QiblaCompassEvent();
}

/// Kullanılabilir bir yön okuması.
final class QiblaCompassHeading extends QiblaCompassEvent {
  const QiblaCompassHeading({
    required this.degrees,
    required this.confidence,
  });

  /// Gerçek kuzeye göre yön, `[0, 360)`.
  final double degrees;

  final QiblaHeadingConfidence confidence;
}

/// Cihazda kullanılabilir bir yön sensörü YOK.
///
/// Bu bir hata değildir: ekran bozulmaz, sabit kıble açısı gösterilmeye
/// devam eder.
final class QiblaCompassUnsupported extends QiblaCompassEvent {
  const QiblaCompassUnsupported();
}

/// Sensör var ama şu an kullanılabilir okuma üretmiyor (geçici).
final class QiblaCompassHeadingUnavailable extends QiblaCompassEvent {
  const QiblaCompassHeadingUnavailable();
}

/// Okumanın güvenilirliği — platformun bildirdiği sensör doğruluğundan
/// türetilir, uygulama tarafından tahmin EDİLMEZ.
enum QiblaHeadingConfidence {
  /// Kalibre, güvenilir okuma.
  high,

  /// Kullanılabilir ama ideal değil.
  medium,

  /// Oynak; kullanıcıya kalibrasyon önerilir.
  low,

  /// Platform okumayı güvenilmez bildirdi ya da sapma düzeltmesi yok.
  unreliable,
}
