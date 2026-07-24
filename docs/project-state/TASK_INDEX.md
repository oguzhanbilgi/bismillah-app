# Task Index

Status values: COMPLETED · IN PROGRESS · PLANNED · BLOCKED · DEFERRED · SUPERSEDED.
The live Git history is authoritative; this index is a human-readable summary.

## Historical (TASK 001–060)

| Task | Status | Checkpoint | Summary | Evidence | Next action |
|---|---|---|---|---|---|
| TASK 001–060 | COMPLETED (grouped) | Foundation | Flutter foundation, 5-tab nav, TR/EN/AR+RTL, onboarding, Prayer, Quran, Learn gate, Profile, local Assistant | Git history (grouped; exact per-task titles not reconstructable) | — |

## Public alpha and stabilization (061–068A)

| Task | Status | Checkpoint | Summary | Evidence | Next action |
|---|---|---|---|---|---|
| TASK 061A-2 | COMPLETED | Public alpha | License, attribution, content policy | main history | — |
| TASK 061A-3 | COMPLETED | Public alpha | Public docs and CI | main history | — |
| TASK 061B | COMPLETED | Public alpha | Public alpha merge + `v0.1.0-alpha.1` | tag `v0.1.0-alpha.1` | — |
| TASK 062A | COMPLETED | Stabilization | Dependency triage (PRs #1–#6) | audit report | — |
| TASK 062B | COMPLETED | Stabilization | Master project audit | MASTER_PROJECT_REPORT | — |
| TASK 063 | COMPLETED | CP09 | package_info_plus 10.2.1 | PR #5 | — |
| TASK 064 | COMPLETED | CP09 | Drift schema + persistence baseline (11 tests) | PR #7 | — |
| TASK 065 | COMPLETED | CP09 | Merge Drift baseline | PR #7 merge | — |
| TASK 066 | BLOCKED | CP09 | Drift official CLI toolchain incompatibility | analyzer 13 vs Flutter 3.44.6 | revisit after SDK upgrade |
| TASK 067 | COMPLETED | CP09 | flutter-action v2.23.0 (+ closed PR #2) | PR #8 | — |
| TASK 068 | COMPLETED | CP09 | Node.js 22 Functions runtime and Functions CI | PR #9, merge `c847c4b` | — |
| TASK 068A | COMPLETED | CP09 | Permanent Claude project memory | PR #10, merge `c167454` | — |
| TASK 069 | COMPLETED | CP09 | fast-xml-parser 5.10.1 validation on Node 22 (23/23) | supersedes PR #6 | — |
| TASK 070 | SUPERSEDED | CP09 | 22.1.0 update — blocked by pre-existing manifest gap; work moved to 070A | local `a05f439` (unpushed) | reapply in TASK 070C |
| TASK 070A | COMPLETED | CP09 | Declare scheduled-notification receivers + manifest regression tests (589 tests) | PR #13 | — |
| TASK 070B | COMPLETED | CP09 | Samsung A36 / Android 16 device validation of manifest fix; reboot delivery deferred | PR #13, device report | — (closed by TASK 071) |
| TASK 070C | COMPLETED | CP09 | flutter_local_notifications 22.1.0 reapplied on validated manifest fix | PR #14, `93d1c86` | — |
| TASK 070D | COMPLETED | CP09 | Exact-alarm permission deep-link UX + 6 tests (focused 26, full 595) | PR #14, `50dacef` | — |
| TASK 071 | COMPLETED | CP09 | Final Samsung A36 end-to-end validation incl. reboot physical delivery; PR #14 merged | PR #14, device report | — |
| TASK 072 | COMPLETED | CP09 | Sync-queue audit: atomic producer + tested queue, NO consumer/remote; verdict READY FOR LOCAL QUEUE HARDENING ONLY (P0 0 / P1 6 / P2 4) | `TASK_072_SYNC_QUEUE_AUDIT.md` | — |
| TASK 073 | COMPLETED | CP09 | Local sync-queue hardening: backoff policy + failure taxonomy + recordFailure + pruning + stale recovery + diagnostics (sync 70/70, full 629); verdict READY FOR CONTROLLED REMOTE SYNC IMPLEMENTATION; remote sync stays disabled | `TASK_073_LOCAL_SYNC_QUEUE_HARDENING.md` | — |
| TASK 074 | COMPLETED | CP09 | Firebase security readiness audit: Rules/App Check/emulator/staging ABSENT (P1 blockers); callable auth-gated + secret-managed but deployed on EOL nodejs20; secret scan clean; verdict READY FOR LOCAL SECURITY HARDENING ONLY (P0 0 / P1 6 / P2 5) | `TASK_074_FIREBASE_SECURITY_READINESS_AUDIT.md` | — |
| TASK 075 | PLANNED | CP09 | CP09 regression checkpoint + Firebase implementation order / staging prerequisites / CP10 gate | audit §20 | run TASK 075 |

## Selected forward milestones

| Task | Status | Checkpoint | Summary |
|---|---|---|---|
| TASK 075 | PLANNED | CP09 | CP09 full regression checkpoint |
| TASK 085 | PLANNED | CP10 | 30-day plan and CP10 checkpoint |
| TASK 094 | PLANNED | CP11 | Learn/Assistant depth checkpoint |
| TASK 101 | PLANNED | CP12 | Closed alpha/beta package |
| TASK 115 | PLANNED | CP13 | Google Play soft launch — **first possible revenue** |
| TASK 121 | PLANNED | CP14 | First 30-day revenue review |
| TASK 122 | PLANNED | CP14 | **Commercial validation** and 5,000–10,000 TL target evaluation |
| TASK 130 | PLANNED | CP15 | App Store public launch (Android + iOS complete) |
| TASK 140 | PLANNED | CP16 | Khatm planner and V1.1 checkpoint |

## Open dependency PRs

| PR | Item | Status | Note |
|---|---|---|---|
| PR #4 | Drift 2.34.2 (+sqlite3 3.5.0) | DEFERRED | tied to TASK 066 blocker |
| PR #3 | flutter_local_notifications 22.1.0 | SUPERSEDED | applied by TASK 070C via PR #14 on validated baseline |
| PR #6 | fast-xml-parser 5.10.1 | SUPERSEDED | applied by TASK 069 on Node 22 baseline |
| PR #2 | flutter-action 2.23.0 | SUPERSEDED | closed; replaced by PR #8 (TASK 067) |
