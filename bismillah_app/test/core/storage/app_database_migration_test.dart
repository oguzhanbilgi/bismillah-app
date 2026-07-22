import 'dart:io';

import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/converters/utc_date_time_converter.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'schema_snapshot_util.dart';

/// TASK 064 — Drift schema v1 migration & data-safety baseline.
///
/// Bu paket mevcut davranışı SABİTLER (yeni davranış tasarlamaz):
///  1. schemaVersion / PRAGMA user_version == 1 (gerçek DB'den okunur)
///  2. Runtime schema, committed v1 snapshot ile semantik olarak eşleşir
///  3. Representative veri file-backed DB kapanıp yeniden açılınca korunur
///  4. clearAll() üç tabloyu boşaltır, schema'yı bozmaz, DB açık kalır
///  + duplicate/PK, cascade ilişki, sync round-trip, UTC dönüşüm regresyonu
///
/// NOT (blocker): `drift_dev schema` CLI bu sürüm ikilisinde (drift 2.34.1 /
/// drift_dev 2.34.0) derlenmiyor; bu yüzden snapshot Drift JSON yerine
/// runtime `sqlite_master` DDL'inden generated'dır (bkz. schema_snapshot_util).

AppDatabase _memoryDb() => AppDatabase(NativeDatabase.memory());

UtcDateTime _utc(int ms) =>
    UtcDateTime(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true));

/// Bir prayer-log gününü ekler (drift generated companion'lar yerine ham
/// insert kullanılır; testler repository katmanına bağımlı olmasın).
Future<void> _insertPrayerDay(
  AppDatabase db, {
  required String dayKey,
  required String deviceId,
  required int updatedAtMs,
}) {
  return db.customInsert(
    'INSERT INTO prayer_log_days (day_key, device_id, updated_at) '
    'VALUES (?, ?, ?)',
    variables: [
      Variable<String>(dayKey),
      Variable<String>(deviceId),
      Variable<int>(const UtcDateTimeConverter().toSql(_utc(updatedAtMs))),
    ],
  );
}

Future<void> _insertPrayerEntry(
  AppDatabase db, {
  required String dayKey,
  required PrayerName prayerName,
  required PrayerCompletionStatus status,
  int? loggedAtMs,
  bool undone = false,
}) {
  return db.customInsert(
    'INSERT INTO prayer_entries (day_key, prayer_name, status, logged_at, undone) '
    'VALUES (?, ?, ?, ?, ?)',
    variables: [
      Variable<String>(dayKey),
      Variable<String>(prayerName.name),
      Variable<String>(status.name),
      if (loggedAtMs == null)
        const Variable<int>(null)
      else
        Variable<int>(const UtcDateTimeConverter().toSql(_utc(loggedAtMs))),
      Variable<bool>(undone),
    ],
  );
}

Future<void> _insertSyncOperation(
  AppDatabase db, {
  required String operationId,
}) {
  final now = const UtcDateTimeConverter().toSql(_utc(1700000000000));
  return db.customInsert(
    'INSERT INTO sync_operations (operation_id, uid, device_id, entity_type, '
    'entity_id, operation_type, payload_ref, payload_hash, created_at, '
    'updated_at, retry_count, next_retry_at, status, last_error_code, '
    'idempotency_key, sensitivity_class) '
    'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      Variable<String>(operationId),
      const Variable<String>('uid-1'),
      const Variable<String>('device-1'),
      Variable<String>(SyncEntityType.prayerLogDay.name),
      const Variable<String>('2026-07-22'),
      Variable<String>(SyncOperationType.upsert.name),
      const Variable<String>('prayer_log_days/2026-07-22'),
      const Variable<String>('hash-abc'),
      Variable<int>(now),
      Variable<int>(now),
      const Variable<int>(0),
      const Variable<int>(null),
      Variable<String>(SyncOperationStatus.pending.name),
      const Variable<String>(null),
      const Variable<String>('idem-1'),
      Variable<String>(SensitivityClass.high.name),
    ],
  );
}

Future<int> _count(AppDatabase db, String table) async {
  final row = await db
      .customSelect('SELECT COUNT(*) AS c FROM $table')
      .getSingle();
  return row.read<int>('c');
}

void main() {
  // Snapshot yalnız SCHEMA_SNAPSHOT_UPDATE=1 iken yeniden üretilir; normal
  // test koşusunda dosyaya DOKUNULMAZ (deterministik, diff üretmez).
  setUpAll(() async {
    final db = _memoryDb();
    await db.initialize();
    await maybeRegenerateSnapshot(db);
    await db.close();
  });

  group('Test 1 — schema version baseline', () {
    test('schemaVersion and PRAGMA user_version are both 1', () async {
      final db = _memoryDb();
      addTearDown(db.close);
      await db.initialize();

      expect(db.schemaVersion, 1);
      final userVersion = await readSchemaUserVersion(db);
      expect(userVersion, 1, reason: 'DB must be opened at schema v1');
      expect(userVersion, isNot(0));
      expect(userVersion, isNot(2));
    });
  });

  group('Test 2 — exported schema matches runtime schema', () {
    test('committed v1 snapshot equals a fresh runtime schema dump', () async {
      final committed = readCommittedSnapshot();
      expect(
        committed,
        isNotNull,
        reason:
            'drift_schemas/app_database_v1_schema.sql must be committed. '
            'Regenerate with SCHEMA_SNAPSHOT_UPDATE=1.',
      );

      final db = _memoryDb();
      addTearDown(db.close);
      await db.initialize();
      final runtime = await dumpCanonicalSchema(db);

      // Semantik/deterministik karşılaştırma: aynı kanonik DDL üretimi.
      expect(runtime, committed);

      // Snapshot beklenen üç tabloyu ve index'leri taşımalı; hayalî tablo yok.
      expect(committed, contains('CREATE TABLE "prayer_log_days"'));
      expect(committed, contains('CREATE TABLE "prayer_entries"'));
      expect(committed, contains('CREATE TABLE "sync_operations"'));
      expect(committed, contains('prayer_log_days_updated_at'));
      expect(committed, contains('sync_operations_status_next_retry_at'));
      expect(committed, contains('sync_operations_entity'));
      // Gelecekte planlanan ama HENÜZ olmayan tablolar bulunmamalı.
      expect(committed, isNot(contains('quran')));
      expect(committed, isNot(contains('learn')));
    });
  });

  group('Test 3 — representative data survives close and reopen', () {
    test('file-backed DB retains rows and schema v1 after reopen', () async {
      final dir = await Directory.systemTemp.createTemp('bismillah_db_test');
      final file = File('${dir.path}/persist.sqlite');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });

      // 1) Aç, representative veri ekle.
      var db = AppDatabase(NativeDatabase(file));
      await db.initialize();
      await _insertPrayerDay(
        db,
        dayKey: '2026-07-22',
        deviceId: 'device-persist',
        updatedAtMs: 1700000000000,
      );
      await _insertPrayerEntry(
        db,
        dayKey: '2026-07-22',
        prayerName: PrayerName.fajr,
        status: PrayerCompletionStatus.onTime,
        loggedAtMs: 1700000005000,
      );
      await _insertSyncOperation(db, operationId: 'op-persist-1');
      await db.close();

      // 2) Aynı dosyayı yeniden aç.
      db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      await db.initialize();

      // 3) Kayıtlar değerleriyle korunmuş olmalı.
      expect(await _count(db, 'prayer_log_days'), 1);
      expect(await _count(db, 'prayer_entries'), 1);
      expect(await _count(db, 'sync_operations'), 1);

      final day = await db
          .customSelect('SELECT device_id FROM prayer_log_days')
          .getSingle();
      expect(day.read<String>('device_id'), 'device-persist');

      final entry = await db
          .customSelect('SELECT prayer_name, status FROM prayer_entries')
          .getSingle();
      expect(entry.read<String>('prayer_name'), PrayerName.fajr.name);
      expect(entry.read<String>('status'), PrayerCompletionStatus.onTime.name);

      // 4) Schema sürümü değişmemeli.
      expect(await readSchemaUserVersion(db), 1);
    });
  });

  group('Test 4 — clearAll data-safety behavior', () {
    test(
      'clearAll empties all three tables, keeps schema, DB usable',
      () async {
        final db = _memoryDb();
        addTearDown(db.close);
        await db.initialize();

        await _insertPrayerDay(
          db,
          dayKey: '2026-07-22',
          deviceId: 'device-1',
          updatedAtMs: 1700000000000,
        );
        await _insertPrayerEntry(
          db,
          dayKey: '2026-07-22',
          prayerName: PrayerName.dhuhr,
          status: PrayerCompletionStatus.onTime,
        );
        await _insertSyncOperation(db, operationId: 'op-1');

        await db.clearAll();

        expect(await _count(db, 'prayer_log_days'), 0);
        expect(await _count(db, 'prayer_entries'), 0);
        expect(await _count(db, 'sync_operations'), 0);

        // Schema/tablolar duruyor, sürüm 1 kalıyor.
        final tables = await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' "
              "AND name NOT LIKE 'sqlite_%'",
            )
            .get();
        final names = tables.map((r) => r.read<String>('name')).toSet();
        expect(
          names,
          containsAll(['prayer_log_days', 'prayer_entries', 'sync_operations']),
        );
        expect(await readSchemaUserVersion(db), 1);

        // clearAll sonrası tekrar veri eklenebilmeli.
        await _insertPrayerDay(
          db,
          dayKey: '2026-07-23',
          deviceId: 'device-2',
          updatedAtMs: 1700000100000,
        );
        expect(await _count(db, 'prayer_log_days'), 1);
      },
    );
  });

  group('Test 5 — schema constraint regression (existing behavior)', () {
    test('prayer_log_days rejects duplicate day_key (PK)', () async {
      final db = _memoryDb();
      addTearDown(db.close);
      await db.initialize();
      await _insertPrayerDay(
        db,
        dayKey: '2026-07-22',
        deviceId: 'd1',
        updatedAtMs: 1700000000000,
      );
      await expectLater(
        _insertPrayerDay(
          db,
          dayKey: '2026-07-22',
          deviceId: 'd2',
          updatedAtMs: 1700000001000,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'prayer_entries composite PK rejects duplicate (day_key, prayer_name)',
      () async {
        final db = _memoryDb();
        addTearDown(db.close);
        await db.initialize();
        await _insertPrayerDay(
          db,
          dayKey: '2026-07-22',
          deviceId: 'd1',
          updatedAtMs: 1700000000000,
        );
        await _insertPrayerEntry(
          db,
          dayKey: '2026-07-22',
          prayerName: PrayerName.asr,
          status: PrayerCompletionStatus.onTime,
        );
        await expectLater(
          _insertPrayerEntry(
            db,
            dayKey: '2026-07-22',
            prayerName: PrayerName.asr,
            status: PrayerCompletionStatus.qada,
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test(
      'deleting a day cascades to its prayer_entries (FK ON DELETE CASCADE)',
      () async {
        final db = _memoryDb();
        addTearDown(db.close);
        await db.initialize();
        await _insertPrayerDay(
          db,
          dayKey: '2026-07-22',
          deviceId: 'd1',
          updatedAtMs: 1700000000000,
        );
        await _insertPrayerEntry(
          db,
          dayKey: '2026-07-22',
          prayerName: PrayerName.maghrib,
          status: PrayerCompletionStatus.onTime,
        );
        expect(await _count(db, 'prayer_entries'), 1);

        await db.customStatement(
          "DELETE FROM prayer_log_days WHERE day_key = '2026-07-22'",
        );
        expect(
          await _count(db, 'prayer_entries'),
          0,
          reason: 'FK ON DELETE CASCADE must remove child entries',
        );
      },
    );

    test(
      'sync_operation round-trips required fields; UTC ints unchanged',
      () async {
        final db = _memoryDb();
        addTearDown(db.close);
        await db.initialize();
        await _insertSyncOperation(db, operationId: 'op-rt-1');

        final row = await db
            .customSelect(
              'SELECT operation_id, entity_type, operation_type, status, '
              'created_at, sensitivity_class FROM sync_operations',
            )
            .getSingle();
        expect(row.read<String>('operation_id'), 'op-rt-1');
        expect(
          row.read<String>('entity_type'),
          SyncEntityType.prayerLogDay.name,
        );
        expect(
          row.read<String>('operation_type'),
          SyncOperationType.upsert.name,
        );
        expect(row.read<String>('status'), SyncOperationStatus.pending.name);
        expect(
          row.read<String>('sensitivity_class'),
          SensitivityClass.high.name,
        );
        // UTC değeri veritabanında bozulmadan (aynı ms epoch) durur.
        expect(
          row.read<int>('created_at'),
          const UtcDateTimeConverter().toSql(_utc(1700000000000)),
        );
      },
    );
  });
}
