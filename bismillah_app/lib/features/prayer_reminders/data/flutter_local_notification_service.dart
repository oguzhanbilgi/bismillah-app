import 'dart:async';

import 'package:bismillah_app/features/prayer_reminders/domain/device_time_zone_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// flutter_local_notifications + timezone tabanlı cihaz-yerel bildirim
/// servisi. Eklenti/tz tipleri bu dosyanın dışına SIZMAZ. FCM/uzak
/// bildirim YOKTUR; zamanlama tamamen cihazda + offline.
final class FlutterLocalNotificationService implements LocalNotificationService {
  FlutterLocalNotificationService({
    required this._timeZoneService,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final DeviceTimeZoneService _timeZoneService;
  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<String> _taps = StreamController<String>.broadcast();

  static const String _channelId = 'prayer_reminders';
  static const String _channelName = 'Namaz hatırlatıcıları';
  bool _initialized = false;

  @override
  Stream<String> get reminderTaps => _taps.stream;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await _timeZoneService.localTimeZoneId()));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Açılışta izin İSTENMEZ (bağlamsal — enable anında istenir).
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (PrayerReminder.isPrayerPayload(payload)) {
          _taps.add(payload!);
        }
      },
    );

    // Soğuk açılış bildirimle olduysa payload'ı yayınla (Prayer'a yönlendirme).
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final launchPayload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp ?? false) {
      if (PrayerReminder.isPrayerPayload(launchPayload)) {
        _taps.add(launchPayload!);
      }
    }
    _initialized = true;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _ios?.requestPermissions(alert: true, sound: true);
      // iOS ilk retten sonra yeniden SORMAZ → red kalıcıdır (ayar gerekir).
      return (granted ?? false)
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.permanentlyDenied;
    }
    final granted = await _android?.requestNotificationsPermission();
    return (granted ?? false)
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  @override
  Future<NotificationPermissionStatus> checkPermission() async {
    final enabled = defaultTargetPlatform == TargetPlatform.iOS
        ? await _ios?.checkPermissions().then((p) => p?.isEnabled)
        : await _android?.areNotificationsEnabled();
    return (enabled ?? false)
        ? NotificationPermissionStatus.granted
        : NotificationPermissionStatus.denied;
  }

  @override
  Future<bool> canScheduleExact() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return true; // iOS zamanlaması kesindir.
    }
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  @override
  Future<void> schedule(PrayerReminder reminder, {required bool exact}) async {
    await _plugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.body,
      payload: reminder.payload,
      scheduledDate: tz.TZDateTime.from(reminder.scheduledUtc, tz.local),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  @override
  Future<void> cancelAllPrayerReminders() async {
    // YALNIZ kendi hatırlatıcılarımız (payload'a göre) — başka bildirimlere
    // dokunulmaz.
    final pending = await _plugin.pendingNotificationRequests();
    for (final req in pending) {
      if (PrayerReminder.isPrayerPayload(req.payload)) {
        await _plugin.cancel(id: req.id);
      }
    }
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();
}
