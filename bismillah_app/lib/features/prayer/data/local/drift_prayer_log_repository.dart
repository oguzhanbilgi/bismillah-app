import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/core/errors/app_failure.dart';
import 'package:bismillah_app/core/result/result.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/utils/uuid_v4.dart';
import 'package:bismillah_app/core/value_objects/day_key.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/prayer/data/mappers/prayer_log_day_mapper.dart';
import 'package:bismillah_app/features/prayer/domain/entities/prayer_log_day.dart';
import 'package:bismillah_app/features/prayer/domain/repositories/prayer_log_repository.dart';
import 'package:bismillah_app/features/sync/data/local/drift_sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:drift/drift.dart';

/// Drift tabanlı namaz kaydı repository'si — local-first yazma kuralının
/// (10 §12-1/2) ilk somut kanıtı:
///
/// > Gün belgesi + entry satırları + ilgili `SyncOperation` **tek Drift
/// > transaction'ında** yazılır. Transaction düşerse hiçbir parça kalmaz —
/// > kayıt hiç "başarılı" görünmemiştir (10 §27-13).
///
/// Uzak uç YOKTUR: başarı Isar/Drift yazımıyla tanımlanır, ağ beklenmez.
final class DriftPrayerLogRepository implements PrayerLogRepository {
  DriftPrayerLogRepository(
    this._db, {
    required this._syncQueue,
    required this._currentUserId,
    String Function()? operationIdFactory,
    this._clock = const SystemClock(),
  }) : _newOperationId = operationIdFactory ?? UuidV4.generate;

  final AppDatabase _db;
  final DriftSyncQueueRepository _syncQueue;

  /// Oturum sahibi — anonim UID dahil ilk andan stabildir (06 §17).
  /// Auth entegrasyonu sonraki görevde bu fonksiyonu gerçek kaynağa bağlar.
  final UserId Function() _currentUserId;

  final String Function() _newOperationId;
  final AppClock _clock;

  @override
  ResultFuture<PrayerLogDay?> getDay(DayKey dayKey) async {
    try {
      final dayRow =
          await (_db.select(_db.prayerLogDays)
                ..where((t) => t.dayKey.equals(dayKey.value)))
              .getSingleOrNull();
      if (dayRow == null) {
        return const Result.success(null);
      }
      final entryRows =
          await (_db.select(_db.prayerEntries)
                ..where((t) => t.dayKey.equals(dayKey.value)))
              .get();
      return Result.success(PrayerLogDayMapper.toDomain(dayRow, entryRows));
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  Stream<PrayerLogDay?> watchDay(DayKey dayKey) {
    final query = _db.select(_db.prayerLogDays).join([
      leftOuterJoin(
        _db.prayerEntries,
        _db.prayerEntries.dayKey.equalsExp(_db.prayerLogDays.dayKey),
      ),
    ])..where(_db.prayerLogDays.dayKey.equals(dayKey.value));

    return query.watch().map((rows) {
      if (rows.isEmpty) {
        return null;
      }
      final dayRow = rows.first.readTable(_db.prayerLogDays);
      final entryRows = [
        for (final row in rows) ?row.readTableOrNull(_db.prayerEntries),
      ];
      return PrayerLogDayMapper.toDomain(dayRow, entryRows);
    });
  }

  @override
  ResultFuture<void> saveDay(PrayerLogDay day) async {
    try {
      await _db.transaction(() async {
        // 1) Gün belgesi upsert + entry satırları tam yenileme
        //    (gün-belgesi aggregate'i; merge kararları domain'de verilir).
        await _db
            .into(_db.prayerLogDays)
            .insertOnConflictUpdate(PrayerLogDayMapper.toDayCompanion(day));
        await (_db.delete(_db.prayerEntries)
              ..where((t) => t.dayKey.equals(day.dayKey.value)))
            .go();
        for (final companion in PrayerLogDayMapper.toEntryCompanions(day)) {
          await _db.into(_db.prayerEntries).insert(companion);
        }

        // 2) Aynı transaction içinde sync op enqueue (10 §12-2).
        //    Exception dış transaction'ı geri alır — kısmi yazım imkânsız.
        await _syncQueue.enqueueInSession(_upsertOperationFor(day));
      });
      return const Result.success(null);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  @override
  ResultFuture<List<PrayerLogDay>> getRange(DayKey from, DayKey to) async {
    try {
      // Sözlüksel sıra = kronolojik sıra (DayKey garantisi).
      final dayRows =
          await (_db.select(_db.prayerLogDays)
                ..where((t) => t.dayKey.isBetweenValues(from.value, to.value))
                ..orderBy([(t) => OrderingTerm.asc(t.dayKey)]))
              .get();
      if (dayRows.isEmpty) {
        return const Result.success([]);
      }
      final keys = [for (final row in dayRows) row.dayKey];
      final entryRows =
          await (_db.select(_db.prayerEntries)
                ..where((t) => t.dayKey.isIn(keys)))
              .get();
      final entriesByDay = <String, List<PrayerEntryRow>>{};
      for (final row in entryRows) {
        entriesByDay.putIfAbsent(row.dayKey, () => []).add(row);
      }
      return Result.success([
        for (final dayRow in dayRows)
          PrayerLogDayMapper.toDomain(
            dayRow,
            entriesByDay[dayRow.dayKey] ?? const [],
          ),
      ]);
    } on Exception {
      return const Result.failure(StorageFailure());
    }
  }

  /// Gün belgesi için upsert sync op'u üretir. `payloadRef` güncel lokal
  /// kayda referanstır — payload kopyalanmaz (10 §11); push anında güncel
  /// hâl okunur. Kuyruk birleştirme sayesinde gün başına tek op yaşar.
  SyncOperation _upsertOperationFor(PrayerLogDay day) {
    final now = UtcDateTime(_clock.nowUtc());
    final operationId = OperationId(_newOperationId());
    final payloadHash = PrayerLogDayMapper.payloadHash(day);
    return SyncOperation(
      operationId: operationId,
      uid: _currentUserId(),
      deviceId: day.deviceId,
      entityType: SyncEntityType.prayerLogDay,
      entityId: EntityId(day.dayKey.value),
      operationType: SyncOperationType.upsert,
      payloadRef: 'local://prayer_log_days/${day.dayKey.value}',
      payloadHash: payloadHash,
      createdAt: now,
      updatedAt: now,
      status: SyncOperationStatus.pending,
      idempotencyKey: IdempotencyKey.derive(
        operationId: operationId,
        payloadHash: payloadHash,
      ),
      sensitivityClass: day.sensitivityClass,
    );
  }
}
