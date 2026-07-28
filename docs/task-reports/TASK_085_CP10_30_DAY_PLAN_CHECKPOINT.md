# TASK 085 — 30-Day Plan and CP10 Checkpoint

## 1. Scope

Validation of the complete local-first 30-day DailyPlan flow built across
TASK 076–084:

```
OnboardingPreferences → OnboardingProfileMapper → DailyPlanGenerator
→ CoreDailyPlanItemSource → atomic savePlans → initial-plan bootstrap
→ Today UI → item completion → persistence after restart
→ local-day rollover → missed-day recovery
```

Roadmap gate: `MASTER_EXECUTION_ROADMAP.md` names the next task exactly
"TASK 085 — 30-day plan and CP10 checkpoint". No product feature was added.
One checkpoint-blocking defect was found and fixed (§3).

Free, ad-free core functionality throughout.

## 2. Invariant matrix

Every row is backed by an executed suite, not by inspection alone.
Suite abbreviations: **CP10** = `cp10_plan_flow_checkpoint_test.dart` (30),
**GEN** = generator (63), **MAP** = profile mapper (78), **LEARN** = Learn
catalog + source (163), **ORCH** = orchestrator (59), **PERS** =
`test/features/today/data` (81), **SM** = state machine (43), **ROLL** =
missed-day + rollover + note (82), **UI** = Today section (62).

### Plan generation

| Invariant | Evidence |
|---|---|
| exactly 30 records | CP10, GEN, ORCH — PASS |
| first DayKey is the local start day | CP10 (`plans.first == today`), ROLL — PASS |
| DayKeys continuous and unique | CP10 (all 30 offsets asserted), GEN — PASS |
| no UTC day shift | ROLL (local 00:30 stays on the local day), GEN — PASS |
| deterministic for identical input | GEN, LEARN (50-run identity) — PASS |
| all eight profiles reachable | MAP, ORCH (coverage lock) — PASS |
| Prayer → Quran → Learn order | CP10, LEARN, UI — PASS |
| stable deterministic item IDs | GEN, LEARN — PASS |
| light budget still valid | LEARN (core day = 5 min, `light` accepts exactly) — PASS |
| no unpublished/unsourced Learn article | LEARN (eligibility re-derived from assets) — PASS |
| no article body or religious prose in DailyPlan | LEARN, UI — PASS |

### Persistence

| Invariant | Evidence |
|---|---|
| initial range is one logical atomic write | CP10 (single `bismillah.daily_plans` key holds all 30), PERS — PASS |
| no partial range after encode/storage failure | PERS (storage byte-identical after failure) — PASS |
| existing valid range not overwritten | CP10 (`alreadyAvailable`, completedAt preserved), ORCH — PASS |
| partial/conflicting range → typed conflict | CP10 (5 seeded days stay 5, `stub-engine` intact), ORCH — PASS |
| unrelated stored days preserved | PERS, ORCH — PASS |
| envelope version remains 1 | CP10 (decoded `v == 1`), PERS — PASS |
| SharedPreferences key unchanged | CP10 (only `bismillah.daily_plans`), PERS — PASS |
| completion + completedAt survive restart | CP10 (new container **and** new repository over the same prefs) — PASS |
| no Drift/Firebase/remote write | ORCH + ROLL source-level import guards — PASS |

### Onboarding and bootstrap

| Invariant | Evidence |
|---|---|
| success waits for plan creation | CP10, ORCH — PASS |
| preference persistence not duplicated | CP10 (`saveCalls == 1`) — PASS |
| failure does not navigate as success | ORCH (gate stays closed) — PASS |
| onboarded user with no plan bootstraps once | CP10, ORCH — PASS |
| repeated bootstrap does not regenerate | CP10 (3× `start()`), ORCH — PASS |
| concurrent orchestration does not overwrite | CP10 (3 concurrent calls), ORCH — PASS |
| build methods do not trigger generation loops | UI (rebuild does not regenerate), ORCH — PASS |

### Today

| Invariant | Evidence |
|---|---|
| all five states safe | UI, SM — PASS |
| Available after orchestration | CP10, UI — PASS |
| Prayer/Quran/Learn rendering correct | UI — PASS |
| unresolved Learn `targetRef` safe | UI (neutral fallback, no crash, no invented title) — PASS |
| progress count accurate | UI (0 / partial / full) — PASS |
| completion preserves all other fields | UI, CP10 — PASS |
| duplicate completion writes blocked | UI (`isSaving` guard) — PASS |
| no paywall/ad/supporter/guilt language | UI, ROLL (all three locales) — PASS |

### Rollover and recovery

| Invariant | Evidence |
|---|---|
| same-day resume is a no-op | CP10 (state object identical), ROLL — PASS |
| new-day resume switches once | CP10, ROLL — PASS |
| live midnight switches once | CP10, ROLL — PASS |
| local boundary DST safe | ROLL (21:15 → 2h45m; month/year/leap cases) — PASS |
| old-day async result cannot replace new day | CP10 (§3 audit), ROLL — PASS |
| detection never mutates historical plans | CP10 (byte-level projection equal before/after) — PASS |
| partially completed day not "fully missed" | ROLL — PASS |
| missing/empty/corrupt days not blamed on user | ROLL — PASS |
| 3+ day recovery does not shrink/reorder/regenerate | CP10 (4 items, same order, same budget) — PASS |
| day 30 not silently extended | CP10 (day 31 stays Empty, range stays 30) — PASS |

## 3. Subscription-cancellation audit (mandatory)

TASK 084 changed `DailyPlanController.loadDay` to initiate — but not await —
cancellation of the previous watch subscription. All ten required properties
were audited against an instrumented subscription that counts `listen`/
`cancel`, can delay cancellation, and can make it fail.

| Property | Result |
|---|---|
| rapid A → B → C cannot stick in Loading | **PASS** — final `selectedDay == C` |
| an event from A cannot replace B or C | **PASS** — state stays on C |
| an event from B cannot replace C | **PASS** |
| final state belongs only to C | **PASS** |
| old subscriptions are actually asked to cancel | **PASS** — 3 listens, 2 cancels |
| repeated switching does not accumulate listeners | **PASS** — 12 switches, 1 active listener |
| disposal cancels the current subscription | **PASS** — active listeners drop to 0 |
| late cancellation cannot mutate newer state | **PASS** — state unchanged after held cancels resolve |
| cancellation failure is not an unhandled async error | **FAILED → FIXED** (below) |
| cancellation failure does not block the new day | **PASS** — C still loads, cancel still requested |

### Defect found and fixed

`unawaited(subscription.cancel())` does **not** contain errors. If `cancel()`
completes with an error the failure escapes as an **unhandled asynchronous
error** — a test-zone failure in tests and a zone error-handler hit in
production. This was a real defect introduced by the TASK 084 change.

Fix (smallest safe containment, `DailyPlanController._cancelQuietly`):

```dart
unawaited(subscription.cancel().catchError((Object _) {}));
```

The fix was verified to be load-bearing: reverting it makes the audit test
fail with `Bad state: cancel failed (test)` escaping through
`_cancelQuietly`. Awaited cancellation was **not** restored — it is exactly
what hung the second day load in TASK 084.

Genuine repository watch failures are **not** hidden: they still reach the
`listen(onError:)` hook and, per the TASK 077 stream contract, do not topple
the last known state. This is asserted separately (`emitError` leaves the
Available state intact).

## 4. End-to-end scenarios

All scenarios run against the **real** `SharedPrefsDailyPlanRepository` over
mocked SharedPreferences, so "restart" means a new `ProviderContainer` *and*
a new repository instance reading the same stored bytes.

- **Fresh user** — onboarding completes → 30 continuous plans persisted →
  Today Available with Prayer → Quran → Learn → one item marked → restart
  restores that exact completion and `completedAt`, others still pending.
- **Existing onboarded user** — no range → bootstrap creates it once →
  repeated `start()` does not regenerate.
- **Existing complete range** — `alreadyAvailable`; completion status and
  timestamp preserved byte-for-byte.
- **Partial range** — 5 seeded days produce a typed `rangeConflict`; the 5
  days keep their original `generatedBy`, nothing is filled or overwritten.
- **Day transition** — complete on day N, advance the clock, Today switches
  to N+1 with a fresh plan while day N keeps its completion.
- **Missed-day return** — 1 day missed → gentle recovery; 3 days → extended
  variant with the full 4-item plan, unchanged order and unchanged
  10-minute budget; historical projection identical before and after; marking
  a task today touches only today.
- **Day 30 boundary** — day 30 (offset 29) loads normally; day 31 (offset 30)
  stays honest Empty with the stored range still exactly 30.

## 5. Results

- `flutter analyze`: **clean** (0 errors, 0 warnings, 0 infos)
- Full Flutter suite: **1392 → 1422**, 0 failed, 0 skipped
- TASK 085 focused: **30 / 30** —
  `flutter test test/features/today/cp10_plan_flow_checkpoint_test.dart`
- Supporting suites re-run unchanged: GEN 63 · MAP 78 · LEARN 163 · ORCH 59 ·
  PERS 81 · SM 43 · ROLL 82 · UI 62
- Functions: **23 / 23** on Node.js **v22.22.0** / npm **10.9.4**
- No dependency change, no lockfile change, no package upgrade or audit fix

## 6. Verdict

## CP10 COMPLETE — 30-DAY LOCAL PLAN FLOW STABLE

All required invariants are proved by executed tests, the one data-integrity
defect found (unhandled cancellation error) is fixed and regression-locked,
analyze is clean, and both the Flutter and Functions suites pass. No
forbidden scope was introduced.

**Product gate: READY TO ENTER CP11 (Learn and Assistant depth).**

The plan flow is technically stable and honest, but this is **not** a claim
of release readiness: no physical-device validation of the plan flow was
performed in this task, and iOS remains unvalidated.

## 7. Intentionally deferred

Not implemented anywhere, by explicit decision:

- day-30 plan renewal (day 31 is honest Empty)
- adaptive plan shrinking after a long absence
- streaks, XP, achievements, badges
- manual calendar / day navigation UI
- automatic repair of a partial or conflicting stored range
  (TASK 083A's typed `rangeConflict` stays a classification, not a repair)
- opening the referenced Learn article from a task card
- notifications, remote sync, Firebase and Drift work for plans
- premium, supporter, LÖSEV and advertising surfaces

Content for `dhikr`, `dua` and `reflection` remains an open owner decision
and must not be invented.

## 8. Unresolved roadmap governance

The commercial decision set the owner has approved — first-month 29.99 TL
then 69.99 TL pricing, annual pricing, supporter tiers, the conditional
LÖSEV process, store presentation, social creatives and AI-ad disclosure —
still **conflicts with** the canonical `docs/business/MONETIZATION_DECISIONS.md`
(79.99 TL monthly, no introductory price, no LÖSEV/creative/AI-disclosure
policy), and **no task number owns the reconciliation**. Recorded here as an
open governance item; no number was invented.

Firebase gates G1, G2, G5, G8 and G14 likewise still have no assigned task
number (unchanged since TASK 075).

## 9. Next task

**TASK 086 — Content-source matrix** (CP11), per
`MASTER_EXECUTION_ROADMAP.md`. Not started.
