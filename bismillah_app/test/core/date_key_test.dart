import 'package:bismillah_app/core/utils/date_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DateKey.fromLocal produces zero-padded yyyy-MM-dd', () {
    expect(DateKey.fromLocal(DateTime(2026, 7, 8)), '2026-07-08');
    expect(DateKey.fromLocal(DateTime(2026, 12, 31)), '2026-12-31');
  });

  test('DateKey.isValid validates real calendar days', () {
    expect(DateKey.isValid('2026-07-08'), isTrue);
    expect(DateKey.isValid('2026-02-30'), isFalse);
    expect(DateKey.isValid('not-a-key'), isFalse);
  });
}
