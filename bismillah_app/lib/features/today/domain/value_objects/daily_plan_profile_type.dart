/// Kanonik kişiselleştirme profili kovaları (04_ONBOARDING §10).
///
/// Sekiz kova, `04_ONBOARDING_FLOW.md` §10'daki "İlk Today Dashboard
/// Eşlemesi" tablosunda adlandırılan profillerin birebir karşılığıdır;
/// `10_DATA_MODEL` §4 de `profileType`'ı **8 kova** olarak sabitler.
/// Dokuzuncu profil YOKTUR.
///
/// `personalization_profile.dart` bu enum'un "kişiselleştirme motoru
/// görevinde" tanımlanacağını not düşmüştü — TASK 078 o tanımı yapar.
///
/// **Bu bir dinî değerlendirme değildir.** Kovalar ürün kişiselleştirme
/// etiketleridir: takva ölçmez, sıralamaz, hiçbir profil diğerinden
/// üstün değildir. Kullanıcıya görünen metinler localization
/// katmanındadır — bu tip yalnız **stabil makine kimliği** taşır.
library;

/// Günlük planın üretim profili kovası.
enum DailyPlanProfileType {
  beginner('beginner'),
  returning('returning'),
  prayerFocused('prayer_focused'),
  quranFocused('quran_focused'),
  dhikrFocused('dhikr_focused'),
  learningFocused('learning_focused'),
  advanced('advanced'),
  lowTime('low_time');

  const DailyPlanProfileType(this.id);

  /// Kalıcılık/sınır geçişlerinde kullanılacak stabil kimlik.
  ///
  /// `DailyPlan.profileType` bugün serbest `String` taşır; dönüşüm
  /// **üretim sınırında (TASK 079)** yapılır — TASK 078 profil
  /// KAYDETMEZ ve `DailyPlan` zarfını değiştirmez.
  final String id;
}
