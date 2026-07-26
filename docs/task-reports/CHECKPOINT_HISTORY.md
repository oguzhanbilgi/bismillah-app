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
- **Next:** **TASK 079 — Deterministic daily plan generator** (consumes the
  typed profile, daily pace and local start `DayKey`; must emit 30 per-day
  records).
