import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:bismillah_app/core/utils/date_key.dart';
import 'package:bismillah_app/features/prayer_times/data/adhan_calculation_method_catalog.dart';
import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculator.dart';

/// adhan_dart tabanlı hesaplayıcı — TAM OFFLINE. adhan tipleri bu dosyanın
/// dışına SIZMAZ (domain/application/presentation adhan görmez).
///
/// Yöntem preset'leri (ör. `CalculationMethodParameters.turkiye()`: fajr 18°,
/// isha 17° + yöntem dakika ayarları sunrise -7, dhuhr +5, asr +4, maghrib +7)
/// açı ve dakika ayarlarını ZATEN kendi içinde uygular — bu yüzden EK
/// temkin/ayar EKLENMEZ (çift uygulama yasak, TASK 021). Sonuçlar UTC
/// instant'tır.
///
/// TASK 096: [method] artık gerçekten UYGULANIR. Eşleme tek bir tüketici
/// `switch` üzerinden ([adhanParametersFor]) yapılır; hesaplayıcı kendi
/// parametre tablosunu TUTMAZ.
final class AdhanPrayerTimeCalculator implements PrayerTimeCalculator {
  const AdhanPrayerTimeCalculator();

  @override
  DailyPrayerTimes calculate({
    required PrayerCoordinates coordinates,
    required DateTime date,
    PrayerTimeCalculationMethod method =
        PrayerTimeCalculationMethod.defaultMethod,
    AsrCalculationMethod asrMethod = AsrCalculationMethod.standard,
  }) {
    final params = adhanParametersFor(method)
      // Asr yöntemi AÇIKÇA ayarlanır (Diyanet resmi takvimi = standard/Şâfiî;
      // §27.5 "madhhab-aware Asr" — ileride ayardan değiştirilebilir).
      ..madhab = switch (asrMethod) {
        AsrCalculationMethod.standard => adhan.Madhab.shafi,
        AsrCalculationMethod.hanafi => adhan.Madhab.hanafi,
      };

    // Yalnız yıl/ay/gün anlamlıdır; UTC gün başı vererek yerel takvim
    // gününü sabitleriz (sonuç yine UTC instant'ıdır).
    final times = adhan.PrayerTimes(
      coordinates: adhan.Coordinates(
        coordinates.latitude,
        coordinates.longitude,
      ),
      date: DateTime.utc(date.year, date.month, date.day),
      calculationParameters: params,
    );

    return DailyPrayerTimes(
      dayKey: DateKey.fromLocal(date),
      fajr: times.fajr.toUtc(),
      sunrise: times.sunrise.toUtc(),
      dhuhr: times.dhuhr.toUtc(),
      asr: times.asr.toUtc(),
      maghrib: times.maghrib.toUtc(),
      isha: times.isha.toUtc(),
      method: method,
      asrMethod: asrMethod,
    );
  }
}
