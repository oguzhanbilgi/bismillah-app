import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/reminder_preference_store.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Widget testlerinde gerçek flutter_local_notifications/flutter_timezone
/// platform çağrılarını engeller (TASK 022). Varsayılan: KAPALI + izinsiz —
/// hatırlatıcı kartı "Hatırlatıcıları aç" gösterir, namaz kaydı bundan
/// etkilenmez.
List<Override> fakeReminderOverrides() => [
  localNotificationServiceProvider.overrideWithValue(_FakeNotifications()),
  reminderPreferenceStoreProvider.overrideWithValue(_FakePrefs()),
];

final class _FakeNotifications implements LocalNotificationService {
  @override
  Stream<String> get reminderTaps => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.denied;

  @override
  Future<NotificationPermissionStatus> checkPermission() async =>
      NotificationPermissionStatus.denied;

  @override
  Future<bool> canScheduleExact() async => false;

  @override
  Future<bool?> requestExactAlarmPermission() async => false;

  @override
  Future<void> schedule(PrayerReminder reminder, {required bool exact}) async {}

  @override
  Future<void> cancelAllPrayerReminders() async {}

  @override
  Future<void> openSettings() async {}
}

final class _FakePrefs implements ReminderPreferenceStore {
  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<void> setEnabled(bool enabled) async {}
}
