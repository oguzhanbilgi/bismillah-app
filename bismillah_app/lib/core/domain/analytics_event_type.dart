/// Analytics event kategorileri (10_DATA_MODEL §18 event kategorileri).
///
/// Bu enum, event SÖZLÜĞÜNÜN kategorik iskeletidir; tekil event'ler
/// `AnalyticsEvent` factory'leriyle üretilir (serbest string yasak).
/// Hiçbir kategori ham ibadet verisi taşıyamaz — yalnız kova/enum/sayı.
enum AnalyticsEventType {
  onboarding,
  navigation,
  habit,
  prayer,
  quran,
  dhikr,
  dua,
  assistant,
  premium,
  paidGrowth,
  notification,
  error,
}
