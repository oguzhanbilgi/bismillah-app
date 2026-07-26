# TASK 079 — Deterministic Daily Plan Generator

Pure, local, deterministic generation of exactly **30 canonical per-day
`DailyPlan` records**, plus an extensible item-source contract for the approved
content tasks that follow. No persistence write, no Today UI, no Drift change,
no Firebase write, no remote sync, and **no invented religious content**.

## 1. Executive summary

TASK 079 builds the generation *skeleton*: a validated request, 30 continuous
`DayKey` records, a four-phase progression index, a deterministic minute
budget, stable item identity, output invariants, and a `DailyPlanItemSource`
contract that TASK 080–082 will implement with approved content.

Implementation stopped at the §3 specification gate first. Four conditions
fired, most importantly that **three of the six `PlanItemType` categories have
no content whatsoever** in the repository — generating items would have meant
inventing worship prescriptions, which `DO_NOT_BREAK` forbids. The roadmap
itself resolves this: Prayer/Quran/Learn plan items are **TASK 080/081/082**,
*after* this task. The owner approved **Option B** — skeleton plus source
contract — and fixed the pace budget and `weekIndex` semantics as explicit
product decisions.

With the default `EmptyDailyPlanItemSource`, generation yields 30 fully valid
plans with **empty `items` lists**, which the `DailyPlan` domain explicitly
allows. 63 focused tests; full suite **820 → 883**.

## 2. Previous task and purpose

TASK 078 (PR #21, merge `8b5f6eb`) produced the typed `DailyPlanProfileType`
and the pure `OnboardingProfileMapper`. TASK 079 consumes that profile and
turns it into the 30-day frame — still with no content, no UI and no
persistence.

## 3. Why the stop gate fired

| Gate condition | Evidence |
|---|---|
| **No approved template/content identifiers exist** | `dhikr`, `dua` and `reflection` have *no* content: `features/dhikr` and `features/dua` contain only domain entities and repository **interfaces** — no implementation, no data source, no assets. `assets/content/` contains **only `learn/`**. No plan template or catalog structure exists anywhere in `lib/`. |
| **Generating items would require inventing religious advice** | Doc `04 §478–485`/`§514–518` describes profile compositions in concrete worship terms ("Sübhanallah zikri 33", "sabah/akşam ezkârı", "kısa dua kartı", "yansıma sorusu"). Fixing which dhikr, how many repetitions, or which dua without a sourced content record would violate `DO_NOT_BREAK` ("No unsourced verse, hadith, ruling, or fatwa anywhere"). |
| **Pace cannot be converted to `sizeMinutes` canonically** | Doc `04 §341` defines `dailyTime` as a **four-bucket** slider (5/10/20/30+ min); the shipped app collects `OnboardingDailyPace` with **three** values (`light`/`balanced`/`focused`). No canonical mapping exists between them. |
| **`weekIndex` semantics undefined** | The domain validates only `weekIndex >= 0`. "Four-week curve" (`§9`) versus 30 ÷ 7 = five buckets. The only precedent was a TASK 076 *test fixture* using `(d-1) ~/ 7` (max index 4) — a fixture, not a specification. |

The roadmap confirmed the correct scope: `TASK 080 — Prayer plan items`,
`TASK 081 — Quran plan items`, `TASK 082 — Learn plan items` all come **after**
079, so this task was never meant to author content.

## 4. Approved TASK 079 product decisions

These were decided in this task. **They were not fully specified by older
documentation** and must not be presented as inherited.

**Scope (Option B).** TASK 079 implements the 30-day structure, request,
four-phase index, pace budget, item-source contract, stable identity, output
validation and tests. It does **not** implement prayer/Quran/Learn content,
dhikr/dua/reflection catalogs, Today UI, persistence orchestration or
onboarding integration.

**Pace budget.**

| Pace | `sizeMinutes` |
|---|---|
| `light` | 5 |
| `balanced` | 10 |
| `focused` | 20 |
| `advanced` profile **+** `focused` pace | 30 |

15 minutes is never produced (asserted by test). The 30-minute Advanced case is
the **only** profile-specific size override; Advanced does not mean unlimited
time.

**Four-phase `weekIndex`.** `weekIndex` is a zero-based *progression phase*,
not a count of calendar weeks:

| Days | Offsets | `weekIndex` |
|---|---|---|
| 1–7 | 0–6 | 0 |
| 8–14 | 7–13 | 1 |
| 15–21 | 14–20 | 2 |
| 22–30 | 21–29 | 3 |

Days 29 and 30 remain in phase 3; **`weekIndex` 4 is never produced**. The
phases carry no invented religious meaning. Resulting day counts are 7/7/7/9.

## 5. Generation request

`bismillah_app/lib/features/today/domain/services/daily_plan_generation_request.dart`

Carries exactly four inputs: `profileType` (`DailyPlanProfileType`), `goals`
(`Set<OnboardingFocusGoal>`), `dailyPace`, `startDay` (`DayKey`). Deliberately
absent: `completedAtUtc`, UID, location, locale, timezone, `DateTime.now`,
device ID, subscription state, notification settings, free-text notes and any
persistence identifier.

Goals are normalized into `normalizedGoals`, an immutable list in **enum
declaration order** — a deliberate, documented canonical order, so `Set`
insertion order cannot affect output.

**Compatibility validation** (`validate()` → `GenerationRequestIssue?`) rejects
combinations TASK 078 could never have produced:

| Profile | Allowed pace |
|---|---|
| `beginner`, `returning` | any (journey stage outranks pace — TASK 078 Rules 1–2) |
| `advanced` | `focused` only (Rule 3) |
| `low_time` | `light` only (Rule 4) |
| the four focus profiles | `balanced` or `focused` (Rule 5; `light` would have become `low_time`) |

Empty goals are rejected (`emptyGoals`). Inconsistent input is **never silently
repaired**, and the generator does **not** re-run `OnboardingProfileMapper` —
the supplied profile stays authoritative after validation.

## 6. Generator contract

`DailyPlanGenerator.generate(request, {source})` → `ResultFuture<List<DailyPlan>>`

Pure with respect to inputs: no `Ref`, `BuildContext`, repository,
`SharedPreferences`, Drift, Firebase, network, system clock, locale, timezone,
randomness, analytics or notifications. Every variable input is explicit, and
the generator **never saves its output**.

`generatedBy` is the canonical rule-engine marker `rule-engine-v1`
(`10_DATA_MODEL` §4 — "generatedBy(rule-engine ver.)").

## 7. Duration and DayKey semantics

Exactly 30 records; index 0 is `request.startDay`, each subsequent record
advances one **local calendar day** via `DateTime(y, m, d + offset)`, which
normalizes overflow. No UTC conversion and no `Duration(hours: 24)` assumption,
so daylight-saving transitions cannot shift a day. `DayKey` is reused; no second
date-only type was introduced.

Verified by test: continuity, uniqueness, ascending order, month rollover, year
rollover, leap day present in 2028, **absent** in 2027, and a DST-crossing
window (2026-03-25 → 2026-04-01) advancing exactly one day at a time.

## 8. Item-source contract

`bismillah_app/lib/features/today/domain/services/daily_plan_item_source.dart`

- **`DailyPlanDayContext`** — read-only per-day input: profile, normalized
  goals, pace, minute budget, `dayKey`, `dayOffset` (0–29), `weekIndex` (0–3).
  Carries no identity, location, clock, locale or persistence reference.
- **`PlanItemDraft`** — a source's proposal: stable `templateId`, `PlanItemType`,
  `estimatedMinutes` (budget checking only — `PlanItem` has no duration field,
  so this is **not** written to the stored plan), optional `targetRef` (content
  or prayer-name **ID**, never raw religious text) and `sizeParam`.
- **`DailyPlanItemSource`** — `itemsFor(context)` returning an ordered list or a
  typed `AppFailure`.
- **`EmptyDailyPlanItemSource`** — the TASK 079 default: no side effects, no
  repository/asset/clock reads, no logging, identical result for equal input.

An empty item list is **not** a failure; `DailyPlan` explicitly accepts empty
`items`.

**Future owners, deliberately not pre-created here:** TASK 080 (Prayer),
TASK 081 (Quran), TASK 082 (Learn). No prayer targets, Quran reading targets,
dhikr counts, dua selections, lesson selections or reflection questions were
defined, and no placeholder religious content was added.

## 9. Stable item identity

`DailyPlanItemIdBuilder.build(...)` composes
`generatorVersion:dayKey:templateId:slot` — e.g.
`rule-engine-v1:2026-07-26:tmpl-a:0`.

Derived only from durable canonical inputs. No random UUID, timestamp,
`hashCode`, process-dependent value, locale-sensitive string or device ID. The
`slot` component means the same template used twice in one day still yields
distinct IDs. Tested: repeat-stability, no same-day collision, no cross-day
collision across all 30 days, negative slot rejected, and no epoch-millisecond
pattern in the ID.

## 10. Output invariants

Validated before any success is returned; a violation returns a typed failure
and **never a partial plan**:

exactly 30 plans · each `dayKey` equals `dayAt(startDay, i)` · no duplicate day
· ascending order · `profileType` equals the profile's **stable ID** · correct
`sizeMinutes` · `weekIndex` matches the phase rule · `generatedBy` is the
canonical marker · no duplicate item identity within a day · per-day
`estimatedMinutes` total never exceeds the budget (`04 §9-2` — "zaman bütçesi
kutsaldır").

## 11. Profile conversion boundary

`DailyPlan.profileType` remains a `String`; the generator writes
`DailyPlanProfileType.id` (e.g. `quran_focused`). `toString()` and localized
labels are never used, the domain field type was **not** changed, the
persistence envelope version stays **1**, and no second profile representation
was introduced.

## 12. Failure behavior

Uses the existing `Result`/`AppFailure` architecture with **no new failure
type**:

- invalid request → `ValidationFailure(messageKey: 'errorUnexpected')`
  (existing key; matching the precedent in the Quran data layer — no new
  localization key was added);
- source failure → the source's `AppFailure` propagated unchanged;
- output-invariant or budget violation → `UnexpectedFailure`.

Machine-readable reasons are exposed separately through the typed
`GenerationRequestIssue` enum (`emptyGoals`, `profilePaceMismatch`) on the
request, so callers and tests can distinguish causes **without** adding an
`AppFailure` subtype. Failure objects carry no raw request, goals, day keys,
generated plan, stack trace, storage key, UID or location — asserted by test.

## 13. Determinism and privacy

No execution-count, `Set` insertion order, locale, RTL, timezone, system
date/time, randomness or map-iteration dependency. Tested with a stable string
projection (not object identity): 50 repeated generations identical; separately
constructed equal requests identical; per-profile repeat stability; goal
insertion permutations identical; generated items always start `pending` with
`completedAt == null`.

The generator logs nothing. `estimatedMinutes` stays in the draft and is never
persisted.

## 14. Automated tests

**63 new TASK 079 tests** in
`bismillah_app/test/features/today/domain/daily_plan_generator_test.dart`:

| Group | Coverage |
|---|---|
| Request validation | valid request; each profile with its compatible paces; beginner/returning accept every pace; advanced rejects light+balanced; low_time rejects balanced+focused; focus profiles reject light; empty goals; typed failure with no partial output; no silent repair |
| 30-day structure | exactly 30; first/last day; continuity, uniqueness, ascending; month rollover; year rollover; leap day present (2028) and absent (2027); DST window |
| Four-phase progression | all nine documented boundaries (offsets 0, 6, 7, 13, 14, 20, 21, 28, 29); `weekIndex` 4 never produced; 7/7/7/9 distribution |
| Pace & budget | 5/10/20 mapping; advanced+focused → 30 and the override not generalizing; 15 never produced; budget written to all 30 days; over-budget source rejected with no partial plan; exact-fit source accepted |
| Eight profiles | valid 30-day output per profile; **enum coverage lock**; stable ID written, not `toString()` |
| Goals | insertion order irrelevant; normalization order; normalized goals reach the source; generator does not re-run profile mapping |
| Empty source | 30 days with empty items; empty is not a failure; identical result for equal input |
| Source contract | called once per day; context carries offset/phase/day; context carries budget and profile; source failure propagated with no partial output; source order preserved; draft rejects blank template ID and negative minutes |
| Stable identity | repeat stability; no cross-day collision; no same-day collision with a repeated template; exact ID composition; no timestamp; negative slot rejected |
| Determinism | 50 repeats; equal separate requests; per-profile stability; items always `pending` |
| Privacy & content boundary | failure exposes no request/goal/day/exception content; **no religious content produced**; generator version is a stable ID |

| Suite | Before | After |
|---|---|---|
| Full Flutter | 820 | **883** (0 failed, 0 skipped) |
| TASK 079-focused | — | **63** |
| TASK 078 mapper | 78 | **78** |
| TASK 077 state machine | 43 | **43** |
| DailyPlan persistence | 70 | **70** |
| Canonical sync-focused | 70 | **70** |
| Drift storage | 11 | **11** |
| Functions (Vitest) | 23 | **23** |
| `flutter analyze` | clean | **clean** |

## 15. No persistence / UI / database / remote verification

**No persistence:** the generator never calls `DailyPlanRepository`,
`SharedPrefsDailyPlanRepository`, `DailyPlanEnvelopeCodec`, `SharedPreferences`,
Drift or the sync queue — a pattern scan of the new service directory returns
matches only inside doc comments stating what is *not* used. Nothing eagerly
saves output, no onboarding completion hook changed, and no stored plan is
replaced.

**No UI:** no Today screen or widget, no onboarding screen or navigation, no
localization file, no route, no progress or completion UI, no profile display
copy. The generator returns domain data only.

**No database or remote change:** no SharedPreferences key, no envelope version
change (still **1**), no storage adapter change, no Drift table/`schemaVersion`/
migration/generated file, no Firebase, Firestore, `cloud_firestore`, Functions
source, `SyncOperations`, queue, connectivity listener or background worker.
Remote sync remains disabled. No dependency or lockfile changed. **Zero tracked
files modified — new files only.**

**No provider added.** The generator is a pure static service, consistent with
TASK 078's mapper, so there is no DI surface and bootstrap cannot instantiate or
execute generation. No orchestration controller was created.

## 16. Source-backed vs. decided vs. mechanical

- **Source-backed:** 30-day frame and per-day `DailyPlan` model
  (`10_DATA_MODEL` §4); `generatedBy` as rule-engine version (§4); "time budget
  is sacred" (`04 §9-2`); local rule-engine generation, offline (`04 §9`); the
  eight profiles and their stable IDs (TASK 078).
- **Approved TASK 079 product decisions:** the pace→minute table including the
  Advanced+focused 30-minute override; the four-phase `weekIndex` boundaries
  with days 29–30 in phase 3; Option B scope.
- **Implementation-only mechanics:** the composite item-ID format, the
  `GenerationRequestIssue` enum, goal normalization order (enum declaration
  order), the draft/context shapes, and the output-invariant checks.

## 17. Remaining orchestration work

- Approved item sources: **TASK 080** (Prayer), **TASK 081** (Quran),
  **TASK 082** (Learn).
- Content decisions still open for `dhikr`, `dua` and `reflection` — those
  categories have no approved content at all today.
- Persistence orchestration: nothing yet calls `generate` and saves the result
  through `DailyPlanRepository`.
- Onboarding-completion integration (deliberately untouched).
- Today UI — **TASK 083**.
- Missed-day recovery — **TASK 084**.
- The temporary envelope → Drift migration; gate **G8** stays owned by
  **TASK 132**.

## 18. Exact next task

From `docs/project-state/MASTER_EXECUTION_ROADMAP.md` (CP10) and
`TASK_INDEX.md`, unchanged and not renumbered:

> **TASK 080 — Prayer plan items**

Purpose: supply the first approved `DailyPlanItemSource` — prayer-category plan
items — using the TASK 079 contract. It integrates generation with approved
content, **not** with persistence or UI; the Today UI remains out of scope until
TASK 083. Required tests will include source determinism, budget compliance,
stable template IDs and per-profile/goal composition.

## 19. Evidence appendix

- `bismillah_app/lib/features/today/domain/services/daily_plan_generation_request.dart`
- `bismillah_app/lib/features/today/domain/services/daily_plan_item_source.dart`
- `bismillah_app/lib/features/today/domain/services/daily_plan_generator.dart`
- `bismillah_app/test/features/today/domain/daily_plan_generator_test.dart` (63)
- Consumed unchanged: `daily_plan_profile_type.dart`, `onboarding_profile_mapper.dart` (TASK 078),
  `daily_plan.dart`, `plan_enums.dart`, `day_key.dart`, `date_key.dart`
- Gate evidence: `bismillah_app/lib/features/dhikr/**`, `bismillah_app/lib/features/dua/**`
  (interfaces only), `bismillah_app/assets/content/` (learn only),
  `docs/04_ONBOARDING_FLOW.md` §9, §10, §341, §478–485, §514–518
- Roadmap ordering: `docs/project-state/MASTER_EXECUTION_ROADMAP.md` CP10 (TASK 080–082 follow 079)
- Prior reports: `TASK_076_DAILY_PLAN_LOCAL_PERSISTENCE.md`,
  `TASK_077_DAILY_PLAN_STATE_MACHINE.md`, `TASK_078_ONBOARDING_PROFILE_MAPPING.md`
- Baselines: analyze clean · full **883/883** · TASK 079-focused **63** ·
  TASK 078 **78/78** · TASK 077 **43/43** · persistence **70/70** ·
  canonical sync **70/70** · Drift storage **11/11** · Functions **23/23**
