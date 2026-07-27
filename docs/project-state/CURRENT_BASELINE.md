# Current Baseline

Canonical, verified snapshot of the project at the time of this documentation task.

## Source-of-truth rule

> The live Git HEAD and `origin/main` are authoritative for the current commit.
> The stored commit below records the last verified baseline **before** this
> task (TASK 082). After the TASK 082 merge, read the real current commit from
> Git — do not treat the stored value as the live HEAD.

## Repository

- Canonical repo: `https://github.com/oguzhanbilgi/bismillah-app`
- Last verified main before TASK 082: `b390141`
- Public tag: `v0.1.0-alpha.1` → `c23f490` (verified intact; must not be moved)
- Latest completed functional task: **TASK 082** — Source-verified Learn plan
  items **and the complete Prayer → Quran → Learn core composition**.
  `LearnDailyPlanItemSource` emits **one** Learn item per generated day when
  the `islamicKnowledge` goal is present (absent ⇒ empty list, not a
  failure), costing **`estimatedMinutes = 1`** (in-app interaction budget —
  **not** required study time, a religious minimum, a ruling, reward or
  rank). The item is `PlanItemType.lesson` with `targetRef` = the **stable
  published + source-verified article ID** and `sizeParam` null. **No article
  title, summary, body, translation or source text is copied into the plan**;
  **no Learn repository, asset bundle or reading history is read during
  generation**. Selection is `dayOffset` → catalog index (no modulo, no
  repetition, no randomness, no locale/profile/phase reordering).
  `LearnDailyPlanCatalog.v1` is an immutable, explicit, versioned **30-entry**
  catalog: entries 0–10 follow the **existing editorial `beginnerPathOrder`**
  (published members only — 11 and 12 are `scholarlyReviewPending` and
  excluded); entries 11–29 are an **approved TASK 082 product decision**
  grouped by `categories.json` `sortOrder`. Content gate passed with **no
  content change**: exactly **30 eligible published + `sourceBodyReview`
  verified** articles, with **identical stable ID sets in TR/EN/AR**.
  `CoreDailyPlanItemSource` bundles the approved **Prayer → Quran → Learn**
  order (`const`, pure, no provider, no bootstrap wiring); the composite and
  generator were **unchanged**, and appending Learn **did not shift** any
  Prayer/Quran slot or final ID on any of the 30 days (tested). Complete core
  day cost = **5 minutes**, which `light` accepts exactly. Contribution is
  identical across all 8 profiles and 4 phases. 163 focused tests; full suite
  1015 → **1178**. **No persistence, Today UI, onboarding integration, Drift,
  Firebase or remote sync; no article asset edited; zero tracked files
  modified.**
  Report: `docs/task-reports/TASK_082_LEARN_PLAN_ITEMS.md`
- Previous completed functional task: **TASK 081** — Quran plan items **and
  ordered source composition**. `QuranDailyPlanItemSource` emits a single
  neutral *continuation/tracking* action `quran_continue_daily` when the
  `quranHabit` goal is present (absent ⇒ empty list, not a failure), costing
  **`estimatedMinutes = 2`** (in-app interaction budget — **not** required
  reading duration, a religious minimum, a ruling, reward or rank).
  **No surah, ayah, juz, page, translation text, reciter, audio URL or
  reading/listening quantity is assigned**; `targetRef`/`sizeParam` stay
  null. No Quran repository, progress, saved verses or audio is read.
  `CompositeDailyPlanItemSource` runs an **explicitly ordered** child list
  once per day and concatenates in **Prayer → Quran → Learn** order —
  a deterministic product rule, **not** a religious ranking. It propagates
  the first typed child failure with **no partial output**, rejects
  **cross-source** duplicate template IDs (`ValidationFailure`, no new
  failure type or l10n key), and returns an empty success for an empty child
  list. Because it implements the same single-source interface, the
  **generator needed no change**. Appending Learn later **cannot shift**
  Prayer/Quran slots or final IDs (tested). Contribution is identical across
  all 8 profiles and 4 phases. 70 focused tests; full suite 945 → **1015**.
  **No persistence, Today UI, Drift, Firebase or remote sync; zero tracked
  files modified.**
  Report: `docs/task-reports/TASK_081_QURAN_PLAN_ITEMS.md`
- Previous completed functional task: **TASK 080** — Prayer plan items: the
  **first approved `DailyPlanItemSource`**. `PrayerDailyPlanItemSource` emits
  `prayer_track_daily` (goal `trackPrayers`) and/or `prayer_on_time_daily`
  (goal `prayOnTime`), in that fixed order, each costing
  **`estimatedMinutes = 1`** (in-app *interaction* cost — **not** prayer
  duration, a religious minimum, a ruling or a rank). Items come from
  **goals, never from the profile**; `prayOnTime` does not imply
  `trackPrayers`; unrelated goals change nothing; no prayer goal ⇒ empty list
  (not a failure). Contribution is **identical across all 8 profiles and all
  4 phases** — no escalation, no beginner discount, no advanced quota.
  Representation gate passed with **no domain change**: the two actions are
  distinguished by `templateId`, which `DailyPlanItemIdBuilder` already
  composes into the final item ID. `targetRef`/`sizeParam` stay **null** — no
  prayer name and no prayer count is ever claimed. **No prayer-time
  calculation, no location, no notification, no `PrayerLog` read, no
  persistence, no Today UI, no Firebase; remote sync stays disabled; zero
  tracked files modified.** 62 focused tests; full suite 883 → **945**.
  Report: `docs/task-reports/TASK_080_PRAYER_PLAN_ITEMS.md`
- Previous completed functional task: **TASK 079** — Deterministic daily plan
  generator (**skeleton + item-source contract**): `DailyPlanGenerator` emits
  exactly **30 per-day `DailyPlan` records** from a validated
  `DailyPlanGenerationRequest` (profile · goals · pace · start `DayKey`).
  The stop gate fired first: `dhikr`/`dua`/`reflection` have **no content at
  all** (interfaces only; `assets/content/` holds only `learn/`), so producing
  items would have meant inventing worship prescriptions. The roadmap resolves
  it — Prayer/Quran/Learn items are **TASK 080/081/082**. Owner approved
  **Option B**.
  **Approved TASK 079 product decisions (NOT in the old spec):** pace budget
  `light` 5 · `balanced` 10 · `focused` 20 · **`advanced`+`focused` → 30**
  (the only profile-specific override; 15 never produced); `weekIndex` is a
  zero-based **four-phase** index — offsets 0–6→0, 7–13→1, 14–20→2, **21–29→3**
  (days 29–30 stay in phase 3; **`weekIndex` 4 is never produced**; 7/7/7/9).
  Default `EmptyDailyPlanItemSource` ⇒ 30 valid plans with **empty `items`**
  (explicitly not a failure). Stable item ID =
  `rule-engine-v1:<dayKey>:<templateId>:<slot>` — no random/timestamp/hashCode.
  63 focused tests; full suite 820 → **883**. **No persistence write, no Today
  UI, no Drift change, no Firebase write, no religious content; remote sync
  stays disabled; zero tracked files modified.**
  Report: `docs/task-reports/TASK_079_DETERMINISTIC_DAILY_PLAN_GENERATOR.md`
- Previous completed functional task: **TASK 078** — Onboarding profile mapping:
  `DailyPlanProfileType` (the **eight** canonical §10 buckets, finally given
  stable IDs: `beginner`, `returning`, `prayer_focused`, `quran_focused`,
  `dhikr_focused`, `learning_focused`, `advanced`, `low_time`) plus the pure
  `OnboardingProfileMapper`. **Input is the really implemented three-axis
  `OnboardingPreferences`** (`goals` / `journeyStage` / `dailyPace`);
  `completedAtUtc` never affects classification. The 16-question
  `OnboardingAnswers` / `OnboardingGoal` / `PersonalizationProfile` types are
  **UNUSED FUTURE SCAFFOLDING** and were not used, deleted or rewritten.
  Doc §474's derivation recipe was unusable because its inputs
  (`growthGoal`, `prayerRoutine`, `mainStruggle`) are **not collected by the
  app** — the stop gate fired and the owner approved Option A.
  **Approved TASK 078 product decision (NOT in the old spec):** priority
  1 `justBeginning`→beginner · 2 `rebuildingRoutine`→returning ·
  3 `strengtheningRoutine`+`focused`→advanced · 4 `light`→low_time ·
  5 goals by fixed order prayer→quran→dhikr→learning. 78 focused tests;
  full suite 742 → **820**. **No generation, no UI, no persistence change,
  no Firebase write, no Drift change; remote sync stays disabled; zero
  tracked files modified.**
  Report: `docs/task-reports/TASK_078_ONBOARDING_PROFILE_MAPPING.md`
- Previous completed functional task: **TASK 077** — DailyPlan state machine:
  `DailyPlanController` (`Notifier<DailyPlanState?>`) loads/observes/refreshes/
  saves one selected `DayKey` through the **unchanged** repository contract.
  Sealed states: **Loading · Empty · Available · Corrupt · Failure** (calm
  states are data, not errors). Stale results are blocked by a **generation
  (epoch) counter** (`QuranSearchController` idiom); save concurrency rule is
  **latest valid completion wins** — an older failed save can never replace a
  newer success. Included the owner-approved minimum contract correction:
  **`StorageCorruptionFailure`** added beside `StorageFailure` so corruption
  (unreadable stored data, not retryable) is distinguishable from transient
  storage-operation failures — **no signature, localization key, envelope
  version, storage key or persistence format changed**. 43 focused tests;
  TASK 076 persistence tests strengthened 67 → **70**; full suite 696 → **742**.
  **No generation, no Today UI, no Firebase write, no Drift migration; remote
  sync stays disabled.**
  Report: `docs/task-reports/TASK_077_DAILY_PLAN_STATE_MACHINE.md`
- Previous completed functional task: **TASK 076** — DailyPlan local persistence:
  the canonical **per-day** `DailyPlan` model and the existing
  `DailyPlanRepository` contract were preserved and given their first real
  implementation, backed by a **temporary versioned key-value envelope**
  (persistence version **1**, single key `bismillah.daily_plans`). The original
  brief's "single active 30-day snapshot" model was **rejected** as
  contradicting `10_DATA_MODEL` §4/§5/§7 and `11_LOCAL_DB` §3; a 30-day plan
  remains a composition of 30 per-day records and **no second DailyPlan
  abstraction exists**. Corruption returns typed failures and is never
  silently overwritten. **No Drift schema change, no dependency change, no
  generation, no Today UI, no Firebase write; remote sync stays disabled.**
  67 focused tests; full suite 629 → **696**.
  Report: `docs/task-reports/TASK_076_DAILY_PLAN_LOCAL_PERSISTENCE.md`
- Previous completed documentation task: **TASK 075** — CP09 technical
  stabilization and full regression checkpoint (verdict: **CP09 COMPLETE —
  TECHNICALLY STABLE**; product gate: **READY TO ENTER NEXT LOCAL-FIRST
  PRODUCT CHECKPOINT**; P0 = 0, P1 = 15, P2 = 12, deferred = 5; remote sync
  stays disabled.
  Report: `docs/task-reports/TASK_075_CP09_TECHNICAL_STABILIZATION_CHECKPOINT.md`)
- Previous documentation task: **TASK 074** — Firebase security and
  console readiness audit (verdict: **READY FOR LOCAL SECURITY HARDENING
  ONLY** — no Rules/App Check/emulator/staging exist yet; Functions callable
  well-guarded but deployed on EOL nodejs20 vs repo nodejs22; secret scan
  clean; P0 = 0, P1 = 6, P2 = 5.
  Report: `docs/task-reports/TASK_074_FIREBASE_SECURITY_READINESS_AUDIT.md`)
- Previous completed functional task: **TASK 073** — local sync-queue hardening:
  deterministic backoff policy (staged + FNV-1a jitter, 24h cap, attempt-8
  quarantine), privacy-safe failure classification (stable enum names only),
  policy-driven atomic `recordFailure`, bounded pruning (30-day terminal
  retention; pending work never pruned), stale-inFlight recovery and
  privacy-safe queue diagnostics. **No consumer, no remote write, no schema
  change, no migration — remote sync stays disabled.** Verdict upgraded to
  **READY FOR CONTROLLED REMOTE SYNC IMPLEMENTATION** (remote still gated by
  payload versioning, consumer, conflicts, Security Rules, App Check).
  Report: `docs/task-reports/TASK_073_LOCAL_SYNC_QUEUE_HARDENING.md`
- Next planned functional task: **TASK 083** — Today task UI (CP10). Open
  sequencing note for the owner: generation is still **not connected** to
  persistence or onboarding completion, and the roadmap names no dedicated
  task for that wiring between TASK 082 and TASK 083.

## Tests (verified at TASK 082)

- Flutter analyze: **clean** (0 errors, 0 warnings, 0 infos)
- Flutter test baseline: **1178 / 1178**, 0 failed, 0 skipped
  (1015 at TASK 081 + 163 Learn catalog/plan-item tests)
- Learn plan-item + catalog suite: **163 / 163** — command:
  `flutter test test/features/today/domain/learn_daily_plan_catalog_test.dart
  test/features/today/domain/learn_daily_plan_item_source_test.dart`
- Learn feature suite: **108 / 108** — command: `flutter test test/features/learn`
- Quran plan-item + composition suite: **70 / 70** — command:
  `flutter test test/features/today/domain/quran_daily_plan_item_source_test.dart`
- Quran feature suite: **89 / 89** — command: `flutter test test/features/quran`
- Prayer plan-item suite: **62 / 62** — command:
  `flutter test test/features/today/domain/prayer_daily_plan_item_source_test.dart`
- Daily plan generator suite: **63 / 63** — command:
  `flutter test test/features/today/domain/daily_plan_generator_test.dart`
- Onboarding profile-mapping suite: **78 / 78** — command:
  `flutter test test/features/today/domain/onboarding_profile_mapper_test.dart`
- DailyPlan state-machine suite: **43 / 43** — command:
  `flutter test test/features/today/application/daily_plan_controller_test.dart`
- DailyPlan persistence suite: **70 / 70** — command:
  `flutter test test/features/today/data`
- **Canonical sync-focused baseline: 70 / 70.** Exact command:
  `flutter test test/features/sync test/app/persistence_wiring_test.dart
  test/app/app_bootstrap_test.dart
  test/features/prayer/data/drift_prayer_log_repository_test.dart`
  — **`test/features/sync` alone is 52 / 52**; that figure is the sync
  directory in isolation and must never replace the official 70 baseline.
- Focused prayer-reminder suite: 26 / 26 (TASK 070D)
- Storage (Drift) tests: **11 / 11** — command: `flutter test test/core/storage`
- Functions tests (Vitest): **23 / 23** on Node.js 22.22.0 — last verified at
  TASK 075. **NOT re-run at TASK 082: Node.js is not installed on the current
  machine** (the Node install directory is still listed on `PATH` but no
  longer exists, so `node` and `npm` are unavailable).
  TASK 082 changed no Functions file, dependency or lockfile; Functions CI
  verifies this baseline on every PR.
- Android debug build: **SUCCESS** at TASK 075
  (`bismillah_app/build/app/outputs/flutter-apk/app-debug.apk`, 170.26 MB,
  SHA-256 `51ca8748877467b58f3b16368b6e5f23bac5eecdd7222e97595f5cc2764cde99`;
  not installed, no device test)
- Known non-blocking test warning: one `tap()` off-screen-offset warning in
  `bismillah_app/test/features/learn/learn_screens_test.dart` (test passes)
- Real-device: Quran main flows verified on **Samsung Galaxy A36 / Android 16**
- Real-device (TASK 071): combined notification candidate (22.1.0 + exact-alarm
  deep-link UX) fully validated on **Samsung Galaxy A36 / Android 16** — update-install,
  data preservation, inexact fallback, "Not now" flow, deep-link + real permission
  recheck, exact reschedule, replace/cancel, removed-from-recents, reboot restore, and
  **reboot physical delivery (exact on-time, single, tap OK, clean logcat)** all PASS.
  APK SHA-256 `a8d00a7f66ec6453104ba73076c9cd88750462c3470bf4cc0056738c252493e1`.
  This closes the reboot-delivery gap deferred by TASK 070B.
- iOS physical-device validation: **not performed (PENDING)**

## Stack

- Flutter `3.44.6` / Dart `3.12.2` (Node.js `22.22.0`, npm `10.9.4`;
  Android SDK 36.1.0, Gradle JDK 21)
- Riverpod (state/DI), GoRouter (routing)
- Drift (SQLite local DB) + SharedPreferences
- Firebase anonymous auth bootstrap; Firebase Cloud Functions
- GitHub Actions CI (Flutter CI + Functions CI)
- **Functions runtime baseline: Node.js 22** (raised from Node 20 in TASK 068)

## Persistence (current reality)

- **Drift** tables: `PrayerLogDays`, `PrayerEntries`, `SyncOperations`
  (schemaVersion 1; empty `onUpgrade` placeholder; no encryption)
- **SharedPreferences**: onboarding, Quran progress/bookmarks/preferences,
  Learn progress, Assistant history (cap 20), locale, reminders, session identity,
  **daily plans** (TASK 076)
- **Interim key-value adapters awaiting Drift** (canonical target is a Drift
  table per `11_LOCAL_DB` §3 — these are explicitly NOT the final architecture):
  - `bismillah.daily_plans` — per-day `DailyPlan` envelope, persistence
    version **1** (TASK 076). Future migration: read v1 envelope → insert one
    row per `DayKey` in a single transaction → verify counts/equality →
    remove envelope only after commit → roll back safely on failure.
    Payload/schema-versioning gate **G8** stays owned by **TASK 132**.
  - `bismillah.quran_daily_progress.*` — per-day Quran progress (TASK 047)

## Latest completed tasks

- TASK 063 — package_info_plus 10.2.1
- TASK 064 — Drift schema and persistence baseline
- TASK 065 — Merge Drift baseline
- TASK 066 — Drift official CLI toolchain alignment — **BLOCKED**
- TASK 067 — flutter-action v2.23.0
- TASK 068 — Node.js 22 Functions runtime and Functions CI (PR #9, merge `c847c4b`)
- TASK 068A — Permanent Claude project memory (PR #10, merge `c167454`)
- TASK 069 — fast-xml-parser 5.10.1 validated on Node.js 22 (Functions 23/23)
- TASK 070A — Android scheduled-notification manifest receiver contract + regression
  tests (PR #13; `flutter_local_notifications` unchanged at 22.0.1)
- TASK 070B — Samsung Galaxy A36 / Android 16 device validation of the manifest fix
  (reboot delivery deferred to TASK 071); merged via PR #13
- TASK 070C — flutter_local_notifications **22.1.0** (+ platform_interface 12.0.1)
  reapplied on the validated manifest baseline (PR #14, commit `93d1c86`)
- TASK 070D — exact-alarm permission deep-link UX with honest recheck + inexact
  fallback; TR/EN/AR copy; 6 new tests (PR #14, commit `50dacef`)
- TASK 071 — final Samsung A36 / Android 16 end-to-end validation incl. reboot
  physical delivery; PR #14 merged
- TASK 072 — sync-queue audit (docs-only): P0 = 0, P1 = 6, P2 = 4; queue producer
  (prayer log) atomic + tested (sync-focused 36/36); **no queue consumer exists**;
  remote sync currently **not enabled and not enabled-able** (no cloud_firestore)
- TASK 073 — local sync-queue hardening: backoff policy + failure taxonomy +
  recordFailure + pruning + stale-inFlight recovery + diagnostics (sync-focused
  70/70; full 629/629); closes the TASK 072 "no backoff/taxonomy" P1; remaining
  queue P1s: consumer stack, cloud_firestore + Rules/App Check, pull/conflicts,
  payload versioning, account linking
- TASK 074 — Firebase security readiness audit (docs-only): Rules/App Check/
  emulator suite/staging all ABSENT (P1 blockers before remote sync); the one
  deployed callable is auth-gated + validated + secret-managed, but runs EOL
  nodejs20 in the console (repo says nodejs22 — controlled redeploy pending);
  no tracked secrets; single dev Firebase project, Android+iOS apps registered
- TASK 075 — CP09 technical stabilization and full regression checkpoint
  (docs-only): all baselines re-run and reproduced (analyze clean, 629/629,
  70/70, 11/11, 23/23, debug APK build SUCCESS) with **no dependency or
  lockfile change**; authoritative 14-gate Firebase security order fixed
  (G1–G14); deployed `nodejs20` drift **re-verified** and promoted to a P1
  operational redeploy; npm advisories enumerated as **two independent
  chains** (5 high = `eslint` dev-only, never deployed; 8 moderate =
  `firebase-admin`/`firebase-functions` production tree; 0 critical; no
  non-breaking fix); payload-version migration (G8) confirmed to belong
  before consumer work and outside CP10. Verdict: **CP09 COMPLETE —
  TECHNICALLY STABLE**; product gate **READY TO ENTER NEXT LOCAL-FIRST
  PRODUCT CHECKPOINT** (TASK 076).
  Report: `docs/task-reports/TASK_075_CP09_TECHNICAL_STABILIZATION_CHECKPOINT.md`
- TASK 076 — DailyPlan local persistence (CP10 opens): first implementation of
  the existing `DailyPlanRepository` (`getPlan`/`watchPlan`/`savePlan`/
  `getRange`) via `SharedPrefsDailyPlanRepository` + `DailyPlanEnvelopeCodec`;
  canonical **per-day** model preserved (30-day frame = 30 records); the
  brief's conflicting 30-day snapshot model was rejected with owner approval;
  typed corruption failures, no silent overwrite, no auto-regeneration;
  privacy-minimal payload (6 canonical fields); full local reset already
  clears the envelope via the `bismillah.` prefix (no reset change needed).
  **Zero tracked files modified — new files only.**
  Report: `docs/task-reports/TASK_076_DAILY_PLAN_LOCAL_PERSISTENCE.md`
- TASK 077 — DailyPlan state machine: `DailyPlanController` +
  sealed `DailyPlanState` (Loading/Empty/Available/Corrupt/Failure); epoch
  counter blocks stale reads/writes/watch events; latest-valid-completion-wins
  save rule; `watchPlan` subscription owned by the controller and cancelled on
  day switch and disposal; bootstrap never instantiates or loads it. Added
  `StorageCorruptionFailure` (approved §10 gate correction) — failure mapping
  inspects **type only**, never `messageKey` or exception text.
  Report: `docs/task-reports/TASK_077_DAILY_PLAN_STATE_MACHINE.md`
- TASK 078 — Onboarding profile mapping: `DailyPlanProfileType` (8 buckets,
  stable IDs) + pure `OnboardingProfileMapper` over the real
  `OnboardingPreferences`; sealed result **Mapped / Incomplete** only
  (`Invalid` and `Contradictory` deliberately omitted as unreachable in the
  current model); stable neutral rule IDs (`journey_beginner`, `pace_low_time`,
  `focus_prayer`…); enum-coverage locks fail the suite if a new profile or
  focus goal is left unmapped; no provider added (pure static utility, so
  bootstrap cannot invoke it).
  Report: `docs/task-reports/TASK_078_ONBOARDING_PROFILE_MAPPING.md`
- TASK 079 — Deterministic daily plan generator: `DailyPlanGenerationRequest`
  (+ typed `GenerationRequestIssue`: `emptyGoals`, `profilePaceMismatch`),
  `DailyPlanGenerator`, and the extensible `DailyPlanItemSource` /
  `DailyPlanDayContext` / `PlanItemDraft` / `EmptyDailyPlanItemSource` /
  `DailyPlanItemIdBuilder`. Request validation rejects profile×pace
  combinations TASK 078 could never produce; the generator **never re-runs**
  the profile mapper. Local calendar arithmetic only (`DateTime(y, m, d+n)`) —
  no UTC conversion, no `Duration(hours: 24)`, DST-safe. Failures reuse
  existing types (`ValidationFailure`/`UnexpectedFailure`) — **no new
  `AppFailure` subtype and no new localization key**; source failures propagate
  unchanged and **partial plans are never returned**. No provider (pure static
  service, like the TASK 078 mapper).
  Report: `docs/task-reports/TASK_079_DETERMINISTIC_DAILY_PLAN_GENERATOR.md`
- TASK 080 — Prayer plan items: `PrayerDailyPlanItemSource` (const, stateless,
  pure; reads only `DailyPlanDayContext.goals`). Stable template IDs
  `prayer_track_daily` / `prayer_on_time_daily`; fixed order via an **explicit
  ordered list** (never `Set`/enum/map order). Source is **total** — no
  unreachable failure branch was fabricated. **No source composition was
  added**: the generator still takes a single source and Prayer is passed
  directly; composition arrives when **TASK 081** first needs Prayer → Quran →
  Learn together.
  Report: `docs/task-reports/TASK_080_PRAYER_PLAN_ITEMS.md`
- TASK 081 — Quran plan items + `CompositeDailyPlanItemSource`: composition
  arrived exactly where TASK 080 predicted. Composite is `const`, pure,
  order-from-constructor-list, one call per child per day; duplicate
  detection is scoped **across children only** (a single source repeating a
  template stays its own decision — TASK 079's `slot` already separates final
  identities). Quran source is `const`, stateless and **total**; no
  unreachable failure branch was fabricated.
  Report: `docs/task-reports/TASK_081_QURAN_PLAN_ITEMS.md`
- TASK 082 — Source-verified Learn plan items + `CoreDailyPlanItemSource`:
  the **three core item sources are now complete**. Learn is the first source
  that attaches a real content reference, so eligibility is re-derived from
  the actual assets on every test run (published + `sourceBodyVerified` +
  publication gate + registered source + TR/EN/AR parity) rather than trusted
  from a hard-coded list. The catalog is an explicit ordered value type, not
  a derived query: JSON file order, localized title sort, runtime locale and
  map iteration are all proved **not** to define plan order. Template ID is a
  **lossless** `learn_article_<articleId>` concatenation — no normalization,
  no `hashCode`, no hashing dependency, and article IDs are verified free of
  the `:` separator used by `DailyPlanItemIdBuilder`. Typed
  `LearnPlanCatalogIssue` mirrors TASK 079's `GenerationRequestIssue`, so
  **no new `AppFailure` subtype and no new localization key** were needed.
  `CoreDailyPlanItemSource` is a `const` value plus a pure `withCatalog`
  factory — deliberately **not** a provider, singleton or bootstrap hook.
  Report: `docs/task-reports/TASK_082_LEARN_PLAN_ITEMS.md`

## Plan content reality (fixed by TASK 079)

Of the six `PlanItemType` categories, only **`quran`** (bundled Tanzil +
QuranEnc) and **`lesson`** (`assets/content/learn/`, 30 published, source
verified) have real content. **`dhikr`, `dua` and `reflection` have none** —
`features/dhikr` and `features/dua` contain domain entities and repository
*interfaces* only, with no implementation, data source or asset. No plan
template/catalog structure exists in `lib/`. TASK 079 therefore generates the
30-day frame with **empty `items`**; approved content sources arrive in
**TASK 080 (Prayer) · TASK 081 (Quran) · TASK 082 (Learn)**. Content for
dhikr/dua/reflection remains an **open owner decision** — do not invent it.

**TASK 080 update:** the prayer slice is done and needed **no content at all** —
prayer items are app *tracking* actions carrying only a stable template ID, with
`targetRef`/`sizeParam` null (no prayer name, no prayer count). Quran and Learn
(TASK 081/082) do have real bundled content to reference by ID.

**TASK 081 update:** the Quran slice also needed **no content**. Although
bundled Quran content exists, the Quran item is a neutral *continuation*
action — no surah/ayah/juz/page/translation/reciter/audio and no reading
quantity is assigned, and no Quran repository is read. Resolving a concrete
reading position remains a later orchestration/content decision.

**TASK 082 update:** the Learn slice is the **first and only** source that
references real content IDs, and it needed **no new content** — the existing
30 published articles were exactly enough. Eligibility (published +
`sourceBodyVerified` + publication gate + registered source + TR/EN/AR
identity parity) is re-derived from the actual assets by test on every run.
The **2** `scholarlyReviewPending` articles (`art-kuran-okumaya-baslangic`,
`art-dua-adabi`) are excluded and proved absent from the catalog. Only the
stable article ID enters the plan — **no title, summary, body, translation or
source text**. **All three core item sources are now complete;** `dhikr`,
`dua` and `reflection` still have no approved content and remain an open
owner decision — do not invent it.

## Onboarding model reality (fixed by TASK 078)

The shipped onboarding is **three screens** (goals · journey stage · daily
pace), persisted as `OnboardingPreferences` under `bismillah.onboarding_*`
keys. The 16-question `OnboardingAnswers` model, `OnboardingGoal`,
`PersonalizationProfile` and `OnboardingRepository` are **UNUSED / FUTURE
EXTENDED ONBOARDING SCAFFOLDING** — never constructed, persisted or
referenced. Do not present them as active inputs, and do not map from them.
The historical "justBeginning skips the prayer-frequency question" skip rule
belongs to that unimplemented spec: **the current flow has no
prayer-frequency question**, so there is no skip or stale-answer handling to
implement.

## Firebase security gate order (authoritative — TASK 075)

Remote sync stays disabled until **all** of G1–G14 are satisfied, in order:
G1 staging environment + aliases + wrong-project guard · G2 Firestore section
in `firebase.json` · G3 Firestore Security Rules · G4 Rules unit tests ·
G5 Emulator Suite in CI · G6 server-side UID ownership · G7 App Check ·
G8 operation payload/schema versioning · G9 queue consumer + `cloud_firestore` ·
G10 remote idempotency · G11 conflict policy · G12 tombstone semantics ·
G13 account-link contract · G14 monitoring/budget/kill switch.

Roadmap owners: G3/G4/G6 → TASK 133 · G7 → TASK 134 · G9–G12 → TASK 132 ·
G13 → TASK 131. **G1, G2, G5, G8 and G14 have no task number yet** — assigning
them is an owner decision; TASK 075 deliberately invented no numbers.

## Open / known dependency status

- PR #4 — Drift 2.34.2 — **DEFERRED, must not be merged** (blocked by TASK 066
  toolchain incompatibility; TASK 075 added a second reason: `drift_dev` is
  capped at 2.34.0, so merging would desynchronise `drift` from `drift_dev`)
- Dependabot branch `dependabot/pub/bismillah_app/cloud_functions-6.3.4` —
  **UNRECORDED / NEEDS TRIAGE** (found at TASK 075; PR state UNVERIFIED
  because `gh` is not installed on the current machine)
- `flutter pub outdated` at TASK 075: **39** outdated (5 direct, 2 direct dev,
  27 transitive, 5 transitive dev). Direct: `flutter_local_notifications`
  22.1.0→22.2.0 (deliberately held at the device-validated 22.1.0),
  `drift` 2.34.1→2.34.2 (PR #4), `cloud_functions` 6.3.3→6.3.5,
  `firebase_auth` 6.5.4→6.5.6, `firebase_core` 4.12.0→4.12.1.
  **No update is required to pass CP09**; none applied.
- npm audit (Functions, TASK 075): **13 total — 0 critical, 5 high, 8
  moderate**, all transitive root advisories, **no non-breaking fix**.
  Chain A (all 5 high): `eslint` devDependency → … → `brace-expansion` —
  lint/build time only, **never deployed**. Chain B (all 8 moderate):
  `firebase-admin`/`firebase-functions` → … → `uuid` — **present in the
  deployed runtime tree**. Both need a major upgrade in a separate gated
  task; `firebase-admin` v14 must precede any remote-sync deployment.
- PR #6 — fast-xml-parser 5.10.1 — **SUPERSEDED** by TASK 069 (applied on the
  current Node.js 22 baseline; `fast-xml-parser 5.10.1`, `@nodable/entities 3.0.0`)
- actions/checkout v7 major — **DEFERRED**
- PR #3 — flutter_local_notifications 22.1.0 — **SUPERSEDED** by PR #14 (TASK 070C
  applied the same update on the validated manifest + exact-alarm UX baseline)
- Local branch `task/070-notifications-22-1-0` (local commit `a05f439`) — historical;
  superseded by the TASK 070C reapply, kept unpushed and untouched
- TASK 070 (original notification-update task) — **SUPERSEDED** by TASK 070A after a
  pre-existing Android manifest gap (missing scheduled-notification receivers) was found

## TASK 066 blocker (root cause)

- `drift_dev >= 2.34.1` requires `analyzer ^13.0.0`.
- Flutter 3.44.6's SDK-pinned test toolchain caps `analyzer < 13`.
- The Flutter SDK will not be upgraded solely to fix the Drift CLI.
- The TASK 064 runtime SQL snapshot remains the interim schema baseline.
