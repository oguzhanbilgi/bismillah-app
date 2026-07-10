/// Veri hassasiyet sınıfları (10_DATA_MODEL §19).
///
/// Her veri alanı tanımlandığı anda bir sınıf alır; sınıfsız alan şemaya
/// giremez. Sınıflar; analytics, log, export ve silme davranışını belirler.
enum SensitivityClass {
  /// İçerik verisi (dua/ders/ayet) — kimseye ait değil.
  publicContent,

  /// Dil, tema, bildirim tercihleri, sync metadata.
  low,

  /// displayName, şehir/ülke, rozetler, favoriler, entitlement meta.
  medium,

  /// İbadet kayıtları, plan, onboarding cevapları, dini profil, AI sohbet.
  /// ASLA loglanmaz, analytics'e ham gitmez.
  high,

  /// Ödeme kartı verisi, API anahtarları — HİÇBİR katmanda saklanmaz;
  /// var olmayarak korunur.
  restricted,
}

extension SensitivityClassRules on SensitivityClass {
  /// Bu sınıftaki veri log satırına yazılabilir mi?
  bool get isLoggable => switch (this) {
    SensitivityClass.publicContent || SensitivityClass.low => true,
    _ => false,
  };

  /// Bu sınıftaki veri analytics'e HAM olarak gidebilir mi?
  /// (High sınıfı yalnız kova/enum eventlerle temsil edilir.)
  bool get isRawAnalyticsAllowed => switch (this) {
    SensitivityClass.publicContent || SensitivityClass.low => true,
    _ => false,
  };

  /// Bu sınıftaki veri herhangi bir katmanda saklanabilir mi?
  bool get isStorable => this != SensitivityClass.restricted;
}
