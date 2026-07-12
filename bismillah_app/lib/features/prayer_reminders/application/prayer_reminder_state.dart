/// Namaz hatırlatıcı görünüm durumu — sakin (izin/hata HATA değil veri).
sealed class PrayerReminderState {
  const PrayerReminderState();
}

/// Kapalı — "Hatırlatıcıları aç" daveti gösterilir.
final class ReminderDisabled extends PrayerReminderState {
  const ReminderDisabled();
}

/// Açık ve zamanlanmış. [exact] false ise dakika hassasiyeti değişebilir.
final class ReminderEnabled extends PrayerReminderState {
  const ReminderEnabled({required this.exact});
  final bool exact;
}

/// Bildirim izni yok — açılamıyor. Kalıcı reddedildiyse "Ayarları aç".
final class ReminderPermissionBlocked extends PrayerReminderState {
  const ReminderPermissionBlocked({required this.permanentlyDenied});
  final bool permanentlyDenied;
}

/// İzin var ama konum alınamadı (vakitler hesaplanamaz) — sakin uyarı.
final class ReminderLocationNeeded extends PrayerReminderState {
  const ReminderLocationNeeded();
}
