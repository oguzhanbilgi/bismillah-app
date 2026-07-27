# TASK 083A — Initial DailyPlan Orchestration

## 1. Why TASK 083A was inserted

TASK 076–083 built every piece of the plan engine — persistence, state
machine, profile mapping, generator, the three core item sources and the
Today task UI — but **nothing ever invoked the generator**. In practice the
Today plan section showed the Empty state for every user, including a user
who had just completed onboarding.

TASK 084 (missed-day recovery and gentle rollover) cannot be built on top of
plans that never exist, so this controlled insertion closes the wiring gap.
It sits **between TASK 083 and TASK 084**; no existing task was renumbered.

Free, ad-free core work: no Bismillah+, subscription, supporter package,
LÖSEV, advertising or remote sync.

## 2. Architecture gate result

| Question | Finding |
|---|---|
| Where is onboarding completion committed? | `OnboardingCompletionController.complete()` → `saveCompleted()` → `markCompleted()` → screen navigates to `/today` |
| Are preferences persisted before navigation? | Yes — the save completes before the gate opens |
| Can an onboarded user have no plan? | Yes — this is the current state of every existing install |
| Does the repository support atomic multi-plan writes? | Not in the contract, but the envelope trivially allows it (read-all → merge → encode once → write once) |
| Would 30 individual writes risk partial state? | Yes — therefore forbidden and not used |
| How does Today pick its initial `DayKey`? | `DayKey.fromLocal(clock.nowLocal())` in a post-frame callback |
| How can bootstrap run once without loops? | A dedicated Riverpod controller holding a run-once flag; never inside `build` |

No stop condition applied: preferences are recoverable, the `AppClock` day
rule already exists, atomicity needs **no storage-format migration**, and the
orchestrator refuses to overwrite existing valid plans.

## 3. Atomic persistence design

`DailyPlanRepository` gained one method:

```dart
ResultFuture<void> savePlans(List<DailyPlan> plans);
```

`SharedPrefsDailyPlanRepository.savePlans` performs **one logical write**:

1. reject an empty batch (typed `ValidationFailure`)
2. reject duplicate `DayKey`s in the batch (typed `ValidationFailure`)
3. read the existing envelope — a **corrupt** envelope is never overwritten
   and propagates `StorageCorruptionFailure`
4. merge the batch into the existing map in memory (days outside the batch
   are preserved untouched)
5. encode **once**
6. `prefs.setString` **once**
7. publish watch events only **after** a successful write

If encoding or storage fails, the stored envelope is byte-identical to what
it was before — a partial range cannot exist. **No 30 sequential `savePlan`
calls.** The storage key stays `bismillah.daily_plans` and the persistence
version stays **1**; no Drift, no migration, no schema change.

## 4. Orchestrator contract

`InitialDailyPlanOrchestrator` (application layer, injected
`DailyPlanRepository` + `OnboardingPreferencesRepository` + `AppClock` +
item source) runs the whole chain:

```
OnboardingPreferences
  → OnboardingProfileMapper
  → DailyPlanGenerationRequest
  → DailyPlanGenerator + CoreDailyPlanItemSource (Prayer → Quran → Learn)
  → savePlans(30)  [one atomic write]
```

Start day is `DayKey.fromLocal(clock.nowLocal())` — no `DateTime.now()`, no
UTC shift (asserted by a source-level test). The orchestrator contains no
user-facing strings.

Typed sealed outcomes:

| Outcome | Meaning |
|---|---|
| `InitialDailyPlanCreated` | 30 plans generated and written atomically |
| `InitialDailyPlanAlreadyAvailable` | range already complete — **nothing written** |
| `InitialDailyPlanOnboardingIncomplete` | no stored preferences, or the profile cannot be resolved |
| `InitialDailyPlanRangeConflict` | partial or non-continuous existing range |
| `InitialDailyPlanGenerationFailed` | typed generator failure |
| `InitialDailyPlanPersistenceFailed` | read or atomic-write failure; storage unchanged |

No variant carries raw onboarding answers, plan JSON, article text, storage
keys, UID, device data, exception text or stack traces (asserted).

## 5. Idempotency and existing data

- **Empty range** → generate + one atomic write.
- **Complete matching range** → `alreadyAvailable`; completion status,
  `completedAt` timestamps, `profileType` and `generatedBy` are untouched.
- **Partial range** (1–29 days, or 30 non-continuous days) → typed
  `rangeConflict`. Missing days are **not** auto-filled and existing days are
  **never** deleted or overwritten. Recovery belongs to TASK 084.
- **Concurrent calls** → the first call's `Future` is memoized; later
  concurrent callers await the same operation and observe the same outcome.
  Two concurrent calls produce exactly **one** write (asserted, including a
  three-way concurrent test).

## 6. New-user onboarding integration

`OnboardingCompletionController.complete()` now:

1. validates selections (unchanged)
2. saves `OnboardingPreferences` (unchanged — still one save, no duplicate
   persistence path)
3. **passes the same in-memory preferences object** to the orchestrator, so
   there is no second read
4. opens the completion gate and returns `true` **only** when the plan is
   available

If plan creation fails, completion is **not** reported as successful, the
gate stays closed, and the screen does not navigate to an Empty Today. The
error state reuses the existing neutral `onboardingSaveIssue` message — the
raw failure is not exposed. Preferences remain persisted, so retrying is
safe and cannot produce a second plan (asserted: after a failed attempt and
a successful retry, a further `complete()` writes nothing more).

If preference saving itself fails, plan creation is never attempted.

## 7. Existing-user bootstrap

`InitialDailyPlanBootstrapController` (Riverpod `Notifier`) runs
`ensureInitialPlan()` **at most once per app lifecycle**, guarded by an
internal flag — regardless of outcome, it never auto-repeats, so no build or
provider loop can regenerate a plan. Generation never runs inside a widget
`build`; `TodayPlanSection` calls it once from its post-frame callback and
then loads the day, so an existing user with no plan lands on a populated
Today instead of an Empty screen.

`retry()` is the explicit user-driven path, wired to the existing neutral
failure retry button (it retries the setup and then re-reads the day).
Because the orchestrator preserves valid plans, retrying cannot duplicate
anything.

App bootstrap itself still touches no plan provider — the existing
"bootstrap does not read, write or generate plans" test was extended to
cover `savePlans` too.

## 8. Today behavior

After a successful setup the current `DayKey` loads into `DailyPlanAvailable`
with the canonical Prayer → Quran → Learn order preserved, completion
toggling still persists, and a restart restores the same plan **and** the same
completion state (asserted end-to-end).

Empty remains valid for genuinely missing preferences and for typed
conflicts. No fake plan is ever rendered.

## 9. Tests

**73 new focused tests**, all passing:

```bash
flutter test test/features/today/application/initial_daily_plan_orchestrator_test.dart
flutter test test/features/today/data/shared_prefs_daily_plan_repository_test.dart
flutter test test/features/today/presentation/today_plan_section_test.dart
```

- Orchestrator suite **59**: generation (30 continuous unique days, core
  composition, clock-derived first day), all **eight** profiles reachable
  with a coverage lock, atomic persistence failure paths, idempotency,
  concurrency, partial/conflicting ranges, onboarding-flow integration,
  existing-user bootstrap, Today integration, restart persistence and
  privacy/regression boundaries.
- Repository `savePlans` contract **11** (suite 70 → **81**): single envelope
  write, version stays 1, empty batch rejected, duplicate `DayKey` rejected
  with nothing written, encoder failure leaves storage byte-identical,
  corrupt storage never overwritten, unrelated days preserved, watch events
  only after success, 30-day batch in one call.
- Today section **3** (suite 50 → **53**): stored preferences create the plan
  and Today shows Available; repeated rebuild does not regenerate; no
  preferences fabricates nothing.

Full Flutter suite: **1231 → 1304**, 0 failed, 0 skipped. `flutter analyze`:
clean. Functions untouched and not re-run.

## 10. No schema, remote or premium changes

- Storage key `bismillah.daily_plans` — unchanged (asserted).
- Envelope persistence version **1** — unchanged (asserted).
- No Drift table, migration or generated code.
- No Firebase write, no `cloud_firestore`, no remote sync, no notifications.
- No dependency change.
- No paywall, subscription, supporter tier, LÖSEV or advertising.
- The orchestrator imports no Drift, Firebase, HTTP or `shared_preferences`
  symbol and calls no `DateTime.now()` (asserted at source level).

## 11. Next task

**TASK 084 — Missed-day recovery and gentle rollover** (CP10) remains next
and is now unblocked: real plans exist, and the typed `rangeConflict` outcome
is exactly the state TASK 084 must learn to recover. Not started.
