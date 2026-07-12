import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';

/// Namaz vakti hesaplama sözleşmesi — TAM OFFLINE, deterministik.
///
/// Somut implementasyon (adhan_dart) yalnız data katmanındadır; domain ve
/// application adhan tiplerini görmez. Ağ/konum servisi ÇAĞIRMAZ — saf
/// astronomik hesap; girdi olarak koordinat + gün alır.
abstract interface class PrayerTimeCalculator {
  /// [date] yerel takvim gününü temsil eder (yalnız yıl/ay/gün kullanılır);
  /// clock provider'dan gelir. Sonuç UTC instant'ları taşır.
  DailyPrayerTimes calculate({
    required PrayerCoordinates coordinates,
    required DateTime date,
    PrayerTimeCalculationMethod method = PrayerTimeCalculationMethod.turkiyeDiyanet,
    AsrCalculationMethod asrMethod = AsrCalculationMethod.standard,
  });
}
