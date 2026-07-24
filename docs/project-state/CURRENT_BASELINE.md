# Current Baseline

Canonical, verified snapshot of the project at the time of this documentation task.

## Source-of-truth rule

> The live Git HEAD and `origin/main` are authoritative for the current commit.
> The stored commit below records the last verified baseline **before** this
> task (TASK 072). After the TASK 072 merge, read the real current commit from
> Git — do not treat the stored value as the live HEAD.

## Repository

- Canonical repo: `https://github.com/oguzhanbilgi/bismillah-app`
- Last verified main before TASK 072: `a8bd880`
- Public tag: `v0.1.0-alpha.1` (may remain on the older public-alpha release commit)
- Latest completed documentation task: **TASK 072** — offline sync-queue
  architecture and data-loss risk audit (audit-only; verdict: **READY FOR LOCAL
  QUEUE HARDENING ONLY** — durable atomic queue exists, but no consumer, no
  `cloud_firestore` dependency, no pull/conflict code; remote sync must NOT be
  enabled; report: `docs/task-reports/TASK_072_SYNC_QUEUE_AUDIT.md`)
- Latest completed functional task: **TASK 070C + 070D + 071** —
  flutter_local_notifications 22.1.0 reapplied on the validated manifest baseline
  (070C), exact-alarm permission deep-link UX added (070D), and the combined
  candidate fully validated end-to-end on Samsung Galaxy A36 / Android 16 including
  reboot physical delivery (071); merged via PR #14
- Next planned functional task: **TASK 073** — local sync-queue hardening slice
  (backoff policy + error taxonomy + pruning; NO remote writes; owner-directed
  redefinition — the original docs-completion scope was largely done by TASK 068A)

## Tests (verified)

- Flutter analyze: **clean**
- Flutter test baseline: **595 / 595** (589 + 6 exact-alarm permission-flow tests
  from TASK 070D; focused prayer-reminder suite 26/26)
- Storage (Drift) tests: **11 / 11**
- Functions tests (Vitest): **23 / 23**
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

- Flutter `3.44.6` / Dart `3.12.2`
- Riverpod (state/DI), GoRouter (routing)
- Drift (SQLite local DB) + SharedPreferences
- Firebase anonymous auth bootstrap; Firebase Cloud Functions
- GitHub Actions CI (Flutter CI + Functions CI)
- **Functions runtime baseline: Node.js 22** (raised from Node 20 in TASK 068)

## Persistence (current reality)

- **Drift** tables: `PrayerLogDays`, `PrayerEntries`, `SyncOperations`
  (schemaVersion 1; empty `onUpgrade` placeholder; no encryption)
- **SharedPreferences**: onboarding, Quran progress/bookmarks/preferences,
  Learn progress, Assistant history (cap 20), locale, reminders, session identity

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

## Open / known dependency status

- PR #4 — Drift 2.34.2 — **DEFERRED** (blocked by TASK 066 toolchain incompatibility)
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
