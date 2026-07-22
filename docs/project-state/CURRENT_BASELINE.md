# Current Baseline

Canonical, verified snapshot of the project at the time of this documentation task.

## Source-of-truth rule

> The live Git HEAD and `origin/main` are authoritative for the current commit.
> The stored commit below records the last verified baseline **before** this
> documentation task (TASK 068A). After TASK 068A merges, read the real current
> commit from Git — do not treat the stored value as the live HEAD.

## Repository

- Canonical repo: `https://github.com/oguzhanbilgi/bismillah-app`
- Last verified product-code main before TASK 068A: `c847c4b`
- Public tag: `v0.1.0-alpha.1` (may remain on the older public-alpha release commit)
- Latest completed functional task: **TASK 068**
- Current documentation task: **TASK 068A**
- Next functional task: **TASK 069** — Validate and merge fast-xml-parser PR #6
  under Node.js 22 and Functions CI

## Tests (verified)

- Flutter analyze: **clean**
- Flutter test baseline: **586 / 586**
- Storage (Drift) tests: **11 / 11**
- Functions tests (Vitest): **23 / 23**
- Real-device: Quran main flows verified on **Samsung Galaxy A36 / Android 16**
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

## Open / known dependency status

- PR #4 — Drift 2.34.2 — **DEFERRED** (blocked by TASK 066 toolchain incompatibility)
- PR #6 — fast-xml-parser 5.10.1 — **OPEN** (next task, TASK 069)
- actions/checkout v7 major — **DEFERRED**
- notification dependency update (flutter_local_notifications 22.1.0) —
  requires **Samsung A36 device validation** before merge

## TASK 066 blocker (root cause)

- `drift_dev >= 2.34.1` requires `analyzer ^13.0.0`.
- Flutter 3.44.6's SDK-pinned test toolchain caps `analyzer < 13`.
- The Flutter SDK will not be upgraded solely to fix the Drift CLI.
- The TASK 064 runtime SQL snapshot remains the interim schema baseline.
