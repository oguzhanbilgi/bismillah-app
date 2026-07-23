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
- **Device validation:** Android (Quran) done; Android notification manifest fix
  validated on A36 (reboot delivery deferred); iOS PENDING.
- **Remaining gaps (CP09):** reapply 22.1.0 on the fix (TASK 070C), final A36
  end-to-end incl. reboot delivery (TASK 071), sync-queue audit (TASK 072),
  security-console checklist (TASK 074), CP09 regression checkpoint (TASK 075).
  PR #4 (Drift 2.34.2) and PR #3 (notifications 22.1.0) remain DEFERRED.
