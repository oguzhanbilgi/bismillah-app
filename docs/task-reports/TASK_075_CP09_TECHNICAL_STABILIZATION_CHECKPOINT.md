# TASK 075 — CP09 Technical Stabilization and Full Regression Checkpoint

Checkpoint and documentation task executed from main `f72fdbf`. No production
Dart, test, Functions, dependency, lockfile, schema, workflow, Android/iOS or
Firebase resource was changed. All Firebase and GitHub inspection was
read-only. Identifiers (project IDs, app IDs, account emails, keys) are
intentionally not reproduced.

Verdicts used: **VERIFIED · UNVERIFIED · IMPLEMENTED · PARTIAL · ABSENT ·
DEFERRED · BLOCKED**

## 1. Executive summary

CP09 closes green. Every recorded baseline was re-run on the current
toolchain and reproduced exactly: analyze clean, Flutter **629/629**,
canonical sync-focused **70/70**, Drift storage **11/11**, Functions
**23/23**, and a successful Android debug APK build. Dependency and lockfile
state is unchanged after full resolution (`flutter pub get`, `npm ci`).

Two findings refine what earlier documentation recorded. First, the npm
advisory picture is **two independent chains**, not one: all **5 high**
findings sit under `eslint` (a devDependency — lint/build time only, never
deployed), while the **8 moderate** findings sit under
`firebase-admin`/`firebase-functions` (production, therefore inside the
deployed runtime tree). Second, the deployed callable was **re-verified today
as `nodejs20`** while the repository declares `nodejs22` — TASK 074's
observation is now confirmed rather than merely observed, which promotes the
controlled redeploy to a verified P1.

Remote sync remains disabled and is still not enable-able: `cloud_firestore`
is absent, and no production code path calls any queue-draining method. No
concrete local data-loss risk exists, so local-first product work is not
blocked by the open remote-sync security gates.

## 2. Checkpoint verdict

## CP09 COMPLETE — TECHNICALLY STABLE

All CP09 regression gates pass on the verified toolchain with an unchanged
dependency set. Remaining open work is entirely **remote-sync-side security
and architecture** plus monitored dependency debt; none of it blocks
local-first product development. No P0 exists.

## 3. Git and repository state

| Check | Result |
|---|---|
| Starting branch | `main` |
| Starting commit | `f72fdbf` (matched required commit) |
| `origin/main` | identical to HEAD before and after `fetch --prune --tags` |
| `git pull --ff-only origin main` | already up to date |
| Working tree at start | clean (`status --short` empty) |
| `git diff --check` | clean |
| Task branch | `task/075-cp09-technical-stabilization-checkpoint` created at `f72fdbf` |
| Public tag | `v0.1.0-alpha.1` → `c23f490` — intact, not moved |
| History rewrite | none; merge-commit history through PR #17 intact |
| `AGENTS.md` | absent on this machine — not read, staged, deleted or ignored |
| Legacy local `a05f439` state | absent on this machine — not recreated |

**GitHub CLI state: UNVERIFIED.** `gh` is not installed on this machine, so
PR open/merged state and CI run history could not be queried. Verified
instead from Git refs alone:

- PR **#17 merged** — confirmed by the merge commit at `main` HEAD.
- Remote PR head refs exist for **#1–#17**; none for #18.
- `origin/dependabot/pub/bismillah_app/drift-2.34.2` still exists → **PR #4
  remains unmerged**, consistent with DEFERRED.
- No `flutter_local_notifications` Dependabot branch remains on origin → the
  superseded notification PR is **no longer actionable**.
- `origin/dependabot/github_actions/actions/checkout-7.0.1` still exists →
  matches the recorded DEFERRED `actions/checkout` v7 item.
- **New, previously unrecorded:**
  `origin/dependabot/pub/bismillah_app/cloud_functions-6.3.4` — a Dependabot
  branch for `cloud_functions` that no project-memory document lists. Its PR
  state is UNVERIFIED (no `gh`). Recorded as P2-9 for triage.
- No unexpected feature branch exists on origin.

No PR was opened, closed, merged or modified during this task.

## 4. Toolchain

| Component | Version | Verdict |
|---|---|---|
| Flutter | 3.44.6 stable (framework `ee80f08bbf`, engine `83675ed276`) | VERIFIED |
| Dart | 3.12.2 stable | VERIFIED |
| Node.js | v22.22.0 | VERIFIED |
| npm | 10.9.4 | VERIFIED |
| Java (system `java`) | 24.0.1 | recorded |
| Java (Android build JDK) | OpenJDK 21 bundled with Android Studio — this is the JDK Gradle actually uses | VERIFIED |
| Android SDK | 36.1.0, platform android-36.1, build-tools 36.1.0, all licenses accepted | VERIFIED |
| Firebase CLI | 15.23.0, already authenticated | read-only use only |
| GitHub CLI | not installed | UNVERIFIED |

`flutter doctor` reports one issue: the Windows **Visual Studio Build Tools
2026** installation is incomplete. This affects Windows-desktop builds only
and is **not an Android blocker**; it was not repaired in this task and is
not tracked as a project risk. `flutter upgrade` was not run.

## 5. Flutter static analysis

Command: `flutter analyze` (from `bismillah_app/`)

| Metric | Value |
|---|---|
| Result | **No issues found** |
| Errors | 0 |
| Warnings | 0 |
| Infos | 0 |
| Analyzer duration | 15.3s (19.6s wall, including dependency resolution) |

Dependency resolution ran first and left `bismillah_app/pubspec.yaml` and
`bismillah_app/pubspec.lock` **unchanged** (empty `git diff` on both).

## 6. Full Flutter test suite

Command: `flutter test` (from `bismillah_app/`)

| Metric | Value |
|---|---|
| Total | **629** |
| Passed | **629** |
| Failed | 0 |
| Skipped | 0 |

**KNOWN NON-BLOCKING TEST WARNING** — exactly one occurrence, reproduced on
every run: a `tap()` call in `bismillah_app/test/features/learn/learn_screens_test.dart`
derives an offset outside the root render-tree bounds (target list item lies
below the 1080×2600 test surface). The test **passes**; the warning is
diagnostic only. Not modified in TASK 075, per scope.

## 7. Canonical sync-focused tests

Exact command (from `bismillah_app/`):

```
flutter test test/features/sync test/app/persistence_wiring_test.dart test/app/app_bootstrap_test.dart test/features/prayer/data/drift_prayer_log_repository_test.dart
```

Result: **70/70**, 0 failed, 0 skipped.

**Baseline distinction — preserve this.** `test/features/sync` **alone**
contains **52** tests (re-verified this run). The canonical sync-focused
checkpoint suite is the **four-path command above** and contains **70**
tests. The official baseline is **70**, not 52; the 52 figure is only the
sync directory in isolation and must never replace it.

## 8. Drift / storage tests

Exact command (from `bismillah_app/`):

```
flutter test test/core/storage
```

Paths covered: `bismillah_app/test/core/storage/app_database_test.dart`,
`bismillah_app/test/core/storage/app_database_migration_test.dart`
(with helper `schema_snapshot_util.dart`).

Result: **11/11**, 0 failed, 0 skipped.

No Drift code generation, schema snapshot change or migration generation was
performed.

## 9. Android debug build

Command: `flutter build apk --debug` (from `bismillah_app/`)

| Item | Value |
|---|---|
| Result | **SUCCESS** (Gradle `assembleDebug`, 23.3s) |
| Output (repo-relative) | `bismillah_app/build/app/outputs/flutter-apk/app-debug.apk` |
| Size | 178,526,133 bytes (170.26 MB, debug/unshrunk) |
| SHA-256 | `51ca8748877467b58f3b16368b6e5f23bac5eecdd7222e97595f5cc2764cde99` |
| Build output tracked by Git | no (ignored; `git status` clean after build) |

The APK was **not** installed; no ADB, no device testing, no notification
re-validation was performed.

**Non-blocking future-compatibility warning (recorded, not fixed):** Gradle
reports that plugins `cloud_functions` and `flutter_timezone` still apply the
Kotlin Gradle Plugin, and that future Flutter versions will fail to build
apps using such plugins (Built-in Kotlin migration). No plugin was upgraded
in this task. Tracked as P2-3.

## 10. Functions tests

From `functions/` on Node **v22.22.0**:

| Step | Result |
|---|---|
| `npm ci` | success |
| `npm test` (Vitest) | **23/23**, 2 test files, 0 failed |

The `stderr` lines emitted during the run originate from **negative test
cases** deliberately exercising upstream-failure and sanitized-logging paths
(`{"chapterId":…,"kind":…,"severity":"WARNING"}` and one wrapped unexpected
error). This is expected test behaviour, **not** a failure.

`functions/package.json` and `functions/package-lock.json` are **unchanged**
after `npm ci` (empty `git diff` on both).

## 11. npm security audit (read-only)

Command: `npm audit --json` (from `functions/`). Non-zero exit is expected
when advisories exist and did not fail this checkpoint. **No** `npm audit
fix`, `--force`, `npm update`, `npm install` or `npm dedupe` was run.

| Severity | Count |
|---|---|
| Critical | **0** |
| High | **5** |
| Moderate | **8** |
| Low / Info | 0 |
| **Total** | **13** |

Dependency tree: 167 prod / 193 dev / 136 optional (443 total).

The 13 findings form **two independent chains**. Earlier documentation
described a single `firebase-admin → @google-cloud/storage` chain; that is
accurate for the moderate half only.

**Chain A — development tooling (all 5 high, never deployed).**
`eslint` (direct **devDependency**, `^9.20.0`) → `@eslint/config-array`,
`@eslint/eslintrc`, `minimatch` → **`brace-expansion`**. Root advisory:
denial of service via unbounded expansion length causing an out-of-memory
process crash. Reachable only when linting runs (locally or in Functions CI)
over attacker-controlled glob patterns — which does not occur; patterns come
from the repository's own config. `fixAvailable` is **breaking**:
`eslint@10.8.0` (major).

**Chain B — production runtime (all 8 moderate, inside the deployed tree).**
`firebase-admin` (direct **dependency**, `^13.0.0`) and `firebase-functions`
(`^6.4.0`) → `@google-cloud/firestore`, `@google-cloud/storage`,
`google-gax`, `retry-request`, `teeny-request`, `gaxios` → **`uuid`**. Root
advisory: missing buffer bounds check in `uuid` v3/v5/v6 when a `buf`
argument is supplied. `fixAvailable` is **breaking**:
`firebase-admin@14.2.0` (major). One leaf (`gaxios`) reports a non-breaking
fix, but it is only an effect of the `uuid` advisory and does not clear the
chain.

**Direct vs transitive.** Direct packages flagged: `eslint` (dev),
`firebase-admin` (prod), `firebase-functions` (prod). All root advisories
(`brace-expansion`, `uuid`) are **transitive**.

**Source-import reality.** `functions/src/` imports only
`firebase-functions/v2`, `firebase-functions/v2/https`,
`firebase-functions/params` and local modules — it imports neither
`firebase-admin` nor `uuid` directly. This narrows the exploitation surface
but **is not a security claim**: `firebase-admin` is a declared production
dependency and ships in the deployed function's `node_modules`, so the
moderate chain is present at runtime regardless of import graph.

**Non-breaking fix available today: none** for either chain. Both require a
major upgrade.

**Relationship to prior tasks.** TASK 069 handled a *different* advisory
(`fast-xml-parser`, a `@google-cloud/storage` optional dependency, resolved
by a transitive bump). TASK 074's secret scan was clean and did not enumerate
advisories. The specific `brace-expansion`/`uuid` findings above are
therefore **newly enumerated here**, though the underlying dependency debt is
the known, previously monitored one.

**Classification.**

- **Not P0** — no exploitable secret or code exposure exists: no tracked
  credentials (TASK 074 §11), no attacker-controlled input reaches either
  advisory path, and the callable's input surface is a single validated
  integer.
- **Chain A → P2-2** — dev/lint-time only, never deployed.
- **Chain B → P2-1** — present in the deployed runtime, but with no known
  reachable exploit path from the one callable's validated input; monitored
  dependency debt, not a concrete runtime blocker today.

**Bounded future action (not performed here):** a dedicated, gated
dependency task must evaluate `firebase-admin` v13 → v14 and `eslint` v9 →
v10 as **separate** major upgrades, each with full Functions CI (`npm ci`,
lint, build, 23/23) and a re-audit; the `firebase-admin` upgrade must be
scheduled **before** any remote-sync deployment, since that is when the
production chain gains real exposure.

## 12. Flutter dependency audit (read-only)

Command: `flutter pub outdated` (from `bismillah_app/`). No package, no
constraint and no lockfile was changed.

| Bucket | Count |
|---|---|
| Total packages reported outdated | **39** |
| Direct dependencies | 5 |
| Direct dev_dependencies | 2 |
| Transitive dependencies | 27 |
| Transitive dev_dependencies | 5 |

`pub` further reports: **10** upgradable dependencies locked to older
versions in `pubspec.lock`, and **10** dependencies constrained below a
resolvable version.

**Direct dependencies:**

| Package | Current | Resolvable | Latest | Note |
|---|---|---|---|---|
| `flutter_local_notifications` | 22.1.0 | 22.2.0 | 22.2.0 | upgradable within constraint; deliberately pinned at the device-validated 22.1.0 (TASK 070C/071) |
| `drift` | 2.34.1 | 2.34.2 | 2.34.2 | this is PR #4 — remains **DEFERRED** |
| `cloud_functions` | 6.3.3 | 6.3.5 | 6.3.5 | needs constraint change; matches the unrecorded Dependabot branch (P2-9) |
| `firebase_auth` | 6.5.4 | 6.5.6 | 6.5.6 | needs constraint change |
| `firebase_core` | 4.12.0 | 4.12.1 | 4.12.1 | needs constraint change |

**Direct dev_dependencies:**

| Package | Current | Resolvable | Latest | Note |
|---|---|---|---|---|
| `drift_dev` | 2.34.0 | **2.34.0 (capped)** | 2.34.5 | TASK 066 blocker |
| `build_runner` | 2.15.1 | **2.15.1 (capped)** | 2.15.2 | capped by the same analyzer ceiling |

**drift_dev / analyzer compatibility — TASK 066 remains BLOCKED, now with
fresh evidence.** `analyzer` resolves to **12.1.0** and `pub` marks it
**not resolvable** to anything newer (latest 14.1.0), because the Flutter
3.44.6 SDK-pinned test toolchain caps it. `drift_dev` therefore cannot move
past 2.34.0. This also means **merging PR #4 would desynchronise `drift`
(2.34.2) from `drift_dev` (2.34.0)** — an independent reason to keep PR #4
deferred beyond the original toolchain rationale.

**Firebase packages** (`firebase_core`, `firebase_auth`, `cloud_functions`
and their platform-interface/web transitives) all have patch-level updates
requiring constraint edits. None is required for CP09.

**Confirmations:** PR #4 remains DEFERRED; TASK 066 remains BLOCKED; **no
package update is necessary to pass CP09**; `pubspec.yaml` and
`pubspec.lock` remain unchanged. No dependency-update PR was created.

## 13. Firebase security gates (authoritative order)

Repository evidence re-verified this task: `firebase.json` contains a
**functions-only** configuration (`runtime: nodejs22`, lint+build predeploy)
with **no `firestore` section and no `emulators` section**; `.firebaserc`
declares a **single `default` alias**; `cloud_firestore` and
`firebase_app_check` are **absent** from `bismillah_app/pubspec.yaml`; no
`*.rules` file and no `firestore.indexes.json` exist anywhere in the
repository.

This is the single authoritative gate sequence. Every gate must be satisfied
before controlled remote sync is enabled; the order is the safe rollout
order.

| # | Gate | Status | Roadmap owner |
|---|---|---|---|
| G1 | Non-production / staging Firebase environment (project + aliases + wrong-project deploy guard) | ABSENT | **unnumbered pre-CP16 prerequisite — needs an owner-assigned task number** |
| G2 | Firestore configuration present in `firebase.json` | ABSENT | with G1 |
| G3 | Firestore Security Rules (deny-by-default, user-scoped) | ABSENT | TASK 133 |
| G4 | Security Rules unit tests (`rules-unit-testing`) | ABSENT | TASK 133 |
| G5 | Emulator Suite (Firestore + Auth + Functions) wired into CI | ABSENT | with G3/G4 |
| G6 | Server-side UID ownership enforcement | ABSENT (client-side contract only) | TASK 133 |
| G7 | App Check code + safe non-enforced → enforced rollout | ABSENT | TASK 134 |
| G8 | Operation payload/schema versioning (Drift v1→v2 + migration fixtures) | ABSENT | **sync-track slice — must land before G9; see §18** |
| G9 | Queue consumer / SyncEngine (+ `cloud_firestore` dependency) | ABSENT | TASK 132 |
| G10 | Remote idempotency enforcement (deterministic user-scoped doc IDs) | ABSENT | TASK 132 |
| G11 | Conflict policy (field-level merge / `updatedAt`) | ABSENT (spec only) | TASK 132 |
| G12 | Delete / tombstone semantics | ABSENT (no tombstone producer) | TASK 132 |
| G13 | Account-link transition contract (anonymous → account) | ABSENT | TASK 131 |
| G14 | Monitoring, budget alerts and a sync kill switch / rollback | ABSENT | with G9 |

G1, G2, G5, G8 and G14 have **no dedicated roadmap number today**. They are
recorded here as explicit prerequisites; assigning them task numbers is an
owner decision and no number was invented in this report.

**Remote-sync-disabled verification (re-run this task):**

- `cloud_firestore` absent from `bismillah_app/pubspec.yaml` — VERIFIED.
- Pattern scan of `bismillah_app/lib/features/sync` for
  `FirebaseFirestore|cloud_firestore|WorkManager|Connectivity|Timer.periodic|https?://`
  → **no matches** — VERIFIED.
- `nextEligible`, `markAcked`, `recordFailure`, `pruneTerminal`,
  `diagnostics(` occur in `bismillah_app/lib` **only** in the repository
  interface and its Drift implementation — **no production caller** —
  VERIFIED.
- No Firestore path is active; **current app users are not uploading queue
  data** — VERIFIED.

No security component was implemented, and no Firebase resource was created,
changed or deployed.

## 14. Functions runtime status

| Aspect | Value | Verdict |
|---|---|---|
| Repository declared runtime | `nodejs22` (`firebase.json`) with `engines.node: "22"` (`functions/package.json`) | **VERIFIED** |
| Local execution runtime | v22.22.0 (tests run on it) | **VERIFIED** |
| Deployed callable runtime | **`nodejs20`** — one v2 callable, region `europe-west1`, 256 MiB, ACTIVE | **VERIFIED** (read-only `firebase functions:list`, CLI 15.23.0) |

TASK 074 observed this drift; this checkpoint **re-confirms it on a second
machine and a later date**, so it is no longer a one-off observation. Node.js
20 is end-of-life for the intended baseline, meaning the deployed function
runs an unsupported runtime while the repository, CI and predeploy pipeline
all target Node 22.

**Classification: P1 (FN-01)** — a verified deployment/runtime mismatch
affecting a live, user-reachable callable. It is an **operational redeploy**,
not a code change: `firebase.json` already declares `nodejs22` and already
runs lint+build as predeploy, so the fix is a controlled deploy in its own
gated task. No deployment was performed here.

Project IDs, app IDs and account identifiers are deliberately omitted.

## 15. Active blockers

### Active P0 — **none**

No tracked credentials, no public write path (nothing remote exists), no
client-writable entitlement, no sensitive logging, no local data-loss path.
Re-verified against TASK 072 §15, TASK 073 §11 and TASK 074 §18 with no new
contradicting evidence.

### Active P1 — 14

Gates G1–G14 in §13 are the P1 register; each appears once and is not
duplicated below. Their shared profile:

- **Evidence:** §13 repository verification (absent Rules/indexes/emulators,
  single alias, no `cloud_firestore`, no consumer).
- **User impact today: none.** Every one of these gates protects a capability
  that does not exist yet; no current user data is exposed, uploaded or at
  risk.
- **Blocking the next product checkpoint? No.** All fourteen gate *remote*
  behaviour. None is reachable from local-first product work.
- **Target:** as mapped in the §13 table.

Plus one non-gate P1:

| ID | Item | Severity | Evidence | User impact | Blocks next product checkpoint? | Target |
|---|---|---|---|---|---|---|
| FN-01 | Deployed callable runs EOL `nodejs20` while repo declares `nodejs22` | **P1** | §14, read-only `firebase functions:list`, CLI 15.23.0 | Live Quran-translation callable runs an unsupported runtime; no data exposure, but no security patches | **No** — the callable is an independent content proxy; local product work does not touch it | Controlled redeploy task (operational; owner-assigned number) |

### Active P2 — 12

| ID | Item | Evidence | User impact | Blocks next checkpoint? | Target |
|---|---|---|---|---|---|
| P2-1 | 8 moderate npm advisories in the **production** chain (`firebase-admin`/`firebase-functions` → … → `uuid`) | §11 | none today; no reachable path from the validated integer input | No | Gated `firebase-admin` v14 major-upgrade task, before remote-sync deployment |
| P2-2 | 5 high npm advisories in the **dev** chain (`eslint` → … → `brace-expansion`) | §11 | none — lint/build time only, never deployed | No | Gated `eslint` v10 major-upgrade task |
| P2-3 | Kotlin Gradle Plugin migration warning (`cloud_functions`, `flutter_timezone`) | §9 build log | none today; future Flutter versions will fail to build | No | Plugin-upgrade task before the Flutter SDK move that enforces Built-in Kotlin |
| P2-4 | Stale "Isar" wording in sync docstrings (actual store is Drift) | TASK 072 §3 | none (comments only) | No | Sync-track docs cleanup |
| P2-5 | `pruneTerminal` / `diagnostics` have no invocation surface; no dead-letter or manual-retry surfacing | §13 no-caller scan; TASK 073 §16 | quarantined operations are invisible to the user | No | With G9 (consumer stack) |
| P2-6 | `CLAUDE.md` "What you must always know" is stale — still names TASK 068 as latest completed, 068A as current, 069 as next | direct read | misleads a fresh session about project position | No | Memory-reconciliation task (file outside TASK 075's allowed diff) |
| P2-7 | `docs/setup/NEW_COMPUTER_SETUP.md` states "expect 586/586" for the full suite | direct read | a new machine would validate against a stale baseline (actual 629) | No | Same memory-reconciliation task |
| P2-8 | `functions/package.json` pins `@types/node: ^20.17.0` while `engines.node` is `22` | direct read | type definitions lag the runtime baseline; no runtime effect | No | With the Functions dependency task |
| P2-9 | Unrecorded Dependabot branch `dependabot/pub/bismillah_app/cloud_functions-6.3.4` on origin; PR state UNVERIFIED | §3 | none | No | Dependency triage (needs `gh` or web console) |
| P2-10 | No repository-root `.gitignore` | TASK 074 §11 | defence-in-depth gap for accidental root-level secret drops | No | Repo hygiene task |
| P2-11 | `docs/07_FIREBASE_ARCHITECTURE.md` describes emulator/App Check intent as if implemented | TASK 074 §18-P2 | documentation/state contradiction | No | With G3/G5 |
| P2-12 | Console-side: no budget/usage/App Check alerting; Cloud Logging retention and access unreviewed | TASK 074 §12, §16 | UNVERIFIED console posture | No | With G1/G14 |

`gh` being uninstalled is recorded as a **tooling limitation** (§3), not a
project risk.

## 16. Deferred items

| ID | Item | Status | Evidence | Why deferred | Target |
|---|---|---|---|---|---|
| D-1 | **TASK 066** — Drift official CLI toolchain alignment | **BLOCKED** | §12: `analyzer` resolves to 12.1.0 and is **not resolvable** higher (latest 14.1.0); `drift_dev` capped at 2.34.0 | The Flutter SDK will not be upgraded solely for the Drift CLI; the TASK 064 runtime SQL snapshot remains the interim schema baseline | Revisit after a deliberate Flutter SDK upgrade; gates G8's tooling comfort but does not block it (migration tests can use the snapshot harness) |
| D-2 | **PR #4** — `drift` 2.34.2 (+ `sqlite3` 3.5.0) | **DEFERRED — must not be merged** | §3 branch still on origin; §12 shows `drift_dev` cannot follow | Merging would desynchronise `drift` 2.34.2 from `drift_dev` 2.34.0 | With D-1 |
| D-3 | iOS physical-device validation | **PENDING** | no macOS/iOS hardware in this environment; CURRENT_BASELINE records PENDING | Requires macOS/Xcode hardware | CP15 (TASK 123–130) |
| D-4 | Remote sync implementation | **DEFERRED (intentional)** | §13 gates G1–G14 all ABSENT | Guardrail: no silent cloud sync; must follow the gate order | CP16 (TASK 131–134) |
| D-5 | Dependency upgrades not required for CP09 — `flutter_local_notifications` 22.2.0, `cloud_functions` 6.3.5, `firebase_core` 4.12.1, `firebase_auth` 6.5.6, `actions/checkout` v7, plus the two npm majors | **DEFERRED** | §11, §12 | None is needed to pass CP09; `flutter_local_notifications` is deliberately held at the device-validated 22.1.0 | Individual gated dependency tasks |

**Counts: P0 = 0 · P1 = 14 (G1–G14) + 1 (FN-01) = 15 · P2 = 12 ·
Deferred = 5.**

## 17. Product checkpoint entry decision

### Safe to continue locally — no security gate blocks these

Today hub and the local 30-day plan engine, local `DailyPlan` persistence,
Learn content authoring and the publication gate, Profile local
functionality, and the deterministic local Assistant. All operate on Drift +
SharedPreferences with no network dependency. Evidence that this is safe:
local truth never depends on the sync queue (TASK 072 §7); the producer is
atomic within a single Drift transaction; queue growth is bounded by the
per-entity merge rule; privacy reset clears everything; and **no concrete
local data-loss risk was identified in this checkpoint**.

### Not safe to activate remotely — blocked until G1–G14

Firestore sync, cloud backup, cross-device data merge, remote entitlement
mutation, and account-link data migration.

### Verdict

## READY TO ENTER NEXT LOCAL-FIRST PRODUCT CHECKPOINT

The fourteen open gates are exclusively remote-sync concerns. Per the
decision rule, local-first product work is **not** blocked merely because
future remote-sync security work remains open, and no concrete local
data-loss risk exists to justify blocking it.

## 18. Exact next task

Taken from `docs/project-state/MASTER_EXECUTION_ROADMAP.md` (CP10 block) and
`docs/project-state/TASK_INDEX.md`; no new sequence was invented.

> ## TASK 076 — DailyPlan repository and local persistence
>
> First task of **CP10 — Today and 30-day personal plan** (TASK 076–085,
> checkpoint at TASK 085).

Boundary conditions carried into TASK 076: local persistence only; no
`cloud_firestore`; no queue consumer; no remote write; Drift schema changes,
if any, require migration tests and a documented rollback strategy
(DO_NOT_BREAK).

**Payload-version migration placement (§20-3 of the TASK 074 audit,
resolved).** The operation payload/schema versioning slice (gate **G8**,
recommended by TASK 073 §18) is confirmed to belong **before any consumer
work** — that is, before **TASK 132** — and **not** inside CP10. It is a
sync-track slice with no product dependency, so it does **not** gate TASK
076. It currently has no roadmap number; assigning one is an owner decision
and none was invented here.

## 19. Evidence appendix

Repository-relative paths only.

- `firebase.json` (functions-only, `nodejs22`, no `firestore`/`emulators` section)
- `.firebaserc` (single `default` alias — structure only)
- `bismillah_app/pubspec.yaml`, `bismillah_app/pubspec.lock` (unchanged; no `cloud_firestore`, no `firebase_app_check`)
- `functions/package.json`, `functions/package-lock.json` (unchanged; `engines.node: "22"`)
- `functions/src/index.ts`, `handler.ts`, `diyanet.ts`, `contract.ts` (import scan — §11)
- `bismillah_app/lib/features/sync/domain/repositories/sync_queue_repository.dart` (interface — no production caller)
- `bismillah_app/lib/features/sync/data/local/drift_sync_queue_repository.dart` (implementation — no production caller)
- `bismillah_app/test/features/sync/**`, `bismillah_app/test/app/persistence_wiring_test.dart`, `bismillah_app/test/app/app_bootstrap_test.dart`, `bismillah_app/test/features/prayer/data/drift_prayer_log_repository_test.dart` (canonical sync-focused suite — 70)
- `bismillah_app/test/core/storage/app_database_test.dart`, `app_database_migration_test.dart` (11)
- `bismillah_app/test/features/learn/learn_screens_test.dart` (known non-blocking tap warning)
- `bismillah_app/build/app/outputs/flutter-apk/app-debug.apk` (debug build artefact; not committed)
- `.github/workflows/flutter-ci.yml`, `.github/workflows/functions-ci.yml` (CI only, no deploy jobs)
- Prior reports: `docs/task-reports/TASK_072_SYNC_QUEUE_AUDIT.md`, `TASK_073_LOCAL_SYNC_QUEUE_HARDENING.md`, `TASK_074_FIREBASE_SECURITY_READINESS_AUDIT.md`
- Read-only CLI outputs summarised in §3, §11 and §14 (identifiers withheld)
- Baselines verified at checkpoint: analyze clean · full **629/629** ·
  canonical sync-focused **70/70** (`test/features/sync` alone **52**) ·
  Drift storage **11/11** · Functions **23/23** · Android debug APK build
  SUCCESS
