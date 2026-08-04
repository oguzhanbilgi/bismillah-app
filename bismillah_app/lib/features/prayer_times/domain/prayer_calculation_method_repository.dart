import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';

/// Seçilen hesaplama yönteminin cihaz-yerel deposu (TASK 096).
///
/// Bu bir AYAR tercihidir, ibadet-geçmişi verisi DEĞİLDİR — dar bir
/// SharedPreferences anahtarı yeterlidir (Drift şeması açılmaz).
abstract interface class PrayerCalculationMethodRepository {
  /// Kayıtlı seçim. **`null` = kullanıcı hiç seçim yapmadı** ya da saklanan
  /// değer tanınmıyor; her iki hâlde de çağıran
  /// [PrayerTimeCalculationMethod.defaultMethod]'a düşer.
  ///
  /// Okuma HİÇBİR koşulda depoya geri yazmaz: tanınmayan bir değer, kullanıcı
  /// açık bir seçim yapana kadar olduğu gibi korunur.
  ResultFuture<PrayerTimeCalculationMethod?> loadMethod();

  /// Kullanıcının açık seçimini yazar.
  ResultFuture<void> saveMethod(PrayerTimeCalculationMethod method);
}
