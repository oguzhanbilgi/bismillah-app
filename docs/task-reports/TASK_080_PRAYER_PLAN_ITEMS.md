# TASK 080 — Prayer DailyPlan Items

The first approved `DailyPlanItemSource`: deterministic, pure, app-tracking-only
prayer plan items derived from the existing `trackPrayers` and `prayOnTime`
onboarding goals. No prayer-time calculation, no location, no notification, no
persistence, no Today UI, no Firebase, no remote sync.

## 1. Executive summary

TASK 079 delivered the 30-day generation skeleton with an empty item source.
TASK 080 supplies the first real source: `PrayerDailyPlanItemSource` emits
`prayer_track_daily` and/or `prayer_on_time_daily` — **purely from the user's
own onboarding goals** — each costing 1 estimated interaction minute, in a fixed
order, identically across all eight profiles and all four progression phases.

The representation gate passed with **no domain change**: the two actions are
distinguished by their stable `templateId`, which TASK 079's
`DailyPlanItemIdBuilder` already composes into the final item identity. No field
was overloaded, no localization key added, no persistence field introduced.

62 focused tests; full suite **883 → 945**. **Zero tracked files modified.**

## 2. Previous task and purpose

TASK 079 (PR #22, merge `36e64f8`) produced `DailyPlanGenerator`,
`DailyPlanItemSource`, `DailyPlanDayContext`, `PlanItemDraft`,
`EmptyDailyPlanItemSource` and `DailyPlanItemIdBuilder`, generating 30 valid
per-day records with empty `items`. TASK 080 fills the prayer slice of that
contract — content-free tracking actions only.

## 3. Representation gate — PASSED

Question: can the existing `PlanItemDraft`/`PlanItem` fields distinguish *daily
prayer tracking* from *daily on-time prayer tracking* without abusing an
unrelated field?

**Yes.** Both use `PlanItemType.prayer` and differ by `templateId`.
`DailyPlanItemIdBuilder` composes `templateId` into the final `itemId`
(`rule-engine-v1:<dayKey>:<templateId>:<slot>`) — the mechanism TASK 079
explicitly designed for stable identity. The distinction therefore survives into
the persisted `PlanItem` through its identity, not through a repurposed field.

Consequently **none** of the following was required: user-facing religious
prose, localization changes, a new persistence field, an envelope-version
change, a Drift schema change, prayer timestamps, or location data.

## 4. Existing code facts (unchanged)

| Symbol | Fact |
|---|---|
| `PlanItemType` | `prayer, quran, dhikr, dua, lesson, reflection` — `prayer` already exists |
| `PlanItemStatus` | `pending, completed` — no "missed/failed" state by design |
| `PlanItemDraft` | `templateId`, `type`, `estimatedMinutes`, `targetRef?`, `sizeParam?` |
| `PlanItem` | `itemId`, `type`, `targetRef?`, `sizeParam?`, `status`, `completedAt?` — **no duration field** |
| `DailyPlanItemIdBuilder` | `generatorVersion:dayKey:templateId:slot` |
| `DailyPlanGenerator` | accepts **one** `DailyPlanItemSource`; enforces budget and duplicate-identity invariants |
| `PrayerName` | `fajr, dhuhr, asr, maghrib, isha` — **deliberately not referenced by this task** |

## 5. Approved TASK 080 product decisions

Decided in this task; **not** pre-existing in older documentation.

**Goal-based inclusion** (items come from *goals*, never from the profile):

| Goals | Output |
|---|---|
| `trackPrayers` only | `prayer_track_daily` |
| `prayOnTime` only | `prayer_on_time_daily` |
| both | `prayer_track_daily`, then `prayer_on_time_daily` |
| neither | empty list (not a failure) |

`quranHabit`, `dhikrRoutine` and `islamicKnowledge` never affect this source.
`prayOnTime` does **not** imply `trackPrayers`. The `prayer_focused` profile
does **not** add prayer items by itself.

**Fixed contribution order:** `prayer_track_daily` → `prayer_on_time_daily`,
declared as an explicit ordered list (`contributionOrder`), never derived from
`Set` iteration, enum declaration order, map insertion order or localized
sorting.

**Estimated cost:** `estimatedMinutes = 1` per emitted item — 0 / 1 / 2 minutes
for zero / one / both goals.

**No progression-phase escalation:** semantics are identical for `weekIndex`
0, 1, 2 and 3. No gradual prayer-count escalation, beginner discount, advanced
quota, recovery week, phase-specific target, streak requirement or difficulty
level was invented.

## 6. Prayer source contract

`bismillah_app/lib/features/today/domain/services/prayer_daily_plan_item_source.dart`

`PrayerDailyPlanItemSource implements DailyPlanItemSource`, `const`
constructible and stateless. It reads **only** `DailyPlanDayContext.goals`.

No dependency on: `Ref`, `BuildContext`, any repository, `SharedPreferences`,
Drift, Firebase, network, system clock, locale, location, prayer-time engine or
`PrayerLog`. It writes no logs and has no side effects.

It is **total** for every valid context: template IDs are distinct constants and
the estimated cost is a fixed positive constant, so draft construction cannot
fail and duplicate templates cannot arise. An unreachable failure branch was
deliberately **not** fabricated (consistent with TASK 078/079 discipline).

## 7. Stable template identities

- `prayer_track_daily`
- `prayer_on_time_daily`

Machine identifiers only: lowercase `^[a-z][a-z0-9_]*$`, no localized text, no
`toString()`, no timestamp, no UUID, no random value, no `hashCode`, no UID, no
device identifier. Tested to contain no date pattern, no long digit run, and no
Turkish/Arabic characters or whitespace.

The **final** `PlanItem` identity continues to be produced by the existing
`DailyPlanItemIdBuilder`; the prayer source never constructs final identities
itself.

## 8. PlanItem representation and semantic boundaries

Both contributions use `PlanItemType.prayer`, with `targetRef == null` and
`sizeParam == null`.

**`prayer_track_daily`** represents the user's existing onboarding goal to track
daily prayers inside the plan system. It claims **no** specific prayer count,
does not equate app tracking with worship completion, does not imply that
missing the app item means missing a prayer, and asserts no reward, punishment
or obligation.

**`prayer_on_time_daily`** represents the user's existing goal of tracking
prayer timeliness. It calculates **no** prayer times, decides **nothing** about
whether a prayer was on time, reads no location and no `PrayerLogDay`, evaluates
no performance, and attaches **no** prayer name and **no** timestamp — asserted
by tests that no `PrayerName` value ever appears in output.

## 9. Budget semantics

`estimatedMinutes` measures estimated **in-app interaction cost**. It is
explicitly **not** the duration of a prayer, a religious minimum, a ruling,
worship value or spiritual rank.

Source totals: 0 (no prayer goal) / 1 (one goal) / 2 (both goals). Every
currently approved budget accommodates both items — `light` 5, `balanced` 10,
`focused` 20, `advanced`+`focused` 30 — verified across all eight
profile×pace combinations, including the tightest 5-minute `low_time` budget.

Per the TASK 079 contract, `estimatedMinutes` remains **generation-only
metadata**: `PlanItem` has no duration field and the value is never persisted.
The generator's existing budget validation was **not weakened** — a deliberately
over-budget fake source is still rejected with no partial output.

## 10. Profile independence

For identical goals, contributions are identical across all eight profiles —
`beginner`, `returning`, `prayer_focused`, `quran_focused`, `dhikr_focused`,
`learning_focused`, `advanced`, `low_time` — in count, template IDs, order,
`PlanItemType` and estimated cost. The `DailyPlan.profileType` remains exactly
the profile supplied in the generation request.

The source does not change the profile, does not remap onboarding answers, does
not infer spiritual level, produces no extra items for `prayer_focused`, and
reduces nothing for `beginner` or `low_time`. An **enum coverage lock** fails
the suite if a future profile is added without review.

## 11. Progression-phase independence

Across `weekIndex` 0–3 the contribution count, template identities, order,
`PlanItemType`, estimated cost and initial completion state are all identical.
Verified additionally at every documented day boundary (offsets 0, 6, 7, 13, 14,
20, 21, 28, 29). Final `PlanItem` IDs differ only because `DayKey` differs. No
phase-specific prayer template exists.

## 12. Initial completion state

Every generated prayer item starts in the canonical incomplete state:
`PlanItemStatus.pending` with `completedAt == null` and `isCompleted == false`.
Nothing is pre-completed, no prayer log is read, no current date is inspected,
no "is this day today?" check occurs, no device state is consulted and no
previously stored `DailyPlan` is mutated.

## 13. Source composition decision

The TASK 079 generator accepts exactly **one** `DailyPlanItemSource` and no
composition abstraction exists. `PrayerDailyPlanItemSource` is passed directly
as that single source, so — per the task's own instruction — **no composition
was added**.

Composition will be introduced when **TASK 081** first requires multiple
concurrent sources. The intended future order is Prayer → Quran → Learn; when
added it must execute children in explicit configured order, preserve
deterministic output order, propagate the first typed failure, return no partial
result, reject duplicate template identities, remain pure and carry focused
tests.

## 14. Thirty-day generator integration

Run through `DailyPlanGenerator` with the prayer source, verified for
`trackPrayers` only, `prayOnTime` only, both, and no prayer goal:

- exactly 30 plans, 30 unique continuous `DayKey`s;
- per-day item count 1 / 1 / 2 / 0 respectively;
- stable order on every day;
- budget respected on every day;
- all items start incomplete;
- 50 repeated generations byte-identical under a stable projection;
- final IDs such as
  `rule-engine-v1:2026-07-26:prayer_track_daily:0` and
  `rule-engine-v1:2026-07-26:prayer_on_time_daily:1`;
- 60 unique item IDs across the 30-day both-goals plan (no cross-day or
  same-day collision);
- a different `startDay` yields different final IDs, per TASK 079 identity
  semantics.

## 15. Religious safety and privacy

No localized religious prose, no Quran verse or hadith text, no reward or
punishment claim, no fatwa-like wording, no obligation beyond what the product
already represents, and no prayer quota. Template identifiers are asserted to
contain none of `sin`, `sinner`, `reward`, `punish`, `obligat`, `fard`, `haram`,
`good`, `bad`, `lazy`, `score`, `rank`, `level`, `quota`.

Output carries no prayer timestamps, coordinates, UID, device identifier, raw
onboarding payload, stack trace or storage key — a projection of a generated
30-day plan is asserted to contain no `latitude`, `longitude`, `uid`,
`deviceId`, nor any of `fajr`/`dhuhr`/`asr`/`maghrib`/`isha`. The source logs
nothing.

## 16. Automated tests

**62 new TASK 080 tests** in
`bismillah_app/test/features/today/domain/prayer_daily_plan_item_source_test.dart`:

| Group | Coverage |
|---|---|
| Goal selection | each goal alone; both; neither; unrelated-only; unrelated goals don't change output; all goals; `prayOnTime` doesn't imply `trackPrayers`; `prayer_focused` profile adds nothing alone |
| Ordering | tracking always first; `Set` insertion order irrelevant; 20 repeats stable; explicit ordered list asserted |
| Template identity | exact IDs; distinct; machine-identifier shape; no date/UUID/device data |
| PlanItem representation | both use `PlanItemType.prayer`; `targetRef` null; `sizeParam` null; items start incomplete |
| Budget | 0/1/2 totals; constant per-item cost; all eight profile×pace budgets accept both; 5-minute `light` accepts both; generator over-budget validation still rejects; `estimatedMinutes` not persisted |
| Profile independence | all eight profiles produce identical contributions; **enum coverage lock**; profile unchanged; no reduction for beginner/low_time; no extra for prayer_focused |
| Phase independence | phases 0–3 identical; all 30 days identical; every documented offset boundary |
| 30-day integration | four goal scenarios; 30 unique days; 50-repeat determinism |
| Final item identity | exact builder format; no same-day collision; 60 unique IDs; repeat stability; different `startDay` differs |
| No side effects | 50-repeat stability; pace irrelevant; `dayKey` irrelevant; **bootstrap invokes neither source nor generator** |
| Religious safety & privacy | no localized prose; no judgmental tokens; no location/UID/prayer-name leakage; no prayer name ever attached |

| Suite | Before | After |
|---|---|---|
| Full Flutter | 883 | **945** (0 failed, 0 skipped) |
| TASK 080-focused | — | **62** |
| TASK 079 generator | 63 | **63** |
| TASK 078 mapper | 78 | **78** |
| TASK 077 state machine | 43 | **43** |
| DailyPlan persistence | 70 | **70** |
| Canonical sync-focused | 70 | **70** |
| Drift storage | 11 | **11** |
| Prayer feature suite | 24 | **24** |
| Functions (Vitest) | 23 | **23** |
| `flutter analyze` | clean | **clean** |

## 17. No UI, persistence, prayer-time, notification or remote changes

**Zero tracked files modified — new files only.** Unchanged accordingly:
onboarding UI and navigation, Today UI, routes, localization files, Prayer
screen UI, prayer-time calculation, location permissions, notification
scheduling, `PrayerLog` persistence, DailyPlan persistence, SharedPreferences
keys, DailyPlan envelope version (still **1**), Drift schema/migrations/generated
files, Firebase, Functions source, sync queue, dependencies, `pubspec` files,
Android/iOS files and build output.

No generated plan is saved, no onboarding completion flow calls the generator,
and no location permission was added. A pattern scan of the new source for
`PrayerName|PrayerLog|prayer_times|latitude|longitude|location|Notification|DailyPlanRepository|SharedPreferences|Drift|Firebase|Ref |BuildContext|DateTime.now|Random`
returns matches **only inside doc comments stating what is not used**.

## 18. Source-backed vs. decided vs. mechanical

- **Existing repository facts:** `PlanItemType.prayer`; the `PlanItemDraft`/
  `PlanItem` field sets; `DailyPlanItemIdBuilder` identity composition; the
  generator's single-source contract and budget/duplicate invariants; the
  approved pace budgets and four-phase indices from TASK 079; the two prayer
  onboarding goals from the shipped onboarding.
- **Approved TASK 080 product decisions:** goal-based inclusion rules; the fixed
  `prayer_track_daily` → `prayer_on_time_daily` order; `estimatedMinutes = 1`;
  no progression-phase escalation.
- **Implementation-only mechanics:** the `contributionOrder` record list, the
  `const` stateless source, and the test projection helper.

## 19. TASK 081 boundary

Canonical next task, unchanged and not renumbered:

> **TASK 081 — Quran plan items**

It must: use the TASK 079 `DailyPlanItemSource` contract; use approved existing
Quran package/content identifiers; avoid embedding unapproved translation prose;
preserve deterministic template and final item identities; stay inside the daily
budget; remain local-only; **not** persist generated plans; **not** implement
Today UI; and **not** add remote synchronization. It is also the task that will
first require source composition (Prayer → Quran → Learn).

**TASK 082** remains Learn plan items. Content for `dhikr`, `dua` and
`reflection` remains an **open owner decision** and must not be invented.

## 20. Evidence appendix

- `bismillah_app/lib/features/today/domain/services/prayer_daily_plan_item_source.dart`
- `bismillah_app/test/features/today/domain/prayer_daily_plan_item_source_test.dart` (62)
- Consumed unchanged: `daily_plan_item_source.dart`, `daily_plan_generator.dart`,
  `daily_plan_generation_request.dart`, `daily_plan_profile_type.dart`,
  `plan_enums.dart`, `daily_plan.dart`, `onboarding_focus_goal.dart`
- Deliberately **not** referenced: `prayer_name.dart`, prayer-time engine,
  `PrayerLogDay`, location services, notification scheduling
- Prior reports: `TASK_078_ONBOARDING_PROFILE_MAPPING.md`,
  `TASK_079_DETERMINISTIC_DAILY_PLAN_GENERATOR.md`
- Baselines: analyze clean · full **945/945** · TASK 080-focused **62** ·
  TASK 079 **63/63** · TASK 078 **78/78** · TASK 077 **43/43** ·
  persistence **70/70** · canonical sync **70/70** · Drift storage **11/11** ·
  Functions **23/23**
