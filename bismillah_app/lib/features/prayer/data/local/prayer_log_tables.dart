import 'package:bismillah_app/core/storage/converters/utc_date_time_converter.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:drift/drift.dart';

/// Namaz gün-belgesi tablosu (10_DATA_MODEL §7 `PrayerLogDayModel`).
///
/// Gün-başına-tek-kayıt deseni: `dayKey` birincil anahtardır (unique).
/// YÜKSEK hassasiyet sınıfı — bu tablo asla loglanmaz/analytics'e çıkmaz;
/// sınıf bildirimi domain entity'sindedir (`PrayerLogDay.sensitivityClass`).
@DataClassName('PrayerLogDayRow')
@TableIndex(name: 'prayer_log_days_updated_at', columns: {#updatedAt})
class PrayerLogDays extends Table {
  /// `yyyy-MM-dd` (geçerlilik domain `DayKey` tipinde doğrulanır).
  TextColumn get dayKey => text()();

  TextColumn get deviceId => text()();

  /// Pull-merge imleç sorgularının index'li alanı (10 §25).
  IntColumn get updatedAt => integer().map(const UtcDateTimeConverter())();

  @override
  Set<Column<Object>> get primaryKey => {dayKey};
}

/// Tek vakit kaydı — gün belgesine gömülü kavram, normalize çocuk tablo
/// olarak saklanır (10 §7 hardening biçim (c): ham Map YASAK).
///
/// Enum'lar KARARLI İSİMLE saklanır (`textEnum` → `name`), asla index'le:
/// enum'a eleman eklemek kalıcı veriyi bozamaz.
@DataClassName('PrayerEntryRow')
class PrayerEntries extends Table {
  TextColumn get dayKey => text().references(
    PrayerLogDays,
    #dayKey,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get prayerName => textEnum<PrayerName>()();

  TextColumn get status => textEnum<PrayerCompletionStatus>()();

  /// Yerel niyet zamanı; çakışma tie-break ölçütü (10 §14-1, §27-10).
  IntColumn get loggedAt =>
      integer().map(const UtcDateTimeConverter()).nullable()();

  /// Açık geri alma tombstone'u (TASK 012B deterministik merge girdisi).
  BoolColumn get undone => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {dayKey, prayerName};
}
