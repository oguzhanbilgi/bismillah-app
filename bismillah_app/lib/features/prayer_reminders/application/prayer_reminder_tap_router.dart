import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';

/// Bildirim dokunuşunu yönlendirir: payload bir namaz hatırlatıcısıysa
/// Prayer sekmesini açar. Payload koordinat/UID TAŞIMAZ (yalnız yönlendirme).
void routeReminderTap(String payload, void Function() openPrayerTab) {
  if (PrayerReminder.isPrayerPayload(payload)) {
    openPrayerTab();
  }
}
