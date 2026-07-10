import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DayKey accepts valid yyyy-MM-dd and formats via toString', () {
    final key = DayKey('2026-07-08');
    expect(key.value, '2026-07-08');
    expect(key.toString(), '2026-07-08');
  });

  test('DayKey rejects invalid calendar days and malformed input', () {
    expect(() => DayKey('2026-02-30'), throwsArgumentError);
    expect(() => DayKey('2026-7-8'), throwsArgumentError);
    expect(() => DayKey('not-a-key'), throwsArgumentError);
    expect(() => DayKey(''), throwsArgumentError);
  });

  test('DayKey.fromLocal produces zero-padded key from local time', () {
    expect(DayKey.fromLocal(DateTime(2026, 7, 8, 23, 59)).value, '2026-07-08');
    expect(DayKey.fromLocal(DateTime(2026, 1, 1)).value, '2026-01-01');
  });

  test('DayKey lexical order equals chronological order', () {
    final earlier = DayKey('2026-07-08');
    final later = DayKey('2026-07-09');
    expect(earlier.compareTo(later), lessThan(0));
    expect(later.compareTo(earlier), greaterThan(0));
    expect(earlier.compareTo(DayKey('2026-07-08')), 0);
    expect(earlier, DayKey('2026-07-08'));
  });
}
