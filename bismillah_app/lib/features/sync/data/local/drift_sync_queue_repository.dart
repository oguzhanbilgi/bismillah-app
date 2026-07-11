import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/data/mappers/sync_operation_mapper.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:drift/drift.dart';

/// Drift tabanlı kalıcı sync kuyruğu (10_DATA_MODEL §10–12).
///
/// YALNIZ kuyruk kalıcılığı — SyncEngine/Firestore yazımı sonraki
/// görevlerdedir. Uygunluk kararının otoritesi domain'dir:
/// [SyncOperation.isEligibleForRetry] SQL ön-filtresinin ÜZERİNDE
/// çalıştırılır; SQL yalnız aday satırları daraltır.
final class DriftSyncQueueRepository implements SyncQueueRepository {
  DriftSyncQueueRepository(
    this._db, {
    this._clock = const SystemClock(),
  });

  final AppDatabase _db;
  final AppClock _clock;

  /// Push önceliği (10 §12-3): ibadet kayıtları > diğer kullanıcı verisi >
  /// ayarlar > attribution.
  static const List<SyncEntityType> _pushPriority = [
    SyncEntityType.prayerLogDay,
    SyncEntityType.dhikrSessionDay,
    SyncEntityType.quranProgress,
    SyncEntityType.dailyPlan,
    SyncEntityType.duaFavorite,
    SyncEntityType.achievement,
    SyncEntityType.assistantMessage,
    SyncEntityType.profile,
    SyncEntityType.settings,
    SyncEntityType.attribution,
  ];

  /// Kuyrukta "bekleyen iş" sayılan durumlar.
  static const List<SyncOperationStatus> _outstanding = [
    SyncOperationStatus.pending,
    SyncOperationStatus.failedRetryable,
  ];

  UtcDateTime _now() => UtcDateTime(_clock.nowUtc());

  @override
  ResultFuture<void> enqueue(SyncOperation operation) async {
    try {
      await _db.transaction(() => enqueueInSession(operation));
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  /// Çağıranın transaction'ına KATILAN enqueue — §12-2'nin "entity yazımı +
  /// kuyruk aynı transaction blokta" kuralını repository'ler arası paylaşır
  /// (Drift transaction'ları zone tabanlıdır: aynı [AppDatabase] üzerinden
  /// yapılan tüm sorgular dış transaction'a katılır). Hata durumunda
  /// exception fırlatır ki dış transaction geri alınsın.
  ///
  /// Kuyruk birleştirme kuralı (10 §11): aynı `entityType+entityId` için
  /// bekleyen op varsa YENİ op yaratılmaz — mevcut kayıt tazelenir
  /// (payloadRef zaten güncel kaydı gösterir; idempotencyKey yeni
  /// payloadHash'ten yeniden türetilir, operationId korunur).
  Future<void> enqueueInSession(SyncOperation operation) async {
    final existing =
        await (_db.select(_db.syncOperations)..where(
              (t) =>
                  t.entityType.equalsValue(operation.entityType) &
                  t.entityId.equals(operation.entityId.value) &
                  t.status.isInValues(_outstanding),
            ))
            .getSingleOrNull();

    if (existing == null) {
      await _db
          .into(_db.syncOperations)
          .insert(SyncOperationMapper.toCompanion(operation));
      return;
    }

    final refreshedKey = IdempotencyKey.derive(
      operationId: OperationId(existing.operationId),
      payloadHash: operation.payloadHash,
    );
    await (_db.update(_db.syncOperations)
          ..where((t) => t.operationId.equals(existing.operationId)))
        .write(
          SyncOperationsCompanion(
            payloadRef: Value(operation.payloadRef),
            payloadHash: Value(operation.payloadHash),
            updatedAt: Value(operation.updatedAt),
            idempotencyKey: Value(refreshedKey.value),
          ),
        );
  }

  @override
  ResultFuture<List<SyncOperation>> nextEligible(
    UtcDateTime now, {
    required int limit,
  }) async {
    try {
      final rows =
          await (_db.select(_db.syncOperations)
                ..where((t) => t.status.isInValues(_outstanding)))
              .get();
      final eligible =
          rows
              .map(SyncOperationMapper.toDomain)
              .where((op) => op.isEligibleForRetry(now))
              .toList()
            ..sort(_byPriorityThenAge);
      return Result.success(eligible.take(limit).toList());
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  static int _byPriorityThenAge(SyncOperation a, SyncOperation b) {
    final priority = _pushPriority
        .indexOf(a.entityType)
        .compareTo(_pushPriority.indexOf(b.entityType));
    if (priority != 0) {
      return priority;
    }
    final age = a.createdAt.compareTo(b.createdAt);
    if (age != 0) {
      return age;
    }
    return a.operationId.value.compareTo(b.operationId.value);
  }

  @override
  ResultFuture<void> markAcked(OperationId operationId) async {
    try {
      // Spec §11: `acked` op ANINDA silinir — kuyruk şişmez.
      await (_db.delete(_db.syncOperations)
            ..where((t) => t.operationId.equals(operationId.value)))
          .go();
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> markFailedRetryable(
    OperationId operationId, {
    required UtcDateTime nextRetryAt,
    required String errorClass,
  }) async {
    try {
      await _db.transaction(() async {
        final row =
            await (_db.select(_db.syncOperations)
                  ..where((t) => t.operationId.equals(operationId.value)))
                .getSingleOrNull();
        if (row == null) {
          return;
        }
        await (_db.update(_db.syncOperations)
              ..where((t) => t.operationId.equals(operationId.value)))
            .write(
              SyncOperationsCompanion(
                status: const Value(SyncOperationStatus.failedRetryable),
                retryCount: Value(row.retryCount + 1),
                nextRetryAt: Value(nextRetryAt),
                lastErrorCode: Value(errorClass),
                updatedAt: Value(_now()),
              ),
            );
      });
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> quarantine(
    OperationId operationId, {
    required String errorClass,
  }) async {
    try {
      await (_db.update(_db.syncOperations)
            ..where((t) => t.operationId.equals(operationId.value)))
          .write(
            SyncOperationsCompanion(
              status: const Value(SyncOperationStatus.quarantined),
              lastErrorCode: Value(errorClass),
              updatedAt: Value(_now()),
            ),
          );
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> cancelAll() async {
    try {
      // Hesap silme akışı (10 §12-7): tüm op'lar cancelled.
      await _db
          .update(_db.syncOperations)
          .write(
            SyncOperationsCompanion(
              status: const Value(SyncOperationStatus.cancelled),
              updatedAt: Value(_now()),
            ),
          );
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<void> recoverInFlight() async {
    try {
      // Açılış kurtarması (10 §27-1): ack alınmamış inFlight op yeniden
      // denenir; idempotent doc ID çift yazımı zararsız kılar.
      await (_db.update(_db.syncOperations)..where(
            (t) => t.status.equalsValue(SyncOperationStatus.inFlight),
          ))
          .write(
            SyncOperationsCompanion(
              status: const Value(SyncOperationStatus.pending),
              updatedAt: Value(_now()),
            ),
          );
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<int> pendingCount({SyncEntityType? entityType}) async {
    try {
      final countExp = countAll();
      final query = _db.selectOnly(_db.syncOperations)
        ..addColumns([countExp])
        ..where(
          entityType == null
              ? _db.syncOperations.status.isInValues(_outstanding)
              : _db.syncOperations.status.isInValues(_outstanding) &
                    _db.syncOperations.entityType.equalsValue(entityType),
        );
      final row = await query.getSingle();
      return Result.success(row.read(countExp) ?? 0);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }
}
