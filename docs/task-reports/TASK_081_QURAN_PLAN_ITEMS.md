# TASK 081 — Quran DailyPlan Items and Ordered Source Composition

The second approved `DailyPlanItemSource`, plus the minimum deterministic
composition mechanism so Prayer and Quran contribute to the same generated
plan. No surah/ayah assignment, no Quran or translation text, no reading
progress, no audio, no persistence, no Today UI, no Firebase, no remote sync.

## 1. Executive summary

`QuranDailyPlanItemSource` emits a single neutral **continuation/tracking**
action (`quran_continue_daily`) when — and only when — the user's existing
`quranHabit` onboarding goal is selected, costing 2 estimated interaction
minutes, identically across all eight profiles and all four progression phases.

`CompositeDailyPlanItemSource` runs an explicitly ordered list of child sources
once per day and concatenates their contributions in **Prayer → Quran → Learn**
order, propagating the first typed failure with no partial output and rejecting
duplicate template identities across children.

The representation gate passed with **no domain change**. 70 focused tests;
full suite **945 → 1015**. **Zero tracked files modified.**

## 2. Previous task and purpose

TASK 080 (PR #23, merge `a63e023`) delivered `PrayerDailyPlanItemSource` and
deliberately deferred composition, because the generator accepted a single
source and Prayer could be passed directly. TASK 081 is the first task needing
two concurrent sources, so it adds both the Quran source and the composition
mechanism.

## 3. Representation gate — PASSED

Question: can the existing `PlanItemDraft`/`PlanItem` fields represent one
neutral machine action — *daily Quran continuation/tracking*?

**Yes.** `PlanItemType.quran` already exists; `targetRef` and `sizeParam` are
optional and nullable on **both** `PlanItemDraft` and `PlanItem`, so they stay
`null` without any constructor pressure; `templateId` carries the distinction
and `DailyPlanItemIdBuilder` composes it into the final identity.

No localization change, no new user-facing string, no surah/ayah reference, no
Quran or translation text, no new persistence field, no envelope-version change,
no Drift schema change, no reading-history access and no audio metadata was
required. No fake surah, verse or quantity value was placed in any field.

## 4. Existing code facts (unchanged)

| Symbol | Fact |
|---|---|
| `PlanItemType` | includes `quran` |
| `PlanItemDraft` | `templateId`, `type`, `estimatedMinutes` required; `targetRef`, `sizeParam` optional nullable |
| `PlanItem` | `itemId`, `type`, `status` required; `targetRef`, `sizeParam`, `completedAt` nullable; **no duration field** |
| `DailyPlanItemIdBuilder` | `generatorVersion:dayKey:templateId:slot` |
| `DailyPlanGenerator` | accepts **one** source; enforces per-day budget and duplicate final-ID invariants; assigns `slot` by position in the concatenated list |
| `PrayerDailyPlanItemSource` | `prayer_track_daily` (1 min), `prayer_on_time_daily` (1 min) |
| Quran architecture | 13 repository interfaces exist (content, progress, saved verses, audio, reciter catalog, translation…) — **confirmed not needed and not referenced** |

## 5. Approved TASK 081 product decisions

Decided in this task; **not** pre-existing in older documentation.

**Goal-based inclusion:** `quranHabit` present → exactly one
`quran_continue_daily` contribution; absent → empty list (not a failure).
`trackPrayers`, `prayOnTime`, `dhikrRoutine` and `islamicKnowledge` never affect
this source. `quran_focused` does **not** produce a Quran item when `quranHabit`
is absent — items come from **goals, never from the profile**. The profile
mapper is never re-run.

**Stable template identity:** `quran_continue_daily`.

**Estimated cost:** `estimatedMinutes = 2`.

**No specific Quran assignment:** no surah, ayah, ayah range, juz, page,
translation text, reciter, audio URL, reading quantity or listening quantity.

**Profile and phase independence:** identical semantics across all eight
profiles and `weekIndex` 0–3. No beginner quota, advanced quantity, phase-based
ayah escalation, recovery phase or profile-specific reading amount.

**Source order:** **Prayer → Quran → Learn** — a deterministic product rule,
explicitly **not** a religious ranking.

## 6. Quran source contract

`bismillah_app/lib/features/today/domain/services/quran_daily_plan_item_source.dart`

`QuranDailyPlanItemSource implements DailyPlanItemSource`, `const`
constructible and stateless, reading **only** `DailyPlanDayContext.goals`.

No dependency on `QuranRepository`, Quran progress, saved verses, audio,
`SharedPreferences`, Drift, Firebase, `Ref`, `BuildContext`, clock, locale or
timezone. It writes no logs and has no side effects.

It is **total** for every valid context: the template ID is a constant and the
cost is a fixed positive constant, so draft construction cannot fail. An
unreachable failure branch was deliberately **not** fabricated.

## 7. Goal-based inclusion

| Goals | Quran output |
|---|---|
| `quranHabit` only | one `quran_continue_daily` |
| `quranHabit` + any unrelated goals | one `quran_continue_daily` |
| all five goals | exactly one `quran_continue_daily` |
| no `quranHabit` | empty list |
| empty goal list | empty list |

`Set` insertion order does not affect output (the generator supplies a
normalized ordered goal list, and the source only tests membership).

## 8. Stable Quran template identity

`quran_continue_daily` — a machine identifier matching `^[a-z][a-z0-9_]*$`,
non-localized and not user-facing. Tested to contain none of `surah`, `sure`,
`ayah`, `ayet`, `verse`, `juz`, `cuz`, `page`, `sayfa`, `translation`, `meal`,
`reciter`, `audio`, `mp3`, `http`; no date pattern, no long digit run, no `uid`,
no `device`; and distinct from both Prayer templates.

The **final** `PlanItem` identity continues to come from
`DailyPlanItemIdBuilder`; the source never constructs final identities.

## 9. PlanItem representation

`type = PlanItemType.quran`, `targetRef = null`, `sizeParam = null`,
`estimatedMinutes = 2`, initial status `pending` with `completedAt == null`.

Semantically it represents the user's existing onboarding goal of maintaining a
Quran habit inside the DailyPlan system. It claims **no** specific religious
quantity, **no** required number of verses, **no** divinely preferred passage,
**no** equivalence between missing an app item and abandoning Quran, and **no**
reward, punishment or spiritual rank.

## 10. Budget semantics

`estimatedMinutes = 2` is a **generation budget value** for the DailyPlan
interaction budget. It does **not** define a required Quran-reading duration, a
minimum religious amount, a ruling, spiritual value, reward or punishment.

| Selection | Source cost |
|---|---|
| Quran only | 2 |
| Prayer track + Quran | 3 |
| Prayer on-time + Quran | 3 |
| both Prayer + Quran | 4 |

All approved budgets accommodate all three current items — verified across all
eight profile×pace combinations, including the tightest 5-minute `light`.

Per the TASK 079 contract, `estimatedMinutes` remains **generation-only
metadata** and is never persisted (`PlanItem` has no duration field). TASK 079
budget enforcement was **not weakened**: a deliberately over-budget extra source
composed alongside Quran still fails the whole generation with no partial
30-day output.

## 11. Profile independence

Identical `quranHabit` input yields an identical contribution across
`beginner`, `returning`, `prayer_focused`, `quran_focused`, `dhikr_focused`,
`learning_focused`, `advanced` and `low_time`, in count, template ID, type and
cost. `quran_focused` receives no extra contribution; `low_time` is not reduced;
`advanced` is not increased. The supplied profile is never altered — the
generated `DailyPlan.profileType` always matches the request. An **enum coverage
lock** fails the suite if a future profile is added without review.

## 12. Progression-phase independence

Across `weekIndex` 0–3 the contribution count, template identity, type, cost and
completion state are identical, verified additionally at every documented day
boundary (offsets 0, 6, 7, 13, 14, 20, 21, 28, 29) and across all 30 generated
days. Final item IDs differ only because `DayKey` differs. No phase-specific
Quran variant exists.

## 13. Ordered composite-source design

`bismillah_app/lib/features/today/domain/services/composite_daily_plan_item_source.dart`

`CompositeDailyPlanItemSource implements DailyPlanItemSource`, `const`
constructible, taking an explicitly ordered `List<DailyPlanItemSource>`.

- Child order is **constructor list order** — never runtime type, class name,
  `Set` storage or map iteration.
- Each child is called **once per day** (verified with a counting fake).
- Successful contributions are concatenated in source order.
- It remains pure: no repository, persistence, network, clock, locale, global
  singleton or logging.
- It is **not** an eager application-global default; callers construct it
  explicitly.

Because it implements the same single-source interface, `DailyPlanGenerator`
needed **no change** — the generator still accepts one source.

**Identity stability under later extension:** the composite does not touch
identity, and `slot` is assigned by position in the concatenated list. Since
Learn will be appended **after** Quran, existing Prayer (slots 0, 1) and Quran
(slot 2) identities cannot shift. A test appends a third source and asserts the
first three final IDs are byte-identical to the two-source run.

## 14. Composite failure behavior

| Case | Behavior |
|---|---|
| all children succeed | concatenated ordered contributions |
| first child fails | that typed failure propagates |
| later child fails | that typed failure propagates; **earlier contributions are discarded** |
| duplicate template ID **across** children | `ValidationFailure` |
| empty child list | successful empty contribution list |

Duplicate detection is scoped to **across children**, matching the requirement:
two different sources claiming the same action is a configuration bug. A single
source repeating a template internally remains its own decision, and TASK 079's
`slot` mechanism already separates the final identities — so this rule adds
safety without contradicting the existing generator contract.

**No new `AppFailure` subtype and no new localization key** were added; the
existing `ValidationFailure(messageKey: 'errorUnexpected')` precedent is reused.
Failure output is asserted to expose no child class name, no raw contribution
payload, no goal collection, no `DayKey`, no exception string and no stack trace.

## 15. Thirty-day Prayer + Quran integration

Generated through `DailyPlanGenerator` with
`CompositeDailyPlanItemSource(sources: [Prayer, Quran])`:

| Scenario | Items/day |
|---|---|
| `quranHabit` only | 1 |
| `quranHabit` + `trackPrayers` | 2 |
| `quranHabit` + `prayOnTime` | 2 |
| `quranHabit` + both Prayer goals | 3 |
| no Quran goal (`trackPrayers`) | 1 |
| all goals | 3 |

Each scenario verifies exactly 30 plans, 30 unique continuous `DayKey`s, stable
item order every day, correct count every day, no duplicate final IDs, budget
respected, all items starting incomplete, no partial output and the correct
profile stable ID. The combined case is generated **50 times** and asserted
byte-identical under a stable projection. Example day-one identities:

```
rule-engine-v1:2026-07-26:prayer_track_daily:0
rule-engine-v1:2026-07-26:prayer_on_time_daily:1
rule-engine-v1:2026-07-26:quran_continue_daily:2
```

## 16. Initial completion-state boundary

Every generated Quran item starts `pending` with `completedAt == null`. No
current Quran progress, last-read verse, saved verses or listening progress is
read; nothing is pre-completed; no "is this day today?" check occurs; no stored
`DailyPlan` is mutated. TASK 081 remains pure generation.

## 17. Religious safety and privacy

No Quran text, no translation text, no surah/ayah assignment, no reciter or
audio URL, no reward or punishment claim, no obligation wording and no reading
quota. The template ID is asserted to contain none of `sin`, `reward`, `punish`,
`obligat`, `fard`, `wajib`, `sunnah`, `good`, `bad`, `score`, `rank`, `quota`,
`must`.

A projection of a generated 30-day plan is asserted to contain no Arabic
scripture marker, no `surah-`, `ayah`, `juz`, `mp3quran`, `http`, `latitude`,
`uid` or `deviceId`. Both sources log nothing.

## 18. Automated tests

**70 new TASK 081 tests** in
`bismillah_app/test/features/today/domain/quran_daily_plan_item_source_test.dart`:

| Group | Coverage |
|---|---|
| Quran goal selection | `quranHabit` alone / with unrelated goals / all goals; absent; each unrelated goal alone; `quran_focused` alone adds nothing; `Set` order irrelevant; empty goal list |
| Template identity | exact ID; machine-identifier shape; no surah/ayah/juz/page/translation/reciter/audio token; no time/UID/device data; distinct from Prayer |
| PlanItem representation | `PlanItemType.quran`; `targetRef`/`sizeParam` null; cost 2; starts incomplete; no embedded text |
| Profile independence | all eight profiles; **enum coverage lock**; profile unchanged; `low_time` not reduced, `advanced` not increased |
| Phase independence | phases 0–3; all 30 days; every documented offset boundary |
| Ordered composition | Prayer before Quran; single Prayer goal still first; Quran-only; empty; constructor order decisive (reversed list reverses output); goal `Set` order irrelevant; 20-repeat stability; one call per child per day; empty child list; **third source appended does not shift Prayer/Quran identities** |
| Composite failure | first-child failure; later-child failure discards earlier contributions; cross-source duplicate rejected; 20-repeat deterministic rejection; failure exposes no internals |
| Budget | 2 / 3 / 3 / 4 totals; `light` 5 holds all three; all eight profile×pace budgets; over-budget extra source fails whole generation; `estimatedMinutes` not persisted |
| 30-day integration | six scenarios; 50-repeat determinism; exact builder-format identities; unique per-day identities |
| No side effects | 50-repeat stability; pace and `dayKey` irrelevant; **bootstrap invokes neither source, composite nor generator** |
| Religious safety & privacy | no text/assignment/coordinates/UID leakage; no judgmental tokens; no reading quantity |

| Suite | Before | After |
|---|---|---|
| Full Flutter | 945 | **1015** (0 failed, 0 skipped) |
| TASK 081-focused | — | **70** |
| TASK 080 Prayer | 62 | **62** |
| TASK 079 generator | 63 | **63** |
| TASK 078 mapper | 78 | **78** |
| TASK 077 state machine | 43 | **43** |
| DailyPlan persistence | 70 | **70** |
| Canonical sync-focused | 70 | **70** |
| Drift storage | 11 | **11** |
| Quran feature (`flutter test test/features/quran`) | — | **89** |
| Functions (Vitest) | 23 | **23** |
| `flutter analyze` | clean | **clean** |

The Quran feature count of **89** was measured, not assumed.

## 19. No Quran-repository, UI, persistence or remote changes

**Zero tracked files modified — new files only.** Unchanged accordingly: Quran
reader UI, Quran navigation, saved verses, Quran progress persistence, Quran
audio, reciter catalog, translation assets, localization files, onboarding UI,
Today UI, routes, notification scheduling, DailyPlan persistence,
SharedPreferences keys, DailyPlan envelope version (still **1**), Drift
schema/migrations/generated files, Firebase, Functions source, sync queue,
dependencies, `pubspec` files, Android/iOS files and build output.

No generated plan is saved, no onboarding completion flow calls the generator,
and no Quran repository is called by the source. A pattern scan of the new Quran
source for `QuranRepository|quran_progress|saved_verse|VerseBookmark|QuranAudio|reciter|SharedPreferences|Drift|Firebase|DailyPlanRepository|BuildContext|Ref |DateTime.now|Random|Locale`
returns matches **only inside doc comments stating what is not used**.

## 20. Source-backed vs. decided vs. mechanical

- **Existing code facts:** `PlanItemType.quran`; nullable `targetRef`/
  `sizeParam`; `DailyPlanItemIdBuilder` identity composition; the generator's
  single-source contract, slot assignment and budget/duplicate invariants;
  TASK 080's Prayer templates and costs; the `quranHabit` onboarding goal.
- **Approved TASK 081 product decisions:** the `quranHabit` inclusion rule;
  `quran_continue_daily`; `estimatedMinutes = 2`; no specific Quran assignment;
  profile/phase independence; the Prayer → Quran → Learn order.
- **Implementation-only mechanics:** the composite's earlier-sources duplicate
  set, `List.unmodifiable` concatenation, and the test projection helper.

## 21. TASK 082 boundary

Canonical next task, unchanged and not renumbered:

> **TASK 082 — Learn plan items**

It must: use the TASK 079 `DailyPlanItemSource` contract; join the existing
ordered composite **after** Prayer and Quran; use only **published and
source-verified** Learn article identifiers; not embed unverified religious
prose; preserve deterministic template and final item identities; stay inside
the daily budget; remain local-only; **not** persist generated plans; **not**
implement Today UI; and **not** add remote synchronization.

Content for `dhikr`, `dua` and `reflection` remains an **open owner decision**
and must not be invented.

## 22. Evidence appendix

- `bismillah_app/lib/features/today/domain/services/quran_daily_plan_item_source.dart`
- `bismillah_app/lib/features/today/domain/services/composite_daily_plan_item_source.dart`
- `bismillah_app/test/features/today/domain/quran_daily_plan_item_source_test.dart` (70)
- Consumed unchanged: `daily_plan_item_source.dart`, `daily_plan_generator.dart`,
  `daily_plan_generation_request.dart`, `prayer_daily_plan_item_source.dart`,
  `daily_plan_profile_type.dart`, `plan_enums.dart`, `daily_plan.dart`,
  `onboarding_focus_goal.dart`
- Deliberately **not** referenced: all 13 interfaces under
  `bismillah_app/lib/features/quran/domain/repositories/`, Quran assets,
  Quran audio and reader UI
- Prior reports: `TASK_079_DETERMINISTIC_DAILY_PLAN_GENERATOR.md`,
  `TASK_080_PRAYER_PLAN_ITEMS.md`
- Baselines: analyze clean · full **1015/1015** · TASK 081-focused **70** ·
  TASK 080 **62/62** · TASK 079 **63/63** · TASK 078 **78/78** ·
  TASK 077 **43/43** · persistence **70/70** · canonical sync **70/70** ·
  Drift storage **11/11** · Quran feature **89/89** · Functions **23/23**
