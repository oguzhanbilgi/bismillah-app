import 'package:bismillah_app/features/prayer_times/domain/daily_prayer_times.dart';

/// Today karşılamasının zaman dilimi (RDX-02A).
///
/// Dilimler **namaz vakitlerine** göre tanımlanır; sabit saat aralıklarına
/// değil. Böylece karşılama, kullanıcının bulunduğu konumun gerçek gün
/// akışını izler — yazın 21:00'de hâlâ "akşam", kışın 18:00'de çoktan "gece"
/// olabilir ve ikisi de doğrudur.
enum TodayGreetingPeriod {
  /// Sabah (İmsak) → Öğle.
  morning,

  /// Öğle → İkindi.
  noon,

  /// İkindi → Akşam.
  day,

  /// Akşam → Yatsı.
  evening,

  /// Yatsı → ertesi Sabah. Bugünün İmsak vaktinden ÖNCESİ de buraya girer:
  /// gece, takvim gününü ortasından böler.
  night,
}

/// Karşılama dilimini çözen saf fonksiyonlar (RDX-02A).
///
/// **Yeni bir namaz vakti hesabı KURMAZ.** Yalnız TASK 021 motorunun zaten
/// ürettiği [DailyPrayerTimes] değerini okur; sabit Türkiye saatleri veya
/// başka bir ülkeye ait varsayım içermez.
abstract final class TodayGreetingResolver {
  /// Namaz vakitleri kullanılamadığında kullanılan cihaz-yerel saat
  /// pencereleri. Kullanıcıya ASLA "vakitler yüklenemedi" gibi teknik bir
  /// dil gösterilmez — karşılama sessizce makul bir dilime düşer.
  static const int _morningStartHour = 5; // 05:00–11:59
  static const int _noonStartHour = 12; // 12:00–14:59
  static const int _dayStartHour = 15; // 15:00–17:59
  static const int _eveningStartHour = 18; // 18:00–22:59
  static const int _nightStartHour = 23; // 23:00–04:59

  /// Gerçek vakitler varsa onlardan, yoksa cihaz yerel saatinden çözer.
  ///
  /// [times] `null` ise **veya** kronolojik değilse (bozuk/tutarsız veri)
  /// yerel saat penceresine düşülür: tutarsız vakitlerden üretilen bir dilim,
  /// hiç dilim üretmemekten daha yanıltıcı olurdu.
  static TodayGreetingPeriod resolve({
    required DailyPrayerTimes? times,
    required DateTime nowUtc,
    required DateTime nowLocal,
  }) {
    if (times == null || !times.isChronological) {
      return fromLocalTime(nowLocal);
    }
    return fromPrayerTimes(times: times, nowUtc: nowUtc);
  }

  /// Gerçek namaz vakitlerinden dilim.
  ///
  /// [nowUtc] UTC olmalıdır — [DailyPrayerTimes] alanları UTC instant'tır ve
  /// karşılaştırma timezone'dan bağımsız kalır. Güneş (sunrise) namaz vakti
  /// olmadığı için sınır olarak KULLANILMAZ; sabah, İmsak'tan Öğle'ye kadar
  /// tek parçadır.
  ///
  /// Sınırlar kapsayıcıdır: vaktin tam üstünde yeni dilim başlar.
  static TodayGreetingPeriod fromPrayerTimes({
    required DailyPrayerTimes times,
    required DateTime nowUtc,
  }) {
    final now = nowUtc.toUtc();
    if (now.isBefore(times.fajr)) {
      // Bugünün İmsak'ından önce: hâlâ gece (dünün Yatsı'sının devamı).
      return TodayGreetingPeriod.night;
    }
    if (now.isBefore(times.dhuhr)) {
      return TodayGreetingPeriod.morning;
    }
    if (now.isBefore(times.asr)) {
      return TodayGreetingPeriod.noon;
    }
    if (now.isBefore(times.maghrib)) {
      return TodayGreetingPeriod.day;
    }
    if (now.isBefore(times.isha)) {
      return TodayGreetingPeriod.evening;
    }
    // Yatsı'dan sonra: gece.
    return TodayGreetingPeriod.night;
  }

  /// Cihaz yerel saatinden dilim — yalnız yedek yol.
  static TodayGreetingPeriod fromLocalTime(DateTime nowLocal) {
    final hour = nowLocal.hour;
    if (hour >= _nightStartHour || hour < _morningStartHour) {
      return TodayGreetingPeriod.night;
    }
    if (hour < _noonStartHour) {
      return TodayGreetingPeriod.morning;
    }
    if (hour < _dayStartHour) {
      return TodayGreetingPeriod.noon;
    }
    if (hour < _eveningStartHour) {
      return TodayGreetingPeriod.day;
    }
    return TodayGreetingPeriod.evening;
  }
}
