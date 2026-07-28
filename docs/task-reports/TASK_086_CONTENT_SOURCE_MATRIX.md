# TASK 086 — Content-Source Matrix

**Checkpoint:** CP11 (Learn and Assistant depth) — first task
**Type:** audit / governance (documentation + one validation test; no production code)
**Starting branch/commit:** `main` @ `969414f` (= `origin/main`)
**Branch:** `task/086-content-source-matrix`

## Roadmap gate

`MASTER_EXECUTION_ROADMAP.md` defines TASK 086 as **Content-source matrix**, the
first task of CP11. That matches the executed scope. No task number was invented
and no roadmap entry was renumbered.

An existing canonical document already covered attribution and delivery
(`docs/CONTENT_SOURCES.md`), so a competing source-policy architecture was **not**
created. The new matrix is a separate artifact type the roadmap explicitly asks
for; licensing facts stay in `CONTENT_SOURCES.md` and `THIRD_PARTY_NOTICES.md`,
the matrix references them, and `CONTENT_SOURCES.md` now links to the matrix so
there is one entry point and no duplicated source facts.

## Canonical matrix location

`docs/CONTENT_SOURCE_MATRIX.md` — 22 rows, each with a stable kebab-case ID.

## Audited content areas

Quran Arabic text · Quran chapter metadata · Quran verse-page map · Quran Turkish
translation · Quran search index · Quran recitation audio · Quran reciter catalog ·
remote Diyanet translation callable · Learn articles · Learn prayer education ·
Learn categories · Learn source registry · Learn plan catalog · prayer-time
calculation · prayer name labels · dua content · dhikr content · onboarding copy ·
Today plan item copy · Assistant retrieval corpus · Assistant safety copy ·
Profile source-reference registry.

No fictional row was created. `dua-content` and `dhikr-content` are recorded as
**NOT IMPLEMENTED** because the repository holds domain interfaces only — no
implementation, asset or route.

## Evidence method

Every claim was taken from a real repository artifact: asset headers and metadata
blocks, article verification records, `sources.json`, generator scripts under
`tool/`, repository and provider wiring in `lib/`, the Functions source, and the
existing content-integrity tests. Article counts, review statuses, verification
methods, TR/EN/AR ID parity, source usage and category population were **recomputed
from the shipped JSON**, not read from prior reports. Where the repository does not
establish a fact — notably translation licensing — the matrix records `UNRESOLVED`
rather than filling it from general knowledge.

## Results

**Status counts:** READY **8** · READY WITH DOCUMENTED LIMITATION **11** ·
REVIEW REQUIRED **1** · BLOCKED **0** · NOT IMPLEMENTED **2**.

- **Quran:** Tanzil Uthmani v1.1 (CC BY 3.0) and Tanzil metadata are bundled,
  generator-produced and unmodified. The only translation is QuranEnc/Rowad
  `turkish_rwwad` V1.0.4. Both carry documented limitations: **no full-corpus
  upstream diff** was ever performed (structural verification for the text, a
  6-sura / 491-verse spot check for the translation). Audio is MP3Quran, remote
  only, with no redistribution licence claimed.
- **Learn:** 32 records per locale — **30 published, 2 `scholarlyReviewPending`** —
  identical in all three locales, with identical review statuses. All 30 published
  records carry `verificationMethod = sourceBodyReview`, an exact locator, an
  evidence summary and a `verifiedAt`; the 2 pending records carry
  `urlExistenceCheck` only and are excluded by the repository. Every referenced
  source ID resolves to a registered `sources.json` record; no orphan reference
  exists. Learn is **READY**.
- **Dua / dhikr / prayer:** dua and dhikr are **NOT IMPLEMENTED** and remain an
  open owner decision. Prayer educational text exists only as a subset of the
  Learn corpus (8 `cat-prayer` + 10 `cat-purity` published articles). Prayer times
  are computed offline by `adhan_dart`'s `turkiye()` preset and are labelled
  "Türkiye hesaplama yöntemi" — the code and the interface both avoid any official
  Diyanet claim, which the matrix records as correct honest labelling.
- **Onboarding / Today copy:** classified as `internal-ui-copy`, not sourced
  religious teaching. "Continue your Quran habit" and "Daily prayer tracking" are
  tracking actions; `estimatedMinutes` is an in-app interaction budget.

## Locale findings

TR/EN/AR carry **identical stable article ID sets and identical review statuses**;
Turkish is `original` and EN/AR are `explanatoryTranslation` on every record. The
repository additionally intersects each locale against the canonical Turkish
published ID set, so a translation cannot publish what Turkish does not. Categories
carry all three locales. The one real gap is the Quran translation: **TR only** —
there is no EN or AR meal asset, and the Quran locale exception means non-Turkish
app locales see Turkish translation content by design.

## Assistant boundary

Approved inputs: published Learn articles (via `getAllPublished`), category titles
(weak ranking signal only) and the source registry (citation + official redirect).
Excluded: all pending/draft records, Quran text/translation/audio, prayer-time
output, the non-existent dua/dhikr content, and **every `internal-ui-copy` row**.
Safe fallback: a neutral no-verified-source answer, with verdict-class queries
redirected to the registered Diyanet question service; any read failure produces
the same safe empty answer. No `officialFatwa` content exists, so
`isVerdictCapable` is unreachable today — intended, and now recorded. No Assistant
behaviour was implemented or changed.

## Attribution / licensing unknowns

- **QuranEnc / Rowad translation:** usage restrictions and required attribution are
  recorded, but **no licence grant** is — `UNRESOLVED`, unlike the Tanzil text's
  explicit CC BY 3.0.
- **Diyanet Kuran API via the deployed callable:** no repository evidence
  establishes permission to redistribute that content — `UNRESOLVED`.
- Both are recorded as unknowns. No permission or licence was invented.

## Blockers and follow-up ownership

No P0 or P1 issue was found. Specifically: no published religious content lacks an
identifiable source; no registry entry mismatches shipped content; no locale set
represents different religious subjects; no review-pending content is exposed as
published; the Assistant cannot reach unpublished material; and no evidenced
licensing conflict exists for content that actually ships.

Six P2 findings are recorded in the matrix:

| ID | Issue | Owner |
|---|---|---|
| F1 | Assistant sensitive-query persistence excludes `worshipRule`, while the classifier's own `isSensitiveVerdict` includes it — and that helper has **no production caller** | TASK 094 |
| F2 | `app_source_reference.dart` duplicates `sources.json` facts with no cross-check test | TASK 094 |
| F3 | QuranEnc translation licensing unestablished | UNRESOLVED — owner decision |
| F4 | Deployed Diyanet callable is client-inactive; licensing unresolved; runs EOL `nodejs20`; App Check still a TODO | existing P1 redeploy + G7 (TASK 134) + owner |
| F5 | 3 of 6 registered sources ground no published article; 11 of 20 categories empty | TASK 087–090, TASK 092 |
| F6 | Tanzil and QuranEnc corpora never fully diffed upstream | UNRESOLVED — owner decision |

## Intentionally unchanged

No religious content was written, edited, repaired or reclassified. No article,
category, source record, Quran asset or localization string was modified. Learn,
Assistant and monetization scope were not broadened. Deliberately **not** addressed
here and preserved as unresolved: Bismillah+ pricing, supporter tiers, LÖSEV,
advertising creatives, AI-ad disclosure, and the unnamed Firebase gates.

## Validation

A small durable check was added at
`bismillah_app/test/content/content_source_matrix_test.dart` (**14 tests**). It
validates the matrix document itself — unique stable IDs, summary/detail agreement
including status, all 18 required fields present, closed value sets for status,
source class, delivery and allowed consumers, a `Limitation` field wherever a
limitation status is claimed, `NOT IMPLEMENTED` rows asserting no consumer or
delivery, no `UNRESOLVED`/`UNKNOWN` inside a `READY` row, and **every cited
repository path actually existing on disk**. It deliberately does **not** duplicate
`learn_content_integrity_test.dart`, which already owns article, source and locale
verification.

Two real defects were caught by the test during authoring and fixed: the parser was
absorbing the Findings section into the last row, and one `Delivery` value carried
a parenthetical instead of a bare token.

- `flutter analyze`: **clean** (0 errors, 0 warnings, 0 infos)
- Matrix suite: **14 / 14** — `flutter test test/content`
- Content governance suite: **199 / 199** —
  `flutter test test/features/learn test/features/assistant test/features/profile/content_sources_test.dart test/content`
- Full Flutter suite: **1422 → 1436**, 0 failed, 0 skipped
- Functions tests: **not run** — no Functions file, dependency or lockfile changed
  (last verified 23/23 at TASK 085)
- Production Dart and assets: **zero files changed** (only `docs/CONTENT_SOURCES.md`
  gained a cross-reference; the matrix and the test are new files)

## Next roadmap task

**TASK 087 — Learn pack: Hadith, Seerah, Prophets** (CP11).
