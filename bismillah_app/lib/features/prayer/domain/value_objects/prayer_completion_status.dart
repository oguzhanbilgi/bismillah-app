/// Tek vaktin kayıt durumu (10_DATA_MODEL §4 `PrayerEntry.status`).
///
/// Kaçırılan/boş durum ASLA error rengiyle veya suçlayıcı dille
/// sunulmaz (CLAUDE.md ton kuralları) — bu enum yalnız veri gerçeğidir.
enum PrayerCompletionStatus {
  none,
  onTime,
  late,
  qada;

  /// Kayıt "tamamlanmış" sayılır mı? ("Completed wins" birimi, §14-1.)
  bool get isCompleted => this != PrayerCompletionStatus.none;
}
