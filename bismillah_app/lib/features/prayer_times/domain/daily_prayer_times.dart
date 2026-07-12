import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';

/// Bir günün hesaplanmış namaz vakitleri — paket-bağımsız domain modeli.
///
/// **Zamanlar UTC instant'larıdır** (adhan_dart UTC döndürür). Yerel
/// cihaz saatine dönüşüm SUNUM katmanında `.toLocal()` ile yapılır —
/// hiçbir yerde sabit UTC+3 eklenmez (TASK 021 zaman kuralı). Böylece
/// model timezone'dan bağımsız ve deterministik test edilebilir kalır.
final class DailyPrayerTimes {
  const DailyPrayerTimes({
    required this.dayKey,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.method,
    required this.asrMethod,
  });

  /// `yyyy-MM-dd` — hangi yerel takvim gününe ait (gün değişiminde controller
  /// yeniden kurulur, temiz gün geçişi).
  final String dayKey;

  final DateTime fajr; // UTC
  final DateTime sunrise; // UTC — "Güneş" (namaz vakti değil, ayrı gösterilir)
  final DateTime dhuhr; // UTC
  final DateTime asr; // UTC
  final DateTime maghrib; // UTC
  final DateTime isha; // UTC

  /// Sonuçta hangi yöntemin kullanıldığı AÇIKÇA saklanır (TASK 021 kuralı).
  final PrayerTimeCalculationMethod method;
  final AsrCalculationMethod asrMethod;

  /// Beş vaktin UTC instant'ı (Güneş HARİÇ — hatırlatıcı yalnız namaz
  /// vakitlerine kurulur; PrayerName'de sunrise yoktur).
  DateTime instantFor(PrayerName name) => switch (name) {
    PrayerName.fajr => fajr,
    PrayerName.dhuhr => dhuhr,
    PrayerName.asr => asr,
    PrayerName.maghrib => maghrib,
    PrayerName.isha => isha,
  };

  /// Verilen ANDAN sonra gelen ilk NAMAZ vakti (Güneş HARİÇ) — ad + UTC
  /// instant. Beş vaktin tümü geçmişse `null` (sunum "bugünün vakitleri
  /// tamamlandı" gösterir; yarının programı BU görevde hesaplanmaz).
  ///
  /// [now] UTC instant olmalıdır (vakitler UTC saklanır); karşılaştırma
  /// timezone'dan bağımsızdır. `PrayerName.values` kronolojik olduğundan
  /// ilk gelecekteki vakit doğru "sıradaki" vakittir.
  ({PrayerName name, DateTime instant})? nextPrayerAfter(DateTime now) {
    for (final name in PrayerName.values) {
      final instant = instantFor(name);
      if (instant.isAfter(now)) {
        return (name: name, instant: instant);
      }
    }
    return null;
  }

  /// Namaz vakitleri kronolojik sırada (Güneş dahil, gün akışı için).
  List<DateTime> get orderedInstants => [
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
  ];

  /// Beş vaktin kronolojik tutarlılığı (Güneş, Fajr ile Öğle arasında).
  bool get isChronological {
    final t = orderedInstants;
    for (var i = 0; i < t.length - 1; i++) {
      if (!t[i].isBefore(t[i + 1])) {
        return false;
      }
    }
    return true;
  }
}
