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

## Current — CP09 (technical stabilization)

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
- **Device validation:** Android (Quran) done; Android notification stack fully
  validated on A36 incl. reboot delivery; iOS PENDING.
- **Remaining gaps (CP09):** CP09 regression checkpoint (TASK 075: Firebase
  implementation order, staging prerequisites, payload-version migration
  placement, CP10 start gate). PR #4 (Drift 2.34.2) remains DEFERRED.
