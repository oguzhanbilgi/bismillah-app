import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:drift/native.dart';

/// Testler için in-memory Drift veritabanı açar (gerçek SQLite, mock değil).
///
/// sqlite3 3.x native kütüphaneyi Dart native assets üzerinden kendisi
/// sağlar — platforma özel DLL kurulumu/override gerekmez.
AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());
