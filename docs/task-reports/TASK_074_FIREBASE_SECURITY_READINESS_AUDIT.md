# TASK 074 — Firebase Security and Console Readiness Audit

Audit-only task at main `813c3c9`. No Firebase resource was deployed, changed
or enabled; no production code changed. Console state was inspected only via
read-only, already-authenticated Firebase CLI commands. Identifiers (project
IDs, app IDs, keys, emails) are intentionally not reproduced here.

Verdicts: **IMPLEMENTED · PARTIAL · ABSENT · UNVERIFIED · DOCUMENTATION ONLY ·
INTENTIONALLY OUT OF SCOPE**

## 1. Executive summary

The repository's Firebase footprint is deliberately small and well-behaved:
Core + anonymous Auth bootstrap with a local fallback, and **one** callable
Function (Diyanet translation proxy) that requires authentication, validates
input, uses Secret Manager and logs nothing sensitive. There is **no
Firestore usage, no Security Rules file, no indexes, no App Check, no
emulator suite, no Rules tests and no staging environment** — consistent with
remote sync being disabled, but all of these are hard blockers before any
remote consumer. One live drift was found: the deployed function still runs
the **Node.js 20 runtime** (EOL) while the repo baseline is Node 22 — a
redeploy (its own gated task) is pending. No tracked secrets were found.

## 2. Readiness verdict

## READY FOR LOCAL SECURITY HARDENING ONLY

Repo-side security work (author Firestore Rules + emulator-based Rules unit
tests + non-enforced App Check client code) can begin without touching the
console. Staging-level implementation is not possible yet: no staging
project/alias exists, no Rules file exists to deploy, and App Check is
absent. **Remote sync remains disabled regardless of this verdict.**

## 3. Repository Firebase inventory

| Item | Evidence | Verdict |
|---|---|---|
| Flutter Firebase init | `bismillah_app/lib/core/firebase/firebase_initializer.dart` | IMPLEMENTED (failure-tolerant; Firestore never initialized) |
| Anonymous auth bootstrap | `bismillah_app/lib/core/session/anonymous_auth_service.dart`, `session_bootstrap.dart` | IMPLEMENTED (timeout + `local-` fallback) |
| Firestore client code | — (`cloud_firestore` absent from `pubspec.yaml`) | ABSENT |
| Functions source | `functions/src/{index,handler,diyanet,contract}.ts` | IMPLEMENTED (1 callable) |
| Firestore Security Rules | no `firestore.rules`; `firebase.json` has no `firestore` section | ABSENT |
| Storage Rules | no `storage.rules` | ABSENT (no Storage usage) |
| Firestore indexes | no `firestore.indexes.json` | ABSENT |
| `firebase.json` | functions-only (runtime nodejs22, lint/build predeploy) | PARTIAL |
| Project aliases | `.firebaserc` with a **single `default` alias** | PARTIAL |
| Google service config | `bismillah_app/android/app/google-services.json`, `lib/firebase_options.dart` (client config — not secrets per project policy) | IMPLEMENTED |
| App Check code/config | only a TODO comment in `functions/src/index.ts`; no `firebase_app_check` dependency | ABSENT |
| Emulator configuration | no `emulators` section anywhere | ABSENT |
| Security tests (Rules) | `rules-unit-testing` referenced only in `docs/07_FIREBASE_ARCHITECTURE.md` | DOCUMENTATION ONLY |
| Deployment workflows | `.github/workflows/{flutter-ci,functions-ci}.yml` — CI only, **no deploy jobs** | INTENTIONALLY OUT OF SCOPE (manual deploys) |
| Data-model/sync spec | `docs/10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` §8–§15 | DOCUMENTATION ONLY |

## 4. Environment separation — verdict: PARTIAL (single dev project)

- One repo-wired project (the `default` alias); its name marks it as a
  **development** project. No staging or production alias exists.
- CLI (read-only): the authenticated account can see a second project, but it
  is not wired anywhere in the repo — environment separation is therefore
  not established in configuration.
- Debug builds connect to the dev project; a production project does not
  exist yet, so "debug hits production" is currently impossible — but this
  inverts once a production project is created (guard needed then).
- Flutter tests never touch Firebase (initializer returns `unavailable`
  without native channels; session falls back to `local-` identity), so
  tests cannot write to any project.
- Project configuration lives in generated client config (standard
  FlutterFire output); no emulator-only mode, no environment switch, no
  release-time wrong-project guard, no documented rollback path.

## 5. Authentication and ownership — client IMPLEMENTED, Rules-side ABSENT

- Anonymous sign-in is the only provider used; bootstrap resolves identity
  **before** persistence, with a bounded timeout; on failure a `local-<uuid>`
  identity is used and is documented as never written to Firebase.
- No code path can perform a remote write before auth completes — because no
  remote write path exists at all.
- Queue rows carry a UID; startup `remapUid` rebinds rows to the session
  owner (single-user local DB). Reinstall produces a new anonymous UID; with
  no remote data this is currently loss-free but account linking (TASK 131)
  must precede remote sync.
- Intended remote paths are user-scoped under `users/{uid}` per spec §8–§9 —
  **enforced nowhere** yet (no Rules). Ownership is currently a client-side
  contract only.
- Sign-out flows do not exist yet; `cancelAll()` exists for future account
  deletion. Cross-user exposure risk **today: none** (nothing remote);
  **future: unmitigated until Rules + tests exist.**

## 6. Intended Firestore paths — DOCUMENTATION ONLY

Spec §7–§17 defines user-scoped collections (profile/preferences, prayer log
days keyed by dayKey, quran progress, dhikr, dua favorites, achievements,
settings, entitlements, attribution) with deterministic client-generated
document IDs (idempotent overwrite by design) and server-timestamp rules.
None are implemented. Must-never-write list re-confirmed against code and
spec: calculated prayer times, precise location, raw notification content,
Assistant questions, raw Quran reading history, verse-level analytics,
device identifiers beyond the app-generated device UUID, unrestricted
worship notes — none of these are queued or transmitted today.

## 7. Firestore Security Rules — verdict: NOT IMPLEMENTED (BLOCKER)

There is no Rules file, so every §8 sub-check (auth gating, write
validation, ownership, sensitive collections, abuse protection,
maintainability) is **NOT IMPLEMENTED**. Firestore for the project is
currently governed by whatever mode the console database was created in —
**UNVERIFIED** from the repo, and irrelevant only while no client can reach
Firestore (no dependency). This becomes the single most important artifact
before any remote implementation.

## 8. Entitlement and premium security — future requirement (recorded)

No entitlement collections or client code exist. Docs (MONETIZATION,
spec §16) already fix the right authority model: RevenueCat/server as source
of truth, no client-writable premium status, supporter status not
purchasable by self-write. These must be encoded in Rules when entitlements
arrive (CP13); recorded as future security requirements, nothing to audit in
code today.

## 9. App Check — verdict: ABSENT (BLOCKER BEFORE REMOTE SYNC)

Not installed (no dependency), not initialized, not enforced anywhere. The
only trace is a `TODO(App Check)` in the callable's options, which correctly
documents that auth-requirement is the interim protection. No debug-token
handling exists (nothing to leak). Safest rollout order is captured in §19;
Play Integrity for Android and App Attest/DeviceCheck for iOS remain
planned-only (spec/roadmap TASK 134).

## 10. Cloud Functions — verdict: IMPLEMENTED and well-guarded (1 function)

`getQuranChapterTranslation` (callable v2, `europe-west1`, 256MiB, 30s
timeout, `maxInstances: 5`):

- **Auth required** (`request.auth` → `unauthenticated` otherwise). App
  Check not enforced (TODO).
- **Input validated** (`chapterId` integer 1–114; anything else →
  `invalid-argument`). Input surface is a single integer — no user-controlled
  URLs/headers → no SSRF; upstream base URL is fixed.
- **Secrets** via `defineSecret` (Secret Manager); token used only in the
  Authorization header; upstream fetch errors are wrapped so header/URL
  content cannot leak (`diyanet.ts`).
- **Logging** limited to `chapterId` + error kind/status (verified in
  `handler.ts`); no request bodies, no tokens, no UID forwarding upstream.
- **Errors** returned to clients are generic, typed `HttpsError`s.
- **Tests:** 23/23 (mock-based, no live upstream).
- **Gaps:** no per-user rate limiting beyond `maxInstances`; response-size
  limit relies on upstream shape validation; **deployed runtime is
  `nodejs20` (EOL) while the repo declares `nodejs22`** — the TASK 068
  runtime upgrade was never deployed (read-only CLI evidence). Redeploy is a
  future gated task; do not deploy in this audit.

## 11. Secrets and configuration — verdict: CLEAN

- Pattern scan over tracked files: **no service-account JSON, no private
  keys, no `.env`, no tokens, no debug App Check tokens, no emulator
  exports, no CLI cache** tracked.
- `google-services.json` and `firebase_options.dart` are tracked — Firebase
  *client* config, explicitly not a secret per project policy (CLAUDE.md);
  acceptable, though identifiers should not be copied into public docs.
- `functions/.gitignore` covers `.env*`/`.secret.local`; Flutter
  `.gitignore` standard. **No repo-root `.gitignore`** (P2): root-level
  accidental files (e.g. a future service-account drop) would rely on
  vigilance rather than rules.

## 12. Logging and privacy — verdict: SAFE (current code)

Flutter logging is a thin app logger; bootstrap warnings carry no IDs or
worship data (verified TASK 072/073). Functions logs carry only `chapterId`
and error class. No UID, operation ID, idempotency key, prayer data,
location, Quran content, Assistant text, notification payload, tokens or
bodies are logged. Cloud Logging retention/access policies are console-side
— **UNVERIFIED** (review when staging exists).

## 13. Firestore indexes — ABSENT (not yet needed)

No queries exist, so no indexes are declared. Spec §25 documents intended
index strategy (status+nextRetryAt analogue lives client-side already).
Index declaration + deploy procedure must be created together with the first
remote queries; user-scoped path constraints will bound query cost.

## 14. Emulator and security tests — ABSENT (BLOCKER before Rules deploy)

No `emulators` config, no Firestore/Auth/Functions emulator wiring, no
`rules-unit-testing` dependency, no Rules tests, no CI execution of any
emulator suite. Existing automated coverage relevant to security: Functions
23/23 (auth-required and validation paths are unit-tested via mocks) and
Flutter 629/629 (identity fallback, ownership remap). Required future Rules
suite (minimum): unauthenticated rejection, own-user read/write, cross-user
rejection, unexpected-field rejection, immutable owner, invalid types,
entitlement forgery, delete behavior, oversized input, `local-` UID
rejection.

## 15. Firebase CLI read-only findings (generic labels only)

- CLI v15.23.0, already authenticated; only read-only commands were run
  (`projects:list`, `use`, `apps:list`, `functions:list`).
- **Configured project:** one; active alias = `default` (dev-named).
- The account can see **2** projects total; the second is not referenced by
  the repo.
- **App registrations:** Android 1, iOS 1 (iOS app registered even though
  iOS builds are not yet validated).
- **Deployed functions:** 1 (`getQuranChapterTranslation`, ACTIVE,
  **runtime nodejs20** — behind the repo's nodejs22 baseline).

## 16. Cost, quota and abuse — mostly UNVERIFIED (console), safeguards defined

Current exposure is minimal: one auth-gated callable with `maxInstances: 5`.
Anonymous-account abuse is possible in principle (free anonymous sign-ins)
but yields only proxy access, which is capped. Budget alerts, quota alerts,
log-based alerts, App Check metrics: **UNVERIFIED/absent** (console-side).
Minimum safeguards before remote sync: staging project; budget alert on both
projects; daily usage review during pilot; bounded batch size + retry cap
(retry cap already implemented in TASK 073); hard query limits via
user-scoped Rules; App Check metrics; a rollback/off switch for the sync
engine; server-side entitlement authority.

## 17. Backup, deletion and recovery

Implemented locally: full local reset (Drift + queue + prefs). Remote data
does not exist, so remote deletion/backup/restore are **not applicable
yet**; deletion semantics for sync (tombstones) remain ABSENT and are a
known P1 for the sync track. Account deletion flow, retention windows,
export, incident response and support process: DOCUMENTATION ONLY or ABSENT
— must be defined before production remote sync (spec §23 sketches the
contracts).

## 18. Risk register

### P0 — none found
No tracked credentials, no public write path (nothing remote exists), no
client-writable entitlement (no entitlements), no sensitive logging.

### P1 — blockers before controlled remote sync
1. **No Firestore Security Rules** (no file, no firebase.json section) —
   author Rules + ship with tests. Target: Rules task (roadmap TASK 133
   scope, may be pulled earlier for staging).
2. **No Rules/emulator test suite** (`rules-unit-testing` absent) — required
   before any Rules deploy.
3. **App Check absent** (client dependency + Functions/Firestore
   enforcement) — target TASK 134 scope; code-first non-enforced rollout.
4. **No staging/production environment separation** (single dev project,
   single alias) — create staging project + aliases + wrong-project guard.
5. **Deployed function runtime nodejs20 (EOL)** vs repo nodejs22 — schedule
   a controlled redeploy task (predeploy lint/build already configured).
6. Carried sync-track P1s (unchanged from TASK 073): consumer stack, remote
   idempotency enforcement, pull/conflict/tombstone, payload versioning,
   account linking.

### P2 — operational hardening
1. No repo-root `.gitignore` (defense-in-depth for accidental root drops).
2. No budget/usage/App Check alerting (console; UNVERIFIED).
3. Cloud Logging retention/access unreviewed.
4. `docs/07_FIREBASE_ARCHITECTURE.md` describes emulator/App Check intent
   that the repo does not yet implement (mark as intent, not state).
5. iOS app registration exists while iOS remains device-unvalidated
   (harmless; note for CP15).

## 19. Safe rollout order (future; NOT executed)

1. Create/confirm staging project + `.firebaserc` aliases + wrong-project
   deploy guard. 2. Add emulator suite (Firestore+Auth+Functions) and wire
CI. 3. Author user-scoped Rules (deny-by-default). 4. Add Rules unit tests
(§14 list). 5. Verify anonymous-auth ownership against the emulator.
6. Add `firebase_app_check` in non-enforced mode + debug provider (dev
only). 7. Configure Play Integrity. 8. Deploy Rules to staging. 9. Redeploy
Functions (Node 22) to staging. 10. Controlled test accounts. 11. App Check
metrics/monitoring. 12. Gradual enforcement (Functions first, then
Firestore). 13. Enable ONE controlled sync entity (prayer log) behind a kill
switch. 14. Monitor denials/costs/duplicates. 15. Production only after a
rollback rehearsal.

## 20. TASK 075 recommendation (bounded checkpoint)

No P0 exists, so TASK 075 stays the CP09 checkpoint:

1. Finalize the controlled Firebase implementation order above as roadmap
   gates (which task numbers own staging, Rules, App Check, Node-22
   redeploy).
2. Define staging prerequisites (project, aliases, guard) as an explicit
   pre-CP16 task.
3. Confirm payload-version migration placement (before consumer work).
4. Resolve the §18-P2 documentation contradictions (07 doc intent vs state).
5. Confirm CP10 (Today/plan engine) may start after the checkpoint — no
   security blocker prevents local product work.
6. Run the CP09 full regression sweep (analyze, 629, 70, 26, 23 baselines).
No remote sync activation; no broad feature work.

## 21. Evidence appendix

- `firebase.json`, `.firebaserc` (structure only)
- `bismillah_app/lib/core/firebase/firebase_initializer.dart`
- `bismillah_app/lib/core/session/anonymous_auth_service.dart`, `session_bootstrap.dart`
- `functions/src/index.ts` (options, secret binding, App Check TODO)
- `functions/src/handler.ts` (auth check, validation, sanitized logging)
- `functions/src/diyanet.ts` (fixed base URL, header-only token, error wrapping)
- `bismillah_app/pubspec.yaml` (no cloud_firestore / firebase_app_check)
- `.github/workflows/` (CI only, no deploys)
- `docs/10_DATA_MODEL_AND_SYNC_SPECIFICATION.md` §7–§17, §22–§25
- `docs/07_FIREBASE_ARCHITECTURE.md` (intent for emulator/App Check)
- Read-only CLI outputs summarized in §15 (identifiers withheld)
- Baselines at audit time: analyze clean · sync-focused 70/70 · full 629/629
  · Functions 23/23 · Rules/emulator tests: none exist
