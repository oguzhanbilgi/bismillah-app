# TASK 083 — Today Task UI

## 1. Scope and user outcome

The Today tab now has a real daily task surface built on the **existing**
`DailyPlanController` / `DailyPlanState` machine (TASK 077) and the
Prayer → Quran → Learn item model (TASK 080–082).

The user opens Today and sees the selected day, that day's `DailyPlan`,
its Prayer/Quran/Learn task cards, daily completion progress, and calm
loading / empty / corrupt / failure states. Tapping a card marks or unmarks
it, and the mark survives a reload.

Free, ad-free core product. No plan generation, no persistence-format
change, no Drift change, no Firebase write, no remote sync.

## 2. Roadmap gate result

`MASTER_EXECUTION_ROADMAP.md` and `TASK_INDEX.md` both name the next task
**TASK 083 — Today task UI**. No blocker applied: a Today route and screen
exist, `DailyPlanState` is a sealed UI-consumable type, `PlanItem` renders
from stable template IDs without inventing religious content, `targetRef`
resolves through the existing published-only Learn repository, and the
persistence envelope already round-trips `status` + `completedAt`.

## 3. UI states

All five states are rendered inside one `TodayPlanSection` card:

| State | Rendering |
|---|---|
| Loading (and `null`) | three **non-animated** neutral skeleton bars at task-card height, with an accessible label |
| Empty | neutral two-line explanation; **no fake "generate plan" button** |
| Available | selected day, `n/total` progress text, `AppProgressBar`, ordered task cards |
| Corrupt | calm explanation, explicitly "nothing was deleted"; no retry button (`canRetry` is false), no automatic reset |
| Failure | neutral message + retry through `controller.retry()` |

The loading placeholder is deliberately animation-free. A spinner draws the
eye, makes the screen restless, and — as this task proved — blocks every
`pumpAndSettle`-based test that mounts Today. No "zero-jump" height is
claimed (the item count is unknown before the read); the skeleton simply
reserves a real block so the card cannot flash at near-zero height.

Corrupt and failure states expose no exception text, stack trace, storage
key, JSON, `SharedPreferences` detail or Firebase reference — asserted by
test.

## 4. Item rendering

`TodayPlanItemPresentation` is a pure, synchronous mapper from a `PlanItem`
to a localized neutral title plus a category icon. It reads the template ID
out of the TASK 079 composed item ID (`<version>:<dayKey>:<templateId>:<slot>`)
and never prints a raw template ID, article ID or generator version.

| Template | Neutral meaning |
|---|---|
| `prayer_track_daily` | Daily prayer tracking |
| `prayer_on_time_daily` | Prayer timeliness tracking |
| `quran_continue_daily` | Continue your Quran habit |
| `learn_article_<id>` | the article's own published title |

Learn titles resolve through `todayPlanLessonTitlesProvider`, which calls
the existing `LearningKnowledgeRepository.getArticlesByIds` with the active
content locale. That repository returns **published content only**, so an
unpublished or removed ID simply does not match. Unresolved, missing and
failing cases all fall back to a neutral "Learning task" label — **no
fabricated article title, and no crash**. No article body, summary or source
text is read into the plan.

Card order is the plan's own item order (Prayer → Quran → Learn). A test
proves the list is not re-sorted by localized text.

Prayer cards show no quota, count or prayer name. Quran cards show no surah,
ayah, page or duration. No card shows reward, sin, score, streak or rank
language.

## 5. Completion interaction decision — IMPLEMENTED

Completion is in scope because the current architecture already supports it
safely, with no new abstraction:

- `AppClock` + `clockProvider` supply `completedAt` (no `DateTime.now()`).
- `DailyPlanController.savePlan` already persists through the repository
  with epoch-based staleness protection.
- The persistence envelope already encodes and decodes `status` and
  `completedAt` — **no new storage key, no envelope version change**.

`DailyPlanController.toggleItemCompletion(EntityId)` was added. It operates
only on the currently displayed `DailyPlanAvailable` plan; it is a no-op when
no day is selected, when the state is not Available, when a save is already
in flight (duplicate-write guard) or when the item ID is not in the plan. It
rebuilds the plan preserving every other field — `dayKey`, `profileType`,
`sizeMinutes`, `weekIndex`, `generatedBy`, item IDs, types and `targetRef`s —
and routes through the existing `savePlan`. The widget never calls `savePlan`
itself. No plan is generated, and no other day is touched.

While a save is in flight the cards become read-only, so a rapid double tap
cannot start a second write.

## 6. Date-navigation decision — DEFERRED

No calendar or day-switching UI was added. The section selects **today's**
`DayKey` once, derived from the injected clock, in a post-frame callback, and
renders only that day. Re-selection is guarded so a rebuild cannot open a
second watch subscription (asserted: `watchCalls == 1`).

Day navigation and missed-day handling belong to **TASK 084 — Missed-day
recovery and gentle rollover**; the roadmap defines no day-navigation
acceptance criteria for TASK 083, so speculative calendar UI was not built.

## 7. Accessibility and RTL

- Each task card is a single semantics node: `"<title>, <status>"`, with
  `button` and `toggled` flags.
- The loading skeleton carries its own semantic label.
- The progress bar carries the localized `n/total` label.
- Cards are constrained to the 48 dp touch-target token.
- Verified at 320 px width and at 1.5× text scale with no overflow.
- Titles are `maxLines`-bounded, so long TR/EN/AR strings truncate instead of
  overflowing.
- Arabic renders RTL; TR/EN/AR strings are asserted to be genuinely different
  translations, not copies.

## 8. Free-core classification

TASK 083 is free core functionality. No paywall, upgrade banner, locked task,
premium-only completion, supporter badge, donation message, ad or promotional
card was added — asserted by a test that scans all rendered text for those
terms. Future premium visual customization can build on this screen later
without changing the free experience.

## 9. Religious-safety boundaries

- Marking a task is an **in-app tracking action**. It is not a claim that an
  act of worship was performed, accepted, or spiritually rewarded.
- No verse, hadith, ruling or fatwa text appears anywhere in this surface.
- An unmarked task carries **no** red styling, warning icon, guilt language,
  streak-loss pressure, score, rank or profile ranking. A test asserts no icon
  uses the error color.
- The empty day is presented as "no plan yet", not as a failure.
- Only published, source-verified article titles can appear, and only via the
  existing verified content layer.

## 10. Tests

**53 focused TASK 083 tests**, all passing:

```bash
flutter test test/features/today/presentation/today_plan_section_test.dart
```

Groups: states (incl. loading skeleton, single subscription, zero-item plan,
retry recovery), item presentation and canonical ordering, pure template
mapping with a `PlanItemType` coverage lock, progress at 0 / partial / full,
completion (mark, unmark, field preservation, injected clock, duplicate-write
guard, reload persistence, save failure, no cross-day mutation, unknown item
ID, no day selected), accessibility/layout/localization (semantics, touch
target, 320 px, 1.5× text, RTL, EN, three-language parity), and religious
safety/privacy (no raw error leakage, no quota or ruling language, no paywall
or ad widgets, no raw IDs on screen, never generates or auto-saves).

Full suite: **1178 → 1231**, 0 failed, 0 skipped. `flutter analyze`: clean.

Functions: **23/23** (Vitest, Node.js v22.22.0) — run once at task start for
the TASK 082 environment correction; no Functions file was touched.

## 11. Deferred work

- Plan **generation orchestration**: nothing generates or saves a plan yet, so
  in practice the section shows the Empty state until a plan exists. The
  roadmap still names no task for wiring onboarding completion → generation →
  persistence; this remains an owner sequencing decision.
- Day navigation / missed-day rollover → TASK 084.
- Opening the referenced Learn article from a task card (navigation) — the
  brief scoped this task to title resolution.
- Corrupt-state recovery (regenerate or clear) — still deliberately absent
  since TASK 077.

## 12. Exact next task

**TASK 084 — Missed-day recovery and gentle rollover** (CP10), per
`MASTER_EXECUTION_ROADMAP.md`. Not started.
