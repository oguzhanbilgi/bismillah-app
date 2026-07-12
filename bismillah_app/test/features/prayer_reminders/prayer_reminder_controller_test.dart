import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/clock_provider.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_controller.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_state.dart';
import 'package:bismillah_app/features/prayer_reminders/data/prayer_reminders_providers.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/reminder_preference_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_prayer_times.dart';

void main() {
  final copy = PrayerReminderCopy(
    title: 'Namaz vakti',
    bodyFor: (n) => '${n.name} hatırlatma',
  );
  final fixedNow = DateTime(2026, 7, 15);

  ProviderContainer build({
    required _FakeNotifications notifications,
    required _FakePrefs prefs,
    Override? location,
  }) {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(FixedClock(fixedNow)),
        localNotificationServiceProvider.overrideWithValue(notifications),
        reminderPreferenceStoreProvider.overrideWithValue(prefs),
        location ?? grantedLocationOverride(),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('build: preference disabled → ReminderDisabled', () async {
    final container = build(
      notifications: _FakeNotifications(),
      prefs: _FakePrefs(false),
    );
    final state = await container.read(prayerReminderControllerProvider.future);
    expect(state, isA<ReminderDisabled>());
  });

  test('build: enabled + permission granted → ReminderEnabled', () async {
    final container = build(
      notifications: _FakeNotifications(check: NotificationPermissionStatus.granted),
      prefs: _FakePrefs(true),
    );
    final state = await container.read(prayerReminderControllerProvider.future);
    expect(state, isA<ReminderEnabled>());
  });

  test('enable: granted + location → schedules, persists, ReminderEnabled',
      () async {
    final notifications = _FakeNotifications(
      request: NotificationPermissionStatus.granted,
    );
    final prefs = _FakePrefs(false);
    final container = build(notifications: notifications, prefs: prefs);
    await container.read(prayerReminderControllerProvider.future);

    await container
        .read(prayerReminderControllerProvider.notifier)
        .enable(copy);

    expect(
      container.read(prayerReminderControllerProvider).value,
      isA<ReminderEnabled>(),
    );
    expect(notifications.scheduled, isNotEmpty); // 7 gün × 5 vakit
    expect(await prefs.isEnabled(), isTrue);
  });

  test('enable: permission denied → blocked, nothing scheduled', () async {
    final notifications = _FakeNotifications(
      request: NotificationPermissionStatus.denied,
    );
    final prefs = _FakePrefs(false);
    final container = build(notifications: notifications, prefs: prefs);
    await container.read(prayerReminderControllerProvider.future);

    await container
        .read(prayerReminderControllerProvider.notifier)
        .enable(copy);

    final state = container.read(prayerReminderControllerProvider).value;
    expect(state, isA<ReminderPermissionBlocked>());
    expect((state as ReminderPermissionBlocked).permanentlyDenied, isFalse);
    expect(notifications.scheduled, isEmpty);
    expect(await prefs.isEnabled(), isFalse);
  });

  test('enable: permanently denied → blocked(permanent)', () async {
    final container = build(
      notifications: _FakeNotifications(
        request: NotificationPermissionStatus.permanentlyDenied,
      ),
      prefs: _FakePrefs(false),
    );
    await container.read(prayerReminderControllerProvider.future);
    await container
        .read(prayerReminderControllerProvider.notifier)
        .enable(copy);
    expect(
      (container.read(prayerReminderControllerProvider).value
              as ReminderPermissionBlocked)
          .permanentlyDenied,
      isTrue,
    );
  });

  test('enable: granted but location unavailable → ReminderLocationNeeded',
      () async {
    final container = build(
      notifications: _FakeNotifications(
        request: NotificationPermissionStatus.granted,
      ),
      prefs: _FakePrefs(false),
      location: fakeLocationOverride(), // reddedilmiş konum
    );
    await container.read(prayerReminderControllerProvider.future);
    await container
        .read(prayerReminderControllerProvider.notifier)
        .enable(copy);
    expect(
      container.read(prayerReminderControllerProvider).value,
      isA<ReminderLocationNeeded>(),
    );
  });

  test('disable: cancels own reminders, persists off, ReminderDisabled',
      () async {
    final notifications = _FakeNotifications();
    final prefs = _FakePrefs(true);
    final container = build(notifications: notifications, prefs: prefs);
    await container.read(prayerReminderControllerProvider.future);

    await container.read(prayerReminderControllerProvider.notifier).disable();

    expect(
      container.read(prayerReminderControllerProvider).value,
      isA<ReminderDisabled>(),
    );
    expect(notifications.cancelAllCalls, greaterThan(0));
    expect(await prefs.isEnabled(), isFalse);
  });
}

final class _FakeNotifications implements LocalNotificationService {
  _FakeNotifications({
    this._request = NotificationPermissionStatus.granted,
    this._check = NotificationPermissionStatus.granted,
  });

  final NotificationPermissionStatus _request;
  final NotificationPermissionStatus _check;
  final List<PrayerReminder> scheduled = [];
  int cancelAllCalls = 0;

  @override
  Stream<String> get reminderTaps => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionStatus> requestPermission() async => _request;

  @override
  Future<NotificationPermissionStatus> checkPermission() async => _check;

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<void> schedule(PrayerReminder reminder, {required bool exact}) async =>
      scheduled.add(reminder);

  @override
  Future<void> cancelAllPrayerReminders() async {
    cancelAllCalls++;
    scheduled.clear();
  }

  @override
  Future<void> openSettings() async {}
}

final class _FakePrefs implements ReminderPreferenceStore {
  _FakePrefs(this._enabled);
  bool _enabled;

  @override
  Future<bool> isEnabled() async => _enabled;

  @override
  Future<void> setEnabled(bool enabled) async => _enabled = enabled;
}
