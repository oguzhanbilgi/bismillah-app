import 'package:bismillah_app/core/privacy/sensitivity_class.dart';
import 'package:bismillah_app/core/storage/app_database.dart';
import 'package:bismillah_app/core/utils/clock.dart';
import 'package:bismillah_app/core/value_objects/unique_id.dart';
import 'package:bismillah_app/core/value_objects/utc_date_time.dart';
import 'package:bismillah_app/features/sync/data/local/drift_sync_queue_repository.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_operation.dart';
import 'package:bismillah_app/features/sync/domain/entities/sync_queue_diagnostics.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_enums.dart';
import 'package:bismillah_app/features/sync/domain/value_objects/sync_failure_class.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_database.dart';

/// TASK 073 — yerel kuyruk sertleştirme testleri: politikalı hata kaydı,
/// budama, bayat inFlight kurtarması ve gizlilik-güvenli teşhis.
void main() {
  final fixedNow = DateTime.utc(2026, 7, 10, 12);
  final now = UtcDateTime(fixedNow);

  late AppDatabase db;
  late DriftSyncQueueRepository queue;

  setUp(() {
    db = createTestDatabase();
    queue = DriftSyncQueueRepository(db, clock: FixedClock(fixedNow));
  });

  tearDown(() async {
    await db.close();
  });

  SyncOperation operation({
    String id = 'op-1',
    String uid = 'user-1',
    String entityId = '2026-07-10',
    SyncOperationStatus status = SyncOperationStatus.pending,
    int retryCount = 0,
    UtcDateTime? nextRetryAt,
    UtcDateTime? createdAt,
  }) {
    final created = createdAt ?? now;
    return SyncOperation(
      operationId: OperationId(id),
      uid: UserId(uid),
      deviceId: DeviceId('device-1'),
      entityType: SyncEntityType.prayerLogDay,
      entityId: EntityId(entityId),
      operationType: SyncOperationType.upsert,
      payloadRef: 'local://x/$entityId',
      payloadHash: 'hash-$id',
      createdAt: created,
      updatedAt: created,
      status: status,
      idempotencyKey: IdempotencyKey.derive(
        operationId: OperationId(id),
        payloadHash: 'hash-$id',
      ),
      sensitivityClass: SensitivityClass.high,
      retryCount: retryCount,
      nextRetryAt: nextRetryAt,
    );
  }

  Future<SyncOperation?> load(String id, {Duration ahead = Duration.zero}) =>
      queue
          .nextEligible(now.add(ahead), limit: 100)
          .then(
            (r) => r.valueOrNull
                ?.where((op) => op.operationId.value == id)
                .firstOrNull,
          );

  group('recordFailure — transitions', () {
    test('transient failure: attempt +1, failedRetryable, nextRetryAt, safe '
        'error class name persisted', () async {
      await queue.enqueue(operation(id: 'op-1'));

      final result = await queue.recordFailure(
        OperationId('op-1'),
        failureClass: SyncFailureClass.transientNetwork,
        now: now,
      );
      expect(result.isSuccess, isTrue);

      // 30s taban + jitter'dan ÖNCE uygun değil…
      expect(await load('op-1'), isNull);
      // …ama taban+jitter tavanından sonra yeniden uygun.
      final later = await load('op-1', ahead: const Duration(minutes: 1));
      expect(later, isNotNull);
      expect(later!.retryCount, 1);
      expect(later.status, SyncOperationStatus.failedRetryable);
      expect(later.lastErrorCode, 'transientNetwork');
      expect(later.nextRetryAt!.isAfter(now), isTrue);
    });

    test('repeated calls increment once per call (local guarantee)', () async {
      await queue.enqueue(operation(id: 'op-1'));
      await queue.recordFailure(
        OperationId('op-1'),
        failureClass: SyncFailureClass.transientNetwork,
        now: now,
      );
      await queue.recordFailure(
        OperationId('op-1'),
        failureClass: SyncFailureClass.transientNetwork,
        now: now,
      );
      final op = await load('op-1', ahead: const Duration(minutes: 5));
      expect(op!.retryCount, 2);
    });

    test('permanent failure quarantines immediately', () async {
      await queue.enqueue(operation(id: 'op-1'));
      await queue.recordFailure(
        OperationId('op-1'),
        failureClass: SyncFailureClass.permissionDenied,
        now: now,
      );
      // Quarantined → hiçbir zaman uygun değil.
      expect(await load('op-1', ahead: const Duration(days: 30)), isNull);
      final diag = (await queue.diagnostics(now: now)).valueOrNull!;
      expect(diag.quarantined, 1);
    });

    test('8th transient failure quarantines (max-attempt contract)', () async {
      await queue.enqueue(operation(id: 'op-1', retryCount: 7));
      await queue.recordFailure(
        OperationId('op-1'),
        failureClass: SyncFailureClass.transientNetwork,
        now: now,
      );
      final diag = (await queue.diagnostics(now: now)).valueOrNull!;
      expect(diag.quarantined, 1);
      expect(await load('op-1', ahead: const Duration(days: 365)), isNull);
    });

    test('terminal record is safely rejected (no-op)', () async {
      await queue.enqueue(
        operation(id: 'op-1', status: SyncOperationStatus.quarantined),
      );
      final result = await queue.recordFailure(
        OperationId('op-1'),
        failureClass: SyncFailureClass.transientNetwork,
        now: now,
      );
      expect(result.isSuccess, isTrue);
      final diag = (await queue.diagnostics(now: now)).valueOrNull!;
      expect(diag.quarantined, 1); // durum değişmedi
    });

    test('missing record is a safe no-op', () async {
      final result = await queue.recordFailure(
        OperationId('ghost'),
        failureClass: SyncFailureClass.transientNetwork,
        now: now,
      );
      expect(result.isSuccess, isTrue);
    });

    test('one quarantined record does not block later valid records', () async {
      await queue.enqueue(
        operation(
          id: 'op-bad',
          entityId: 'day-a',
          status: SyncOperationStatus.quarantined,
        ),
      );
      await queue.enqueue(operation(id: 'op-good', entityId: 'day-b'));
      final eligible = (await queue.nextEligible(now, limit: 10)).valueOrNull!;
      expect(eligible.map((o) => o.operationId.value), ['op-good']);
    });
  });

  group('pruneTerminal — retention', () {
    final old = UtcDateTime(fixedNow.subtract(const Duration(days: 31)));
    final recent = UtcDateTime(fixedNow.subtract(const Duration(days: 29)));

    test(
      'old quarantined and cancelled rows prune; recent are retained',
      () async {
        await queue.enqueue(
          operation(
            id: 'q-old',
            entityId: 'a',
            status: SyncOperationStatus.quarantined,
            createdAt: old,
          ),
        );
        await queue.enqueue(
          operation(
            id: 'c-old',
            entityId: 'b',
            status: SyncOperationStatus.cancelled,
            createdAt: old,
          ),
        );
        await queue.enqueue(
          operation(
            id: 'q-recent',
            entityId: 'c',
            status: SyncOperationStatus.quarantined,
            createdAt: recent,
          ),
        );

        final pruned = (await queue.pruneTerminal(now: now)).valueOrNull;
        expect(pruned, 2);
        final diag = (await queue.diagnostics(now: now)).valueOrNull!;
        expect(diag.total, 1);
        expect(diag.quarantined, 1);
      },
    );

    test('pending/failedRetryable/inFlight are never pruned by age', () async {
      await queue.enqueue(operation(id: 'p', entityId: 'a', createdAt: old));
      await queue.enqueue(
        operation(
          id: 'f',
          entityId: 'b',
          status: SyncOperationStatus.failedRetryable,
          createdAt: old,
          nextRetryAt: now,
        ),
      );
      await queue.enqueue(
        operation(
          id: 'i',
          entityId: 'c',
          status: SyncOperationStatus.inFlight,
          createdAt: old,
        ),
      );

      final pruned = (await queue.pruneTerminal(now: now)).valueOrNull;
      expect(pruned, 0);
      expect((await queue.diagnostics(now: now)).valueOrNull!.total, 3);
    });

    test(
      'prune with no matches succeeds and repeated prune is idempotent',
      () async {
        expect((await queue.pruneTerminal(now: now)).valueOrNull, 0);
        expect((await queue.pruneTerminal(now: now)).valueOrNull, 0);
      },
    );
  });

  group('recoverStaleInFlight', () {
    test('stale inFlight returns to pending with attempt metadata intact; '
        'recent inFlight is retained', () async {
      final stale = UtcDateTime(fixedNow.subtract(const Duration(minutes: 20)));
      final fresh = UtcDateTime(fixedNow.subtract(const Duration(minutes: 5)));
      await queue.enqueue(
        operation(
          id: 'stale',
          entityId: 'a',
          status: SyncOperationStatus.inFlight,
          retryCount: 3,
          createdAt: stale,
        ),
      );
      await queue.enqueue(
        operation(
          id: 'fresh',
          entityId: 'b',
          status: SyncOperationStatus.inFlight,
          createdAt: fresh,
        ),
      );

      final recovered = (await queue.recoverStaleInFlight(
        now: now,
      )).valueOrNull;
      expect(recovered, 1);

      final op = await load('stale');
      expect(op, isNotNull); // pending → yeniden uygun
      expect(op!.status, SyncOperationStatus.pending);
      expect(op.retryCount, 3); // attempt metadata korunur

      // İkinci çağrı idempotent: taze kayıt hâlâ inFlight, kurtarılan 0.
      expect((await queue.recoverStaleInFlight(now: now)).valueOrNull, 0);
    });
  });

  group('diagnostics — privacy-safe summary', () {
    test(
      'counts, eligibility split, ownership and age bucket are correct',
      () async {
        // 2 gün önce oluşturulmuş pending (auth sahibi) → under7Days.
        await queue.enqueue(
          operation(
            id: 'op-auth',
            uid: 'firebase-uid-1',
            entityId: 'a',
            createdAt: UtcDateTime(fixedNow.subtract(const Duration(days: 2))),
          ),
        );
        // Backoff bekleyen (yarın uygun) lokal-fallback sahipli kayıt.
        await queue.enqueue(
          operation(
            id: 'op-local',
            uid: 'local-abc',
            entityId: 'b',
            status: SyncOperationStatus.failedRetryable,
            nextRetryAt: now.add(const Duration(days: 1)),
          ),
        );
        // Quarantined + cancelled.
        await queue.enqueue(
          operation(
            id: 'op-q',
            entityId: 'c',
            status: SyncOperationStatus.quarantined,
          ),
        );
        await queue.enqueue(
          operation(
            id: 'op-c',
            entityId: 'd',
            status: SyncOperationStatus.cancelled,
          ),
        );

        final diag = (await queue.diagnostics(now: now)).valueOrNull!;
        expect(diag.total, 4);
        expect(diag.byStatus[SyncOperationStatus.pending], 1);
        expect(diag.byStatus[SyncOperationStatus.failedRetryable], 1);
        expect(diag.eligibleNow, 1);
        expect(diag.retryWaiting, 1);
        expect(diag.quarantined, 1);
        expect(diag.cancelled, 1);
        expect(diag.staleInFlight, 0);
        expect(diag.oldestUnresolvedAge, SyncQueueAgeBucket.under7Days);
        expect(diag.authenticatedOwnerCount, 3);
        expect(diag.localFallbackOwnerCount, 1);
        expect(diag.hasMixedOwnership, isTrue);
      },
    );

    test('empty queue: zero counts and none age bucket', () async {
      final diag = (await queue.diagnostics(now: now)).valueOrNull!;
      expect(diag.total, 0);
      expect(diag.eligibleNow, 0);
      expect(diag.oldestUnresolvedAge, SyncQueueAgeBucket.none);
      expect(diag.hasMixedOwnership, isFalse);
    });

    test(
      'summary leaks no uid, operation id, entity id or payload ref',
      () async {
        await queue.enqueue(
          operation(
            id: 'op-SECRET-ID',
            uid: 'firebase-SECRET-UID',
            entityId: 'SECRET-DAY',
          ),
        );
        final diag = (await queue.diagnostics(now: now)).valueOrNull!;
        final rendered = diag.toString();
        expect(rendered.contains('SECRET'), isFalse);
        expect(rendered.contains('local://'), isFalse);
      },
    );
  });
}
