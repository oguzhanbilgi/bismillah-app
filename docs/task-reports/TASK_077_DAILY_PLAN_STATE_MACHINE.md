# TASK 077 — Daily Plan State Machine

Application-layer state machine that loads, observes, refreshes and saves one
selected day's canonical per-day `DailyPlan` through the existing repository.
Includes an approved minimum failure-contract correction.

## 1. Executive summary

TASK 076 gave `DailyPlanRepository` its first implementation but nothing
consumed it. TASK 077 adds the deterministic state machine that does: a
selected `DayKey` moves through **loading → empty / available / corrupt /
failure**, with a live `watchPlan` subscription, controlled saving, and
**epoch-based stale-result protection** so a late async result can never
overwrite newer state.

Implementation ran into a real contract defect first: the repository could not
express *"the stored data is corrupt"* separately from *"a storage operation
failed"* — both returned an identical `StorageFailure()`. Work stopped at the
§10 gate rather than string-matching error text. The owner approved a minimum
correction: a new `StorageCorruptionFailure` sibling type.

`DailyPlan` remains per-day, the repository contract is unchanged, envelope
version stays **1**, and there is no generation, Today UI, Firebase write,
Drift migration or remote sync.

TASK 077-focused tests: **43 new**. TASK 076 persistence tests: **67 → 70**.
Full suite: **696 → 742**.

## 2. Previous task and purpose

TASK 076 (PR #19, merge `d9671c4`) preserved the canonical per-day model and
implemented `getPlan` / `watchPlan` / `savePlan` / `getRange` over a temporary
version-1 key-value envelope. TASK 077 is the CP10 slice that turns that data
layer into usable application state — still with no UI and no generation.

## 3. Why the stop gate was triggered, and the approved change

### The defect

`SharedPrefsDailyPlanRepository` returned the same `const StorageFailure()`
from **every** failure path — corrupt JSON, unsupported envelope version,
invalid serialized plan, wrong stored type, SharedPreferences read/write
exceptions, and even an inverted `getRange` argument. `AppFailure` had no
member expressing data corruption.

§5 of this task requires **both** a `Corrupt` state and an ordinary `Failure`
state. With one indistinguishable failure value, the only way to separate them
would have been parsing raw error text — which §10 explicitly forbids. Work
therefore stopped and reported before any edit.

### The approved minimum correction

```dart
final class StorageCorruptionFailure extends AppFailure {
  const StorageCorruptionFailure() : super(messageKey: 'errorStorage');
}
```

Properties, all verified:

- **No signature changed** — `Result` / `ResultFuture` already carry
  `AppFailure`; every repository method keeps its exact signature.
- **Sealed hierarchy preserved** — added as a sibling `final class`.
- **No localization key added** — reuses `errorStorage`, so user-visible copy
  is unchanged. A test asserts the corruption failure still reports
  `messageKey == 'errorStorage'`.
- **Non-breaking** — a repository-wide scan found **no exhaustive `AppFailure`
  switch**. The only `switch (failure)` sites are over the feature-local
  `QuranBookmarkFailure` enum, and `Result.fold`'s switch is over `Result`
  subtypes. Nothing required a compiler-silencing `default`.
- Carries no exception, JSON, payload, path or storage key.

### StorageCorruptionFailure vs StorageFailure

The distinction is **semantic, not cosmetic**: corruption is not retryable
(re-reading yields the same result and recovery is a separate decision),
whereas a storage operation failure is transient and retrying is sensible.

| Path | Failure |
|---|---|
| Stored value has wrong runtime type | `StorageCorruptionFailure` |
| Envelope JSON cannot be decoded | `StorageCorruptionFailure` |
| Envelope structurally invalid | `StorageCorruptionFailure` |
| Version missing / malformed / unsupported | `StorageCorruptionFailure` |
| Invalid serialized `DailyPlan` / `PlanItem` / `DayKey` / enum | `StorageCorruptionFailure` |
| `savePlan` refusing to overwrite an already-corrupt envelope | `StorageCorruptionFailure` |
| SharedPreferences read exception | `StorageFailure` |
| SharedPreferences write exception | `StorageFailure` |
| SharedPreferences write returned `false` | `StorageFailure` |
| Encode failure from invalid caller/domain state | `StorageFailure` |
| Invalid `getRange` arguments (inverted range) | `StorageFailure` |

**Caller validation errors are never classified as storage corruption** —
asserted by two dedicated tests (inverted range; duplicate item IDs supplied
by the caller).

`savePlan` now **propagates the read failure's type** rather than flattening
it, so a save blocked by corrupt storage surfaces corruption while a save
blocked by a transient read error surfaces an ordinary failure.

## 4. State model

`bismillah_app/lib/features/today/application/daily_plan_state.dart` — a
sealed hierarchy following the `PrayerTimesState` precedent, where calm
situations are modelled as **data, not errors**.

| State | Meaning |
|---|---|
| `DailyPlanLoading` | Read in progress for the selected day |
| `DailyPlanEmpty` | No plan stored for that day (not a deficiency — simply not generated yet) |
| `DailyPlanAvailable` | Valid plan loaded; carries `plan` and `isSaving` |
| `DailyPlanCorrupt` | Stored data unreadable; `canRetry == false` |
| `DailyPlanFailure` | Transient storage operation failure; `canRetry == true` |

Every state carries the requested `dayKey`. The controller's overall state is
`DailyPlanState?`, where `null` means *no day selected yet* — matching the
existing `Notifier<T?>` precedent (`OnboardingPaceController`).

There is deliberately **no "generated" state**: generation does not exist
(TASK 079).

## 5. State invariants

- `DailyPlanAvailable.dayKey` is **derived** from `plan.dayKey`
  (`super(dayKey: plan.dayKey)`), so "the displayed plan belongs to the
  selected day" is structurally guaranteed — a plan for another day cannot be
  represented in that state at all.
- Empty, corrupt and failure states all retain the requested `DayKey`.
- `savePlan` with a plan whose `dayKey` differs from the active day is
  rejected without touching state or calling the repository.
- A disposed controller publishes nothing.
- Older operations cannot overwrite newer selected-day state (§7).
- Watch events from a previously selected day cannot affect the current day.
- Exactly one active watch subscription per controller; switching days
  cancels the previous one.
- `retry()` acts only on the currently selected day.

Domain validation was not weakened anywhere.

## 6. Controller operations

`bismillah_app/lib/features/today/application/daily_plan_controller.dart` —
`DailyPlanController extends Notifier<DailyPlanState?>`.

**`loadDay(DayKey)`** — opens a new epoch, marks the day current, publishes
`DailyPlanLoading` **synchronously** (so the caller sees the selection take
effect without awaiting), cancels the previous subscription, attaches
`watchPlan` for the new day, then performs an explicit `getPlan` read and maps
the result. Re-selecting the same day deliberately re-reads.

**`refresh()`** — re-reads only the active day; publishes loading first; never
creates or generates a plan; a safe no-op when no day is selected (verified:
zero repository calls).

**`savePlan(DailyPlan)`** — requires `plan.dayKey == activeDay`; sets
`isSaving` on the existing `DailyPlanAvailable` so the visible plan does not
disappear mid-save; delegates to the repository (never touches
`SharedPreferences` directly); returns to `DailyPlanAvailable` on success;
maps failures by type.

**`retry()`** — re-runs the read for the current day. Caller-initiated only;
there is no automatic retry loop. On corruption `canRetry` is `false` (a
re-read cannot help), but an insistent caller still gets an honest re-read
rather than a silent no-op.

## 7. Initial read / watch coordination and stale-result protection

TASK 076 documented that `watchPlan` does **not** replay the stored value on
subscribe. The controller therefore combines an explicit `getPlan` with a live
subscription, and resolves the resulting race with a **generation (epoch)
counter** — the same idiom as `QuranSearchController`.

Every selection, refresh, save and watch event increments `_generation`. Any
awaited completion re-checks its captured generation and silently drops if it
is no longer current. Disposal also marks all pending work stale.

The specific race in §8 of the brief is covered by a dedicated test:

1. `getPlan` is held open by a test gate.
2. A newer `savePlan` emission arrives on the watch stream and publishes.
3. The older `getPlan` then completes — and is **discarded**, because the
   watch event advanced the generation.

Order is never assumed; the gates make the interleaving deterministic rather
than relying on "usually completes first".

## 8. Save concurrency

Rule: **latest valid completion wins, enforced by epochs** — no global queue,
no serialization lock.

Verified behaviours:

- Save during a pending load/refresh: the save's epoch supersedes the read.
- Two rapid saves: both reach the repository; the later result is the one
  reflected; the earlier completion is dropped.
- Save completing after switching day: cannot publish the old day's state.
- Watch emission arriving before the save future completes: no duplicate or
  contradictory state — both paths converge on the same `DailyPlanAvailable`.
- **An older failed save can never replace a newer successful state** —
  covered by an explicit test.

## 9. Failure mapping

```dart
switch (failure) {
  StorageCorruptionFailure() => DailyPlanCorrupt(dayKey: dayKey),
  _                          => DailyPlanFailure(dayKey: dayKey),
}
```

Only the **type** is inspected. `messageKey` is not read, exception text is
not parsed, no string matching occurs, and the failure object is never stored
in or copied into state. Any other `AppFailure` (e.g. `UnexpectedFailure`)
maps to `DailyPlanFailure` — asserted by test.

Watch-stream errors follow the existing `core/contracts` rule: they do **not**
topple the last known state; errors are reported through the read path.

## 10. Provider lifecycle

`dailyPlanControllerProvider` is a `NotifierProvider<DailyPlanController,
DailyPlanState?>` that resolves the repository through the existing
`dailyPlanRepositoryProvider`. It is not `autoDispose`, watches no provider
(so it never rebuilds unexpectedly), and reads the repository at call time.

`ref.onDispose` marks the controller disposed and cancels the subscription;
a test asserts the subscription is cancelled on container disposal, and
another asserts a post-disposal `savePlan` performs no repository call.

**Bootstrap does not instantiate or load the controller** — verified by
running `initializeLocalPersistence` with a recording repository and
asserting zero `getPlan` / `watchPlan` / `savePlan` / `getRange` calls. No
Today screen dependency, no `BuildContext`, no widget-level repository access.

## 11. Privacy guarantees

State objects hold only a `DayKey` and, when available, the canonical
`DailyPlan`. They expose no raw JSON, no storage key, no exception message, no
stack trace, no UID, no location and no Firebase data — asserted by two tests
that render state and scan for forbidden markers (including `errorStorage`,
proving the failure's internals are not surfaced through state). Nothing in
the controller logs plan content.

## 12. Automated tests

**43 new TASK 077 tests** in
`bismillah_app/test/features/today/application/daily_plan_controller_test.dart`,
using a controllable fake repository with per-call gates (`Completer`s) so
concurrency is deterministic rather than timing-dependent:

| Group | Tests | Coverage |
|---|---|---|
| Initial load | 7 | initial `null`; loading→available; loading→empty; corrupt; ordinary failure; other `AppFailure`→failure; day preserved in every terminal state |
| Refresh | 6 | refresh available/empty/after-failure/after-corruption; no-op with no day; no generation; selected day unchanged |
| Day switching | 5 | A→B; previous subscription cancelled; late A read ignored; late A watch event ignored; re-selecting same day re-reads |
| Repository watch | 6 | matching-day emission; null→empty; latest of many wins; watch error preserves state; single subscription; disposal cancels |
| Save | 8 | success; `isSaving` transition without screen jump; write failure; corrupt-storage save; wrong-day rejection; no-day rejection; no generation; post-disposal no-op |
| Race conditions | 6 | newer watch beats older read; newer day beats older load; newer save success beats older save failure; day switch during save; rapid double save; refresh cannot overwrite newer watch |
| Provider & lifecycle | 3 | production wiring; override; **bootstrap performs zero plan calls** |
| Privacy | 2 | state exposes no internals; failure states carry no raw content |

**TASK 076 persistence tests: 67 → 70**, strengthened not weakened —
corruption assertions now demand `StorageCorruptionFailure`, ordinary-I/O and
caller-validation assertions still demand `StorageFailure`, plus three new
tests (invalid serialized data is corruption; corruption still uses
`errorStorage`; caller-supplied duplicate item IDs are *not* corruption).

| Suite | Before | After |
|---|---|---|
| Full Flutter | 696 | **742** (0 failed, 0 skipped) |
| TASK 077-focused | — | **43** |
| DailyPlan persistence (TASK 076) | 67 | **70** |
| Canonical sync-focused | 70 | **70** |
| Drift storage | 11 | **11** |
| Functions (Vitest) | 23 | **23** |
| `flutter analyze` | clean | **clean** |

## 13. No generation / UI / remote / database verification

**No generation:** no onboarding-profile mapping, four-week progression,
30-day loop, generated plan content, religious recommendation, schedule
composition, template catalogue or randomization. The controller only reads
and writes plans supplied by callers. Tests assert refresh and save never
produce a plan. Generation remains **TASK 079**.

**No Today UI:** no screen, widget, card, button, progress or state widget, no
route, no copy and no localization string was added or modified. Only state
*definitions* were introduced; `presentation/` was untouched.

**No remote or database change:** a scan of the new application layer for
`cloud_firestore|FirebaseFirestore|SyncOperation|enqueue|Timer.periodic|Connectivity|WorkManager`
returns no matches. No Drift table, migration, `schemaVersion` or generated
file changed; no dependency or lockfile changed; `cloud_firestore` remains
absent and remote sync remains disabled.

**Persistence untouched:** envelope version stays **1**, storage key stays
`bismillah.daily_plans`, envelope format and `SharedPrefsDailyPlanRepository`
persistence shape are unchanged — only failure *classification* changed.

**Domain untouched:** `DailyPlan` per-day meaning, `DayKey` representation,
`PlanItem` semantics and completed-wins behaviour are unchanged. The TASK 076
`PlanItem` identity-uniqueness observation remains a future domain-hardening
item and was **not** moved into the state machine.

## 14. Remaining DailyPlan work

- Today UI consuming this state machine (later CP10 task).
- Deterministic plan generation — **TASK 079**.
- Onboarding profile mapping — **TASK 078**.
- Corruption **recovery** policy (regenerate vs clear): deliberately not
  implemented; the controller reports corruption and stops.
- Migration of the temporary envelope to the canonical Drift table; gate
  **G8** remains owned by **TASK 132**.
- `PlanItem` identity uniqueness in the domain entity (codec-level today).
- `watchPlan` still does not replay the current value on subscribe; real
  reactive queries arrive with Drift.

## 15. Exact next task

From `docs/project-state/MASTER_EXECUTION_ROADMAP.md` (CP10) and
`TASK_INDEX.md`, unchanged and not renumbered:

> **TASK 078 — Onboarding profile mapping**

TASK 079 (*Deterministic daily plan generator*) continues to own generation.

## 16. Evidence appendix

- `bismillah_app/lib/core/errors/app_failure.dart` (`StorageCorruptionFailure`)
- `bismillah_app/lib/features/today/application/daily_plan_state.dart`
- `bismillah_app/lib/features/today/application/daily_plan_controller.dart`
- `bismillah_app/lib/features/today/data/shared_prefs_daily_plan_repository.dart` (failure classification only)
- `bismillah_app/test/features/today/application/daily_plan_controller_test.dart` (43)
- `bismillah_app/test/features/today/data/shared_prefs_daily_plan_repository_test.dart` (70)
- Unchanged contract: `bismillah_app/lib/features/today/domain/repositories/daily_plan_repository.dart`
- Unchanged domain: `bismillah_app/lib/features/today/domain/entities/daily_plan.dart`
- Precedents reused: `bismillah_app/lib/features/quran/application/quran_search_controller.dart` (generation counter),
  `bismillah_app/lib/features/today/application/today_prayer_summary_controller.dart` (subscription + `ref.onDispose`),
  `bismillah_app/lib/features/prayer_times/application/prayer_times_state.dart` (sealed calm states)
- Bootstrap (untouched): `bismillah_app/lib/app/app_bootstrap.dart`
- Prior report: `docs/task-reports/TASK_076_DAILY_PLAN_LOCAL_PERSISTENCE.md`
- Baselines: analyze clean · full **742/742** · TASK 077-focused **43** ·
  DailyPlan persistence **70** · canonical sync **70/70** · Drift storage
  **11/11** · Functions **23/23**
