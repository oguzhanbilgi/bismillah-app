import 'package:bismillah_app/features/prayer_times/data/adhan_prayer_time_calculator.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_coordinates.dart';
import 'package:bismillah_app/features/prayer_times/domain/prayer_time_calculation_method.dart';
import 'package:flutter_test/flutter_test.dart';

/// TASK 021: offline namaz vakti motoru testleri + Diyanet karşılaştırması.
void main() {
  const calc = AdhanPrayerTimeCalculator();
  const istanbul = PrayerCoordinates(latitude: 41.0082, longitude: 28.9784);
  final date = DateTime(2026, 7, 15);

  test('returns all six times (fajr, sunrise, dhuhr, asr, maghrib, isha)', () {
    final t = calc.calculate(coordinates: istanbul, date: date);
    for (final instant in t.orderedInstants) {
      expect(instant.isUtc, isTrue); // model UTC instant taşır
    }
    expect(t.orderedInstants, hasLength(6));
  });

  test('times are chronologically ordered', () {
    final t = calc.calculate(coordinates: istanbul, date: date);
    expect(t.isChronological, isTrue);
  });

  test('Türkiye/Diyanet method + standard Asr stored explicitly', () {
    final t = calc.calculate(coordinates: istanbul, date: date);
    expect(t.method, PrayerTimeCalculationMethod.turkiyeDiyanet);
    expect(t.asrMethod, AsrCalculationMethod.standard);
    expect(t.dayKey, '2026-07-15');
  });

  test('hanafi Asr is later than standard Asr (madhab-aware)', () {
    final std = calc.calculate(coordinates: istanbul, date: date);
    final hanafi = calc.calculate(
      coordinates: istanbul,
      date: date,
      asrMethod: AsrCalculationMethod.hanafi,
    );
    expect(hanafi.asr.isAfter(std.asr), isTrue);
  });

  test('deterministic: same coordinates + date → identical output', () {
    final a = calc.calculate(coordinates: istanbul, date: date);
    final b = calc.calculate(coordinates: istanbul, date: date);
    expect(a.orderedInstants, b.orderedInstants);
  });

  test('UTC→Türkiye-yerel (UTC+3) dönüşümü dakika hassasiyetini korur', () {
    final t = calc.calculate(coordinates: istanbul, date: date);
    // Diyanet İstanbul 15 Tem 2026 Öğle 13:15 (yerel). Motor UTC + 3sa.
    final dhuhrLocal = t.dhuhr.add(const Duration(hours: 3));
    expect(dhuhrLocal.hour, 13);
    expect(dhuhrLocal.minute, 15);
  });

  group('Diyanet resmi takvimi karşılaştırması', () {
    // Kaynak: namazvakitleri.diyanet.gov.tr (Diyanet İşleri Başkanlığı),
    // 2026-07-12'de alındı. Sıra: Fajr(İmsak) Sunrise(Güneş) Dhuhr(Öğle)
    // Asr(İkindi) Maghrib(Akşam) Isha(Yatsı). Değerler Türkiye yerel saati
    // (UTC+3, yaz saati yok). Bu bir DİYANET YAKLAŞIMIDIR; resmi/sertifikalı
    // parite İDDİA EDİLMEZ. Gözlenen maks. fark ≤1 dk (aşağıdaki tolerans 2).
    const fixtures = <_DiyanetFixture>[
      // İstanbul
      _DiyanetFixture('İstanbul', 41.0082, 28.9784, 2026, 7, 15,
          ['03:44', '05:38', '13:15', '17:13', '20:43', '22:28']),
      _DiyanetFixture('İstanbul', 41.0082, 28.9784, 2026, 1, 15,
          ['06:50', '08:20', '13:18', '15:45', '18:07', '19:31']),
      // Ankara
      _DiyanetFixture('Ankara', 39.9334, 32.8597, 2026, 7, 15,
          ['03:35', '05:25', '13:00', '16:56', '20:24', '22:06']),
      _DiyanetFixture('Ankara', 39.9334, 32.8597, 2026, 1, 15,
          ['06:33', '08:02', '13:03', '15:32', '17:54', '19:17']),
      // Tatvan (Bitlis) — doğu Türkiye
      _DiyanetFixture('Tatvan', 38.5017, 42.2797, 2026, 7, 15,
          ['03:06', '04:52', '12:22', '16:15', '19:42', '21:20']),
      _DiyanetFixture('Tatvan', 38.5017, 42.2797, 2026, 1, 15,
          ['05:54', '07:20', '12:25', '14:58', '17:20', '18:41']),
    ];

    // Diyanet temkin/yuvarlama farkı için makul tolerans. Motor tek şehre
    // GÖRE AYARLANMAZ; bu yalnız kabul eşiğidir (gözlenen maks. 1 dk).
    const tolerance = Duration(minutes: 2);

    for (final f in fixtures) {
      test('${f.city} ${f.y}-${f.m}-${f.d} tüm vakitler ±2 dk içinde', () {
        final t = calc.calculate(
          coordinates: PrayerCoordinates(latitude: f.lat, longitude: f.lng),
          date: DateTime(f.y, f.m, f.d),
        );
        final engineLocal = [
          t.fajr,
          t.sunrise,
          t.dhuhr,
          t.asr,
          t.maghrib,
          t.isha,
        ].map((u) => u.add(const Duration(hours: 3))).toList();

        for (var i = 0; i < 6; i++) {
          final expected = _parse(f.y, f.m, f.d, f.times[i]);
          final diff = engineLocal[i].difference(expected).abs();
          expect(
            diff <= tolerance,
            isTrue,
            reason: '${f.city} ${f.times[i]} vakit#$i: motor '
                '${engineLocal[i]} Diyanet $expected (fark $diff)',
          );
        }
      });
    }
  });
}

/// Diyanet yerel saatini UTC-kind duvar-saati olarak kurar; motor çıktısı
/// da UTC-kind (+3sa) olduğundan `.difference` DUVAR-SAATİ farkını verir
/// (test runner timezone'undan bağımsız — kind karışımı yok).
DateTime _parse(int y, int m, int d, String hm) {
  final parts = hm.split(':');
  return DateTime.utc(y, m, d, int.parse(parts[0]), int.parse(parts[1]));
}

final class _DiyanetFixture {
  const _DiyanetFixture(
    this.city,
    this.lat,
    this.lng,
    this.y,
    this.m,
    this.d,
    this.times,
  );

  final String city;
  final double lat;
  final double lng;
  final int y;
  final int m;
  final int d;
  final List<String> times;
}
