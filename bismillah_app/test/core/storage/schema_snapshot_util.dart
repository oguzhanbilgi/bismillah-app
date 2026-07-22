import 'dart:io';

import 'package:bismillah_app/core/storage/app_database.dart';

/// TASK 064 — Kanonik Drift schema v1 snapshot yardımcıları.
///
/// NEDEN elle değil generated: kurulu `drift_dev` (2.34.0) + `drift`
/// (2.34.1) ikilisinde resmî `drift_dev schema` CLI'ı derlenmiyor
/// (drift3_preview API skew: `GeneratedDatabase.schema` / `allSchemaEntities`).
/// Bu yüzden snapshot, çalışan veritabanının KENDİ `sqlite_master` DDL'inden
/// deterministik olarak üretilir — hiçbir SQL elle yazılmaz/düzenlenmez.
/// Kanonik record ayrıca runtime ile karşılaştırılıp schema drift'ini yakalar.

/// Committed kanonik snapshot dosyasının repo-içi yolu (app dizinine göre).
const String kSchemaV1SnapshotPath = 'drift_schemas/app_database_v1_schema.sql';

/// Çalışan veritabanının kanonik, deterministik schema DDL'ini üretir.
///
/// Yalnız kullanıcı tabloları ve index'leri (SQLite iç nesneleri hariç),
/// tür ve isme göre sıralı; satır sonları normalize edilir. Çıktı makineden
/// bağımsızdır (path/timestamp içermez).
Future<String> dumpCanonicalSchema(AppDatabase db) async {
  final userVersion = await _readUserVersion(db);

  final rows = await db
      .customSelect(
        'SELECT type, name, sql FROM sqlite_master '
        "WHERE type IN ('table', 'index') "
        "AND name NOT LIKE 'sqlite_%' "
        'AND sql IS NOT NULL '
        'ORDER BY type, name',
      )
      .get();

  final buffer = StringBuffer()
    ..writeln('-- Bismillah AppDatabase canonical schema snapshot')
    ..writeln('-- GENERATED from the running database (sqlite_master).')
    ..writeln('-- Do NOT edit by hand. See drift_schemas/README.md.')
    ..writeln('-- schemaVersion / PRAGMA user_version: $userVersion')
    ..writeln();

  final statements = [
    for (final row in rows)
      '${row.read<String>('sql').trim().replaceAll('\r\n', '\n')};',
  ];
  buffer.write(statements.join('\n\n'));

  // Tek sonlandırıcı satır sonu; EOF'ta fazladan boş satır bırakılmaz
  // (deterministik ve `git diff --check` temiz).
  return '${buffer.toString().trimRight()}\n';
}

/// Drift'in veritabanına yazdığı schema sürümü (`PRAGMA user_version`).
Future<int> _readUserVersion(AppDatabase db) async {
  final result = await db.customSelect('PRAGMA user_version').getSingle();
  return result.read<int>('user_version');
}

/// Drift'in schema sürümünü veritabanına gerçekten yazdığından emin olmak
/// için testlerde çağrılır (tembel açılışta bir sorgu tetikler).
Future<int> readSchemaUserVersion(AppDatabase db) => _readUserVersion(db);

/// Committed snapshot dosyasını okur (yoksa null).
String? readCommittedSnapshot() {
  final file = File(kSchemaV1SnapshotPath);
  return file.existsSync()
      ? file.readAsStringSync().replaceAll('\r\n', '\n')
      : null;
}

/// Snapshot'ı yeniden üretir (yalnız `SCHEMA_SNAPSHOT_UPDATE=1` iken).
///
/// Bu, "generated" snapshot akışıdır: dosya içeriği runtime DB'den gelir.
Future<void> maybeRegenerateSnapshot(AppDatabase db) async {
  if (Platform.environment['SCHEMA_SNAPSHOT_UPDATE'] != '1') return;
  final content = await dumpCanonicalSchema(db);
  final file = File(kSchemaV1SnapshotPath);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}
