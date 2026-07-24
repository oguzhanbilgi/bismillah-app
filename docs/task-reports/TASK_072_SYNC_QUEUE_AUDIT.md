# TASK 072 — Offline Sync Queue Architecture and Data-Loss Risk Audit

Audit-only task. No production code, schema, dependency or workflow was changed.
All findings are backed by repository evidence at main `a8bd880`.

Verdicts used: **IMPLEMENTED · PARTIAL · ABSENT · UNVERIFIED · INTENTIONALLY OUT OF SCOPE**

## 1. Executive summary

Bismillah has a **well-designed, tested, durable local sync queue** with atomic
enqueue, idempotency keys, ownership UIDs and a retry *state machine* — but
**no sync engine, no remote writer, and no `cloud_firestore` dependency**.
Queue records are produced (prayer log only), recovered and remapped at
startup, and deleted on privacy reset, but they are **never transmitted
anywhere**. This matches the documented intent ("SyncEngine, Firestore yazımı
ve kuyruk kalıcılığı sonraki görevlerdedir") and the DO_NOT_BREAK rule of no
silent cloud sync. There is **no data-loss path today** because local truth
never depends on the queue; the practical risks are all about what must exist
*before* remote sync is enabled.

## 2. Readiness verdict

## READY FOR LOCAL QUEUE HARDENING ONLY

Queue foundations exist and are tested, but remote transmission is not safe or
even possible today: `cloud_firestore` is not a dependency, no consumer drains
the queue, pull/conflict handling is specification-only, and Firestore
Security Rules (TASK 133) / App Check (TASK 134) are roadmapped for CP16.
Enabling real Firestore synchronization now is **NOT safe** and would violate
the roadmap ordering and the "no silent cloud sync" guardrail.

## 3. Architecture inventory

| Layer | Path | Classification |
|---|---|---|
| Queue schema (Drift) | `bismillah_app/lib/features/sync/data/local/sync_operation_table.dart` | production |
| Domain entity + retry rules | `bismillah_app/lib/features/sync/domain/entities/sync_operation.dart` | production |
| Enums (status/type/entity) | `bismillah_app/lib/features/sync/domain/value_objects/sync_enums.dart` | production |
| Repository contract | `bismillah_app/lib/features/sync/domain/repositories/sync_queue_repository.dart` | interface (fully implemented) |
| Drift queue repository | `bismillah_app/lib/features/sync/data/local/drift_sync_queue_repository.dart` | production |
| Mapper | `bismillah_app/lib/features/sync/data/mappers/sync_operation_mapper.dart` | production |
| DI providers | `bismillah_app/lib/features/sync/data/sync_data_providers.dart` | production |
| Producer (prayer log) | `bismillah_app/lib/features/prayer/data/local/drift_prayer_log_repository.dart` | production |
| Bootstrap remap/recovery | `bismillah_app/lib/app/app_bootstrap.dart` (`initializeLocalPersistence`) | production |
| Anonymous auth / local fallback | `bismillah_app/lib/core/session/*` | production |
| Reset (queue deletion) | `bismillah_app/lib/core/storage/app_database.dart` (reset path deletes `syncOperations`) | production |
| Sync engine / Firestore writer / pull | — | **ABSENT** |
| Spec | `docs/10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` (§10–§15, §22, §27) | documentation proposal |

Note: several docstrings still say "Isar" (e.g. `sync_operation.dart`); the
actual store is Drift. Stale wording only — no behavioral impact.

## 4. Queue schema — verdict: IMPLEMENTED (for local queueing)

`SyncOperations` fields: `operationId` (PK, UUIDv4), `uid`, `deviceId`,
`entityType` / `operationType` / `status` (stored by **stable enum name**,
never index), `entityId`, `payloadRef`, `payloadHash`, `createdAt`/`updatedAt`
(UTC converter), `retryCount` (default 0), `nextRetryAt` (nullable),
`lastErrorCode` (error *class* only, never raw messages), `idempotencyKey`,
`sensitivityClass`. Indexes: `(status, nextRetryAt)` hot-path and
`(entityType, entityId)`.

- Two identical operations cannot accumulate: enqueue **merges** on
  `(entityType, entityId, outstanding-status)` — verified by test.
- Ordering is deterministic: priority list → `createdAt` → `operationId`.
- Idempotency key exists (`IdempotencyKey.derive(operationId, payloadHash)`),
  refreshed on merge.
- Ownership: every row carries a `uid`.
- Malformed payloads: payload is **not stored** — `payloadRef` points at the
  live local row (`local://prayer_log_days/<dayKey>`); the push-time state
  would be read fresh. Domain constructor rejects empty ref/hash and
  **rejects `SensitivityClass.restricted` entirely**.
- App-update safety: because no payload copy exists, a queued op cannot carry
  a stale payload shape across updates (the reference design mitigates this).
  However there is **no explicit payload/schema version column**, which the
  spec (§22) requires before remote sync — PARTIAL for that future need.
- Failed vs pending vs dead-letter are distinguishable:
  `pending / inFlight / failedRetryable / quarantined / cancelled`
  (`acked` rows are deleted immediately).

## 5. Producers — verdict: PARTIAL (one entity, correctly implemented)

The **only** producer is `DriftPrayerLogRepository.saveDay` (prayer mark/undo
via `prayer_log_controller.dart`): day upsert + entry rewrite + `upsert` op
enqueue in **one Drift transaction** (`enqueueInSession` joins the caller's
transaction; any exception rolls back everything). Re-saving the same day
coalesces to a single op (tested).

Classification of local writes:

| Data | Sync status |
|---|---|
| Prayer log day | **currently queued** (upsert only; no delete producer) |
| Quran progress/bookmarks/position | local-only today (SharedPreferences); entity types exist in enums → **should eventually sync** |
| Learn progress, reminder settings, onboarding/profile prefs | **local-only by design** today (SharedPreferences; `settings`/`profile` enum values reserved) |
| Assistant history | local-only; sensitive queries never persisted (guardrail) |
| Prayer times / location | **INTENTIONALLY OUT OF SCOPE** (device-computed, never synced) |

No local write is documented as *currently* syncable but silently unqueued;
the enum's unused entity types are forward declarations, not broken paths.

## 6. Consumers — verdict: ABSENT

**ABSENT — queue records can be created but are not transmitted.**
No production caller of `nextEligible` / `markAcked` / `markFailedRetryable` /
`quarantine` exists (only tests exercise them). There is no startup drain,
no manual sync action, no connectivity listener, no background worker, and no
Firestore/Functions upload path. `cloud_firestore` is **not** in
`pubspec.yaml` (only `firebase_core`, `firebase_auth`, `cloud_functions`; the
existing callable is a Diyanet content proxy, not sync).
Production-used queue operations are limited to bootstrap `remapUid` +
`recoverInFlight` and reset-time deletion.

## 7. Atomicity and crash safety

| Failure point | Protection |
|---|---|
| Local write ok, enqueue fails | **protected** — same transaction; both roll back; user sees save failure (no silent divergence) |
| Enqueue ok, local write fails | **protected** — same transaction |
| Process death mid-transaction | **protected** — SQLite atomicity |
| Death after remote success, before ack-delete | **not applicable today**; design (`recoverInFlight` + idempotent doc IDs) anticipates it |
| Same op processed twice | not applicable (no consumer); idempotency key present for the future |
| Rapid repeated user action | **protected** — merge rule keeps one outstanding op per entity |
| Upgrade with pending ops | **partially protected** — reference-payload design is upgrade-tolerant; no versioned migration fixture yet (schema still v1, `onUpgrade` placeholder documents "queue must never be dropped") |
| Migration with non-empty queue | **UNVERIFIED** — no v2 migration exists to test against; placeholder only |

No concrete data-loss or duplicate-write scenario exists today.

## 8. Retry/failure — verdict: PARTIAL

State machine and accounting are implemented (`isEligibleForRetry`,
`maxRetryCount = 8`, `markFailedRetryable` increments + gates by
`nextRetryAt`, `quarantine` isolates without blocking the batch — all tested).
**No execution logic uses them**: there is no scheduler, no
exponential-backoff/jitter computation (callers must supply `nextRetryAt`),
no error-class taxonomy (retryable vs permanent vs auth vs permission), no
user-visible failure surface, no queue-size limit. Battery/rate-limit/head-of-
line concerns are moot until a consumer exists, but the backoff policy must be
implemented before one.

## 9. Idempotency — verdict: no remote implementation exists

`idempotencyKey` is derived, stored and merge-refreshed; the spec (§8–§9,
§27-1) prescribes deterministic user-scoped document IDs so double delivery
overwrites rather than duplicates. None of this is enforced remotely because
no remote path exists. "Can the same queue item be safely processed twice?" —
**no remote implementation exists** (design intends "yes" via deterministic
doc IDs).

## 10. Conflict resolution — verdict: ABSENT (spec-only)

Spec §14 documents field-level merge / updatedAt comparison / tombstone rules
(§15), and the entity supports `tombstone` ops. **No code** implements pull,
merge, version comparison, or deletion propagation; there is not even a
delete/tombstone *producer*. Two-device, delete-vs-edit, clock-skew and
reinstall-with-cloud-data scenarios are entirely unimplemented.

## 11. Authentication/ownership

- Every op carries a `uid` captured at enqueue time from
  `currentUserIdProvider` (bootstrap-injected; throws if unset — cannot be
  silently wrong).
- Identity: anonymous Firebase auth with a bounded timeout; on failure a
  `local-<uuid>` fallback is used and is documented as **never written to
  Firestore**.
- Startup `remapUid` rebinds **all** rows to the current session owner
  (single-user local DB per spec §15/§10) — idempotent, transactional,
  tested. This is correct for a single-user device DB but means queue rows
  follow the *device* owner; anonymous-to-account upgrade (TASK 131) must
  revisit it before remote sync.
- Reinstall changes the anonymous UID; with no remote writes today there is
  no cross-user upload risk. Sign-out/account-deletion path: `cancelAll`
  exists (unused in production). Remote user-scoped paths: spec-only.
- Ownership assertion before upload: **ABSENT** (no upload).

## 12. Privacy/data minimization — verdict: IMPLEMENTED (strong)

- Queue stores **references, not payload copies**; no worship content, no
  coordinates, no verse-level data, no notification text, no Assistant
  content ever enters the table.
- `SensitivityClass.restricted` is rejected at the domain constructor — it
  can never reach the table.
- `lastErrorCode` stores an error *class* bucket, never raw messages.
- Prayer times, precise location and Quran verse analytics are not queued
  (INTENTIONALLY OUT OF SCOPE / local-only).
- Privacy reset deletes the queue with all other local data.
- Sole queued entity (`prayerLogDay`) references dayKey-scoped completion
  state — minimal fields; retention = until acked/reset.

## 13. Lifecycle behavior

- **Durable** across restart/process death/reboot (SQLite).
- **Not drained** (no consumer) and **not pruned** except: `acked` deleted
  immediately (by design), full reset deletes everything. `cancelled` /
  `quarantined` rows are never pruned — slow unbounded growth (P2).
- Growth is bounded in practice by the merge rule: ≤1 outstanding op per
  entity → at most one row per logged day.
- `recoverInFlight` restores interrupted ops each startup; failures are
  logged and retried next launch (non-blocking).
- Observable only via `pendingCount` (not surfaced in UI).
- User clearing app storage / reinstall: queue is lost with everything else —
  acceptable while local-only.

## 14. Test coverage

Sync-relevant suites (run: `flutter test test/features/sync
test/app/persistence_wiring_test.dart test/app/app_bootstrap_test.dart
test/features/prayer/data/drift_prayer_log_repository_test.dart` → **36/36**):

| Area | Covered by |
|---|---|
| Schema/mapper round-trip, stable enum names | `test/features/sync/data/drift_sync_queue_repository_test.dart` (12), `sync_operation_test.dart` (6) |
| Atomic save+enqueue, coalescing, canonical payloadHash | `test/features/prayer/data/drift_prayer_log_repository_test.dart` (8) |
| Eligibility, priority ordering, retry accounting, quarantine, ack-delete, cancelAll, recoverInFlight, pendingCount, remapUid idempotency | queue repository suite |
| Bootstrap wiring/remap/recovery | `test/app/app_bootstrap_test.dart` (4), `test/app/persistence_wiring_test.dart` (6) |
| **Not covered** | backoff computation (none exists), consumer/drain, remote idempotency, conflicts, tombstones, migration-with-pending-queue, error-class taxonomy |

## 15. Risk register

### P0 — none found
No cross-user upload (no upload), no unqueued-loss (atomic), no destructive
conflict handling (no conflicts), no sensitive payload storage (references
only, restricted rejected).

### P1 — must exist before enabling remote sync
1. **No queue consumer/SyncEngine** — `nextEligible`/`markAcked` unused in
   production (evidence: §6). Fix: build the engine as its own gated task.
2. **No `cloud_firestore` dependency or remote contract in code** — spec-only
   (§8–§9). Requires an approved dependency task + Security Rules (TASK 133)
   + App Check (TASK 134) first.
3. **No pull/conflict/tombstone implementation** (spec §13–§15 only).
4. **No backoff policy computation / error-class taxonomy** — retry fields
   exist, nothing computes `nextRetryAt` or classifies errors (§8).
5. **No payload/schema version marker for ops** across future migrations
   (spec §22); mitigated by reference-payload design but unproven
   (no v2 migration fixture).
6. **Anonymous→account identity story** — `remapUid` assumes single-user
   device DB; account linking (TASK 131) must precede remote sync.

### P2 — operational hardening
1. `cancelled`/`quarantined` rows never pruned (slow growth).
2. No queue observability/diagnostics surface (`pendingCount` unused in UI).
3. No manual retry / dead-letter surfacing for quarantined ops.
4. Stale "Isar" wording in sync docstrings.

## 16. TASK 073 recommendation (bounded, local-only)

Owner-directed redefinition: the original roadmap TASK 073 (project-state
docs completion) was largely completed early by TASK 068A (noted in the
roadmap itself); TASK 073 is redefined as the **local sync-queue hardening
slice**. No remote writes.

**In scope**
- Deterministic backoff policy (exponential + jitter, pure domain function)
  producing `nextRetryAt`; error-class taxonomy enum (retryable / permanent /
  auth / permission) with `lastErrorCode` buckets.
- Pruning policy for `cancelled` and quarantine-expired rows.
- Wire `pendingCount` into a debug/diagnostics surface (no user-facing UI
  redesign).
- Fix stale "Isar" docstrings in sync files.

**Out of scope**: any remote write, `cloud_firestore` dependency, pull/
conflict/tombstone logic, schema migration (stay v1), Security Rules,
account linking, background workers.

**Acceptance criteria**: analyze clean; new focused tests for backoff bounds/
jitter determinism (seeded), taxonomy mapping, pruning idempotency; full
suite ≥ 595 with no regressions.

**Migration implications**: none (no schema change allowed in the slice).

**Privacy constraints**: no payload copies, no raw error strings, no new
telemetry.

**Device validation**: not required (no platform-channel or notification
changes); CI + unit tests suffice.

## 17. Evidence appendix

- Queue schema: `bismillah_app/lib/features/sync/data/local/sync_operation_table.dart`
- Entity/state machine: `bismillah_app/lib/features/sync/domain/entities/sync_operation.dart`
- Repository: `bismillah_app/lib/features/sync/data/local/drift_sync_queue_repository.dart`
- Producer: `bismillah_app/lib/features/prayer/data/local/drift_prayer_log_repository.dart` (`saveDay`, `_upsertOperationFor`)
- Bootstrap: `bismillah_app/lib/app/app_bootstrap.dart` (`initializeLocalPersistence`)
- Identity: `bismillah_app/lib/core/session/session_bootstrap.dart`, `anonymous_auth_service.dart`
- Reset deletes queue: `bismillah_app/lib/core/storage/app_database.dart`
- Migration placeholder: `bismillah_app/lib/core/storage/app_database.dart` (`onUpgrade`)
- Dependency proof: `bismillah_app/pubspec.yaml` (no `cloud_firestore`)
- Spec: `docs/10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` §10–§15, §22, §25, §27
- Baselines at audit time: Flutter analyze clean; sync-focused 36/36; full
  595/595; Functions 23/23 (Node.js 22).
