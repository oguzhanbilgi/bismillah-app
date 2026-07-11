import 'package:bismillah_app/core/database/local_database.dart';
import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/storage/converters/utc_date_time_converter.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/data/local/prayer_log_tables.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_completion_status.dart';
import 'package:bismillah_app/features/prayer/domain/value_objects/prayer_name.dart';
import 'package:bismillah_app/features/sync/data/local/sync_operation_table.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Bismillah lokal veritabanı (TASK 013 kararı: **Drift / SQLite**).
///
/// Local-first mimarinin source of truth'u (06 §14; 10 §1): UI daima
/// buradan beslenir, Firestore sonradan eklenecek gölgedir. Tablo
/// tanımları feature data katmanlarında yaşar (06 §7); şema kaydı ve
/// migration çatısı burada toplanır.
///
/// **Şifreleme henüz YOKTUR** — MVP'de platform sandbox yeterlidir
/// (10 §19); SQLCipher geçişi ayrı görevdir (doc 11 §12-1) ve AI sohbet
/// persistence'ıyla birlikte ele alınacaktır. Yedekleme/export da bu
/// katmanın işi değildir (ayrı görev, 10 §23).
@DriftDatabase(tables: [PrayerLogDays, PrayerEntries, SyncOperations])
class AppDatabase extends _$AppDatabase implements LocalDatabase {
  AppDatabase(super.executor);

  /// Üretim bağlantısı: drift_flutter platforma uygun dosya DB'si açar.
  /// Testler `NativeDatabase.memory()` ile ana constructor'ı kullanır.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'bismillah'));

  bool _initialized = false;

  /// Şema v1 — TASK 014 dilimi (PrayerLogDay + SyncOperation).
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Placeholder (10 §22): şema v2 ile birlikte sürümlü, idempotent
      // migration adımları ve drift_dev şema export/önce-sonra fixture
      // testleri ZORUNLU hâle gelir. Kuyruk tablosu migration'da asla
      // drop edilemez (bekleyen op korunumu, 10 §22).
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // Drift tembel açar; şema kurulumunu bootstrap anına sabitlemek için
    // önemsiz bir sorgu çalıştırılır (soğuk açılış bütçesi 06 §8).
    await customSelect('SELECT 1').get();
    _initialized = true;
  }

  /// Hesap silme akışının lokal ayağı (10 §15): tüm kullanıcı verisi +
  /// kuyruk + cache tek transaction'da temizlenir.
  @override
  Future<void> clearAll() {
    return transaction(() async {
      await delete(prayerEntries).go();
      await delete(prayerLogDays).go();
      await delete(syncOperations).go();
    });
  }

  @override
  Future<void> close() {
    _initialized = false;
    return super.close();
  }
}
