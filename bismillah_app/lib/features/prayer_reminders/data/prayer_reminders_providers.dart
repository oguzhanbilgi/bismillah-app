import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/data/flutter_device_time_zone_service.dart';
import 'package:bismillah_app/features/prayer_reminders/data/flutter_local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/data/shared_prefs_reminder_preference_store.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/device_time_zone_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/reminder_preference_store.dart';
import 'package:bismillah_app/features/prayer_times/data/prayer_times_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hatırlatıcı altyapı provider'ları — somut flutter_local_notifications/
/// flutter_timezone implementasyonlarını arayüz arkasından verir.
final deviceTimeZoneServiceProvider = Provider<DeviceTimeZoneService>(
  (ref) => const FlutterDeviceTimeZoneService(),
);

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => FlutterLocalNotificationService(
    timeZoneService: ref.watch(deviceTimeZoneServiceProvider),
  ),
);

final reminderPreferenceStoreProvider = Provider<ReminderPreferenceStore>(
  (ref) => const SharedPrefsReminderPreferenceStore(),
);

final prayerReminderSchedulerProvider = Provider<PrayerReminderScheduler>(
  (ref) => PrayerReminderScheduler(
    calculator: ref.watch(prayerTimeCalculatorProvider),
    notifications: ref.watch(localNotificationServiceProvider),
    clock: ref.watch(clockProvider),
  ),
);
