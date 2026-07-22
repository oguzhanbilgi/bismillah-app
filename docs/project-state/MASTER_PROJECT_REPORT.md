# Master Project Report

Evidence-based canonical description of Bismillah. Sanitized for the repository
(no secrets, no machine-specific paths). Where documentation and code disagree,
**code and current Git history win**.

## 1. Executive summary

Bismillah is a **working public alpha** (`v0.1.0-alpha.1`) — a calm, offline-first
Islamic daily companion built with Flutter, Android-primary. It delivers a mature
Quran experience, working prayer tools, a small source-verified Learn library, a
functional Profile, and a deterministic local Assistant. It is **not** a
feature-complete store product: the Today personal-plan engine, payments, cloud
sync, and iOS validation are not yet built.

## 2. Product vision

Help Muslims build consistent worship habits through calm, premium design,
authentic clearly-sourced knowledge, gentle (non-guilt) motivation, and
privacy-first local storage. Today is the intended daily center. The long-term
vision (deep personalization, 30-day plans, ethical premium, sync) lives in
`Bismillah Engineering Constitution.md` and the PRD — treat those as aspiration,
not a current feature list.

## 3. Architecture

- Clean Architecture, **feature-first** (`domain / application / data / presentation`).
- **Riverpod** (single state/DI), **GoRouter** (single router, 5-branch shell).
- **Drift** (SQLite) for prayer log + sync queue; **SharedPreferences** for
  everything else. Custom `AppLocalizations` (not ARB) for TR/EN/AR.
- Architecture-boundary tests prevent UI from importing Firebase/DB/audio SDKs.
- No external generative AI anywhere.

## 4. Feature status

- **Today** — PARTIALLY_IMPLEMENTED: summary hub + one deterministic personalized
  suggestion. No plan engine (DailyPlan domain is dormant scaffolding).
- **Prayer** — IMPLEMENTED: offline device-computed times, mark/undo log (Drift),
  7-day history, local exact-alarm reminders. No Qibla/adhan yet.
- **Quran** — IMPLEMENTED (most mature): Tanzil reader, QuranEnc Turkish
  translation, offline search + verse-ref + Ayetel Kürsi alias, bookmarks, resume,
  device-local progress, reciter selection, MP3Quran audio, Android background /
  lock-screen / media-notification playback.
- **Learn** — engine IMPLEMENTED, coverage PARTIAL: publication gate
  (`sourceBodyVerified` + locator + evidence); 30 published / 2 pending; only 9 of
  20 categories populated (purity/prayer-heavy).
- **Profile** — IMPLEMENTED: personalization summary, language switch, content
  sources, privacy/data reset, About (live version via package_info_plus).
- **Assistant** — IMPLEMENTED: deterministic, local, published-only retrieval;
  source citations; refuses rulings without a verified official source; refuses
  personal fatwas; history capped at 20; sensitive queries not persisted.
- Five fixed tabs (Today, Prayer, Quran, Learn, Profile); **Assistant is a FAB /
  root route, not a sixth tab**.

## 5. Test and device validation

- Flutter analyze clean; **586/586** Flutter tests; **11/11** storage tests;
  **23/23** Functions tests (Vitest on Node 22).
- Real-device: Quran audio/background/lock-screen/search/reader verified on
  **Samsung Galaxy A36 / Android 16**.
- iOS: no physical-device validation. Platform behaviors (notifications, audio,
  location, Firebase) are otherwise only mock-tested.

## 6. Content and source safety

- Quran text: **Tanzil Uthmani v1.1** (114/6236, CC BY 3.0, unmodified). Structural
  verification complete; full byte-for-byte upstream diff not done (open item).
- Turkish translation: **QuranEnc Rowad V1.0.4** (6236 records, unmodified).
  Spot-check only (6 suras / 491 verses); no full-corpus compare.
- Learn: original short summaries grounded in six official **Diyanet** sources,
  each with an exact locator + evidence. No Diyanet endorsement; not an official
  Diyanet app. Canonical Turkish; EN/AR are translations.

## 7. Firebase and backend status

- Client config only (public identifiers, not secrets). Anonymous auth bootstrap.
- **No Firestore / Analytics / Crashlytics / FCM wired.** Cloud sync is not active
  (sync queue accumulates locally; no push engine).
- Cloud Functions: single callable `getQuranChapterTranslation` (Diyanet proxy,
  inactive in the app flow). **Runtime is Node.js 22** (TASK 068). App Check is a
  documented TODO, not enforced. Functions CI runs npm ci / lint / build / vitest.

## 8. Monetization status

- DORMANT scaffolding only: premium domain models + placeholder screens; routes
  `/premium`, `/settings/subscription`. **No payment SDK** (no RevenueCat / IAP).
- Canonical pricing and tier decisions: see `docs/business/MONETIZATION_DECISIONS.md`.
- First possible real revenue: **TASK 115**. Commercial validation: **TASK 122**.

## 9. Store readiness

- Not on any store. Blockers: iOS validation + no release signing, Firebase console
  hardening, store assets/screenshots, App Check, thin Learn coverage, and the
  Today plan engine (flagship gap).

## 10. Known risks and blockers

- TASK 066 BLOCKED: drift_dev ≥2.34.1 needs analyzer ^13; Flutter 3.44.6 caps
  analyzer <13. PR #4 (Drift) deferred; interim SQL snapshot baseline kept.
- Empty `onUpgrade` migration placeholder; no migration tests yet; no encryption.
- Firebase Console hardening unverified (key/API restrictions, Rules, App Check).
- iOS unvalidated; single-device Android validation only.
- PR #6 (fast-xml-parser) pulls @nodable/entities 2→3 (transitive; TASK 069).

## 11. Current roadmap position

Checkpoint **CP09 — Technical stabilization**. Latest completed functional task:
**TASK 068**. Current documentation task: **TASK 068A**. Next functional task:
**TASK 069** (fast-xml-parser PR #6 on Node 22). See
`docs/project-state/MASTER_EXECUTION_ROADMAP.md`.

## 12. Canonical source-of-truth rules

- Repository code + current Git HEAD/`origin/main` override any stale document.
- Never present old Isar/Firebase/RevenueCat design docs as current: the code uses
  **Drift** (not Isar), Firebase backend is mostly unwired, and there is no payment SDK.
- Never invent tasks, tests, sources, religious claims, or device validation.
