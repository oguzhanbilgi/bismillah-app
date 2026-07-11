import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/storage/converters/utc_date_time_converter.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:drift/drift.dart';

/// Kalıcı sync kuyruğu tablosu (10_DATA_MODEL §7 `SyncOperationModel`,
/// alan seti §11).
///
/// - Enum'lar KARARLI İSİMLE saklanır (`textEnum`), asla index'le.
/// - `status + nextRetryAt` kuyruğun en sıcak sorgusudur (10 §25) —
///   index'lidir; `entityType + entityId` birleştirme sorgusu içindir.
/// - Payload KOPYALANMAZ: `payloadRef` güncel lokal kayda referanstır
///   (tek doğruluk kaynağı korunur, §11).
/// - Restricted sınıf payload domain constructor'ında reddedilir —
///   bu tabloya hiç ulaşamaz.
@DataClassName('SyncOperationRow')
@TableIndex(
  name: 'sync_operations_status_next_retry_at',
  columns: {#status, #nextRetryAt},
)
@TableIndex(name: 'sync_operations_entity', columns: {#entityType, #entityId})
class SyncOperations extends Table {
  TextColumn get operationId => text()();

  TextColumn get uid => text()();

  TextColumn get deviceId => text()();

  TextColumn get entityType => textEnum<SyncEntityType>()();

  TextColumn get entityId => text()();

  TextColumn get operationType => textEnum<SyncOperationType>()();

  TextColumn get payloadRef => text()();

  TextColumn get payloadHash => text()();

  IntColumn get createdAt => integer().map(const UtcDateTimeConverter())();

  IntColumn get updatedAt => integer().map(const UtcDateTimeConverter())();

  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  IntColumn get nextRetryAt =>
      integer().map(const UtcDateTimeConverter()).nullable()();

  TextColumn get status => textEnum<SyncOperationStatus>()();

  /// Son hata SINIFI (kova) — ham hata mesajı saklanmaz (10 §11).
  TextColumn get lastErrorCode => text().nullable()();

  TextColumn get idempotencyKey => text()();

  TextColumn get sensitivityClass => textEnum<SensitivityClass>()();

  @override
  Set<Column<Object>> get primaryKey => {operationId};
}
