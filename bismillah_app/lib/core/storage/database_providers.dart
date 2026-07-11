import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [AppDatabase] yaşam döngüsü provider'ı.
///
/// Uygulama TEK paylaşımlı veritabanı örneği açar; container dispose
/// olduğunda bağlantı kapatılır. Drift tipleri bu dosyanın ve data
/// katmanlarının dışına sızmaz — UI/application yalnız repository
/// interface provider'larını okur (06_FLUTTER_ARCHITECTURE §11).
///
/// Testler in-memory örnekle override eder
/// (`test/helpers/test_database.dart` → `inMemoryAppDatabaseOverride`).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.open();
  ref.onDispose(database.close);
  return database;
});
