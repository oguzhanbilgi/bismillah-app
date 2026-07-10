/// UTC'ye normalize edilmiş zaman damgası.
///
/// Domain katmanında çıplak `DateTime` yerine kullanılır; yerel/UTC
/// karışıklığı tip düzeyinde engellenir. Çakışma/imleç kararlarında
/// sunucu zaman damgası esastır (10_DATA_MODEL §13, §27-10) — bu tip
/// yalnız taşıyıcıdır, "şimdi" üretmek `AppClock`'un işidir.
final class UtcDateTime implements Comparable<UtcDateTime> {
  UtcDateTime(DateTime value) : value = value.toUtc();

  final DateTime value;

  bool isAfter(UtcDateTime other) => value.isAfter(other.value);
  bool isBefore(UtcDateTime other) => value.isBefore(other.value);
  Duration difference(UtcDateTime other) => value.difference(other.value);
  UtcDateTime add(Duration duration) => UtcDateTime(value.add(duration));

  @override
  int compareTo(UtcDateTime other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) =>
      other is UtcDateTime && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toIso8601String();
}
