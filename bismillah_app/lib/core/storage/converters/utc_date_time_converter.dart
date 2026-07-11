import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:drift/drift.dart';

/// [UtcDateTime] ↔ SQLite integer (UTC mikrosaniye epoch) dönüştürücüsü.
///
/// Drift'in varsayılan `dateTime()` kolonu saniye çözünürlüğündedir;
/// çakışma çözümü zaman damgası karşılaştırmalarına dayandığı için
/// (10_DATA_MODEL §14) tam çözünürlük korunur ve UTC garantisi tip
/// düzeyinde taşınır.
final class UtcDateTimeConverter extends TypeConverter<UtcDateTime, int> {
  const UtcDateTimeConverter();

  @override
  UtcDateTime fromSql(int fromDb) =>
      UtcDateTime(DateTime.fromMicrosecondsSinceEpoch(fromDb, isUtc: true));

  @override
  int toSql(UtcDateTime value) => value.value.microsecondsSinceEpoch;
}
