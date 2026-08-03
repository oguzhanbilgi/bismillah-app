import 'package:bismillah_app/features/qibla/domain/qibla_bearing.dart';

/// Hizalanma değerlendirmesi — SAF (TASK 095).
///
/// "Hizalandı" sakin bir arayüz ipucudur; dinî bir onay veya ölçüm
/// garantisi DEĞİLDİR. Tolerans, telefon manyetometresinin gerçekçi hata
/// payından küçük seçilmez: daha dar bir eşik, sensörün veremeyeceği bir
/// kesinliği vaat etmiş olurdu.
abstract final class QiblaAlignment {
  /// Hizalı sayılan yarı-açı (derece). Toplam pencere bunun iki katıdır.
  static const double toleranceDegrees = 5;

  /// [heading] yönünden [qiblaBearing] yönüne en kısa işaretli sapma.
  ///
  /// Pozitif değer "saat yönünde çevir", negatif değer "saat yönünün
  /// tersine çevir" anlamına gelir.
  static double offset({
    required double heading,
    required double qiblaBearing,
  }) => QiblaBearing.shortestDifference(heading, qiblaBearing);

  /// Sapma tolerans penceresi içindeyse `true`.
  static bool isAligned({
    required double heading,
    required double qiblaBearing,
  }) =>
      offset(heading: heading, qiblaBearing: qiblaBearing).abs() <=
      toleranceDegrees;
}
