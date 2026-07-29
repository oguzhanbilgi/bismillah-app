# Checkpoint History

Short, verified history of major checkpoints. Exact TASK 001–060 titles are not
individually reconstructable from Git history and are not invented here.

## Foundation phase (early tasks)

- **Scope:** Flutter foundation and architecture, five-tab navigation, TR/EN/AR +
  RTL localization, onboarding.
- **Verified result:** app scaffold, shell, routing, and onboarding gate in place.
- **Test baseline:** grew incrementally (superseded by later baselines).
- **Device validation:** none recorded at this stage.
- **Remaining gaps:** most product features not yet built.

## Quran checkpoint

- **Scope:** Tanzil reader, QuranEnc Turkish translation, offline search + verse
  reference + Ayetel Kürsi alias, bookmarks, resume, device-local reading progress,
  reciter selection, MP3Quran audio, app-wide mini-player, Android background /
  media-notification / lock-screen playback.
- **Verified result:** Quran is the most mature feature.
- **Device validation:** Samsung Galaxy A36 / Android 16 (audio/background/lock-screen/search/reader).
- **Remaining gaps:** iOS background audio unverified.

## Learn / Profile / Assistant checkpoint

- **Scope:** Learn source model + publication gate (`sourceBodyVerified` + locator +
  evidence); Profile (personalization, sources, privacy/reset, About); deterministic
  local Assistant (published-only retrieval, citations, fatwa refusal).
- **Verified result:** engines work; Learn coverage is thin (9 of 20 categories).
- **Remaining gaps:** broader verified Learn corpus; official-answer index.

## Public alpha

- **Scope:** licenses, attribution, content policy, public docs, CI, public
  visibility, tag `v0.1.0-alpha.1`.
- **Verified result:** repository public; prerelease published (no binaries).
- **Remaining gaps:** screenshots; internal aspirational docs still present.

## Dependency stabilization

- **Scope:** dependency triage (PRs #1–#6); master project audit; package_info_plus
  10.2.1 (TASK 063); Drift persistence baseline + merge (TASK 064/065);
  flutter-action v2.23.0 (TASK 067).
- **Verified result:** 586/586 Flutter tests; 11/11 storage tests.
- **Blocked:** TASK 066 (Drift official CLI toolchain vs analyzer 13).

## CP09 — technical stabilization (CLOSED at TASK 075)

Test counts quoted inside individual task bullets below are the baselines *at
that task's time*; the current verified baseline lives in
`docs/project-state/CURRENT_BASELINE.md`.

- **Scope:** Node.js 22 Functions runtime + Functions CI (TASK 068); permanent
  Claude project memory (TASK 068A); fast-xml-parser 5.10.1 validation (TASK 069).
- **Verified result:** Functions on Node 22; Functions CI (npm ci / lint / build /
  vitest) green; **23/23** Functions tests; **586/586** Flutter tests.
- **TASK 069:** transitive `fast-xml-parser 5.10.0 → 5.10.1` (with
  `@nodable/entities 2.2.0 → 3.0.0`) applied on the current Node.js 22 baseline;
  optional dependency via `@google-cloud/storage` (not imported by Functions
  source); npm ci and engine-strict npm ci passed; lint/build/tests **23/23**;
  Dependabot PR #6 superseded.
- **TASK 070 / 070A / 070B (notifications):** the planned 22.1.0 update (TASK 070)
  surfaced a pre-existing Android manifest gap — the app never declared
  `flutter_local_notifications`'s `ScheduledNotificationReceiver` /
  `ScheduledNotificationBootReceiver`, so scheduled reminders could not fire.
  TASK 070A added those receivers + `RECEIVE_BOOT_COMPLETED` and manifest-contract
  regression tests (Flutter tests **586 → 589**), with **no** dependency change
  (stayed 22.0.1). TASK 070B validated the fix on a real **Samsung Galaxy A36 /
  Android 16** device (source `074ec01`): update-install with data preservation,
  notification + exact-alarm permission flows, live removed-from-recents delivery,
  replace/cancel, and **reboot restore without opening the app** all PASS; **reboot
  notification delivery was DEFERRED / not observed** (owner-approved risk, to be
  re-verified in TASK 071). Merged via PR #13.
- **TASK 070C / 070D / 071 (notifications, PR #14):** `flutter_local_notifications
  22.0.1 → 22.1.0` (+ platform_interface 12.0.1) reapplied on the validated manifest
  baseline (070C); exact-alarm permission deep-link UX added — calm TR/EN/AR dialog,
  direct "Alarms & reminders" screen, real capability recheck on return, honest
  inexact fallback, 6 new tests (focused **26**, full **595**) (070D). TASK 071
  validated the combined APK end-to-end on **Samsung Galaxy A36 / Android 16**:
  update-install + data preservation, inexact fallback, "Not now", deep-link +
  recheck + exact reschedule, replace/cancel, removed-from-recents, reboot restore,
  and **reboot physical delivery** (exact on-time at prayer minute, single
  notification, tap OK, clean logcat) — closing the gap TASK 070B had deferred.
  PR #14 merged; Dependabot PR #3 superseded.
- **TASK 072 (sync-queue audit, docs-only):** the local queue is durable, atomic
  (prayer-log save + enqueue in one Drift transaction), idempotency-keyed,
  uid-owned, merge-bounded, startup-recovered and reset-cleared — verified by
  36/36 sync-focused tests. **No consumer/SyncEngine exists, `cloud_firestore`
  is not a dependency, pull/conflict/tombstone are spec-only.** Verdict:
  **READY FOR LOCAL QUEUE HARDENING ONLY** (P0 0 / P1 6 / P2 4); remote sync
  must stay disabled until the CP16 stack (engine, Security Rules, App Check).
  TASK 073 redefined as the local hardening slice (backoff policy, error
  taxonomy, pruning, diagnostics; no remote writes).
- **TASK 073 (local sync-queue hardening):** deterministic retry/backoff
  (staged delays, FNV-1a-seeded bounded jitter, 24h cap, attempt-8 quarantine,
  slow auth-unavailable schedule, conservative unknown rule), privacy-safe
  failure classification (stable enum names only in `lastErrorCode`),
  policy-driven atomic `recordFailure`, bounded pruning (30-day terminal
  retention; pending work never pruned by age), stale-inFlight recovery and a
  privacy-safe diagnostics summary. **No consumer, no remote write, no schema
  change, no migration; remote sync stays disabled.** Sync-focused tests
  **36 → 70**, full suite **595 → 629**, Functions 23/23. Verdict upgraded to
  **READY FOR CONTROLLED REMOTE SYNC IMPLEMENTATION** (remote still gated by
  payload versioning, consumer stack, conflicts, Security Rules, App Check).
- **TASK 074 (Firebase security readiness audit, docs-only):** repo Firebase
  footprint is minimal and clean — anonymous-auth bootstrap with local
  fallback; one callable (auth-required, validated, Secret Manager, sanitized
  logs, maxInstances 5). **Rules, Rules tests, App Check, emulator suite and
  staging separation are all ABSENT** (P1 blockers before any remote sync);
  read-only CLI shows the deployed callable still on **EOL nodejs20** vs repo
  nodejs22 (controlled redeploy pending); secret scan clean. Verdict:
  **READY FOR LOCAL SECURITY HARDENING ONLY** (P0 0 / P1 6 / P2 5); remote
  sync remains disabled.
- **TASK 075 (CP09 full regression checkpoint, docs-only):** every recorded
  baseline was re-run on the verified toolchain (Flutter 3.44.6 / Dart 3.12.2
  / Node 22.22.0 / npm 10.9.4) and reproduced exactly — analyze **clean**
  (0/0/0), Flutter **629/629**, canonical sync-focused **70/70**, Drift
  storage **11/11**, Functions **23/23**, and an Android debug APK build
  **SUCCESS** — with `pubspec.yaml`, `pubspec.lock`, `package.json` and
  `package-lock.json` all **unchanged** after full resolution. Two findings
  refined earlier documentation: (a) the npm advisory picture is **two
  independent chains** — all **5 high** sit under `eslint` (devDependency,
  lint/build time only, never deployed) and all **8 moderate** under
  `firebase-admin`/`firebase-functions` (production, inside the deployed
  tree), 0 critical, **no non-breaking fix** for either; (b) the deployed
  callable was **re-verified as `nodejs20`** against a repo declaring
  `nodejs22`, promoting the controlled redeploy from an observation to a
  verified **P1**. The authoritative 14-gate Firebase security order
  (G1–G14) was fixed, with G3/G4/G6 → TASK 133, G7 → TASK 134, G9–G12 →
  TASK 132, G13 → TASK 131, and **G1/G2/G5/G8/G14 explicitly unnumbered**
  (owner decision; no task number was invented). Payload/schema versioning
  (G8) was confirmed to belong **before consumer work and outside CP10**.
  Remote sync re-verified disabled: no `cloud_firestore`, no pattern match in
  `lib/features/sync`, and **no production caller** of any queue-draining
  method. **P0 = 0 · P1 = 15 · P2 = 12 · deferred = 5.** Verdict:
  **CP09 COMPLETE — TECHNICALLY STABLE**; product gate: **READY TO ENTER
  NEXT LOCAL-FIRST PRODUCT CHECKPOINT**.
- **Device validation:** Android (Quran) done; Android notification stack fully
  validated on A36 incl. reboot delivery; iOS PENDING. TASK 075 built a debug
  APK for build-health only — **not installed, no device test**.
- **Remaining gaps (CP09):** none blocking. CP09 is **closed**; CP10 began at
  **TASK 076 — DailyPlan repository and local persistence**. Carried forward:
  PR #4 (Drift 2.34.2) DEFERRED, TASK 066 BLOCKED, iOS validation PENDING,
  remote sync gated by G1–G14, and monitored npm/pub dependency debt.

## CP10 — Today and 30-day personal plan (in progress)

- **TASK 076 (DailyPlan local persistence):** the existing
  `DailyPlanRepository` contract (`getPlan` / `watchPlan` / `savePlan` /
  `getRange`) received its **first real implementation**. A model conflict was
  found and resolved before any code was written: the task brief specified a
  *single active 30-day snapshot*, which contradicts `10_DATA_MODEL` §4/§5/§7
  ("**Bir günün planı**"; `dayKey`-keyed; `users/{uid}/plans/{dayKey}`;
  item-level completed-wins), `11_LOCAL_DB` §3 and the code already present.
  Work stopped and reported; the owner approved **Option A — preserve the
  canonical per-day model**. A 30-day plan is therefore a **composition of 30
  per-day records**, and **no second DailyPlan abstraction was added**.
  Persistence is a **temporary versioned key-value envelope** (version **1**,
  single key `bismillah.daily_plans`, deterministic `DayKey` ordering, stable
  enum names) documented in-source as *TEMPORARY LOCAL ADAPTER — MIGRATION
  REQUIRED*; the canonical target remains a Drift table, blocked today by the
  TASK 066 toolchain and the G8 migration gate (owned by **TASK 132**).
  Corruption — invalid JSON, missing/wrong/unsupported version, bad `DayKey`,
  key/field mismatch, unknown enum, duplicate item ID, read/write failure —
  yields **typed `StorageFailure`** only: never a crash, never a silent
  overwrite, never auto-deletion or auto-regeneration, and never raw payload
  in error output. Full local reset already clears the envelope through the
  existing `bismillah.` prefix rule, so **no reset code changed**.
  **67 new focused tests**; full suite **629 → 696**; canonical sync 70/70;
  Drift storage 11/11; Functions 23/23; analyze clean. **Zero tracked files
  modified** — no Drift schema, dependency, generation, Today UI, Firebase
  write or remote-sync change; remote sync stays disabled.
- **TASK 077 (DailyPlan state machine):** the application layer that consumes
  TASK 076's repository. `DailyPlanController` (`Notifier<DailyPlanState?>`)
  selects one `DayKey` and moves it through a sealed **Loading · Empty ·
  Available · Corrupt · Failure** model, where calm situations are data rather
  than errors (`PrayerTimesState` precedent). Because `watchPlan` does not
  replay the stored value on subscribe, the controller combines an explicit
  `getPlan` with a live subscription and resolves the resulting race with a
  **generation (epoch) counter** (`QuranSearchController` idiom): a late read,
  save or old-day watch event can never overwrite newer state. Save
  concurrency follows **latest valid completion wins** — an older *failed*
  save cannot replace a newer success. Exactly one watch subscription exists
  per controller, cancelled on day switch and on disposal; bootstrap neither
  instantiates nor loads it (verified with a recording repository).
  A genuine contract defect was found first and reported at the stop gate:
  the repository returned an identical `StorageFailure()` for corrupt stored
  data and for ordinary I/O errors, so the required Corrupt/Failure split was
  impossible without parsing error text. The owner approved the minimum fix —
  a sibling **`StorageCorruptionFailure`** reusing `errorStorage`. **No
  method signature, localization key, envelope version (still 1), storage key
  or persistence format changed**, and no exhaustive `AppFailure` switch
  existed to break. Failure→state mapping inspects **type only**. TASK 076
  persistence tests were *strengthened* 67 → **70** (corruption now demands
  the new type; caller-validation errors explicitly are **not** corruption).
  **43 new state-machine tests** (including six deterministic race tests using
  per-call gates); full suite **696 → 742**; canonical sync 70/70; Drift
  storage 11/11; Functions 23/23; analyze clean. **No generation, no Today UI,
  no Firebase write, no Drift/schema/dependency change; remote sync stays
  disabled.**
- **TASK 078 (onboarding profile mapping):** the eight canonical profile
  buckets named in `04_ONBOARDING_FLOW` §10 finally became a typed
  `DailyPlanProfileType` with stable IDs (`beginner`, `returning`,
  `prayer_focused`, `quran_focused`, `dhikr_focused`, `learning_focused`,
  `advanced`, `low_time`) — fulfilling the note in `personalization_profile.dart`
  that the buckets would be enumerated by the personalization task. **Eight,
  not nine.**
  A second stop gate fired first: doc §474 derives the profile from
  `growthGoal` → `prayerRoutine`/`quranHabit` → `dailyTime` → `mainStruggle`,
  but the shipped onboarding is a **three-screen flow** and collects none of
  those. The 16-question `OnboardingAnswers` model, `OnboardingGoal`,
  `PersonalizationProfile` and `OnboardingRepository` were found to be
  **unused scaffolding** — never constructed, persisted or referenced. The
  owner approved **Option A**: map from the really implemented
  `OnboardingPreferences` (goals · journeyStage · dailyPace), leaving the
  onboarding UI and persistence untouched.
  The **axis precedence and multi-goal tie-break are an approved TASK 078
  product decision, not inherited from the old specification**:
  `justBeginning`→beginner (outranks pace, so a light-pace beginner stays
  beginner) · `rebuildingRoutine`→returning · `strengtheningRoutine`+`focused`
  →advanced (never inferred from goals alone) · `light`→low_time (a scheduling
  constraint, never a religious judgment) · else goals in the fixed order
  prayer→quran→dhikr→learning. `completedAtUtc` never affects classification.
  The sealed result has only **Mapped** and **Incomplete**; `Invalid` and
  `Contradictory` were deliberately **not** created because the current model
  cannot represent them — multi-goal and stage+pace combinations are
  legitimate, not contradictions. The historical "justBeginning skips the
  prayer-frequency question" rule was documented as inapplicable: that
  question does not exist in the current flow, so no fake skip logic was
  written. The mapper is pure — no Ref, storage, Firebase, clock, locale,
  timezone or randomness — and logs nothing.
  **78 new tests** (per-profile reachability plus **enum-coverage locks** that
  fail the suite if a future profile or focus goal is left unmapped, full
  3 × 3 × 5 grid determinism, tie boundaries, privacy and neutrality checks);
  full suite **742 → 820**; TASK 077 43/43; persistence 70/70; canonical sync
  70/70; Drift storage 11/11; Functions 23/23; analyze clean. **Zero tracked
  files modified** — no generation, Today UI, onboarding UI, persistence,
  Drift, Firebase or remote-sync change.
- **TASK 079 (deterministic daily plan generator):** a third stop gate fired
  before implementation. Three of the six `PlanItemType` categories —
  **`dhikr`, `dua` and `reflection` — have no content at all** (domain
  entities and repository *interfaces* only; `assets/content/` holds only
  `learn/`), and no plan template/catalog structure exists anywhere in `lib/`.
  Producing items would have meant inventing worship prescriptions, which
  `DO_NOT_BREAK` forbids. Two further conditions fired: the docs' four-bucket
  `dailyTime` (5/10/20/30) has no canonical mapping to the shipped three-value
  `OnboardingDailyPace`, and `weekIndex` had no defined semantics (domain
  enforces only `>= 0`; "four-week curve" vs. 30 ÷ 7 = five buckets). The
  roadmap itself resolved the scope — Prayer/Quran/Learn plan items are
  **TASK 080/081/082**, *after* 079 — and the owner approved **Option B**:
  build the generation skeleton plus an extensible item-source contract.
  Delivered: `DailyPlanGenerationRequest` (profile · goals · pace · start
  `DayKey`; typed `GenerationRequestIssue`), `DailyPlanGenerator`, and
  `DailyPlanItemSource` / `DailyPlanDayContext` / `PlanItemDraft` /
  `EmptyDailyPlanItemSource` / `DailyPlanItemIdBuilder`. Output is exactly
  **30 per-day `DailyPlan` records** with continuous local `DayKey`s —
  `DateTime(y, m, d+n)` arithmetic only, so month/year/leap/DST transitions
  cannot shift a day. **Approved TASK 079 product decisions:** pace budget
  `light` 5 · `balanced` 10 · `focused` 20 · **`advanced`+`focused` → 30**
  (the only profile-specific override; 15 never produced), and a zero-based
  **four-phase** `weekIndex` (0–6→0, 7–13→1, 14–20→2, **21–29→3**; days 29–30
  stay in phase 3, index 4 never produced, distribution 7/7/7/9). Request
  validation rejects profile×pace pairs TASK 078 could not produce, and the
  generator **never re-runs** the profile mapper. With the default empty
  source, 30 fully valid plans carry **empty `items`** — explicitly not a
  failure. Item identity is `rule-engine-v1:<dayKey>:<templateId>:<slot>`:
  no random UUID, timestamp, `hashCode` or device value. Failures reuse
  existing types — **no new `AppFailure` subtype, no new localization key** —
  source failures propagate unchanged and **partial plans are never
  returned**. **63 new tests**; full suite **820 → 883**; TASK 078 78/78;
  TASK 077 43/43; persistence 70/70; canonical sync 70/70; Drift storage
  11/11; Functions 23/23; analyze clean. **Zero tracked files modified** — no
  persistence write, Today UI, Drift, Firebase or remote-sync change, and **no
  religious content invented**.
- **TASK 080 (prayer plan items):** the **first approved
  `DailyPlanItemSource`**, and the first CP10 task with **no stop gate** — the
  representation gate passed cleanly. `PrayerDailyPlanItemSource` emits
  `prayer_track_daily` and/or `prayer_on_time_daily` purely from the user's own
  onboarding goals (`trackPrayers` / `prayOnTime`), always tracking first, each
  costing **1 estimated in-app interaction minute** — explicitly *not* prayer
  duration, a religious minimum, a ruling, worship value or spiritual rank.
  The gate passed **without any domain change**: the two actions are
  distinguished by their stable `templateId`, which TASK 079's
  `DailyPlanItemIdBuilder` already composes into the final item identity
  (`rule-engine-v1:<dayKey>:<templateId>:<slot>`), so no field was overloaded
  and no localization key, persistence field, envelope-version or Drift change
  was needed.
  **Approved TASK 080 product decisions:** items derive from **goals, never
  from the profile** (`prayer_focused` adds nothing by itself, `prayOnTime`
  does not imply `trackPrayers`, unrelated goals change nothing, no prayer goal
  ⇒ empty list which is not a failure); a fixed contribution order declared as
  an **explicit ordered list** (never `Set`/enum/map iteration order); 1 minute
  per item; and **no progression-phase escalation** — contribution is identical
  across all eight profiles and all four phases, with no beginner discount,
  advanced quota, recovery week or streak requirement invented.
  Hard boundaries held: **no prayer-time calculation, no location access, no
  notification scheduling, no `PrayerLogDay` read, no completion inference**;
  `targetRef` and `sizeParam` stay null so no prayer name and no prayer count
  is ever claimed. The source is pure, `const`, stateless, logs nothing, and is
  **total** — an unreachable failure branch was deliberately not fabricated.
  Per the task's own rule, **no source composition was added**: the generator
  still accepts a single source and Prayer is passed directly; composition
  (Prayer → Quran → Learn) arrives with **TASK 081**, the first task needing
  multiple concurrent sources.
  **62 new tests** (goal selection, ordering, template and final-item identity,
  budget across all eight profile×pace combinations including the tightest
  5-minute `light`, profile and phase independence with an **enum coverage
  lock**, 30-day integration over four goal scenarios with 50-repeat
  determinism, and religious-safety/privacy assertions that no prayer name,
  coordinate, UID or judgmental token ever appears); full suite **883 → 945**;
  TASK 079 63/63; TASK 078 78/78; TASK 077 43/43; persistence 70/70; canonical
  sync 70/70; Drift storage 11/11; prayer feature suite 24/24; Functions 23/23;
  analyze clean. **Zero tracked files modified.**
- **TASK 081 (Quran plan items + ordered source composition):** the second
  approved `DailyPlanItemSource` and the first task needing two concurrent
  sources, so composition arrived exactly where TASK 080 predicted. The
  representation gate passed cleanly again — `targetRef`/`sizeParam` are
  optional nullable on both `PlanItemDraft` and `PlanItem`, so **no domain,
  localization, persistence, envelope-version or Drift change** was needed.
  `QuranDailyPlanItemSource` emits a single neutral **continuation/tracking**
  action `quran_continue_daily` when — and only when — the existing
  `quranHabit` goal is selected (absent ⇒ empty list, not a failure), costing
  **2 estimated in-app interaction minutes**, explicitly *not* a required
  reading duration, religious minimum, ruling, reward or rank. Notably the
  Quran slice **also needed no content**: despite bundled Quran content
  existing, **no surah, ayah, juz, page, translation text, reciter, audio URL
  or reading/listening quantity is assigned**, and none of the 13 Quran
  repository interfaces, progress, saved verses or audio is read — resolving a
  concrete reading position stays a later orchestration decision.
  `CompositeDailyPlanItemSource` is `const`, pure and takes an **explicitly
  ordered** child list: order comes from the constructor list (never runtime
  type, class name, `Set` storage or map iteration), each child is called
  **once per day**, and contributions concatenate in the approved
  **Prayer → Quran → Learn** order — a deterministic product rule, **not** a
  religious ranking. The first typed child failure propagates and **earlier
  contributions are discarded** (no partial list); duplicate template IDs
  **across children** are rejected via the existing
  `ValidationFailure` — **no new `AppFailure` subtype and no new localization
  key**; a single source repeating a template internally remains its own
  decision because TASK 079's `slot` already separates final identities; an
  empty child list yields an empty success. Because the composite implements
  the same single-source interface, **`DailyPlanGenerator` needed no change**,
  and since Learn will append *after* Quran, existing Prayer (slots 0, 1) and
  Quran (slot 2) final IDs **cannot shift** — asserted by a test that appends a
  third source. Contribution is identical across all eight profiles and all
  four phases, with no beginner quota, advanced quantity or phase-based ayah
  escalation.
  **70 new tests** (goal selection, template identity, PlanItem representation,
  profile/phase independence with an **enum coverage lock**, composition
  ordering including reversed-constructor and third-source-append cases,
  composite failure and duplicate handling, budget across all eight
  profile×pace combinations including the tightest 5-minute `light` holding all
  three items, six 30-day scenarios with 50-repeat determinism, and
  religious-safety/privacy assertions that no scripture, translation,
  assignment, coordinate or UID ever appears); full suite **945 → 1015**;
  TASK 080 62/62; TASK 079 63/63; TASK 078 78/78; TASK 077 43/43; persistence
  70/70; canonical sync 70/70; Drift storage 11/11; **Quran feature suite
  89/89** (measured, not assumed); Functions 23/23; analyze clean. **Zero
  tracked files modified.**
- **TASK 082 — Source-verified Learn plan items (CP10).** The **third and
  final core `DailyPlanItemSource`**, and the **only** one that references
  real content. The content stop gate passed with **no content change**: the
  shipped Learn assets already hold **exactly 30** articles that are
  `published`, carry a `sourceBodyReview` verification record satisfying the
  publication gate, reference a registered official source, and exist under
  **identical stable IDs in TR, EN and AR**. The two `scholarlyReviewPending`
  articles (`art-kuran-okumaya-baslangic`, `art-dua-adabi`) carry only a
  `urlExistenceCheck` record and are **excluded and proved absent** from the
  catalog. Nothing was padded, duplicated, weakened or newly authored, and
  **no article asset was edited**. Eligibility is **re-derived from the real
  assets by test on every run**, so the catalog breaks if an article is
  unpublished, removed, loses a locale or loses source metadata.
  `LearnDailyPlanCatalog.v1` is an **immutable, explicit, versioned 30-entry**
  catalog holding only stable article IDs — no title, summary, body,
  translation, source text, locale, date, UID or device data. Entries **0–10
  are source-backed**: the already-existing editorial `beginnerPathOrder`
  field, published members only, ascending. Entries **11–29 are an approved
  TASK 082 product decision**: the remaining 19 grouped by the existing
  `categories.json` `sortOrder` (purity → prayer → fasting → zakat → hajj)
  with the within-group sequence written explicitly. Plan order is proved
  **not** to be JSON file order, any localized title sort, runtime locale or
  map iteration. `LearnDailyPlanItemSource` is `const`, pure and stateless
  apart from the injected catalog: it emits **one** `PlanItemType.lesson` item
  per day when — and only when — `islamicKnowledge` is selected (absent ⇒
  empty list, not a failure), costing **1 estimated in-app interaction
  minute**, explicitly *not* the time needed to study the article, a
  religiously sufficient duration, a mandatory amount, a ruling or spiritual
  value. `context.dayOffset` **is** the catalog index — no modulo, cycling,
  repetition, randomness, day-of-month, weekday, `weekIndex`, locale sorting,
  asset order, current date or profile reordering; all 30 mappings and the
  uniqueness of the 30 article IDs are asserted individually. `targetRef`
  carries **only** the stable article ID and `sizeParam` stays null, so no
  article text and no learning quantity ever reaches a `DailyPlan`; **no Learn
  repository, asset bundle or reading history is read during generation**
  (asserted structurally over the production source files). `templateId` is a
  **lossless** `learn_article_<articleId>` concatenation — no normalization,
  no `hashCode`, no hashing dependency — and article IDs are verified free of
  the `:` separator used by `DailyPlanItemIdBuilder`. A typed
  `LearnPlanCatalogIssue` (mirroring TASK 079's `GenerationRequestIssue`)
  meant **no new `AppFailure` subtype and no new localization key**; a broken
  catalog or out-of-contract offset fails the **entire** 30-day generation
  with no partial output. `CoreDailyPlanItemSource` bundles the approved
  **Prayer → Quran → Learn** order as a `const` value plus a pure
  `withCatalog` factory — deliberately **not** a provider, singleton or
  bootstrap hook; `CompositeDailyPlanItemSource` and `DailyPlanGenerator` were
  **unchanged**, and for **all 30 days** the first three final item IDs are
  byte-identical with and without Learn present. The complete core day costs
  **5 minutes**, which the `light` budget accepts **exactly**; TASK 079 budget
  validation was not weakened (one extra minute on top fails the whole
  generation, and core items are never silently dropped). Contribution is
  identical across all eight profiles and all four phases — `learning_focused`
  gets no extra article, `low_time` loses nothing, `advanced` gains nothing,
  and no educational ability is inferred.
  **163 new tests** (content eligibility gate against the real assets,
  source-verification evidence, TR/EN/AR identity parity, catalog composition
  and order determinism, broken-catalog rejection, goal selection, all 30
  day-offset mappings, PlanItem representation, profile independence with an
  **enum coverage lock**, phase independence, composite ordering, identity
  stability, budget, 30-day integration with 50-repeat determinism, structural
  no-side-effect checks and religious-safety/privacy assertions); full suite
  **1015 → 1178**; TASK 081 70/70; TASK 080 62/62; TASK 079 63/63; TASK 078
  78/78; TASK 077 43/43; persistence 70/70; canonical sync 70/70; Drift
  storage 11/11; Quran feature 89/89; **Learn feature suite 108/108**
  (measured, not assumed); analyze clean. **Functions tests were NOT RUN —
  Node.js is not installed on the current machine** (the Node install
  directory is still listed on `PATH` but no longer exists); no Functions file,
  dependency or lockfile changed and Functions CI verifies the 23/23 baseline
  on the PR. **Zero tracked files modified.** This task is **free core
  product**: no Bismillah+ paywall, entitlement, price or upsell was added.
- **TASK 083 — Today task UI (CP10).** The plan engine finally has a face:
  `TodayPlanSection` is the **first and only** consumer of the TASK 077
  `DailyPlanController`, rendering all five sealed states inside the existing
  Today screen. Loading uses a **non-animated** neutral skeleton — a spinner
  is restless and, as this task proved, blocks every `pumpAndSettle` test that
  mounts Today; no "zero-jump" height is claimed because the item count is
  unknown before the read, so the skeleton only reserves a real block. Empty
  shows a neutral explanation and **no fake "generate plan" button**, because
  generation orchestration still does not exist. Corrupt states that nothing
  was deleted, offers no retry (`canRetry` is false) and never auto-resets.
  Failure is a neutral message plus the existing `retry()`. Item titles come
  from the pure `TodayPlanItemPresentation` mapper (composed item ID →
  template ID → neutral localized text); Learn titles resolve through the
  existing **published-only** `LearningKnowledgeRepository`, and an
  unresolved, removed, unpublished, null-`targetRef` or failing article falls
  back to a neutral label — **no fabricated title, no crash, and no raw
  template ID, article ID or generator version ever printed**. Card order is
  the plan's own **Prayer → Quran → Learn** order, proved not re-sorted by
  localized text. **Completion was implemented** rather than deferred, because
  the architecture already supported it safely: the `AppClock` provider
  supplies `completedAt`, `savePlan` already carries epoch staleness
  protection, and the persistence envelope already round-trips
  `status`/`completedAt`. `toggleItemCompletion` preserves every other plan
  field, blocks a second write while one is in flight, ignores unknown item
  IDs, never generates a plan and never touches another day — **no new storage
  key and no envelope-version change**, and the widget never calls `savePlan`
  itself. **Day navigation was deliberately deferred to TASK 084**: today's
  `DayKey` is selected once from the injected clock and exactly one watch
  subscription is opened. Tone guardrails hold — unmarked tasks get no red
  styling, warning icon, guilt language, streak, score, rank or profile
  ranking, and marking is presented as an in-app tracking action, never as a
  claim that worship was performed or accepted. Free core: no paywall,
  upgrade banner, locked task, supporter badge, donation message or ad
  (asserted by test).
  **53 new tests** (five states incl. skeleton and single-subscription,
  canonical ordering, pure template mapping with a `PlanItemType` coverage
  lock, Learn resolution and every fallback path, progress at 0/partial/full,
  completion incl. duplicate-write guard, injected clock, reload persistence,
  save failure and cross-day safety, semantics/touch target/320 px/1.5× text/
  RTL/EN/three-language parity, and religious-safety + privacy assertions);
  full suite **1178 → 1231**; analyze clean.
  **Functions 23/23 re-verified** on Node.js v22.22.0 / npm 10.9.4 — this
  also closes the TASK 082 `PENDING (environment)` record, now **POST-MERGE
  VERIFIED**; no Functions file was touched by either task.
- **TASK 083A — Initial DailyPlan orchestration (CP10, controlled roadmap
  insertion between TASK 083 and TASK 084; nothing renumbered).** Everything
  from TASK 076 onward existed, but **nothing ever invoked the generator** —
  so Today showed Empty for every user, and TASK 084 would have had no plans
  to recover. `InitialDailyPlanOrchestrator` closes the chain in one place:
  `OnboardingPreferences` → `OnboardingProfileMapper` →
  `DailyPlanGenerationRequest` → `DailyPlanGenerator` +
  `CoreDailyPlanItemSource` → **one atomic write**, with the start day taken
  from the injected `AppClock` (no `DateTime.now()`, asserted at source
  level). The key data-integrity decision: **atomicity needed no
  storage-format change**. The existing single-key envelope already supports
  read-all → merge → encode once → write once, so the new
  `DailyPlanRepository.savePlans(List)` is a contract addition, not a
  migration — the storage key and persistence version **1** are untouched.
  **30 sequential `savePlan` calls are explicitly forbidden**: an interruption
  would leave a partial plan. `savePlans` rejects an empty batch and duplicate
  `DayKey`s, never overwrites a corrupt envelope, preserves every day outside
  the batch, and publishes watch events only **after** a successful write; a
  failed encode or write leaves storage byte-identical. The orchestrator
  **classifies rather than repairs**: a complete matching range returns
  `alreadyAvailable` with completion status, `completedAt`, `profileType` and
  `generatedBy` untouched, while a partial or non-continuous range returns a
  typed `rangeConflict` that is deliberately **never auto-filled or
  overwritten** — silently completing a half-written range would let a stale
  profile bulldoze real user history, and recovery is TASK 084's job.
  Concurrent callers share one memoized operation, so two (and three)
  simultaneous calls produce exactly **one** write. Onboarding completion now
  returns success **only after** the plan exists: on failure the gate stays
  closed, the user is not sent to an Empty Today as "success", preferences
  stay persisted for a safe retry, and the existing neutral
  `onboardingSaveIssue` message is reused without leaking the raw cause.
  Already-onboarded users with no plan are covered by
  `InitialDailyPlanBootstrapController`, which runs **at most once per app
  lifecycle and never inside a widget `build`** (no provider or rebuild loop
  can regenerate), with an explicit user-driven `retry()`. App bootstrap
  itself still touches no plan provider. Typed outcomes carry no raw
  onboarding answers, plan JSON, article text, storage keys, UID, device data
  or exception text.
  **73 new tests** (orchestrator 59 — generation, all eight profiles with a
  coverage lock, atomic failure paths, idempotency, concurrency, partial and
  conflicting ranges, onboarding integration, existing-user bootstrap, Today
  integration and restart persistence; `savePlans` contract 11, persistence
  suite 70 → **81**; Today section 3, suite 50 → **53**); full suite
  **1231 → 1304**; analyze clean. Functions untouched and not re-run.
- **TASK 084 — Missed-day recovery and gentle rollover (CP10).** Today now
  follows the **local calendar day** on its own. `TodayDayController` owns the
  displayed day and the calm return state; `TodayPlanSection` only forwards
  lifecycle events and draws. Three cases are covered and tested: app starts
  on the current day, app resumes after the date changed, and the app stays
  open across local midnight. Midnight uses **one armed one-shot timer**
  through an injected `DayRolloverScheduler` — **periodic polling is
  forbidden**, exactly one timer exists at a time, it is cancelled on
  disposal, and a fire after disposal changes nothing. The boundary is
  `DateTime(y, m, d + 1)` minus the injected local now, so **24 hours is
  never assumed** and DST, month, year and leap-day transitions fall out
  naturally; `DayKey` comes only from `DayKey.fromLocal(clock.nowLocal())`
  with no UTC conversion and no `DateTime.now()` (asserted at source level).
  A resume or timer fire on the **same** day is a genuine no-op — no second
  read, no second watch subscription, no second bootstrap — and a generation
  counter stops an old day's late read from overwriting a newer day.
  The **missed-day definition is deliberately narrow**: a past `DayKey`
  counts only if it has a plan, has items, and has zero completions. Absent
  records, empty plans, corrupt records, today and future days are **data or
  product states, not user behaviour** — they are never called missed and
  each of them **breaks** the consecutive chain, so the app can never imply a
  gap it cannot honestly prove. Lookback is capped at the canonical 30 days.
  `MissedDayCalculator` is pure (no repository, clock, locale or write) and
  `MissedDayRecovery` is explicitly **not a streak model**: nothing is
  persisted, no score, badge or rank is derived, and **the count is never
  rendered**. Historical integrity is absolute — nothing is auto-completed,
  marked failed, copied into today, deleted, reordered or re-timed, and the
  recovery path performs **zero writes** (asserted after both a rollover and
  a current-day toggle). `TodayRecoveryNote` sits **above** the plan without
  blocking a single task: no modal, no animation in its own subtree
  (reduced-motion friendly), no error colour, no warning icon, no flame, and
  no streak/penalty/score/paywall/donation language in any of TR, EN or AR.
  It disappears once any current-day task is marked — derived purely from
  existing plan state, so **no new persistence key was added** just to
  dismiss a message. At **3+** consecutive missed days only the wording
  softens to a warm re-entry sentence; the full plan, its Prayer → Quran →
  Learn order and the daily minute budget are untouched, because adaptive
  shrinking belongs to a later decision. A day with no plan keeps the honest
  Empty state — nothing is generated, yesterday is never copied forward, and
  the range is never extended past day 30.
  One pre-existing behaviour had to change: `DailyPlanController.loadDay`
  still cancels the previous watch subscription but **no longer awaits** it.
  `StreamSubscription.cancel()` does not resolve promptly for every stream
  implementation, and awaiting it left the second day load stuck in `Loading`
  forever (reproduced by widget test). Waiting was never necessary —
  `_onWatchEvent` compares the subscribed day against the active day and the
  generation counter independently blocks stale results.
  **88 new tests** (calculator 30, rollover controller 31, recovery note 21,
  Today section +6); full suite **1304 → 1392**; analyze clean. Functions
  untouched and not run. **Stored-figure correction:** the Today section
  suite was recorded as 53 by TASK 083 and TASK 083A but measures **56** on
  merged `7b0d2b5` — only the stored number was wrong, no test was lost, and
  every full-suite total on record stays correct.
- **TASK 085 — 30-day plan and CP10 checkpoint. Verdict: CP10 COMPLETE —
  30-DAY LOCAL PLAN FLOW STABLE. Product gate: READY TO ENTER CP11.**
  The whole local-first chain — onboarding → profile mapping → generation →
  Prayer/Quran/Learn sources → **one atomic write** → bootstrap → Today →
  completion → restart → local-day rollover → missed-day recovery — was
  validated against **executed** suites rather than inspection: CP10
  checkpoint 30, generator 63, mapper 78, Learn catalog+source 163,
  orchestrator 59, persistence 81, state machine 43, rollover/recovery 82,
  Today UI 62. The new end-to-end harness deliberately runs on the **real**
  `SharedPrefsDailyPlanRepository` over mocked prefs, so "restart" means a
  new `ProviderContainer` **and** a new repository instance reading the same
  stored bytes — a fake would have proved nothing about persistence.
  **The checkpoint's real value was the audit, not the green tests.**
  Reviewing TASK 084's non-awaited subscription cancellation exposed a
  genuine data-path defect: `unawaited(future)` **contains nothing**, so a
  failing `cancel()` escaped as an **unhandled asynchronous error** — a
  test-zone failure in tests and a zone error-handler hit in production.
  The fix is the smallest safe containment,
  `unawaited(cancel().catchError((Object _) {}))`, and it was proved
  load-bearing by reverting it and watching the audit test fail with
  `Bad state: cancel failed (test)` escaping through `_cancelQuietly`.
  Awaited cancellation was **deliberately not restored** — awaiting is
  precisely what deadlocked the second day load at TASK 084. Genuine
  repository watch failures are still surfaced through `listen(onError:)`
  and, per the TASK 077 stream contract, do not topple the last known state
  (asserted separately). The remaining nine audit properties all passed:
  rapid A→B→C never sticks in `Loading`, events from A or B cannot replace
  C, the final state belongs only to C, old subscriptions really are
  cancelled (3 listens → 2 cancels), **12 day switches leave exactly one
  active listener**, disposal drops it to zero, and late-resolving cancels
  cannot mutate newer state.
  Scenario coverage: fresh user gets 30 continuous plans and a completion
  that survives restart; an onboarded user with no range bootstraps **once**;
  a complete range is a no-op preserving status and `completedAt`; a partial
  range stays a typed conflict with **no repair and no overwrite**; day N's
  completion survives the switch to N+1; a missed-day return shows gentle
  then extended copy **without shrinking, reordering or regenerating** the
  plan and leaves history byte-identical; day 30 loads normally while **day
  31 stays honest Empty** with the stored range still exactly 30.
  Full suite **1392 → 1422**; analyze clean; Functions **23/23** on Node.js
  v22.22.0 / npm 10.9.4. No schema, storage-key, envelope-version, Drift,
  Firebase, remote-sync, notification, dependency or premium change.
  **CP10 is closed.** This is explicitly **not** a release-readiness claim:
  the plan flow has had no physical-device validation and iOS remains
  unvalidated.
- **Next:** **CP11 opened at TASK 086 — Content-source matrix** (see the CP11
  section below). Deferred out of CP10 and owned by **no task yet**: day-30 plan
  renewal, adaptive plan shrinking, streak/XP/achievements, manual calendar
  navigation, opening a Learn article from a task card, and repair of TASK
  083A's typed `rangeConflict`. The commercial roadmap-alignment item below
  remains open and unnumbered, as do Firebase gates G1, G2, G5, G8 and G14.
- **Standing owner decisions (opened at TASK 082, still open):**
  (1) generation is **not wired** to persistence or onboarding completion and
  the roadmap names no dedicated task for that wiring; (2) a **commercial
  roadmap-alignment task is required but unnumbered** — the owner's approved
  pricing (first month 29.99 TL then 69.99 TL), supporter tiers, conditional
  LÖSEV process, store presentation, social creatives and AI-ad disclosure
  **conflict** with the canonical `MONETIZATION_DECISIONS.md` (79.99 TL
  monthly, no introductory price, no LÖSEV/creative/AI-disclosure policy).
  Content for dhikr/dua/reflection remains an **open owner decision**.

## CP11 — Learn and Assistant depth (in progress)

- **TASK 086 — Content-source matrix (CP11 opens).** The first governance task
  since the public-alpha content work: an audit that answers, for every
  religious and educational content class, what the source is, whether it is
  official/primary or reviewed secondary, where it lives, how it is delivered,
  which publication and review gates apply, what TR/EN/AR coverage exists,
  which surfaces may consume it, and what is still unresolved. A competing
  source-policy architecture was deliberately **not** created:
  `docs/CONTENT_SOURCES.md` (attribution/delivery), `THIRD_PARTY_NOTICES.md`
  (formal licences) and `CONTENT_POLICY.md` (publication gate) keep their
  roles, the new `docs/CONTENT_SOURCE_MATRIX.md` references them rather than
  restating licensing facts, and `CONTENT_SOURCES.md` gained a cross-reference
  so there is one entry point.
  **22 rows**, each with a stable kebab-case ID: Quran text, chapter metadata,
  verse-page map, Turkish translation, search index, recitation audio and
  reciter catalog; the **inactive** remote Diyanet translation callable; Learn
  articles, prayer education, categories, source registry and plan catalog;
  prayer-time calculation and prayer labels; dua and dhikr; onboarding copy and
  Today plan copy; the Assistant retrieval corpus and safety copy; and the
  Profile source registry. Status counts: **READY 8 · READY WITH DOCUMENTED
  LIMITATION 11 · REVIEW REQUIRED 1 · BLOCKED 0 · NOT IMPLEMENTED 2**.
  Every figure was **recomputed from the shipped assets**, not carried over
  from earlier reports: **32 records per locale — 30 `published`, 2
  `scholarlyReviewPending`**, with TR/EN/AR carrying identical stable ID sets
  **and** identical review statuses; all 30 published on `sourceBodyReview`
  with an exact locator, evidence summary and `verifiedAt`; every referenced
  source ID resolving to a registered `sources.json` record; zero orphan
  references. Where the repository establishes nothing — notably translation
  licensing — the matrix records **UNRESOLVED** rather than general knowledge.
  A classification decision was fixed: **`internal-ui-copy` is a first-class
  source class.** Onboarding wording, Today plan labels ("Continue your Quran
  habit", "Daily prayer tracking"), prayer name labels and the Assistant's own
  safety strings are interface copy, **never** sourced religious teaching, and
  the Assistant may never treat them as authority. Prayer times were confirmed
  honestly labelled: `adhan_dart`'s `turkiye()` preset behind "Türkiye
  hesaplama yöntemi", with **no official-Diyanet claim** anywhere in code or
  interface.
  **No P0 or P1 issue was found.** No published religious content lacks an
  identifiable source; no source-registry entry mismatches shipped content; no
  locale set represents different religious subjects; no review-pending content
  is exposed as published; the Assistant cannot reach unpublished material; and
  no evidenced licensing conflict exists for content that actually ships.
  **Six P2 findings** were recorded with owners: **F1** the Assistant
  sensitive-query persistence gate excludes `worshipRule` while the classifier's
  own `isSensitiveVerdict` includes it — and that helper has **no production
  caller** (TASK 094); **F2** `app_source_reference.dart` duplicates
  `sources.json` facts with no cross-check (TASK 094); **F3** QuranEnc/Rowad
  licensing is unestablished (UNRESOLVED, owner decision); **F4** the deployed
  Diyanet callable is client-inactive with unresolved upstream licensing, EOL
  `nodejs20` and `enforceAppCheck` still a TODO (existing P1 redeploy + gate G7,
  TASK 134); **F5** 3 of 6 registered sources ground no published article and 11
  of 20 categories are empty (TASK 087–090, TASK 092); **F6** neither Quran
  corpus was ever fully diffed upstream (UNRESOLVED). **No task number was
  invented**, and the deferred governance items — Bismillah+ pricing, supporter
  tiers, LÖSEV, advertising creatives, AI-ad disclosure and the unnamed Firebase
  gates — were preserved untouched.
  A small durable validator was added (`test/content/content_source_matrix_test.dart`,
  **14 tests**) that checks the matrix document itself — unique IDs,
  summary/detail agreement including status, all 18 required fields, closed
  value sets, a `Limitation` field wherever a limitation status is claimed, no
  `UNRESOLVED` inside a `READY` row, and **every cited repository path really
  existing on disk**. It deliberately does not duplicate
  `learn_content_integrity_test.dart`. The validator caught two real defects
  during authoring: the parser was absorbing the Findings section into the last
  row, and one `Delivery` value carried a parenthetical instead of a bare token.
  Full suite **1422 → 1436**; analyze clean; Learn/Assistant/content-sources +
  matrix **199/199**; Functions **not run** (no Functions file, dependency or
  lockfile changed; last verified 23/23 at TASK 085). **No religious content was
  written, edited, repaired or reclassified, and zero production Dart or asset
  files changed.**
- **TASK 087 — Learn pack: Hadith, Seerah, Prophets.** The first CP11 task to
  write content, and the first Learn expansion since the public alpha. The
  roadmap fixes no article counts, so the owner set the scope explicitly at
  **3 + 3 + 3** — **9 new stable IDs, 27 localized records** — populating
  `cat-hadith`, `cat-seerah` and `cat-prophets`. Per locale the library moved
  from 32 records / 30 published to **41 / 39**; populated categories **9 → 12
  of 20**; sources grounding published content **1 → 3 of 7**.
  **The value of this task was the gate, not the volume.** It blocked twice and
  both blocks were correct. First, the Seerah e-book and Prophets PDF named for
  the pack were **unreachable** — `dijital.diyanet.gov.tr` answers HTTP/0.9 and
  the Prophets download redirects to `diyanet.gov.tr/hata.html` — so working
  official substitutes were located rather than the sources being declared
  absent. Second, a proposed hadith article was rejected outright: reading
  *Hadislerle İslâm* Cilt 1 s. 250 in full showed it covers the first
  revelation, Hz. Hatice's consolation and Varaka b. Nevfel, **not** good
  character; the candidate sentence was one clause inside an unrelated
  narrative. The topic was replaced only on explicit owner permission, never
  silently. The **direct-source rule** held throughout: PDFs were downloaded
  outside the repository and their text extracted directly, the digital hadith
  work was read as rendered page bodies, **no summary or snippet was used as
  evidence**, and nothing downloaded was committed. `diyanet-islam-ilmihali`
  was confirmed as **34. Baskı, 2019** from the PDF's own colophon — the exact
  edition the existing 30 articles already cite.
  A **new source record** `diyanet-hz-muhammedin-hayati` was registered
  (*Hz. Muhammed'in Hayatı*, Prof. Dr. Casim Avcı – Mevlâna İdris, Genel Yayın
  No 1286, **Çocuk Kitapları 302**, 16. Baskı Mart 2025, ISBN
  978-975-19-6627-8). Its series, edition and authorship are explicit and **no
  Diyanet endorsement of the app is implied**. `diyanet-hadislerle-islam` now
  grounds published content for the first time.
  **Review provenance was handled honestly.** The repository never defined who
  may perform `editorialReview`, so the packet was reported as **AMBIGUOUS** and
  **no verified status was written** until the owner performed and recorded an
  explicit source-fidelity review — editorial comparison only, expressly not
  scholar approval, fatwa review, hadith grading or Diyanet approval. Proposed
  `CONTENT_POLICY.md` wording was prepared and deliberately **not applied**.
  **A structural conflict surfaced and was resolved in-branch on owner
  decision:** four merged TASK 082 assertions encoded "the eligible library
  *equals* the 30-entry plan catalog", which every CP11 Learn pack necessarily
  breaks. The canonical rule is now fixed: **TASK 082's catalog is a curated
  versioned subset of the growing published Learn library, not a permanent
  mirror.** The exact-count assertion became **at least** `requiredEntryCount`
  plus identical TR/EN/AR eligible ID sets; the equality assertion was removed
  and the subset invariant **strengthened** to require every catalog ID to be
  eligible in **every** locale; the length comparison became catalog length plus
  ID uniqueness; and the file-order check now compares only the catalog's own
  IDs. `LearnDailyPlanCatalog.v1` itself is **untouched** — same 30 entries,
  order and version, absent from the diff — and none of the 9 new IDs enters it
  (asserted). Source verification, publication, locale parity and review gates
  were **not** weakened.
  Content-safety exclusions were deliberate: hadith authenticity grading,
  personal rulings, sectarian argument, political comparison, reward or
  punishment guarantees, miracle framing, the definitive 28-prophet count and
  the disputed Zülkarneyn/Lokman/Üzeyir classification, and the exact Veda Haccı
  attendance figure in user-facing prose (kept in evidence metadata only). New
  articles carry no `beginnerPathOrder`, so the beginner path stays contiguous,
  and the two `scholarlyReviewPending` articles remain pending for TASK 091.
  **No Assistant code was touched**: the 9 articles become retrievable solely
  because they are published and source-verified, and no Assistant readiness is
  claimed. 34 focused tests; catalog suite **40/40**; full suite **1436 →
  1472**; analyze clean; Functions untouched and not run.
- **TASK 088 — Learn pack: Dua, Family, Halal foundations.** The roadmap fixes no
  article count, and TASK 087's 3+3+3 was deliberately **not** inherited. A Phase A
  evidence gate ran first and returned **PARTIALLY READY**, which is what set the
  final scope: the owner fixed **4 articles** — `cat-dua` 1, `cat-family` 2,
  `cat-halal` 1 (12 localized records). Per locale the library moved from 41
  records / 39 published to **45 / 43**; populated categories **12 → 15 of 20**;
  **no new source record** was needed, so the registry stays at 7.
  **Three gate findings shaped the pack.** First, Dua had no usable source at the
  outset: the İslam İlmihali has **no standalone dua chapter** — its TOC carries
  only namaz-attached duas — and its one general dua passage at printed s. 163
  **extracts with corrupted glyphs**, making it unusable as evidence. Second, once
  the owner named the right location and the chapter boundary was confirmed
  (Hadislerle İslâm Cilt 2: s. 33 previous chapter, s. 34 blank, s. 35–37 hadith
  cluster, s. 38 blank, s. 39 onward commentary), the chapter turned out to be
  built on precisely the excluded material — *guaranteed acceptance and special
  times* ("hangi dua daha çok kabule şayandır", the Friday hour where "Allah ona
  dilediğini mutlaka verir", "duaların en hayırlısı arefe günü", the night-descent
  hadith). `art-dua-nedir` therefore rests on **s. 40 alone**, and that thinner
  evidence base was **disclosed before drafting rather than padded**. Third,
  `cat-dua` was already occupied by the pending `art-dua-adabi`, which belongs to
  **TASK 091** and was left untouched — `cat-dua` is now the first category
  carrying a published and a pending record side by side.
  Scope was narrowed rather than stretched elsewhere too. The second family
  article was renamed `art-anne-babaya-saygi-ve-nezaket` and reduced to courtesy,
  dropping the source's **blanket-obedience items** (answering when called,
  carrying out instructions, pleasing them in every matter) and its **financial
  maintenance item**. The halal article is definitions only — it attributes them
  explicitly to the Diyanet İslam İlmihali and redirects personal cases to the
  competent authority — while `art-haramin-cesitleri` was left out of scope and
  classified **SCHOLARLY REVIEW REQUIRED**. One instruction was **not** followed
  literally: "attentive listening" was omitted from the parent article because it
  does not appear in the source body in that form, and the omission was recorded
  rather than invented around.
  **A frozen-count defect recurred and was fixed at source.** The suite written in
  TASK 087 asserted absolute library totals (`32 + 9 = 41`, `30 + 9 = 39`) — the
  same class of assumption the TASK 082 reconciliation had already corrected, and
  one that every later Learn pack necessarily breaks. Those two assertions were
  replaced with a growth-tolerant pair: totals must be **at least** the TASK 087
  baseline, and all nine TASK 087 articles must still be present, published and
  source-verified in every locale — strengthening the real guarantee while
  removing the false one. `LearnDailyPlanCatalog.v1` remains untouched and none of
  the 4 new IDs enters it.
  All four records carry `verifiedBy: editorialReview` on the owner's explicit
  source-fidelity approval — editorial comparison only, expressly not scholar
  approval, fatwa review, hadith grading or Diyanet approval. `CONTENT_POLICY.md`
  still does not define who may perform `editorialReview`; the wording proposed at
  TASK 087 remains unapplied and open. No Assistant code was touched. 29 focused
  tests; Learn + catalog **211/211**; full suite **1472 → 1501**; analyze clean;
  Functions untouched and not run.
- **TASK 089 — Learn pack: Women, Afterlife, Islamic history.** Owner scope after
  a **PARTIALLY READY** evidence gate: **5 articles** — `cat-afterlife` 3,
  `cat-women` 1, `cat-history` 1 (15 localized records). Per locale the library
  moved from 45 records / 43 published to **50 / 48**; populated categories
  **15 → 18 of 20**, leaving only `cat-madhhabs` and `cat-calendar` for TASK 090;
  **no new source record**, so the registry stays at 7. The optional
  `art-olum-nedir` was **not** added.
  **The task's own pointer was rejected rather than forced.** The brief named
  Hadislerle İslâm Cilt 1 ~s. 69 as the likely home of an article on scholarly
  journeys. Eleven pages across s. 66–82 were fetched and read directly, and
  **there is no *rihle* chapter there**: s. 66–67 is narration methodology,
  s. 69 is *"halifeler zamanında düzenlenen askerî seferlerle… ele geçirdiği
  bölgelerin tamamına"* (military and political history), s. 70 gives counts the
  source itself reports as conflicting (12.304 / ~4.000 / 1.500 and "asla
  2.000'i bulmaz"), s. 71 is fitne, sects, Hz. Osman's killing and Emevî-era
  fabrication, and s. 72–82 discusses the collections throughout in terms of
  *sahîh*, *zayıf* and *illetli*. The words *seyahat* and *sefer* on s. 76 and
  s. 78 are incidental. `art-ilim-yolculuklari` was therefore dropped and — on
  explicit owner approval — replaced by `art-kuranin-yazilmasi-ve-cogaltilmasi`
  from İslam İlmihali s. 55–56: written revelation on stone, shoulder blade,
  palm branch and hide because paper did not yet exist; Hz. Ebû Bekir's single
  mushaf after Yemâme; Hz. Osman's seven copies sent to the centres. Stable,
  broadly accepted, non-political chronology.
  **A locator was corrected during drafting:** `art-ahiret-nedir` is recorded as
  **s. 65–67**, not s. 65, because the "Ahiret Günü" definition it summarises
  sits at the end of the *Öldükten Sonra Dirilmek* sub-section on s. 67.
  Content-safety exclusions were substantial and deliberate. The Afterlife set
  drops the fear-toned Hacc 1–2 kıyamet scene, cennet and cehennem description,
  kabir azabı, şefaat (classified SCHOLARLY REVIEW REQUIRED and left out),
  hesap/mizan/sırat detail, salvation judgments, and the source's "milletine ve
  vatanına karşı görevler" clause. Notably `art-kiyametin-vakti-bilinmez` is a
  **protective** article: it carries direct source support that only God knows
  the time and that the Prophet said he had no knowledge of it — a counterweight
  to date speculation rather than an invitation to it. The Women article rests
  on the narration at Cilt 4 s. 241 (Müslim, Birr, 152) where a woman asks the
  Prophet to set aside a day to teach women and he does, while excluding the
  governance narration (s. 236), mahrem-travel rulings (s. 238), covering
  rulings, the war-participation clause and s. 240's normative social
  conclusion. The History article excludes conquest framing, caliphal
  legitimacy, sectarian reading and manuscript criticism, and preserves the
  source's own hedging — "yaklaşık yetmiş hâfız", "yedi kadar nüsha" — which is
  test-enforced.
  **Two stale fixtures were fixed durably.** `learn_repository_test` and
  `learn_screens_test` both hard-coded `cat-history` as their empty-category
  exemplar — a fixture this task necessarily invalidates. Rather than swapping in
  another soon-to-be-populated category, both now **derive** an empty category
  from the shipped assets, so no future Learn pack can break them. This is the
  third instance of the same growth-tolerance lesson, after the TASK 082 catalog
  reconciliation and the TASK 087 total-count correction.
  `LearnDailyPlanCatalog.v1` remains untouched and none of the 5 new IDs enters
  it. No Assistant code was touched. 27 focused tests; Learn + catalog
  **238/238**; full suite **1501 → 1528**; analyze clean; Functions untouched and
  not run.
- **Next:** **TASK 090 — Learn pack: Madhhabs, Islamic calendar and remaining
  gaps.**
