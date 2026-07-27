# TASK 084 — Missed-Day Recovery and Gentle Rollover

## 1. Scope and gate result

`MASTER_EXECUTION_ROADMAP.md` and `TASK_INDEX.md` name TASK 084 exactly
"Missed-day recovery and gentle rollover", carrying two earlier notes: day
selection was deferred here by TASK 083, and the typed `rangeConflict` from
TASK 083A must not be repaired here. No blocker applied — the work needed no
persistence-schema change, no new database, no regeneration, no historical
rewrite, no streak model, no background execution and no plan extension
beyond day 30.

Free, ad-free core functionality.

## 2. Missed-day definition

A historical day counts as **missed** only when all three hold:

1. a valid `DailyPlan` record exists for that exact `DayKey`,
2. the plan has at least one item,
3. **none** of its items are completed.

Explicitly **not** user-missed — these are data/product states, not
behaviour, and each of them **breaks** the consecutive chain:

- no plan record for that day (never generated, or outside the range)
- an empty plan (zero items)
- the current day itself
- any future day

Corrupt records never reach the calculator: the repository returns a typed
failure, and the controller then falls back to "no missed days" rather than
presenting a storage problem as a user failure.

`MissedDayCalculator.evaluate` is pure and synchronous: it reads no
repository, calls no clock, uses no locale, and takes an already-read list of
previous plans plus today's `DayKey`.

## 3. Consecutive-gap calculation

Counting walks **backwards from the day immediately before today** and stops
at the first day that is not user-missed. Lookback is capped at 30 days —
the canonical generated frame — so nothing older is inspected. Input order
does not matter (days are matched by key), and repeated calls return the same
value.

`MissedDayRecovery` is a plain value carrying only `consecutiveMissedDays`.
It is **not a streak model**: nothing is persisted, no key is written, no
score, badge, rank or spiritual judgement is derived, and the count is never
rendered.

## 4. Historical integrity

TASK 084 is presentation and safe day selection only. Nothing in this task
completes, fails, copies, deletes, reorders or re-times a historical item.
Tests assert that after a rollover and after marking a current-day task,
yesterday's plan still has zero completions, the same item count, the same
`generatedBy` and null `completedAt` values, and that `savePlan`/`savePlans`
were never called by the recovery path.

## 5. Rollover architecture

`TodayDayController` (`Notifier<TodayDayState>`) now owns which day Today
shows. `TodayPlanSection` no longer selects the day itself; it only forwards
lifecycle events and draws state.

- `start()` — first mount: runs the TASK 083A bootstrap **once per app
  lifecycle**, selects the local day, loads the plan, computes recovery and
  schedules the next boundary.
- `onAppResumed()` — called from `WidgetsBindingObserver`; if the local
  `DayKey` is unchanged it does **nothing** (no re-read, no second watch
  subscription, no second bootstrap).
- `retry()` — user-driven: retries plan setup, then force-reloads the day.
  It does not additionally call `DailyPlanController.retry()`, so a retry
  performs one read, not two.

A generation counter guards every transition, so a late-returning
missed-day read for an older day cannot overwrite a newer day's state.

**One behaviour change was required in `DailyPlanController.loadDay`:** the
previous watch subscription is still cancelled, but the reload no longer
*awaits* the cancellation. `StreamSubscription.cancel()` does not resolve
promptly for every stream implementation, and awaiting it left the second day
load stuck in `Loading` forever (reproduced in a widget test). Waiting is also
unnecessary: `_onWatchEvent` compares the subscribed day against the active
day, and the generation counter independently blocks stale results.

## 6. Lifecycle and local-midnight behaviour

Three cases are supported and tested:

1. **app starts on the current day** — day selected from the clock,
2. **app resumes after the date changed** — one switch, one new subscription,
   recovery recomputed,
3. **app stays open across local midnight** — a single one-shot schedule
   fires, the day switches once, and the next boundary is re-scheduled.

`DayRolloverScheduler` is a small injected abstraction with one production
implementation (`TimerDayRolloverScheduler`, a single `Timer`) and a test
fake that fires on demand. There is **no periodic polling**: exactly one
timer is armed at a time, and it is cancelled on disposal. After disposal a
fired callback changes nothing.

## 7. Timezone and DST handling

The next boundary is `DateTime(now.year, now.month, now.day + 1)` minus the
injected local now — local calendar arithmetic, so a DST day naturally yields
23 or 25 hours and **24 hours is never assumed**. `DayKey` is always derived
via `DayKey.fromLocal(clock.nowLocal())`; there is no UTC conversion and no
`DateTime.now()` anywhere in the controller (asserted at source level).
Month, year and leap-day boundaries are covered by test.

## 8. Recovery UI

`TodayRecoveryNote` is a calm card rendered **above** the plan card. It never
blocks or hides tasks, opens no modal, runs no animation in its own subtree
(reduced-motion friendly), and uses a neutral sun icon — no error colour, no
warning icon, no flame.

`TodayRecoveryNote.shouldShow` is a pure rule: show when there are missed
days **and** the current day has no completed item. Marking any current-day
task makes the note disappear naturally — derived entirely from existing plan
state, with **no new persistence key** added to dismiss it.

The missed-day **count is never displayed**, and TR/EN/AR copy is asserted to
contain no streak, penalty, score, badge, guilt, sin/reward, paywall,
donation or advertising language, and no raw `DayKey`, template ID or
generator version.

## 9. Three or more missed days

At `consecutiveMissedDays >= 3` the note switches to a simpler warm re-entry
sentence. Nothing else changes: the full current-day plan stays available and
unchanged, the canonical Prayer → Quran → Learn order is preserved, no task
is removed or reordered, no lighter plan is generated and the daily minute
budget is untouched (asserted: zero writes in this path).

Visual emphasis of the first pending task was deliberately **not** added —
it was permitted, not required, and every available form of it risked either
reordering perception or extra visual noise on a calm screen.

## 10. Missing or out-of-range day

A new day with no plan keeps the honest Empty state. Nothing is generated,
yesterday's tasks are never copied forward, the range is never extended past
day 30, and the absence is not framed as a user failure. Partial or
conflicting stored ranges remain TASK 083A's typed conflict and are not
repaired here.

**Day-30 renewal, adaptive plan shrinking, streak persistence, XP,
achievements, notifications and manual calendar navigation all remain
deferred** and were not implemented.

## 11. Tests

**88 focused TASK 084 tests**, all passing:

```bash
flutter test test/features/today/domain/missed_day_recovery_test.dart test/features/today/application/today_day_controller_test.dart test/features/today/presentation/today_recovery_note_test.dart
```

- Missed-day calculation **30** — definition table (no record, fully pending,
  partially completed, fully completed, empty plan, today, future), gap
  chains broken by a completed day and by a missing record, 30-day lookback
  cap, order independence, purity, threshold table, value-object rules and a
  historical-integrity check.
- Day rollover **31** — day derived locally without UTC shift, one-time
  bootstrap, no duplicate subscriptions, resume with and without a date
  change, one-shot boundary scheduling and re-scheduling, month/year and leap
  boundaries, disposal safety, stale-result protection, recovery recompute,
  honest Empty for a missing or out-of-range day, no copy-forward, and
  source-level guards (no `DateTime.now`, no Drift/Firebase/network/
  notification imports, no streak or preference writes).
- Recovery UI **21** — show/hide rule table, gentle vs warm-re-entry copy,
  count never rendered, tone and privacy scans across all three locales,
  no modal/animation, semantics, 320 px, 1.5× text, AR RTL, EN, and
  three-language translation parity.
- Today section **+6** (suite 56 → **62**) — note above the plan, hidden when
  nothing was missed, hidden when yesterday had activity, 3-day variant keeps
  all four tasks with zero writes, note disappears after marking a task
  today, and historical plan untouched after a current-day toggle.

Full suite: **1304 → 1392**, 0 failed, 0 skipped. `flutter analyze`: clean.
This is modestly above the suggested 45–75 band because the required-coverage
list itself enumerates roughly 35 distinct cases; the tests are table-driven
and none is a Cartesian-product repetition.

**Stored-figure correction:** TASK 083 and TASK 083A both recorded the Today
section suite as `53`. Measured against merged `7b0d2b5` it is **56**, so
TASK 084 adds 6 there, not 9. Only the stored number was wrong — no test was
lost and every full-suite total on record stays correct.

Functions untouched and not run. No dependency change.

## 12. Schema, remote and premium status

No new persistence key, no envelope-version change, no migration, no Drift,
no Firebase write, no remote sync, no notifications, no onboarding change,
and no premium, supporter, LÖSEV or advertising content.

## 13. Next task

**TASK 085 — 30-day plan and CP10 checkpoint**, per
`MASTER_EXECUTION_ROADMAP.md`. Not started.
