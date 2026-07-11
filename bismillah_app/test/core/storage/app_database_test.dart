import 'package:bismillah_app/core/database/local_database.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('database opens and schema v1 initializes with expected tables',
      () async {
    await db.initialize();
    expect(db.isInitialized, isTrue);
    expect(db.schemaVersion, 1);

    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        )
        .get();
    final names = tables.map((row) => row.read<String>('name')).toSet();
    expect(names, containsAll(['prayer_log_days', 'prayer_entries',
        'sync_operations']));
  });

  test('hot-query indexes exist (status+nextRetryAt, entity)', () async {
    await db.initialize();
    final indexes = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index'",
        )
        .get();
    final names = indexes.map((row) => row.read<String>('name')).toSet();
    expect(names, contains('sync_operations_status_next_retry_at'));
    expect(names, contains('sync_operations_entity'));
    expect(names, contains('prayer_log_days_updated_at'));
  });

  test('AppDatabase fulfils the package-agnostic LocalDatabase contract',
      () async {
    expect(db, isA<LocalDatabase>());
    await db.initialize();
    await db.clearAll(); // boş tablolarda dahi hatasız çalışmalı
    await db.close();
    expect(db.isInitialized, isFalse);
  });

  // TODO(TASK 015+): Şema v2 doğduğu anda drift_dev şema export'u ve
  // önce-sonra fixture migration testleri ZORUNLU hâle gelir
  // (10_DATA_MODEL §22/§28). v1 tek şema olduğu için burada yalnız
  // onCreate yolu test edilir.
}
