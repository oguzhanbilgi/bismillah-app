import 'package:bismillah_app/features/qibla/domain/qibla_bearing.dart';
import 'package:bismillah_app/features/qibla/domain/qibla_compass_service.dart';

/// Kıble ekranının mühürlü durumları (TASK 095).
///
/// Her başarısızlık ayrı bir durumdur: kullanıcıya "bir şeyler ters gitti"
/// demek yerine ne olduğu ve ne yapılabileceği dürüstçe söylenir. Ham
/// koordinat hiçbir duruma KONULMAZ.
sealed class QiblaState {
  const QiblaState();
}

/// Konum izni yok. [permanentlyDenied] ise yeniden istenemez, sistem
/// ayarından açılmalıdır.
final class QiblaLocationPermissionNeeded extends QiblaState {
  const QiblaLocationPermissionNeeded({required this.permanentlyDenied});

  final bool permanentlyDenied;
}

/// Cihazın konum servisi kapalı.
final class QiblaLocationServiceDisabledState extends QiblaState {
  const QiblaLocationServiceDisabledState();
}

/// İzin var ama kullanılabilir konum alınamadı.
final class QiblaLocationUnavailableState extends QiblaState {
  const QiblaLocationUnavailableState();
}

/// Konum var ama kerteriz hesaplanamadı (geçersiz koordinat, Kâbe'nin
/// üzerinde olma gibi). Sebep tiplidir.
final class QiblaBearingFailed extends QiblaState {
  const QiblaBearingFailed(this.issue);

  final QiblaBearingIssue issue;
}

/// Kıble açısı hesaplandı. Pusula durumu bundan BAĞIMSIZDIR: sensör hiç
/// olmasa bile bu durum gösterilir ve sabit açı okunabilir.
final class QiblaReady extends QiblaState {
  const QiblaReady({
    required this.bearingDegrees,
    required this.approximateLocation,
    required this.compass,
  });

  /// Gerçek kuzeye göre kıble kerterizi, `[0, 360)`.
  final double bearingDegrees;

  /// Konum son-bilinen konumdan geldiyse `true` (nazik not için).
  final bool approximateLocation;

  final QiblaCompassStatus compass;

  QiblaReady withCompass(QiblaCompassStatus next) => QiblaReady(
    bearingDegrees: bearingDegrees,
    approximateLocation: approximateLocation,
    compass: next,
  );
}

/// Pusula alt-durumu.
sealed class QiblaCompassStatus {
  const QiblaCompassStatus();
}

/// Cihazda yön sensörü yok — sabit açı gösterilmeye devam eder.
final class QiblaCompassUnsupportedStatus extends QiblaCompassStatus {
  const QiblaCompassUnsupportedStatus();
}

/// Akış açıldı, ilk okuma henüz gelmedi.
final class QiblaCompassWaitingStatus extends QiblaCompassStatus {
  const QiblaCompassWaitingStatus();
}

/// Okuma geldi ama sonra kesildi ya da platform geçici olarak veremedi.
final class QiblaCompassInterruptedStatus extends QiblaCompassStatus {
  const QiblaCompassInterruptedStatus();
}

/// Canlı okuma.
final class QiblaCompassActiveStatus extends QiblaCompassStatus {
  const QiblaCompassActiveStatus({
    required this.headingDegrees,
    required this.offsetDegrees,
    required this.aligned,
    required this.confidence,
  });

  /// Cihazın baktığı yön (gerçek kuzeye göre), `[0, 360)`.
  final double headingDegrees;

  /// Kıbleye kalan en kısa işaretli sapma, `(-180, 180]`.
  final double offsetDegrees;

  final bool aligned;

  final QiblaHeadingConfidence confidence;

  /// Okuma oynak — kullanıcıya kalibrasyon önerilir.
  bool get isLowConfidence =>
      confidence == QiblaHeadingConfidence.low ||
      confidence == QiblaHeadingConfidence.unreliable;
}
