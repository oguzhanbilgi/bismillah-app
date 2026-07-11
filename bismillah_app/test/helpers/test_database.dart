import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/database_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Testler için in-memory Drift veritabanı açar (gerçek SQLite, mock değil).
///
/// sqlite3 3.x native kütüphaneyi Dart native assets üzerinden kendisi
/// sağlar — platforma özel DLL kurulumu/override gerekmez.
AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());

/// [appDatabaseProvider]'ı in-memory DB ile değiştirir; üretim provider'ı
/// gibi container dispose'unda DB'yi kapatır (sızıntısız test yaşam
/// döngüsü).
Override inMemoryAppDatabaseOverride() {
  return appDatabaseProvider.overrideWith((ref) {
    final database = createTestDatabase();
    ref.onDispose(database.close);
    return database;
  });
}
