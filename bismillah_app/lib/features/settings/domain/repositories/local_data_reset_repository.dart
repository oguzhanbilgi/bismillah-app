/// Yerel veri sıfırlama sözleşmesi (TASK 058 §7).
///
/// Cihaz-lokal veriyi kontrollü biçimde siler. Presentation bu arayüzü
/// görür — SharedPreferences importu yalnız data katmanındadır (06
/// FLUTTER_ARCHITECTURE §11).
abstract interface class LocalDataResetRepository {
  /// Yalnız öğrenme kayıtlarını siler (kaydedilen, tamamlanan, son okunan).
  /// Diğer hiçbir tercihe DOKUNMAZ.
  Future<void> clearLearningData();

  /// Tüm `bismillah.*` yerel anahtarlarını siler; yalnız uygulama DİLİ
  /// tercihi korunur. Namaz kaydı gibi veritabanı verisi buraya dâhil
  /// DEĞİLDİR (çağıran ayrıca temizler).
  Future<void> clearAllExceptLocale();
}
