# Current Baseline

Canonical, verified snapshot of the project at the time of this documentation task.

## Source-of-truth rule

> The live Git HEAD and `origin/main` are authoritative for the current commit.
> The stored commit below records the last verified baseline **before** this
> task (TASK 070A). After TASK 070A/070B merge, read the real current commit from
> Git — do not treat the stored value as the live HEAD.

## Repository

- Canonical repo: `https://github.com/oguzhanbilgi/bismillah-app`
- Last verified main before TASK 070A: `dd74ac9`
- Public tag: `v0.1.0-alpha.1` (may remain on the older public-alpha release commit)
- Latest completed documentation task: **TASK 068A** (permanent Claude project memory)
- Latest completed functional task: **TASK 070A + 070B** — Android scheduled-notification
  manifest receiver contract fixed (070A) and validated on a real Samsung Galaxy A36 /
  Android 16 device (070B, merged via PR #13)
- Next planned functional task: **TASK 070C** — reapply flutter_local_notifications
  22.1.0 on top of the validated manifest fix and run automated validation

## Tests (verified)

- Flutter analyze: **clean**
- Flutter test baseline: **589 / 589** (586 + 3 Android manifest-contract tests from TASK 070A)
- Storage (Drift) tests: **11 / 11**
- Functions tests (Vitest): **23 / 23**
- Real-device: Quran main flows verified on **Samsung Galaxy A36 / Android 16**
- Real-device (TASK 070B): notification manifest fix validated on **Samsung Galaxy A36 /
  Android 16** — update-install, data preservation, exact-alarm flow, live delivery,
  replace/cancel, and reboot **restore** all PASS; reboot notification **delivery**
  **DEFERRED / NOT OBSERVED** (owner-approved risk; re-verify in TASK 071). APK SHA-256
  `ab86da0b5cd323cc1a219faefb408fa94ac3a6696908a4ba26c378dd6d231717`
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

## Open / known dependency status

- PR #4 — Drift 2.34.2 — **DEFERRED** (blocked by TASK 066 toolchain incompatibility)
- PR #6 — fast-xml-parser 5.10.1 — **SUPERSEDED** by TASK 069 (applied on the
  current Node.js 22 baseline; `fast-xml-parser 5.10.1`, `@nodable/entities 3.0.0`)
- actions/checkout v7 major — **DEFERRED**
- PR #3 — flutter_local_notifications 22.1.0 — **OPEN** (still deferred; to be
  reapplied on the validated manifest fix in TASK 070C, then re-validated in TASK 071)
- Local candidate branch `task/070-notifications-22-1-0` (local commit `a05f439`) holds
  the validated 22.1.0 lockfile change; **not pushed** — reserved for TASK 070C
- TASK 070 (original notification-update task) — **SUPERSEDED** by TASK 070A after a
  pre-existing Android manifest gap (missing scheduled-notification receivers) was found

## TASK 066 blocker (root cause)

- `drift_dev >= 2.34.1` requires `analyzer ^13.0.0`.
- Flutter 3.44.6's SDK-pinned test toolchain caps `analyzer < 13`.
- The Flutter SDK will not be upgraded solely to fix the Drift CLI.
- The TASK 064 runtime SQL snapshot remains the interim schema baseline.
