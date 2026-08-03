import 'dart:math' as math;

import 'package:bismillah_app/features/qibla/domain/kaaba_location.dart';

/// Kıble yönü matematiği — SAF alan katmanı (TASK 095).
///
/// Bu dosya hiçbir eklenti, widget, provider veya platform API'si import
/// etmez; yalnız `dart:math` kullanır. Böylece yön hesabı sensörden ve
/// arayüzden bağımsız olarak tek başına test edilebilir.
///
/// Hesap: iki nokta arasındaki **başlangıç büyük-çember kerteriz açısı**
/// (initial great-circle bearing). Sonuç GERÇEK KUZEY'e görelidir; manyetik
/// sapma (declination) düzeltmesi pusula katmanının işidir.
abstract final class QiblaBearing {
  /// Aynı nokta / karşı-ayak (antipod) sayılan açısal tolerans (derece).
  ///
  /// Bu iki durumda kerteriz matematiksel olarak TANIMSIZDIR; `atan2(0, 0)`
  /// sessizce `0` döndürdüğü için "kuzey" gibi yanıltıcı bir sonuç
  /// üretilmemesi adına açıkça yakalanır.
  static const double degenerateToleranceDegrees = 1e-6;

  /// [latitude]/[longitude] noktasından Kâbe'ye başlangıç kerterizi.
  ///
  /// Girdi geçersizse veya yön tanımsızsa hesaplanmış bir sayı yerine
  /// tipli bir başarısızlık döner — uydurma bir derece ASLA üretilmez.
  static QiblaBearingResult fromCoordinates({
    required double latitude,
    required double longitude,
  }) {
    if (!_isValidLatitude(latitude) || !_isValidLongitude(longitude)) {
      return const QiblaBearingUnavailable(
        QiblaBearingIssue.invalidCoordinates,
      );
    }

    final deltaLatitude = (latitude - KaabaLocation.latitude).abs();
    final deltaLongitude = _shortestLongitudeDelta(
      longitude,
      KaabaLocation.longitude,
    ).abs();

    if (deltaLatitude <= degenerateToleranceDegrees &&
        deltaLongitude <= degenerateToleranceDegrees) {
      // Kullanıcı zaten Kâbe'nin üzerinde: yön diye bir şey yok.
      return const QiblaBearingUnavailable(QiblaBearingIssue.atKaaba);
    }
    if ((latitude + KaabaLocation.latitude).abs() <=
            degenerateToleranceDegrees &&
        (180 - deltaLongitude).abs() <= degenerateToleranceDegrees) {
      // Tam karşı-ayak nokta: her yön eşit derecede "doğru", yani tanımsız.
      return const QiblaBearingUnavailable(QiblaBearingIssue.antipodal);
    }

    final phi1 = _toRadians(latitude);
    final phi2 = _toRadians(KaabaLocation.latitude);
    final deltaLambda = _toRadians(KaabaLocation.longitude - longitude);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x =
        math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final degrees = _toDegrees(math.atan2(y, x));
    if (!degrees.isFinite) {
      return const QiblaBearingUnavailable(QiblaBearingIssue.notComputable);
    }
    return QiblaBearingComputed(normalizeDegrees(degrees));
  }

  /// Herhangi bir dereceyi `[0, 360)` aralığına indirger.
  ///
  /// Negatif değerler, 360'ın katları ve birden çok tur sarılmış değerler
  /// aynı kurala uyar. Sonlu olmayan girdi (NaN/∞) için `0` DÖNDÜRÜLMEZ —
  /// çağıran taraf sonlu değer geçmekle yükümlüdür ve bu durum
  /// [fromCoordinates] içinde zaten elenir.
  static double normalizeDegrees(double degrees) {
    final wrapped = degrees % 360;
    final normalized = wrapped < 0 ? wrapped + 360 : wrapped;
    // `-0.0 + 360` gibi durumlarda tam 360 çıkabilir; aralık üst uçtan açık.
    return normalized == 360 ? 0 : normalized + 0.0;
  }

  /// İki yön arasındaki **en kısa işaretli fark**, `(-180, 180]` aralığında.
  ///
  /// Pozitif değer, [from] açısından [to] açısına saat yönünde gitmek
  /// gerektiğini söyler. 359° ile 1° arasındaki farkın 358 değil 2 olması
  /// bu fonksiyonun tek varlık sebebidir.
  static double shortestDifference(double from, double to) {
    final diff = normalizeDegrees(to) - normalizeDegrees(from);
    if (diff > 180) {
      return diff - 360;
    }
    if (diff <= -180) {
      return diff + 360;
    }
    return diff;
  }

  static bool _isValidLatitude(double value) =>
      value.isFinite && value >= -90 && value <= 90;

  static bool _isValidLongitude(double value) =>
      value.isFinite && value >= -180 && value <= 180;

  /// Boylam farkını `[-180, 180]` aralığına indirger (tarih çizgisi güvenli).
  static double _shortestLongitudeDelta(double from, double to) {
    final diff = (to - from) % 360;
    if (diff > 180) {
      return diff - 360;
    }
    if (diff < -180) {
      return diff + 360;
    }
    return diff;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  static double _toDegrees(double radians) => radians * 180 / math.pi;
}

/// Kıble kerterizi hesabının tipli sonucu.
sealed class QiblaBearingResult {
  const QiblaBearingResult();
}

/// Başarılı hesap — [degrees] daima `[0, 360)` aralığındadır.
final class QiblaBearingComputed extends QiblaBearingResult {
  const QiblaBearingComputed(this.degrees);

  final double degrees;
}

/// Hesap yapılamadı — sebebi tiplidir, serbest metin değildir.
final class QiblaBearingUnavailable extends QiblaBearingResult {
  const QiblaBearingUnavailable(this.issue);

  final QiblaBearingIssue issue;
}

/// Kerteriz üretilememe sebepleri.
enum QiblaBearingIssue {
  /// Enlem/boylam sonlu değil ya da geçerli aralığın dışında.
  invalidCoordinates,

  /// Kullanıcı konumu Kâbe ile aynı noktada.
  atKaaba,

  /// Kullanıcı konumu Kâbe'nin tam karşı-ayağında.
  antipodal,

  /// Beklenmedik biçimde sonlu olmayan bir ara değer üretildi.
  notComputable,
}
