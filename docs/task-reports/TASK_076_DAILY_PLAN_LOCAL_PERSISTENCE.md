# TASK 076 — DailyPlan Local Persistence

Implements local persistence for the **canonical per-day `DailyPlan`** model
using a temporary, versioned key-value adapter. No Drift schema change, no
plan generation, no Today UI, no Firebase write, no remote sync.

## 1. Executive summary

The existing `DailyPlanRepository` contract had no implementation: plans
could be modelled but not stored. TASK 076 supplies that implementation
behind the **unchanged** interface, so a per-day plan now survives app
restarts, can be read by `DayKey`, watched reactively, read as a range, and
replaced safely — entirely offline and device-local.

The original TASK 076 brief specified a *single active 30-day snapshot*
aggregate. That model **contradicts** the canonical specification and the
code already in the repository; the contradiction was reported before any
implementation and the owner approved **Option A — preserve the canonical
per-day model**. This report records that decision.

Persistence is a **single versioned JSON envelope** under one
`SharedPreferences` key. This is explicitly an **interim** arrangement: the
canonical target is a Drift table, which is blocked today. Corruption is
never silently repaired — it is reported as a typed failure.

Focused tests: **67 new**. Full Flutter suite: **629 → 696**.

## 2. Previous task and purpose

TASK 075 closed CP09 (*CP09 COMPLETE — TECHNICALLY STABLE*) and set the
product gate to *READY TO ENTER NEXT LOCAL-FIRST PRODUCT CHECKPOINT*.
TASK 076 is the first task of **CP10 — Today and 30-day personal plan**:
build the local data foundation the plan engine and Today UI will later use.

## 3. Canonical conflict and approved decision

### The contradiction

The original brief asked for one active 30-day snapshot with
`readActivePlan` / `saveActivePlan` / `clearActivePlan`. Repository evidence
says otherwise:

| Evidence | What it says |
|---|---|
| `docs/10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` §4 | `DailyPlan` = **"Bir günün planı"** (one day's plan): `dayKey, items[], profileType, sizeMinutes, weekIndex, generatedBy`; **"30 günlük çatı = 30 DailyPlan referans iskeleti"** |
| §5 | `PlanItem` is embedded in the plan document — *"Ayrı koleksiyon DEĞİL"* |
| §7 | `DailyPlanModel` keyed by **`dayKey` (unique)** |
| §9 | Remote path `users/{uid}/plans/{dayKey}` — one document **per day** |
| §11 | Conflict unit: **item-level completed-wins** within a plan-day |
| `docs/11_LOCAL_DATABASE_PACKAGE_DECISION.md` §3 | *"10 §7 tablosundaki 18 koleksiyon birebir Drift tablosuna eşlenir"* — DailyPlan is one of those 18 |
| `bismillah_app/lib/features/today/domain/entities/daily_plan.dart` | Already implements the per-day model |
| `bismillah_app/lib/features/today/domain/repositories/daily_plan_repository.dart` | Already declares `getPlan(DayKey)` / `watchPlan(DayKey)` / `savePlan` / `getRange` |

The canonical documents are **internally consistent**; only the brief
diverged. Implementing it would have created a second, conflicting DailyPlan
abstraction and invalidated the documented sync path and conflict rule.

### Approved decision — Option A

> Preserve the canonical per-day `DailyPlan` model and the existing
> `DailyPlanRepository` contract. Implement a temporary, versioned,
> key-value-backed local adapter without changing the Drift schema.

Consequences recorded here: the *single active 30-day snapshot* brief was
**rejected**; a 30-day plan remains a **composition of 30 per-day records**;
**no second DailyPlan abstraction was added**; `docs/10` and `docs/11` were
**not** edited — the final target architecture is unchanged.

Two incidental corrections: the canonical personalization model has **eight**
profile buckets (`10 §4`), not nine; the onboarding document is
`docs/04_ONBOARDING_FLOW.md`, not `04_ONBOARDING_SPEC.md`.

## 4. Existing per-day DailyPlan model (unchanged)

`DailyPlan` — `dayKey` (`DayKey`), `items` (unmodifiable `List<PlanItem>`),
`profileType`, `sizeMinutes`, `weekIndex`, `generatedBy`; validates
non-negative `sizeMinutes`/`weekIndex` and non-empty `generatedBy`; exposes
`completedCount` / `isFullyCompleted`; classified `SensitivityClass.high`.

`PlanItem` — `itemId` (`EntityId`), `type` (`PlanItemType`), `status`
(`PlanItemStatus`), optional `targetRef`, `sizeParam`, `completedAt`
(`UtcDateTime`), plus the order-independent `resolveCompletedWins` merge rule.

**No file in `lib/features/today/domain/` was modified by this task.**

## 5. Existing repository contract reused

```dart
ResultFuture<DailyPlan?>       getPlan(DayKey dayKey);
Stream<DailyPlan?>             watchPlan(DayKey dayKey);
ResultFuture<void>             savePlan(DailyPlan plan);
ResultFuture<List<DailyPlan>>  getRange(DayKey from, DayKey to);
```

Signatures and semantics are unchanged; only an implementation was added. No
`readActivePlan`/`saveActivePlan`/`clearActivePlan`, no second repository, no
second `Result`, no parallel date type. **No delete/tombstone operation was
added** — deletion propagation stays an unresolved remote-sync concern.

## 6. Temporary adapter rationale

`SharedPrefsDailyPlanRepository` is documented in-source as:

> **TEMPORARY LOCAL ADAPTER — MIGRATION REQUIRED BEFORE FINAL DATABASE
> CONSOLIDATION**

Reasons: DailyPlan ultimately belongs in Drift (`11 §3`); the first Drift
migration is blocked/deferred (TASK 066 toolchain; TASK 075 gate **G8**);
TASK 076 must not touch `schemaVersion`; and CP10 product work should not
wait on the migration toolchain. The identical trade-off was already accepted
in TASK 047 for `SharedPrefsQuranDailyProgressRepository`, so this follows an
established precedent rather than inventing one.

This is **not** described anywhere as the final persistence architecture.

## 7. Versioned envelope format

One logical value under one key.

- **Storage key:** `bismillah.daily_plans` (constant
  `SharedPrefsDailyPlanRepository.storageKey`). The `bismillah.` prefix is
  deliberate — see §12. The key carries **no** user, device or profile
  identity.
- **Current persistence version: 1** (`DailyPlanEnvelopeCodec.currentVersion`).

```json
{
  "v": 1,
  "plans": {
    "2026-07-26": {
      "dayKey": "2026-07-26",
      "profileType": "reconnect",
      "sizeMinutes": 20,
      "weekIndex": 0,
      "generatedBy": "rule-engine-v1",
      "items": [
        { "itemId": "…", "type": "quran", "status": "pending",
          "targetRef": "surah-2", "sizeParam": 5 }
      ]
    }
  }
}
```

Properties: days serialise in **ascending `DayKey` order** (deterministic
output — the same input always produces the same string); item order is
preserved exactly; enums use **stable machine names** (`.name`), never index;
optional fields are omitted when null; `completedAt` is ISO-8601 UTC.

`dayKey` is intentionally stored **both** as the map key and as an embedded
field: the embedded copy makes each record self-describing for the future
Drift row migration, and makes key/field mismatch a *detectable* corruption.

**30 separate preference keys are not used, and no key-per-item exists** —
proven by a test asserting exactly one plan-related key after multiple saves.

**Unknown-field policy (explicit):** unknown *optional* fields — at envelope
root, plan level or item level — are **ignored** for forward compatibility;
missing or wrong-typed **required** fields are always an error. Both halves
are tested.

## 8. Repository behavior

**`getPlan`** — absent day → `Success(null)` (not a failure); present day →
that plan; whole-envelope corruption or unsupported version → typed
`StorageFailure`; never returns a different day.

**`savePlan`** — reads the current envelope first; **if the existing envelope
is corrupt it returns `StorageFailure` and writes nothing** (verified: the
corrupt bytes remain untouched afterwards); otherwise replaces only the entry
matching `plan.dayKey`, preserves every other day, and writes the whole
envelope as one value, so no partial multi-key state can exist. Write
failures (including a `false` return from the platform) are typed.

**`getRange`** — **inclusive on both ends**; returns only days inside the
range, ordered ascending by `DayKey`; no matches → empty list; inverted range
(`from > to`) → typed failure, matching the one existing range precedent in
the codebase (`QuranDailyProgressRepository.loadRange`).

**`watchPlan`** — see §9.

## 9. watchPlan semantics

Implemented with a broadcast `StreamController`, filtered by `DayKey`.

- Emits when `savePlan` succeeds for the watched day.
- A save for a **different** day never reaches the stream.
- Multiple simultaneous listeners each receive the emission.
- Cancelling a subscription, and saving afterwards, is safe.
- `dispose()` closes the controller and is idempotent; the DI provider wires
  it via `ref.onDispose`, so no controller leaks.
- A failed save (e.g. corrupt storage) produces **no** emission.

**Documented interim limitation:** subscribing does **not** replay the
current value; the stream carries only subsequent saves. This matches the
existing project convention (`SharedPrefsQuranDailyProgressRepository.watchToday`).
Callers obtain the initial value with `getPlan`. Genuine reactive queries
arrive when plan data moves to Drift. This behaviour is asserted by a test so
the limitation cannot regress unnoticed.

No polling and no `Timer.periodic` were introduced.

## 10. Corruption handling

Every case below yields a **typed `StorageFailure`** at the repository
boundary and a `FormatException` at the codec boundary — never a crash, never
a raw exception reaching callers:

invalid JSON · root not an object · missing version · version wrong type ·
unsupported future version (and version `0`) · missing `plans` · `plans`
wrong type · invalid `DayKey` map key · map-key/embedded-`dayKey` mismatch ·
plan field wrong type · plan failing domain validation · unknown enum value ·
invalid `PlanItem` · duplicate item ID within a day · non-string stored value
· storage read exception · storage write failure.

Guarantees: raw stored JSON, day keys and item targets are **never** copied
into failure output (asserted with marker-laden fixtures); unknown versions
are **never** silently migrated; unknown enums **never** fall back to a
default; corrupt storage is **never** auto-deleted, auto-overwritten or
silently replaced by an empty envelope; no plan is auto-generated. Recovery
remains a later, deliberate decision.

Note a deliberate divergence from `SharedPrefsQuranDailyProgressRepository`,
which silently clears a corrupt day record: DailyPlan **reports** corruption
instead, per this task's requirements.

Codec-level invariant: item IDs are unique within a day, enforced
**symmetrically** on encode and decode so a duplicate can neither be written
nor read. The domain entity does not currently enforce this and was not
changed; hardening it is left to a future domain task.

## 11. Privacy guarantees

The stored plan object contains **exactly** six keys — `dayKey`,
`profileType`, `sizeMinutes`, `weekIndex`, `generatedBy`, `items` — asserted
by test. Absent by construction and by explicit assertion: precise location,
calculated prayer times, Firebase UID, `local-` fallback UID, device
identifier, notification payload, Assistant questions, Quran reading history,
analytics identifiers, subscription/entitlement state, free-text notes.

Nothing is logged by this adapter: no serialized plans, no item targets, no
completion values, no day keys. Failures surface only as `StorageFailure`
(`messageKey: 'errorStorage'`), which carries no user text.

## 12. Reset-data behavior

**Decision: no reset code was changed — the existing mechanism already
covers DailyPlan.**

`SharedPrefsLocalDataResetRepository.clearAllExceptLocale()` removes every
key beginning with `bismillah.` except the locale key. Because the plan
envelope lives at `bismillah.daily_plans`, a full local reset clears it
without any enumeration change. This is proven by two tests: the envelope is
gone (and `getPlan` returns no plan) after reset, and the app locale
survives. Prayer, Quran and onboarding reset semantics are untouched, and no
repository-level delete/tombstone behaviour was added.

## 13. Automated tests

**67 new DailyPlan-focused tests**, all passing, zero skipped:

| File | Tests | Coverage |
|---|---|---|
| `bismillah_app/test/features/today/data/daily_plan_envelope_codec_test.dart` | 30 | encode determinism/order, version-1 emission, stable enum names, full round-trips (fields, multi-day, item order, completion, all `PlanItemType` values, timezone-free `DayKey`), 15 corruption rejections, payload-free error text, unknown-field policy |
| `bismillah_app/test/features/today/data/shared_prefs_daily_plan_repository_test.dart` | 32 | `getPlan` empty/hit/wrong-day/corrupt/unsupported/non-string/leak-free; `savePlan` multi-day preservation, same-day replacement, completion durability, corrupt-storage refusal, unrelated keys untouched, single-key proof; `getRange` ordering/bounds/empty/inverted/corrupt/30-day frame; adapter-recreation persistence; 8 `watchPlan` cases; 2 reset cases; 2 privacy cases |
| `bismillah_app/test/features/today/data/daily_plan_providers_test.dart` | 5 | production provider resolves the adapter, single instance, test override, disposal closes the stream, **bootstrap performs zero plan reads/writes/watches** |

Persistence-across-restart is demonstrated by **adapter recreation** (save
with instance A, dispose, read with instance B over the same backing store).
This is explicitly *not* a claim of real OS process-death testing.

Existing suites were not weakened or modified: `plan_item_test.dart` (4) and
all `DayKey` behaviour still pass unchanged.

| Suite | Before | After |
|---|---|---|
| Full Flutter | 629 | **696** (0 failed, 0 skipped) |
| Canonical sync-focused | 70 | **70** |
| Drift storage | 11 | **11** |
| Functions (Vitest) | 23 | **23** |
| `flutter analyze` | clean | **clean** (0/0/0) |

## 14. No Drift / schema / dependency changes

`git status` shows **only new files** — zero modifications to tracked files.
Unchanged accordingly: Drift tables, `app_database.dart`, `schemaVersion`,
migrations, `app_database.g.dart`, schema snapshots, `drift_dev`, `analyzer`,
`pubspec.yaml`, `pubspec.lock`, `functions/package.json`,
`functions/package-lock.json`, Firebase files, workflows, Android/iOS files,
notification code, app version. No Drift generation tooling was run and no
build output was committed.

## 15. No generation / UI / remote-sync verification

**No generation:** no onboarding-profile-to-plan mapping, no four-week
progression, no 30-day generation loop, no religious recommendation content,
no streak logic. The only `generatedBy` occurrences are the canonical
rule-engine **version string** field, not generation logic. The repository
only stores and returns plans supplied by a caller.

**No UI:** no Today cards, controller, state machine or completion
interaction; no onboarding UI change; no `presentation/` file touched.

**No remote sync:** a pattern scan of `lib/features/today/data` for
`cloud_firestore|FirebaseFirestore|FirebaseFunctions|http|WorkManager|Connectivity|Timer.periodic|SyncOperation|enqueue`
returns **no matches**. DailyPlan was **not** added to `SyncOperations`; no
queue producer or consumer exists; `cloud_firestore` remains absent. The
canonical `users/{uid}/plans/{dayKey}` path stays documentation-only, and
remote sync remains disabled.

## 16. Future Drift migration boundary

The envelope→Drift migration is **not** implemented here. When the Drift gate
opens, the migration must:

1. Read the version-1 envelope under `bismillah.daily_plans`.
2. Insert one `DailyPlan` row per `DayKey` **inside a single transaction**.
3. Verify row count and per-plan equality (including item order and
   completion state).
4. Preserve completion state and `completedAt` exactly.
5. Remove the old envelope **only after** the transaction commits.
6. Roll back safely on any failure, leaving the envelope intact.

TASK 075 associated payload/schema-versioning gate **G8** with **TASK 132**;
that ownership is preserved and **no new task number was invented**.

## 17. TASK 077 scope (not implemented)

Canonical next task, unchanged from the roadmap:

> **TASK 077 — Daily plan state machine**

Expected bounded purpose: load a per-day `DailyPlan` through the repository;
expose loading / empty / available / corrupt states; support controlled
save-and-refresh transitions. Remains local-only. **Not** in scope unless the
roadmap explicitly assigns it: the full generation algorithm, the final Today
UI, and any remote sync. It must not be redefined as plan generation —
generation is TASK 079 (*Deterministic daily plan generator*).

## 18. Evidence appendix

- `bismillah_app/lib/features/today/data/daily_plan_envelope_codec.dart`
- `bismillah_app/lib/features/today/data/shared_prefs_daily_plan_repository.dart`
- `bismillah_app/lib/features/today/data/today_data_providers.dart`
- `bismillah_app/test/features/today/data/daily_plan_envelope_codec_test.dart`
- `bismillah_app/test/features/today/data/shared_prefs_daily_plan_repository_test.dart`
- `bismillah_app/test/features/today/data/daily_plan_providers_test.dart`
- Unchanged domain: `bismillah_app/lib/features/today/domain/entities/daily_plan.dart`,
  `.../domain/repositories/daily_plan_repository.dart`,
  `.../domain/value_objects/plan_enums.dart`
- Reset mechanism: `bismillah_app/lib/features/settings/data/shared_prefs_local_data_reset_repository.dart`
- Interim-adapter precedent: `bismillah_app/lib/features/quran/data/shared_prefs_quran_daily_progress_repository.dart`
- Bootstrap (untouched): `bismillah_app/lib/app/app_bootstrap.dart`
- Canonical specs: `docs/10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` §4–§11,
  `docs/11_LOCAL_DATABASE_PACKAGE_DECISION.md` §3
- Baselines: analyze clean · full **696/696** · DailyPlan-focused **67** ·
  canonical sync-focused **70/70** · Drift storage **11/11** · Functions
  **23/23**
