import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/storage/converters/utc_date_time_converter.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/data/mappers/sync_operation_mapper.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_queue_diagnostics.dart';
import 'package:bismillah_app/features/sync/domain/policies/sync_retry_policy.dart';
import 'package:bismillah_app/features/sync/domain/repositories/sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_failure_class.dart';
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
    this._retryPolicy = const SyncRetryPolicy(),
  });

  final AppDatabase _db;
  final AppClock _clock;
  final SyncRetryPolicy _retryPolicy;

  /// Terminal (`quarantined`/`cancelled`) kayıt saklama penceresi (§8.2).
  static const Duration terminalRetention = Duration(days: 30);

  /// Bayat `inFlight` eşiği — bunu aşan işleme kaydı kesintiye uğramış
  /// sayılır ve `pending`e döner (temkinli; TASK 073 §7.6).
  static const Duration staleInFlightThreshold = Duration(minutes: 15);

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
    await (_db.update(
      _db.syncOperations,
    )..where((t) => t.operationId.equals(existing.operationId))).write(
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
      final rows = await (_db.select(
        _db.syncOperations,
      )..where((t) => t.status.isInValues(_outstanding))).get();
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
      await (_db.delete(
        _db.syncOperations,
      )..where((t) => t.operationId.equals(operationId.value))).go();
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
        await (_db.update(
          _db.syncOperations,
        )..where((t) => t.operationId.equals(operationId.value))).write(
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

  /// Hata kaydında geçiş yapılabilir (terminal olmayan) durumlar.
  static const List<SyncOperationStatus> _failureRecordable = [
    SyncOperationStatus.pending,
    SyncOperationStatus.inFlight,
    SyncOperationStatus.failedRetryable,
  ];

  @override
  ResultFuture<void> recordFailure(
    OperationId operationId, {
    required SyncFailureClass failureClass,
    required UtcDateTime now,
  }) async {
    try {
      await _db.transaction(() async {
        final row =
            await (_db.select(_db.syncOperations)
                  ..where((t) => t.operationId.equals(operationId.value)))
                .getSingleOrNull();
        // Geçersiz geçişler GÜVENLE reddedilir: kayıt yoksa veya terminal
        // durumdaysa (acked silinmiş / quarantined / cancelled) no-op.
        if (row == null || !_failureRecordable.contains(row.status)) {
          return;
        }
        // Attempt bu transaction'da TAM BİR KEZ artar; aynı geçiş için
        // tekrar çağrı yeni bir hata denemesi olarak sayılır (yerel
        // garanti — dağıtık idempotency iddiası YOK, consumer yok).
        final attempt = row.retryCount + 1;
        final decision = _retryPolicy.decide(
          attempt: attempt,
          failureClass: failureClass,
          operationSeed: row.operationId,
          now: now,
        );
        await (_db.update(_db.syncOperations)
              ..where((t) => t.operationId.equals(operationId.value)))
            .write(switch (decision) {
              SyncRetryAt(:final retryAt) => SyncOperationsCompanion(
                status: const Value(SyncOperationStatus.failedRetryable),
                retryCount: Value(attempt),
                nextRetryAt: Value(retryAt),
                lastErrorCode: Value(failureClass.name),
                updatedAt: Value(now),
              ),
              SyncQuarantine() => SyncOperationsCompanion(
                status: const Value(SyncOperationStatus.quarantined),
                retryCount: Value(attempt),
                lastErrorCode: Value(failureClass.name),
                updatedAt: Value(now),
              ),
            });
      });
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<int> pruneTerminal({required UtcDateTime now}) async {
    try {
      final cutoff = UtcDateTime(now.value.subtract(terminalRetention));
      // YALNIZ terminal durumlar yaşa göre budanır; bekleyen kullanıcı
      // değişikliği (pending/failedRetryable/inFlight) ASLA silinmez.
      final pruned = await _db.transaction(() {
        return (_db.delete(_db.syncOperations)..where(
              (t) =>
                  t.status.isInValues(const [
                    SyncOperationStatus.quarantined,
                    SyncOperationStatus.cancelled,
                  ]) &
                  t.updatedAt.isSmallerThanValue(
                    const UtcDateTimeConverter().toSql(cutoff),
                  ),
            ))
            .go();
      });
      return Result.success(pruned);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<int> recoverStaleInFlight({required UtcDateTime now}) async {
    try {
      final cutoff = UtcDateTime(now.value.subtract(staleInFlightThreshold));
      final recovered = await _db.transaction(() {
        return (_db.update(_db.syncOperations)..where(
              (t) =>
                  t.status.equalsValue(SyncOperationStatus.inFlight) &
                  t.updatedAt.isSmallerThanValue(
                    const UtcDateTimeConverter().toSql(cutoff),
                  ),
            ))
            .write(
              SyncOperationsCompanion(
                status: const Value(SyncOperationStatus.pending),
                updatedAt: Value(now),
              ),
            );
      });
      return Result.success(recovered);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<SyncQueueDiagnostics> diagnostics({
    required UtcDateTime now,
  }) async {
    try {
      // Kuyruk merge kuralıyla küçük kalır (entity başına ≤1 outstanding);
      // tam okuma + Dart'ta sayım yeterlidir. Modele payload/ID/UID GİRMEZ.
      final rows = await _db.select(_db.syncOperations).get();
      final byStatus = <SyncOperationStatus, int>{};
      var eligibleNow = 0;
      var retryWaiting = 0;
      var staleInFlight = 0;
      var authOwned = 0;
      var localOwned = 0;
      UtcDateTime? oldestUnresolved;
      final staleCutoff = UtcDateTime(
        now.value.subtract(staleInFlightThreshold),
      );

      for (final row in rows) {
        byStatus[row.status] = (byStatus[row.status] ?? 0) + 1;
        if (row.uid.startsWith('local-')) {
          localOwned++;
        } else {
          authOwned++;
        }
        final op = SyncOperationMapper.toDomain(row);
        final outstanding = _outstanding.contains(row.status);
        if (outstanding) {
          if (op.isEligibleForRetry(now)) {
            eligibleNow++;
          } else {
            retryWaiting++;
          }
        }
        if (row.status == SyncOperationStatus.inFlight &&
            row.updatedAt.isBefore(staleCutoff)) {
          staleInFlight++;
        }
        final unresolved =
            outstanding || row.status == SyncOperationStatus.inFlight;
        if (unresolved &&
            (oldestUnresolved == null ||
                row.createdAt.isBefore(oldestUnresolved))) {
          oldestUnresolved = row.createdAt;
        }
      }

      return Result.success(
        SyncQueueDiagnostics(
          total: rows.length,
          byStatus: Map.unmodifiable(byStatus),
          eligibleNow: eligibleNow,
          retryWaiting: retryWaiting,
          quarantined: byStatus[SyncOperationStatus.quarantined] ?? 0,
          cancelled: byStatus[SyncOperationStatus.cancelled] ?? 0,
          staleInFlight: staleInFlight,
          oldestUnresolvedAge: _ageBucket(oldestUnresolved, now),
          authenticatedOwnerCount: authOwned,
          localFallbackOwnerCount: localOwned,
        ),
      );
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  /// Kesin zaman damgası sızdırmayan kaba yaş kovası.
  static SyncQueueAgeBucket _ageBucket(UtcDateTime? oldest, UtcDateTime now) {
    if (oldest == null) {
      return SyncQueueAgeBucket.none;
    }
    final age = now.difference(oldest);
    if (age < const Duration(hours: 1)) {
      return SyncQueueAgeBucket.under1Hour;
    }
    if (age < const Duration(days: 1)) {
      return SyncQueueAgeBucket.under1Day;
    }
    if (age < const Duration(days: 7)) {
      return SyncQueueAgeBucket.under7Days;
    }
    if (age < const Duration(days: 30)) {
      return SyncQueueAgeBucket.over7Days;
    }
    return SyncQueueAgeBucket.over30Days;
  }

  @override
  ResultFuture<void> quarantine(
    OperationId operationId, {
    required String errorClass,
  }) async {
    try {
      await (_db.update(
        _db.syncOperations,
      )..where((t) => t.operationId.equals(operationId.value))).write(
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
      await (_db.update(_db.syncOperations)
            ..where((t) => t.status.equalsValue(SyncOperationStatus.inFlight)))
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

  /// Lokal kuyruğu güncel oturum sahibine bağlar (interface DIŞI —
  /// bootstrap altyapı işlemi, 07 §146 "rebind").
  ///
  /// TASK 016–017, gerçek auth'tan ÖNCE `placeholder-local-user` (ve
  /// Firebase'siz açılışlarda `local-*` fallback kimliği) altında lokal
  /// sync satırları üretmiş olabilir. Gerçek sync engine açılmadan önce
  /// bu satırlar güncel UID'ye taşınmak ZORUNDADIR. Lokal DB tek
  /// kullanıcılıdır (10 §15): güncel UID'den farklı uid taşıyan HER satır
  /// oturum sahibine aittir ve remap edilir.
  ///
  /// Idempotent (eşleşen satıra dokunmaz), tek transaction, entity id ve
  /// namaz verisi değişmez.
  ResultFuture<int> remapUid({required UserId to}) async {
    try {
      final remapped = await _db.transaction(() {
        return (_db.update(_db.syncOperations)
              ..where((t) => t.uid.equals(to.value).not()))
            .write(SyncOperationsCompanion(uid: Value(to.value)));
      });
      return Result.success(remapped);
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
