import 'package:bismillah_app/features/prayer_times/data/adhan_prayer_time_calculator.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 021 gizlilik: hassas koordinatlar loglanamaz / sync payload'ına
/// giremez. Koordinat yalnız hesap girdisidir; sonuç modeli (DailyPrayerTimes)
/// koordinat TAŞIMAZ, dolayısıyla sync/analytics yoluna ulaşamaz.
void main() {
  const coords = PrayerCoordinates(latitude: 41.0082, longitude: 28.9784);

  test('PrayerCoordinates.toString redakte eder (ham enlem/boylam sızmaz)', () {
    final s = coords.toString();
    expect(s.contains('41.0082'), isFalse);
    expect(s.contains('28.9784'), isFalse);
    expect(s, contains('redacted'));
  });

  test('DailyPrayerTimes koordinat taşımaz (sync/log yoluna ulaşamaz)', () {
    final t = const AdhanPrayerTimeCalculator()
        .calculate(coordinates: coords, date: DateTime(2026, 7, 15));
    // Modelin hiçbir string temsili koordinat içermez.
    final dump = '${t.dayKey}|${t.method}|${t.asrMethod}|'
        '${t.orderedInstants.join('|')}';
    expect(dump.contains('41.0082'), isFalse);
    expect(dump.contains('28.9784'), isFalse);
  });
}
