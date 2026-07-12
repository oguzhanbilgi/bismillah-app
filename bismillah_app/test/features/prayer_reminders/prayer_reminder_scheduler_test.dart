import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_scheduler.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/local_notification_service.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/notification_permission_status.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:bismillah_app/features/prayer_times/data/adhan_prayer_time_calculator.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 022: hatırlatıcı zamanlayıcı — gerçek offline calculator + fake
/// bildirim servisi (platform gerekmez).
void main() {
  const calculator = AdhanPrayerTimeCalculator();
  const istanbul = PrayerCoordinates(latitude: 41.0082, longitude: 28.9784);
  final copy = PrayerReminderCopy(
    title: 'Namaz vakti',
    bodyFor: (n) => '${n.name} hatırlatma',
  );

  // Gece yarısı (Türkiye): günün tüm vakitleri gelecekte.
  final localMidnight = DateTime(2026, 7, 15);
  final utcMidnight = DateTime.utc(2026, 7, 14, 21); // 00:00 İstanbul (UTC+3)

  List<PrayerReminder> compute({
    required DateTime localNow,
    required DateTime nowUtc,
  }) =>
      PrayerReminderScheduler.computeReminders(
        calculator: calculator,
        coordinates: istanbul,
        localNow: localNow,
        nowUtc: nowUtc,
        copy: copy,
      );

  test('schedules 5 prayers/day over 7 days; Sunrise excluded', () {
    final r = compute(localNow: localMidnight, nowUtc: utcMidnight);
    expect(r.length, 35); // 7 gün × 5 vakit

    // Hiçbir payload sunrise içermez; her payload beş vakitten biridir.
    final names = {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};
    for (final rem in r) {
      expect(rem.payload.startsWith('prayer:'), isTrue);
      expect(names.contains(rem.prayerName.name), isTrue);
      expect(rem.payload.contains('sunrise'), isFalse);
    }
  });

  test('seven-day horizon: 7 distinct dayKeys, today..+6', () {
    final r = compute(localNow: localMidnight, nowUtc: utcMidnight);
    final days = r.map((e) => e.dayKey).toSet().toList()..sort();
    expect(days, hasLength(7));
    expect(days.first, '2026-07-15');
    expect(days.last, '2026-07-21');
  });

  test('deterministic ids: match formula and are unique', () {
    final r = compute(localNow: localMidnight, nowUtc: utcMidnight);
    for (final rem in r) {
      expect(rem.id, PrayerReminder.deterministicId(rem.dayKey, rem.prayerName));
    }
    expect(r.map((e) => e.id).toSet().length, r.length); // benzersiz
  });

  test('skips prayers already passed today', () {
    // 14:00 İstanbul: bugünün fajr/güneş/öğle geçti; ikindi(17:13)+ geleceğe.
    final r = compute(
      localNow: DateTime(2026, 7, 15, 14),
      nowUtc: DateTime.utc(2026, 7, 15, 11),
    );
    final today = r.where((e) => e.dayKey == '2026-07-15');
    final todayNames = today.map((e) => e.prayerName).toSet();
    expect(todayNames.contains(PrayerName.fajr), isFalse); // geçti
    expect(todayNames.contains(PrayerName.asr), isTrue); // gelecek
    expect(r.length, 33); // bugün 3 (asr,akşam,yatsı) + 6×5
  });

  test('reschedule cancels own reminders first, then schedules (no dup)',
      () async {
    final notifications = _FakeNotifications()..exact = true;
    final scheduler = PrayerReminderScheduler(
      calculator: calculator,
      notifications: notifications,
      clock: FixedClock(localMidnight),
    );

    final first = await scheduler.reschedule(coordinates: istanbul, copy: copy);
    expect(notifications.cancelAllCalls, 1);
    expect(notifications.scheduled.length, first.scheduledCount);
    expect(first.exact, isTrue);

    // İkinci kez: önce iptal, sonra aynı sayıda — ÇİFT birikmez.
    await scheduler.reschedule(coordinates: istanbul, copy: copy);
    expect(notifications.cancelAllCalls, 2);
    expect(notifications.scheduled.length, first.scheduledCount);
  });

  test('inexact capability is reported through the outcome', () async {
    final notifications = _FakeNotifications()..exact = false;
    final scheduler = PrayerReminderScheduler(
      calculator: calculator,
      notifications: notifications,
      clock: FixedClock(localMidnight),
    );
    final outcome =
        await scheduler.reschedule(coordinates: istanbul, copy: copy);
    expect(outcome.exact, isFalse);
  });
}

final class _FakeNotifications implements LocalNotificationService {
  final List<PrayerReminder> scheduled = [];
  int cancelAllCalls = 0;
  bool exact = true;

  @override
  Stream<String> get reminderTaps => const Stream.empty();

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionStatus> requestPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<NotificationPermissionStatus> checkPermission() async =>
      NotificationPermissionStatus.granted;

  @override
  Future<bool> canScheduleExact() async => exact;

  @override
  Future<void> schedule(PrayerReminder reminder, {required bool exact}) async =>
      scheduled.add(reminder);

  @override
  Future<void> cancelAllPrayerReminders() async {
    cancelAllCalls++;
    scheduled.clear(); // gerçek servis payload'a göre yalnız kendi id'lerini siler
  }

  @override
  Future<void> openSettings() async {}
}
