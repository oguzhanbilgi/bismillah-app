import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/prayer_reminders/application/prayer_reminder_tap_router.dart';
import 'package:bismillah_app/features/prayer_reminders/domain/prayer_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 022: payload gizliliği + dokunuş yönlendirmesi.
void main() {
  final reminder = PrayerReminder(
    id: PrayerReminder.deterministicId('2026-07-15', PrayerName.asr),
    prayerName: PrayerName.asr,
    dayKey: '2026-07-15',
    scheduledUtc: DateTime.utc(2026, 7, 15, 14, 13),
    title: 'Namaz vakti',
    body: 'İkindi vakti için sakin bir hatırlatma.',
  );

  test('payload carries only routing keys — no coordinates or UID', () {
    expect(reminder.payload, 'prayer:asr:2026-07-15');
    // Koordinat/UID benzeri hiçbir veri yok.
    expect(reminder.payload.contains(RegExp(r'\d+\.\d+')), isFalse); // enlem/boylam yok
    expect(reminder.payload.toLowerCase().contains('uid'), isFalse);
    expect(reminder.payload.toLowerCase().contains('user'), isFalse);
  });

  test('deterministic id encodes date + prayer', () {
    expect(reminder.id, 202607150 + PrayerName.asr.index);
  });

  test('tap on a prayer payload routes to Prayer tab', () {
    var routed = false;
    routeReminderTap('prayer:asr:2026-07-15', () => routed = true);
    expect(routed, isTrue);
  });

  test('tap on a non-prayer payload does NOT route', () {
    var routed = false;
    routeReminderTap('other:whatever', () => routed = true);
    expect(routed, isFalse);
    expect(PrayerReminder.isPrayerPayload('other:whatever'), isFalse);
  });
}
