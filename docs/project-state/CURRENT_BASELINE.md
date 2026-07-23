# Current Baseline

Canonical, verified snapshot of the project at the time of this documentation task.

## Source-of-truth rule

> The live Git HEAD and `origin/main` are authoritative for the current commit.
> The stored commit below records the last verified baseline **before** this
> task (TASK 069). After TASK 069 merges, read the real current commit from
> Git — do not treat the stored value as the live HEAD.

## Repository

- Canonical repo: `https://github.com/oguzhanbilgi/bismillah-app`
- Last verified main before TASK 069: `c167454`
- Public tag: `v0.1.0-alpha.1` (may remain on the older public-alpha release commit)
- Latest completed documentation task: **TASK 068A** (permanent Claude project memory)
- Latest completed functional task: **TASK 069** — fast-xml-parser 5.10.1
  validated under Node.js 22 (merged; supersedes Dependabot PR #6)
- Next planned functional task: **TASK 070** — automated validation of
  flutter_local_notifications 22.1.0

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
- TASK 068A — Permanent Claude project memory (PR #10, merge `c167454`)
- TASK 069 — fast-xml-parser 5.10.1 validated on Node.js 22 (Functions 23/23)

## Open / known dependency status

- PR #4 — Drift 2.34.2 — **DEFERRED** (blocked by TASK 066 toolchain incompatibility)
- PR #6 — fast-xml-parser 5.10.1 — **SUPERSEDED** by TASK 069 (applied on the
  current Node.js 22 baseline; `fast-xml-parser 5.10.1`, `@nodable/entities 3.0.0`)
- actions/checkout v7 major — **DEFERRED**
- notification dependency update (flutter_local_notifications 22.1.0) —
  requires **Samsung A36 device validation** before merge

## TASK 066 blocker (root cause)

- `drift_dev >= 2.34.1` requires `analyzer ^13.0.0`.
- Flutter 3.44.6's SDK-pinned test toolchain caps `analyzer < 13`.
- The Flutter SDK will not be upgraded solely to fix the Drift CLI.
- The TASK 064 runtime SQL snapshot remains the interim schema baseline.
