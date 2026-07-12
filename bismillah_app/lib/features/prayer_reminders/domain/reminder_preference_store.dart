/// Namaz hatırlatıcılarının açık/kapalı tercihi — TEK cihaz-yerel boolean.
///
/// Bu bir AYAR tercihidir, ibadet-geçmişi verisi DEĞİLDİR; Drift şema v2
/// açmaya gerek yok (dar SharedPreferences deposu yeterli, TASK 022 kuralı).
abstract interface class ReminderPreferenceStore {
  Future<bool> isEnabled();
  Future<void> setEnabled(bool enabled);
}
