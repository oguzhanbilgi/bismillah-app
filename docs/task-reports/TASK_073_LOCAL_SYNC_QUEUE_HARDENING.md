# TASK 073 — Local Sync Queue Hardening

Local-only hardening of the offline sync queue, implementing the bounded slice
defined by the TASK 072 audit. **No data leaves the device.**

## 1. Executive summary

The existing queue (schema, atomic producer, state machine, UID ownership)
was extended with the execution-side foundations it lacked: a deterministic
retry/backoff policy, privacy-safe failure classification, policy-driven
atomic failure transitions, bounded pruning, stale-inFlight recovery and a
privacy-safe diagnostics summary. Sync-focused tests grew **36 → 70**; the
full suite grew **595 → 629**. No schema change, no migration, no consumer,
no remote write, no new dependency.

## 2. Scope

- `SyncRetryPolicy` (pure domain) + `SyncRetryDecision` (retry-at /
  quarantine)
- `SyncFailureClass` enum + `SyncFailureClassifier` (type-based, no message
  reads)
- `SyncQueueRepository.recordFailure / pruneTerminal / recoverStaleInFlight /
  diagnostics` + Drift implementations
- `SyncQueueDiagnostics` model with coarse age buckets and ownership counts
- 34 new focused tests

## 3. Explicit non-goals (verified absent from the diff)

- **No queue consumer was added.**
- **No Firestore dependency was added** (`cloud_firestore` still absent).
- **No remote write, Firebase callable upload or HTTP upload was added.**
- No connectivity listener, WorkManager/background worker, periodic or
  startup queue drain.
- **No schema change, no schemaVersion change, no migration, no regenerated
  Drift files.**
- No conflict resolution, delete/tombstone sync, or account linking.
- **Remote sync remains disabled.**

## 4. Existing architecture reused

`DriftSyncQueueRepository` and `SyncQueueRepository` were extended in place
(no parallel repository/model/enums). Existing `AppClock` injection,
`Result`/`ResultFuture` contracts, `StableHash` (FNV-1a), mapper and test
harness (`createTestDatabase`, in-memory Drift) were reused. Existing
methods (`enqueue`, `nextEligible`, `markAcked`, `markFailedRetryable`,
`quarantine`, `cancelAll`, `recoverInFlight`, `remapUid`, `pendingCount`)
are unchanged.

## 5. Deterministic backoff policy

`lib/features/sync/domain/policies/sync_retry_policy.dart` — pure (no
`DateTime.now`, no `Random`), reference time is a parameter.

- **Transient/service:** staged bases 30s / 2m / 10m / 30m / 2h / 8h / 24h
  for attempts 1–7; **attempt 8 → quarantine** (preserves the documented
  `maxRetryCount = 8` contract).
- **Auth unavailable:** 15m / 30m / 2h / 8h; attempt 5+ waits at the 24h cap
  and is **never quarantined by attempt count** (temporary anonymous-auth
  unavailability must not kill a valid operation).
- **Permanent classes:** immediate quarantine.
- **Unknown (documented conservative rule):** `unknownRetryable` follows the
  transient bases for attempts 1–3 and **quarantines at attempt 4**;
  `unknownPermanent` quarantines immediately. Raw details are never stored.
- **Jitter:** derived from `FNV-1a(seed:attempt)` → bounded fraction of
  `min(base/4, 10 min)`. Same operation + attempt + time ⇒ identical result;
  different operations spread out; delay is never negative and total delay
  is capped at 24h. Retry time can never precede the reference time.

## 6. Failure classification

`SyncFailureClass`: transientNetwork, serviceUnavailable,
authenticationUnavailable, permissionDenied, validation, malformedOperation,
missingPayload, ownershipMismatch, unknownRetryable, unknownPermanent
(`isPermanent` covers the last six minus unknownRetryable — exact set
tested). `SyncFailureClassifier.classify` maps by **type only**
(TimeoutException → transientNetwork, FormatException →
malformedOperation, ArgumentError/StateError → validation, otherwise
unknownRetryable); it never reads or propagates message content. Only the
**stable enum name** is persisted into the existing `lastErrorCode` column —
no new column.

## 7. Repository state transitions

`recordFailure` (single Drift transaction): reads the row, increments the
attempt **exactly once per call**, asks the policy, then writes either
`failedRetryable + nextRetryAt + lastErrorCode` or
`quarantined + lastErrorCode`. Missing rows and terminal states
(quarantined/cancelled; acked rows are already deleted) are **safely
rejected as no-ops**. Local guarantee documented: one call = one attempt;
no distributed idempotency is claimed (no consumer exists).

## 8. Eligibility and ordering

Unchanged and reused: domain rule `isEligibleForRetry` (pending or
failedRetryable, backoff elapsed, `retryCount ≤ 8`; `nextRetryAt == null` ⇒
eligible immediately) over a SQL pre-filter, ordered deterministically by
spec §12-3 priority → `createdAt` → `operationId`. Verified: a quarantined
record does not block later valid records; failed records are ineligible
before `nextRetryAt` and eligible after.

## 9. Pruning and retention

`pruneTerminal(now)`:

- **Acked:** deleted immediately on ack by existing design (spec §11 — the
  queue never bloats); the 7-day acked-retention idea does not apply and
  actual behavior is preserved and documented.
- **Quarantined / cancelled:** retained **30 days** (by `updatedAt`), then
  pruned.
- **Never pruned by age:** pending, failedRetryable, inFlight — pending user
  changes are never deleted.
- Idempotent, returns only a safe count, zero-match prune succeeds, no
  background worker (exposed for future controlled invocation only).
- UID scoping: the local DB is single-user by spec (§15) and startup
  `remapUid` rebinds all rows; pruning therefore targets terminal statuses
  only, never another user's pending work.

## 10. Privacy-safe diagnostics

`SyncQueueDiagnostics` (+ `diagnostics(now)` repository method): total,
counts by status, eligible-now vs retry-waiting split, quarantined,
cancelled, stale-inFlight count, **coarse** oldest-unresolved age bucket
(none/under1Hour/under1Day/under7Days/over7Days/over30Days),
authenticated-owner vs `local-` fallback-owner **counts** and a
mixed-ownership warning. Internal foundation only — no UI screen was added.

## 11. Privacy guarantees

The diagnostics model has **no fields** for payloads, payload refs,
entity/operation IDs, idempotency keys, raw UIDs, error text, URLs, tokens
or exact timestamps; a test renders the summary built from marker-laden rows
and asserts no leakage. `lastErrorCode` stores only stable enum names. The
classifier never persists or logs exception content. Stale-processing
recovery and pruning return counts only.

## 12. Automated tests

Sync-focused suite (exact command:
`flutter test test/features/sync test/app/persistence_wiring_test.dart
test/app/app_bootstrap_test.dart
test/features/prayer/data/drift_prayer_log_repository_test.dart`):
**70/70, 0 failed, 0 skipped** (was 36).

- `test/features/sync/domain/sync_retry_policy_test.dart` (13): staged
  increase, caps, attempt-8 quarantine, never-in-past, jitter determinism
  and bounds, auth schedule slower + no count-quarantine, permanent
  immediate, unknown conservative rule, invalid attempt rejected.
- `test/features/sync/domain/sync_failure_class_test.dart` (7): permanent
  set, stable names, type-based classification, no raw text in output.
- `test/features/sync/data/sync_queue_hardening_test.dart` (14):
  recordFailure transitions (single increment, eligibility gate before/after
  `nextRetryAt`, permanent and max-attempt quarantine, terminal/missing
  no-ops, bad record does not block), pruning retention windows and
  never-prune statuses, idempotent zero-match prune, stale-inFlight recovery
  (metadata preserved, idempotent), diagnostics counts/ownership/age
  bucket/leak-free rendering.
- Existing guarantees re-verified unchanged: atomic saveDay+enqueue,
  coalescing, restricted rejection, remap idempotency, bootstrap recovery,
  mapper round-trip, wiring.

Full Flutter suite: **629/629**. Functions: **23/23** (Node.js 22).

## 13. Schema and migration status

No Drift table, schemaVersion, migration or generated file changed
(verified in the final diff). **Operation payload/schema versioning remains
unresolved** (TASK 072 P1) and stays outside this task by design.

## 14. No-remote-sync verification

`rg -i "FirebaseFirestore|cloud_firestore|https?://|WorkManager|
Connectivity|Timer.periodic|FirebaseFunctions|callable"` over
`lib/features/sync` → no matches. `pubspec.yaml`/lockfiles untouched.

## 15. Remaining P1 risks (before enabling remote sync)

1. No queue consumer/SyncEngine (by design here).
2. No `cloud_firestore` dependency / remote contract (+ Security Rules
   TASK 133, App Check TASK 134).
3. No pull/conflict/tombstone implementation.
4. No operation payload/schema version marker (migration-fixture proof
   pending).
5. Anonymous→account identity story (TASK 131) unresolved.

(The TASK 072 P1 "no backoff policy / error taxonomy" item is now closed.)

## 16. Remaining P2 risks

1. Diagnostics/prune methods have no invocation surface yet (foundation
   only).
2. Stale "Isar" wording in some sync docstrings (unchanged).
3. No manual retry / dead-letter surfacing for quarantined ops.

## 17. Readiness verdict

## READY FOR CONTROLLED REMOTE SYNC IMPLEMENTATION

Deterministic eligibility, deterministic backoff, safe failure
classification, single-increment attempt accounting, quarantine behavior,
bounded pruning, privacy-safe diagnostics and UID ownership are implemented
and tested, with no known local atomicity blocker. **Remote sync itself
remains disabled** and must stay disabled until later tasks deliver payload
versioning, a consumer, remote idempotency, conflict handling, Security
Rules, App Check and a controlled rollout.

## 18. TASK 074 recommendation

Per the roadmap, TASK 074 is the **Firebase and GitHub security-console
checklist** — it remains the next task and is untouched by this
recommendation. For the *sync track specifically*, the highest-value next
bounded slice (for a later sync-numbered task, before any consumer) is:

- **Objective:** operation payload/schema versioning + migration-safety
  proof (closes the last queue-side P1 other than the consumer stack).
- **In scope:** schema v2 adding a payload/schema version column with a
  versioned, idempotent migration; before/after migration fixture tests
  proving a non-empty queue survives; version stamping in the producer.
- **Out of scope:** consumer, remote writes, conflicts, account linking,
  Security Rules.
- **Schema implications:** first real Drift migration (v1→v2); queue rows
  must never be dropped (spec §22).
- **Required tests:** migration with pending/failedRetryable/quarantined
  rows; version stamping; old-row defaulting.
- **Privacy constraints:** version integer only — no payload copies.
- **Migration safety:** reversible plan + rollback strategy documented
  before merge (DO_NOT_BREAK rule).
- **Remote activation status:** stays disabled.
- **Acceptance criteria:** analyze clean; sync-focused ≥ 70 plus migration
  tests; full suite green; no data loss across upgrade.

## 19. Evidence appendix

- Policy: `bismillah_app/lib/features/sync/domain/policies/sync_retry_policy.dart`
- Failure classes: `bismillah_app/lib/features/sync/domain/value_objects/sync_failure_class.dart`
- Diagnostics model: `bismillah_app/lib/features/sync/domain/entities/sync_queue_diagnostics.dart`
- Interface: `bismillah_app/lib/features/sync/domain/repositories/sync_queue_repository.dart`
- Implementation: `bismillah_app/lib/features/sync/data/local/drift_sync_queue_repository.dart`
- Tests: `bismillah_app/test/features/sync/domain/sync_retry_policy_test.dart`,
  `.../domain/sync_failure_class_test.dart`, `.../data/sync_queue_hardening_test.dart`
- Unchanged schema: `bismillah_app/lib/features/sync/data/local/sync_operation_table.dart`
- Baselines: analyze clean · sync-focused 70/70 · full 629/629 · Functions 23/23
