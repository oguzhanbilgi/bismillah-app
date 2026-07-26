# TASK 078 — Onboarding Profile Mapping

Pure, deterministic mapping from the **currently implemented** onboarding
model into the eight canonical profile buckets. No plan generation, no UI
change, no persistence change, no Firebase write, no remote sync.

## 1. Executive summary

TASK 078 introduces `DailyPlanProfileType` (the eight canonical buckets, finally
given stable machine IDs) and `OnboardingProfileMapper`, a pure function from
`OnboardingPreferences` to a typed mapping result.

Implementation stopped at the §3 contradiction gate first. The canonical
derivation recipe in `04_ONBOARDING_FLOW.md` §474 depends on onboarding inputs
(`growthGoal`, `prayerRoutine`, `quranHabit`, `mainStruggle`) that **the app
does not collect** — the shipped onboarding is a three-screen flow, not the
16-question specification. The owner approved **Option A**: map from the real
implemented model, and fixed the precedence order as an explicit product
decision.

The mapper is dependency-free and total: all eight profiles are reachable, every
`OnboardingFocusGoal` value is mapped, and enum-coverage locks fail the build if
a future profile or goal is left unmapped. 78 focused tests; full suite
**742 → 820**.

## 2. Previous task and purpose

TASK 077 (PR #20, merge `1813a1c`) delivered the DailyPlan state machine.
TASK 078 supplies the profile input that TASK 079's deterministic generator
will consume — mapping logic only, no generation.

## 3. Canonical input inventory

### Actually implemented and persisted

`bismillah_app/lib/features/onboarding/domain/entities/onboarding_preferences.dart`

| Field | Type | Values | Persisted key | Used for mapping |
|---|---|---|---|---|
| `goals` | `Set<OnboardingFocusGoal>` (multi-select, asserted non-empty) | `trackPrayers`, `prayOnTime`, `quranHabit`, `dhikrRoutine`, `islamicKnowledge` | `bismillah.onboarding_goals` | **yes** |
| `journeyStage` | `OnboardingJourneyStage` | `justBeginning`, `rebuildingRoutine`, `strengtheningRoutine` | `bismillah.onboarding_journey_stage` | **yes** |
| `dailyPace` | `OnboardingDailyPace` | `light`, `balanced`, `focused` | `bismillah.onboarding_daily_pace` | **yes** |
| `completedAtUtc` | `DateTime` | any | `bismillah.onboarding_completed_at` | **no — must not affect classification** |

All three mapping inputs are **enums serialised by stable `name`**
(`SharedPrefsOnboardingPreferencesRepository`), never by localized label. The
repository already rejects unknown/legacy enum names by treating onboarding as
not completed, so an invalid value cannot reach the mapper.

### UNUSED / FUTURE EXTENDED ONBOARDING SCAFFOLDING

These types exist in the repository but are **never constructed, never
persisted and never referenced** in production code or tests (verified: they
appear only in their own declaration files, and in zero test files). They are
**not** active production inputs and were **not** used, deleted or rewritten:

- `onboarding/domain/entities/onboarding_answers.dart` (`OnboardingAnswers`, the 16-question model)
- `onboarding/domain/value_objects/onboarding_enums.dart` (`OnboardingGoal`, `ExperienceLevel`)
- `onboarding/domain/entities/personalization_profile.dart` (`PersonalizationProfile`, `BehaviorSignals`)
- `onboarding/domain/repositories/onboarding_repository.dart`

### The gap that triggered the stop gate

`04_ONBOARDING_FLOW.md` §474 derives the profile as: **(1)** `growthGoal` →
**(2)** `prayerRoutine`/`quranHabit` → **(3)** `dailyTime` → **(4)**
`mainStruggle`. Of those, `growthGoal`, `prayerRoutine`, `quranHabit`
(as a frequency answer) and `mainStruggle` are **not collected by the app at
all**, and `dailyTime` exists only as a coarse three-value `dailyPace`.
Following §474 literally would have required building the 16-question
onboarding — explicitly outside this task's scope.

## 4. Canonical eight-profile inventory

Source: `docs/04_ONBOARDING_FLOW.md` §10 ("İlk Today Dashboard Eşlemesi",
lines 526–535), corroborated by §9 example plans and by the "8 profil" counts
at §618, §783, §792 and `10_DATA_MODEL` §4 (`profileType (8 kova)`).

`bismillah_app/lib/features/today/domain/value_objects/daily_plan_profile_type.dart`

| Doc name (§10) | Enum value | Stable ID |
|---|---|---|
| Beginner | `beginner` | `beginner` |
| Returning | `returning` | `returning` |
| Prayer-focused | `prayerFocused` | `prayer_focused` |
| Quran-focused | `quranFocused` | `quran_focused` |
| Dhikr-focused | `dhikrFocused` | `dhikr_focused` |
| Learning-focused | `learningFocused` | `learning_focused` |
| Advanced | `advanced` | `advanced` |
| Low-time | `lowTime` | `low_time` |

**Eight profiles, not nine.** This fulfils the note in
`personalization_profile.dart` that the eight buckets would be enumerated by
the personalization task. Exactly one profile type was created — there is no
competing `PersonalizationProfileType`. The type is placed in the plan feature
because `06_FLUTTER_ARCHITECTURE` §648 assigns `DeriveProfile` to the plan
feature.

## 5. Mapping strategy

An **explicit ordered rule list** — not a weighted score. Documentation defines
bucket *semantics* but no numeric weights, so inventing weights would be fake
precision. The rule list is the smallest deterministic construct that honours
those semantics.

**Source-backed facts** (from documentation and code):

- the eight profile names (§10)
- the current three-axis onboarding model and its exact enum values
- `dailyTime` being a hard product constraint (§497 "zaman bütçesi kutsaldır")
- Beginner/Returning/Low-time composition semantics (§528, §529, §535)
- Advanced meaning 30+ minutes and a full panel (§517, §534)

**Approved TASK 078 product inference** (decided in this task, **not** present
in the previous onboarding specification):

- the precedence order between the three axes
- the multi-goal tie-breaking order

## 6. Rule table

Evaluated top-down; the first match wins.

| # | Condition | Result | Rule ID |
|---|---|---|---|
| 1 | `journeyStage == justBeginning` | `beginner` | `journey_beginner` |
| 2 | `journeyStage == rebuildingRoutine` | `returning` | `journey_returning` |
| 3 | `journeyStage == strengtheningRoutine && dailyPace == focused` | `advanced` | `journey_advanced` |
| 4 | `dailyPace == light` (and 1–3 did not match) | `lowTime` | `pace_low_time` |
| 5 | first matching goal by fixed precedence | focus profile | `focus_*` |

Rule 5 goal precedence (explicit ordered list — never `Set` iteration order and
never enum declaration order):

| Order | Goal | Result | Rule ID |
|---|---|---|---|
| 1 | `trackPrayers` | `prayerFocused` | `focus_prayer` |
| 2 | `prayOnTime` | `prayerFocused` | `focus_prayer` |
| 3 | `quranHabit` | `quranFocused` | `focus_quran` |
| 4 | `dhikrRoutine` | `dhikrFocused` | `focus_dhikr` |
| 5 | `islamicKnowledge` | `learningFocused` | `focus_learning` |

Resulting full coverage of the 3 × 3 axis grid:

| journeyStage | `light` | `balanced` | `focused` |
|---|---|---|---|
| `justBeginning` | beginner | beginner | beginner |
| `rebuildingRoutine` | returning | returning | returning |
| `strengtheningRoutine` | lowTime | *goal-based* | advanced |

Notable consequences, each covered by a test: a beginner on the light pace stays
**beginner** (Rule 1 outranks Rule 4); **Advanced is never inferred from goals
alone** — it requires the `focused` pace.

## 7. Skip-rule handling

The historical rule *"selecting 'Yeni başlıyorum' skips the prayer-frequency
question"* belongs to the **unimplemented extended onboarding specification**
and does not apply to the current three-screen flow, which contains **no
prayer-frequency question at all** (`onboarding_goals_screen.dart`,
`onboarding_journey_screen.dart`, `onboarding_pace_screen.dart`).

Consequently there is no dependent answer to skip and no stale-dependent-answer
state to defend against. No fake skip logic was written, no prayer-frequency
field was added, and no UI was touched. In the current model `justBeginning`
maps directly to `beginner`; goals and pace may still be present but cannot
override Rule 1 — asserted by a test across every goal × pace combination.

## 8. Contradiction and incomplete handling

`ProfileMappingResult` is a sealed type with exactly two variants, because only
two are genuinely representable:

- **`ProfileMapped`** — canonical profile plus a stable `ruleId`.
- **`ProfileIncomplete`** — carries only a stable field identifier
  (`focus_goals`), never answer content.

Deliberately **not** created, to avoid fabricating unreachable variants:

- **No `Invalid`.** All three mapping inputs are enums, so the type system
  forbids invalid values, and the repository already converts unknown/legacy
  persisted names into "not completed". An invalid value cannot reach the mapper.
- **No `Contradictory`.** Multiple goals, stage + pace and stage + goals are all
  *legitimate* states in the current model, resolved by the priority rules.
  They are not contradictions.

`ProfileIncomplete` is reachable only when the goal set is empty. That is
blocked in debug by the `OnboardingPreferences` assertion and is never produced
by the repository, but remains representable in release builds — so the branch
exists defensively rather than silently defaulting to some profile. To test it
**without weakening the constructor invariant**, Rule 5's resolver is exposed as
a separate pure function (`resolveFocusProfile`) and tested directly with an
empty set; a further test asserts the constructor still rejects an empty goal
set.

## 9. Tie-breaking

Multi-goal ties are broken by the fixed `focusPrecedence` list declared in the
mapper (prayer → quran → dhikr → learning). It is a literal ordered list of
`(goal, profile, ruleId)` records, so the outcome depends on neither `Set`
iteration order, nor enum declaration order, nor any locale-sensitive sort.
Every documented boundary is tested, including `prayer + quran`,
`quran + dhikr`, `dhikr + learning`, learning alone, `prayOnTime` carrying
prayer precedence, and all five goals selected at once.

## 10. Determinism

The mapper reads no `Ref`, `SharedPreferences`, Drift, Firebase, `BuildContext`,
clock, locale, timezone, device state, network or randomness. Verified by test:

- 50 repeated calls return an identical result;
- goal-set insertion order does not change the result;
- `completedAtUtc` does not affect classification (two far-apart timestamps, and
  a 14-hour offset shift, both produce identical results);
- across the entire 3 × 3 × 5 input grid, five repeated calls collapse to a
  single distinct result.

Locale is not an input, so TR/EN/AR and RTL cannot alter classification.

## 11. Religious and ethical boundaries

Profile mapping is **product personalization, not religious judgment**. The
implementation assigns no piety score, infers no belief strength, ranks no user
and implies no spiritual superiority; `low_time` encodes a scheduling
constraint, not a verdict. Identifiers are neutral internal machine IDs, with
all user-facing naming left to the localization layer outside this task. A test
asserts no profile ID contains judgmental tokens (`good`, `bad`, `weak`,
`pious`, `sinner`, `lazy`, `better`, `score`, `rank`, …), and the profile type
carries no numeric ranking field.

## 12. Privacy guarantees

The mapper logs nothing at all. Result objects expose only a profile enum, a
stable rule ID and (for incomplete) a field identifier. A test renders a mapping
result and asserts it contains no goal values, no journey stage, no
`completedAt`, no UID, no location, no device ID, no exception and no stack
trace. No onboarding answers are copied or persisted, no new storage key is
introduced, and no analytics event is added.

## 13. Automated tests

**78 new TASK 078 tests** in
`bismillah_app/test/features/today/domain/onboarding_profile_mapper_test.dart`,
table-driven over the real `OnboardingPreferences` model:

| Group | Coverage |
|---|---|
| Eight-profile reachability | one fixture per profile; **enum coverage lock** (a new profile fails the suite until mapped); stable-ID assertion; count is exactly 8 |
| Rule 1 (beginner) | every goal × pace → `beginner`; light-pace beginner is not `low_time` |
| Rule 2 (returning) | every goal × pace → `returning` |
| Rule 3 (advanced) | every goal with `focused` → `advanced`; advanced not inferable from goals alone |
| Rule 4 (low-time) | every goal with `light` → `low_time` |
| Rule 5 (goal mapping) | each of the five goals individually; **goal coverage lock** |
| Multi-goal precedence | prayer+quran, quran+dhikr, dhikr+learning, learning only, `prayOnTime` precedence, all-goals |
| Determinism | repetition, insertion order, `completedAtUtc`, offset shift, full-grid single-output |
| Incomplete | empty goal set resolves nothing; no silent default; identifier-only payload; constructor invariant preserved |
| Rule IDs | uniqueness, neutral `^[a-z][a-z0-9_]*$` form, every ID actually producible across the full grid |
| Privacy & ethics | no raw answers/identifiers in output; neutral profile IDs; no score field |

| Suite | Before | After |
|---|---|---|
| Full Flutter | 742 | **820** (0 failed, 0 skipped) |
| TASK 078-focused | — | **78** |
| DailyPlan persistence | 70 | **70** |
| TASK 077 state machine | 43 | **43** |
| Canonical sync-focused | 70 | **70** |
| Drift storage | 11 | **11** |
| Functions (Vitest) | 23 | **23** |
| `flutter analyze` | clean | **clean** |

Onboarding-touching regression suites (`privacy_data_reset_test.dart`,
`local_data_reset_test.dart`) pass unchanged at 9/9.

## 14. No generation / UI / persistence / remote verification

**No generation:** the diff contains no `DailyPlan` or `PlanItem` construction,
no 30-day array, no four-week curve, no schedule template, no target
escalation, no recovery-week logic, no religious recommendation content and no
repository save. The mapper's only output is a profile enum plus a rule ID.

**No UI:** no onboarding screen, navigation, question copy, localized string,
progress indicator, Today screen, profile display or route was added or
modified. No widget file appears in the diff.

**No persistence change:** no SharedPreferences key added or altered; onboarding
keys, repository and answer storage untouched; DailyPlan envelope version stays
**1** and its storage key stays `bismillah.daily_plans`; `DailyPlan.profileType`
remains a `String` and was **not** changed — TASK 079 will convert
`DailyPlanProfileType.id` at the generation boundary. TASK 078 persists no
profile.

**No database or remote change:** no Drift table, `schemaVersion`, migration or
generated file; no Firebase, Firestore, `cloud_firestore`, Functions upload,
`SyncOperations` or sync-queue change; remote sync remains disabled. No
dependency or lockfile changed. **Zero tracked files modified — new files only.**

**No provider was added.** The mapper is a pure static utility (the
`DailyPlanEnvelopeCodec` precedent), so there is no DI surface, nothing for
bootstrap to invoke, and no eager initialization. Callers invoke it directly;
purity makes it trivially testable without Riverpod overrides.

## 15. TASK 079 boundary

Canonical next task, unchanged and not renumbered:

> **TASK 079 — Deterministic daily plan generator**

Expected inputs: the typed `DailyPlanProfileType` from this mapper; the
canonical plan size / daily pace; the local start `DayKey`; the approved
content/template catalogue; and the four-week progression rules
(`04_ONBOARDING_FLOW` §9).

Required boundaries: deterministic; local-only; no unsourced religious claims;
30 per-day `DailyPlan` records (never a single aggregate — TASK 076 rule); no
Today UI; no remote sync; no notification scheduling. TASK 079 also owns
converting `DailyPlanProfileType.id` into the existing `DailyPlan.profileType`
string. No generation content was invented in TASK 078.

## 16. Evidence appendix

- `bismillah_app/lib/features/today/domain/value_objects/daily_plan_profile_type.dart`
- `bismillah_app/lib/features/today/domain/services/onboarding_profile_mapper.dart`
- `bismillah_app/test/features/today/domain/onboarding_profile_mapper_test.dart` (78)
- Input model (unchanged): `bismillah_app/lib/features/onboarding/domain/entities/onboarding_preferences.dart`,
  `.../value_objects/onboarding_focus_goal.dart`, `onboarding_journey_stage.dart`, `onboarding_daily_pace.dart`
- Persistence (unchanged): `bismillah_app/lib/features/onboarding/data/shared_prefs_onboarding_preferences_repository.dart`
- Unused scaffolding (untouched): `onboarding_answers.dart`, `onboarding_enums.dart`,
  `personalization_profile.dart`, `onboarding_repository.dart`
- Canonical specs: `docs/04_ONBOARDING_FLOW.md` §9, §10, §474, §618;
  `docs/10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` §4;
  `docs/06_FLUTTER_ARCHITECTURE.md` §648
- Prior reports: `docs/task-reports/TASK_076_DAILY_PLAN_LOCAL_PERSISTENCE.md`,
  `docs/task-reports/TASK_077_DAILY_PLAN_STATE_MACHINE.md`
- Baselines: analyze clean · full **820/820** · TASK 078-focused **78** ·
  TASK 077 state machine **43/43** · DailyPlan persistence **70/70** ·
  canonical sync **70/70** · Drift storage **11/11** · Functions **23/23**
