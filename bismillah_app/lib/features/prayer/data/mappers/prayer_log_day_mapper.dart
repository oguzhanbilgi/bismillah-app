import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/utils/stable_hash.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:drift/drift.dart';

/// `PrayerLogDay` domain ↔ Drift satırları eşlemesi.
///
/// Drift tipleri bu dosyanın (ve local datasource'un) dışına sızmaz;
/// domain constructor'ları doğrulamanın otoritesidir (geçersiz `dayKey`
/// satırı domain'e dönüşemez). Enum'lar tabloda kararlı İSİMLE durur —
/// dönüşüm `textEnum` üzerinden tip güvenlidir, index kullanılmaz.
abstract final class PrayerLogDayMapper {
  static PrayerLogDay toDomain(
    PrayerLogDayRow day,
    List<PrayerEntryRow> entryRows,
  ) {
    final byName = {for (final row in entryRows) row.prayerName: row};
    return PrayerLogDay(
      dayKey: DayKey(day.dayKey),
      deviceId: DeviceId(day.deviceId),
      updatedAt: day.updatedAt,
      // Deterministik sıra: domain merge çıktısıyla aynı (PrayerName.values).
      entries: [
        for (final name in PrayerName.values)
          if (byName[name] case final row?)
            PrayerEntry(
              prayerName: row.prayerName,
              status: row.status,
              loggedAt: row.loggedAt,
              undone: row.undone,
            ),
      ],
    );
  }

  static PrayerLogDaysCompanion toDayCompanion(PrayerLogDay day) {
    return PrayerLogDaysCompanion.insert(
      dayKey: day.dayKey.value,
      deviceId: day.deviceId.value,
      updatedAt: day.updatedAt,
    );
  }

  static List<PrayerEntriesCompanion> toEntryCompanions(PrayerLogDay day) {
    return [
      for (final entry in day.entries)
        PrayerEntriesCompanion.insert(
          dayKey: day.dayKey.value,
          prayerName: entry.prayerName,
          status: entry.status,
          loggedAt: Value(entry.loggedAt),
          undone: Value(entry.undone),
        ),
    ];
  }

  /// Sync kuyruğu için deterministik içerik hash'i (10 §11 `payloadHash`).
  ///
  /// Kanonik biçim entry sırasından bağımsızdır (PrayerName sırasına
  /// sabitlenir) — aynı içerik her zaman aynı hash'i üretir.
  static String payloadHash(PrayerLogDay day) {
    final sorted = [...day.entries]
      ..sort((a, b) => a.prayerName.index.compareTo(b.prayerName.index));
    final canonical = StringBuffer()
      ..write(day.dayKey.value)
      ..write('|')
      ..write(day.deviceId.value)
      ..write('|')
      ..write(day.updatedAt.value.microsecondsSinceEpoch);
    for (final entry in sorted) {
      canonical
        ..write('|')
        ..write(entry.prayerName.name)
        ..write(':')
        ..write(entry.status.name)
        ..write(':')
        ..write(entry.loggedAt?.value.microsecondsSinceEpoch ?? '')
        ..write(':')
        ..write(entry.undone);
    }
    return StableHash.fnv1a64(canonical.toString());
  }
}
