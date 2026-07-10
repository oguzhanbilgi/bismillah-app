import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/dhikr/domain/entities/dhikr_session_day.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dayKey = DayKey('2026-07-08');
  final t1 = UtcDateTime(DateTime.utc(2026, 7, 8, 10));
  final t2 = UtcDateTime(DateTime.utc(2026, 7, 8, 12));
  final morning = EntityId('set-morning');
  final evening = EntityId('set-evening');
  final custom = EntityId('set-custom');

  test('mergeMaxUnion takes max counts and unions completed sets', () {
    final deviceA = DhikrSessionDay(
      dayKey: dayKey,
      completedSetIds: [morning],
      counts: [
        DhikrCountEntry(setId: morning, count: 33),
        DhikrCountEntry(setId: custom, count: 10),
      ],
      updatedAt: t1,
    );
    final deviceB = DhikrSessionDay(
      dayKey: dayKey,
      completedSetIds: [evening],
      counts: [
        DhikrCountEntry(setId: morning, count: 21),
        DhikrCountEntry(setId: evening, count: 99),
      ],
      updatedAt: t2,
    );

    final merged = deviceA.mergeMaxUnion(deviceB);

    // Sayım kaybolmaz: set bazında max.
    expect(merged.countFor(morning), 33);
    expect(merged.countFor(evening), 99);
    expect(merged.countFor(custom), 10);
    // Tamamlanan setler union.
    expect(merged.completedSetIds.toSet(), {morning, evening});
    // Metadata en yeni updatedAt.
    expect(merged.updatedAt, t2);
  });

  test('mergeMaxUnion is order-independent', () {
    final deviceA = DhikrSessionDay(
      dayKey: dayKey,
      completedSetIds: [morning, custom],
      counts: [
        DhikrCountEntry(setId: morning, count: 33),
        DhikrCountEntry(setId: custom, count: 7),
      ],
      updatedAt: t1,
    );
    final deviceB = DhikrSessionDay(
      dayKey: dayKey,
      completedSetIds: [evening],
      counts: [
        DhikrCountEntry(setId: morning, count: 40),
        DhikrCountEntry(setId: evening, count: 5),
      ],
      updatedAt: t2,
    );

    final ab = deviceA.mergeMaxUnion(deviceB);
    final ba = deviceB.mergeMaxUnion(deviceA);

    expect(ab.dayKey, ba.dayKey);
    expect(ab.updatedAt, ba.updatedAt);
    expect(ab.completedSetIds, ba.completedSetIds);
    expect(ab.counts.length, ba.counts.length);
    for (final setId in [morning, evening, custom]) {
      expect(ab.countFor(setId), ba.countFor(setId));
    }
    // Deterministik sıralama: counts setId'ye göre sıralı gelir.
    final orderedIds = ab.counts.map((e) => e.setId.value).toList();
    expect(orderedIds, [...orderedIds]..sort());
  });

  test('mergeMaxUnion loses no count from either side', () {
    final onlyA = DhikrSessionDay(
      dayKey: dayKey,
      completedSetIds: const [],
      counts: [DhikrCountEntry(setId: custom, count: 3)],
      updatedAt: t1,
    );
    final onlyB = DhikrSessionDay(
      dayKey: dayKey,
      completedSetIds: const [],
      counts: [DhikrCountEntry(setId: evening, count: 12)],
      updatedAt: t1,
    );

    final merged = onlyA.mergeMaxUnion(onlyB);
    expect(merged.countFor(custom), 3);
    expect(merged.countFor(evening), 12);
  });
}
