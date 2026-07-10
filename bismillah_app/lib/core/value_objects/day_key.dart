import 'package:bismillah_app/core/utils/date_key.dart';

/// Gün anahtarı değer nesnesi (10_DATA_MODEL §6): `yyyy-MM-dd`.
///
/// Kullanıcının yazım anındaki YEREL gününe kilitlenir; timezone sonradan
/// değişse bile geçmiş anahtarlar kaymaz (§27-11). Geçersiz takvim günü
/// bu tiple temsil edilemez.
final class DayKey implements Comparable<DayKey> {
  DayKey(this.value) {
    if (!DateKey.isValid(value)) {
      throw ArgumentError.value(
        value,
        'value',
        'DayKey geçerli bir yyyy-MM-dd günü olmalı',
      );
    }
  }

  /// Verilen yerel zamandan gün anahtarı üretir.
  factory DayKey.fromLocal(DateTime local) => DayKey(DateKey.fromLocal(local));

  final String value;

  /// Sözlüksel sıra = kronolojik sıra (yyyy-MM-dd garantisi).
  @override
  int compareTo(DayKey other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is DayKey && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
