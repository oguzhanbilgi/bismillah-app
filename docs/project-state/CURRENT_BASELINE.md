# Current Baseline

Canonical, verified snapshot of the project at the time of this documentation task.

## Source-of-truth rule

> The live Git HEAD and `origin/main` are authoritative for the current commit.
> The stored commit below records the last verified baseline **before** this
> task (TASK 076). After the TASK 076 merge, read the real current commit from
> Git — do not treat the stored value as the live HEAD.

## Repository

- Canonical repo: `https://github.com/oguzhanbilgi/bismillah-app`
- Last verified main before TASK 076: `86857d1`
- Public tag: `v0.1.0-alpha.1` → `c23f490` (verified intact; must not be moved)
- Latest completed functional task: **TASK 076** — DailyPlan local persistence:
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
- Next planned functional task: **TASK 077** — Daily plan state machine
  (CP10; load per-day plan through the repository, expose
  loading/empty/available/corrupt states, controlled save/refresh
  transitions; local-only; **not** plan generation — that is TASK 079)

## Tests (verified at TASK 076)

- Flutter analyze: **clean** (0 errors, 0 warnings, 0 infos)
- Flutter test baseline: **696 / 696**, 0 failed, 0 skipped
  (629 at TASK 075 + 67 DailyPlan-focused tests from TASK 076)
- DailyPlan-focused suite: **67 / 67** — command:
  `flutter test test/features/today/data`
- **Canonical sync-focused baseline: 70 / 70.** Exact command:
  `flutter test test/features/sync test/app/persistence_wiring_test.dart
  test/app/app_bootstrap_test.dart
  test/features/prayer/data/drift_prayer_log_repository_test.dart`
  — **`test/features/sync` alone is 52 / 52**; that figure is the sync
  directory in isolation and must never replace the official 70 baseline.
- Focused prayer-reminder suite: 26 / 26 (TASK 070D)
- Storage (Drift) tests: **11 / 11** — command: `flutter test test/core/storage`
- Functions tests (Vitest): **23 / 23** on Node.js 22.22.0
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
