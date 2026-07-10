import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dayKey = DayKey('2026-07-08');
  final t1 = UtcDateTime(DateTime.utc(2026, 7, 8, 10));
  final t2 = UtcDateTime(DateTime.utc(2026, 7, 8, 12));

  PrayerLogDay day(List<PrayerEntry> entries, {UtcDateTime? updatedAt}) {
    return PrayerLogDay(
      dayKey: dayKey,
      entries: entries,
      updatedAt: updatedAt ?? t1,
      deviceId: DeviceId('device-a'),
    );
  }

  test('completed entry wins over non-completed entry', () {
    final completed = day([
      PrayerEntry(
        prayerName: PrayerName.fajr,
        status: PrayerCompletionStatus.onTime,
        loggedAt: t1,
      ),
    ]);
    final none = day([
      const PrayerEntry(
        prayerName: PrayerName.fajr,
        status: PrayerCompletionStatus.none,
      ),
    ], updatedAt: t2);

    final merged = none.mergeCompletedWins(completed);
    expect(merged.entryFor(PrayerName.fajr)!.isCompleted, isTrue);
    expect(merged.completedCount, 1);
  });

  test('merge is order-independent', () {
    final a = day([
      PrayerEntry(
        prayerName: PrayerName.dhuhr,
        status: PrayerCompletionStatus.late,
        loggedAt: t1,
      ),
      const PrayerEntry(
        prayerName: PrayerName.asr,
        status: PrayerCompletionStatus.none,
      ),
    ]);
    final b = day([
      const PrayerEntry(
        prayerName: PrayerName.dhuhr,
        status: PrayerCompletionStatus.none,
      ),
      PrayerEntry(
        prayerName: PrayerName.asr,
        status: PrayerCompletionStatus.qada,
        loggedAt: t2,
      ),
    ], updatedAt: t2);

    final ab = a.mergeCompletedWins(b);
    final ba = b.mergeCompletedWins(a);
    for (final name in [PrayerName.dhuhr, PrayerName.asr]) {
      expect(ab.entryFor(name), ba.entryFor(name));
    }
    expect(ab.completedCount, 2);
  });

  test('explicit undone tombstone wins only when strictly newer', () {
    final completed = PrayerEntry(
      prayerName: PrayerName.maghrib,
      status: PrayerCompletionStatus.onTime,
      loggedAt: t1,
    );
    final newerUndo = PrayerEntry(
      prayerName: PrayerName.maghrib,
      status: PrayerCompletionStatus.none,
      loggedAt: t2,
      undone: true,
    );
    final olderUndo = PrayerEntry(
      prayerName: PrayerName.maghrib,
      status: PrayerCompletionStatus.none,
      loggedAt: t1,
      undone: true,
    );

    expect(
      PrayerEntry.resolveCompletedWins(completed, newerUndo).isCompleted,
      isFalse,
    );
    expect(
      PrayerEntry.resolveCompletedWins(completed, olderUndo).isCompleted,
      isTrue,
    );
  });

  test('equal-time same-status undone tie-break is order-independent', () {
    // Aynı loggedAt + aynı status, yalnız `undone` farklı: eşitlikte
    // tombstone kazanamaz ve sonuç argüman sırasından bağımsızdır.
    final plainNone = PrayerEntry(
      prayerName: PrayerName.isha,
      status: PrayerCompletionStatus.none,
      loggedAt: t1,
    );
    final undoneNone = PrayerEntry(
      prayerName: PrayerName.isha,
      status: PrayerCompletionStatus.none,
      loggedAt: t1,
      undone: true,
    );

    final ab = PrayerEntry.resolveCompletedWins(plainNone, undoneNone);
    final ba = PrayerEntry.resolveCompletedWins(undoneNone, plainNone);
    expect(ab, ba);
    expect(ab.undone, isFalse);

    // Zaman damgası hiç yokken de deterministik.
    const noTimePlain = PrayerEntry(
      prayerName: PrayerName.isha,
      status: PrayerCompletionStatus.none,
    );
    const noTimeUndone = PrayerEntry(
      prayerName: PrayerName.isha,
      status: PrayerCompletionStatus.none,
      undone: true,
    );
    expect(
      PrayerEntry.resolveCompletedWins(noTimePlain, noTimeUndone),
      PrayerEntry.resolveCompletedWins(noTimeUndone, noTimePlain),
    );
  });

  test('completed entry still beats incomplete entry after tie-break fix', () {
    final completed = PrayerEntry(
      prayerName: PrayerName.fajr,
      status: PrayerCompletionStatus.qada,
      loggedAt: t1,
    );
    final incomplete = PrayerEntry(
      prayerName: PrayerName.fajr,
      status: PrayerCompletionStatus.none,
      loggedAt: t1,
    );
    expect(
      PrayerEntry.resolveCompletedWins(completed, incomplete),
      PrayerEntry.resolveCompletedWins(incomplete, completed),
    );
    expect(
      PrayerEntry.resolveCompletedWins(incomplete, completed).isCompleted,
      isTrue,
    );
  });
}
