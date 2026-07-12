/// Namaz vakti hesaplama yöntemi — KARARLI enum isimleri (adhan_dart
/// tiplerinden bağımsız). PRD §27.5: Türkiye için Diyanet varsayılan;
/// diğer yöntemler (MWL/ISNA/Umm al-Qura/Egyptian) ileride eklenir.
///
/// `turkiyeDiyanet` bir **Diyanet YAKLAŞIMIDIR** — resmi/sertifikalı
/// Diyanet vakti DEĞİLDİR (adhan_dart `turkiye()` preset'i: fajr 18°,
/// isha 17° + yöntem dakika ayarları; Türkiye dışında doğruluk düşer).
enum PrayerTimeCalculationMethod {
  turkiyeDiyanet;

  /// UI etiketi localization'dan çözülür; bu yalnız kararlı anahtardır.
  String get stableName => name;
}

/// İkindi (Asr) fıkhî yöntemi (PRD §27.5 "madhhab-aware Asr").
///
/// **Varsayılan `standard`** (gölge = nesne boyu, ×1): Diyanet RESMİ
/// takvimi Asr'ı bu standart (Şâfiî) yöntemle hesaplar — Türkiye ağırlıklı
/// Hanefî olsa da resmi vakit standart yöntemdedir (fixture'larla
/// doğrulandı). `hanafi` (×2) ileride ayarlardan seçilebilir kılınacak;
/// bu görevde ayar ekranı YOKTUR (karar burada izole + belgeli).
enum AsrCalculationMethod { standard, hanafi }
