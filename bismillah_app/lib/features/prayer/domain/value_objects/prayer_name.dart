/// Beş vakit (10_DATA_MODEL §4 `PrayerEntry.prayerName`).
///
/// Kullanıcıya görünen etiketler localization'dan gelir — enum adları
/// teknik tanımlayıcıdır. Sünnet/nafile genişlemesi ileriki görevde
/// nullable alanlarla eklenir (§7 migration notu).
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }
