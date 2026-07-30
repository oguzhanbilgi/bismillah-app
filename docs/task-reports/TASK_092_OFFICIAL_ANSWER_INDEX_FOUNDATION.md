# TASK 092 — Official-answer / fatwa-source index foundation

Checkpoint: **CP11 — Learn and Assistant depth**
Branch: `task/092-official-answer-index-foundation`
Starting commit: `06d1925`

## Scope as read from the repository

TASK 092 is defined in the roadmap, `TASK_INDEX.md`, `CURRENT_BASELINE.md` and
`MASTER_PROJECT_STATE.json` as a **one-line entry with no acceptance criteria**,
no storage format, no record count and no approval gate. Scope was therefore read
narrowly — the same discipline TASK 090 and TASK 091 applied to their own
underspecified entries — and nothing was inferred that the repository does not
state.

Delivered: **the index contract only, with zero production records.** No
Assistant wiring (that is TASK 093), no UI, no network, no persistence key, no
migration, no dependency change.

## What ships

New feature module `lib/features/official_answers/`:

- `domain/entities/official_answer_record.dart` — per-record entity. Fields are
  id · topic · summary · sourceId · sourceUrl · reviewStatus · verification ·
  locale · isGeneralInformationOnly. It carries **no answer body field at all**,
  so the module is structurally incapable of holding a composed ruling.
- `domain/value_objects/official_answer_publication_gate.dart` — the dedicated
  gate (below), returning a typed `OfficialAnswerGateIssue` list, never free text.
- `domain/entities/official_answer_index.dart` — per-locale index; rejects
  duplicate ids; `published` is the single retrieval chokepoint.
- `domain/repositories/official_answer_repository.dart` — read-only contract.
  There is no write or compose API.
- `data/official_answer_index_parser.dart` — strict pure-Dart parser/validator,
  throwing the existing `ContentSchemaError`. `validSources` is **required**.
- `data/asset_official_answer_repository.dart` — offline `AssetBundle` loader.

Assets `assets/content/official_answers/index_{tr,en,ar}.json`, each exactly
`{"schemaVersion": 1, "locale": "<x>", "answers": []}` — **zero records in all
three locales**.

## The dedicated publication gate (owner decision)

The generic Learn article publication gate is **deliberately not** the final gate
for official answers. `SourceVerification.satisfiesPublicationGate` never inspects
`verifiedBy`, so reusing it would let `editorialReview` publish a fatwa-shaped
record. It is now reused only as **one component** of a stricter gate.

A published, retrievable official-answer record requires **all** of:

- `reviewStatus == published`
- source body verified (Learn component gate satisfied)
- **`verifiedBy == scholarlyReview`** — `editorialReview` and
  `automatedSourceCheck` both **fail**
- an **approved authority source**: only the two authority-typed registry ids
  (`diyanet-din-isleri-yuksek-kurulu` / `fatwa`,
  `diyanet-dini-soru-hizmetleri` / `officialAnswer`), which are read from
  `sources.json` rather than invented, and additionally `isOfficial` with
  `sourceType` in {`fatwa`, `officialAnswer`}
- a non-empty `sourceUrl`: absolute `https`, passing the existing
  `OfficialSourceDomains` allowlist, and on a path **strictly deeper** than the
  source's own `canonicalUrl` — a bare fatwa landing page cannot be presented as
  an exact answer address
- a non-empty exact `sourceLocator`
- a stable unique `oa-` id containing no `:`
- locale consistency
- `isGeneralInformationOnly == true`

The gate runs at **both** construction and the retrieval boundary. The
`final class` record has one generative constructor, no `copyWith`, no
`fromJson` and an unmodifiable answer list, so a published-but-ungated record
cannot be constructed at all; the retrieval filter is retained as a guard
against a future shortcut rather than as today's only defence.

**The Learn article gate was not touched.** No file under
`lib/features/learn/` or `assets/content/learn/` is modified, and a negative-control
test asserts `editorialReview` still satisfies the Learn gate — so a later
refactor cannot globally tighten Learn without failing the suite.

`verifiedBy: scholarlyReview` is a **data field this gate checks, not evidence
that a qualified human review occurred.** No agent may record it. A qualified
human scholarly reviewer is required before any real record ships.

## Boundaries preserved

- **Zero production records.** Asserted structurally and by a raw-text scan
  proving no `oa-` id appears in any shipped index asset.
- **No consumer.** No production code calls the repository; a source-scan test
  asserts no file under `lib/` outside `official_answers/data` references
  `getIndex(`.
- **No personal fatwa path.** No answer body field, no compose or write API,
  `getById` returns `null` for a missing or ungated record and **never falls back
  to Learn content**.
- **Privacy.** No raw user question is stored, logged or echoed — `topic` and
  `summary` are authored asset fields. No network, Firebase, SharedPreferences,
  new storage key or migration. Parse and asset failures collapse to a bare
  `StorageFailure` with no leaked id, path or exception prose; `_guard` contains
  `Error` as well as `Exception`, because the record's own `ArgumentError` would
  otherwise escape and leak validation text.
- Remote sync stays disabled. `art-dua-adabi` unchanged.
  `LearnDailyPlanCatalog.v1` unchanged (30 entries). No Learn article content
  changed.

## Governance

`docs/CONTENT_SOURCE_MATRIX.md` gains one row, `official-answer-index`, as the
CP11 content-governance rule requires. Status **READY WITH DOCUMENTED
LIMITATION** — the contract is shipped and tested but grounds no content, so
`READY` would be false and `NOT IMPLEMENTED` would also be false. Recorded
limitations: zero published records; no consumer wired; a qualified human
scholarly reviewer required before any real record; and `isGeneralInformationOnly`
is **declarative** — nothing verifies that a body is not a personal ruling.

## Tests

`test/features/official_answers/task_092_official_answer_index_test.dart` — **49**
focused tests. Load-bearing coverage, each proving a real rejection rather than a
count:

- `editorialReview` and `automatedSourceCheck` rejected for a published record
- non-authority source (`diyanet-islam-ilmihali`, a book) rejected
- missing `sourceUrl`, non-Diyanet host, and a URL equal to the source's bare
  `canonicalUrl` all rejected
- empty locator rejected — asserted honestly at **both** levels, since the parser's
  generic-homepage rule fires before the gate's `missingSourceLocator`
- empty evidence summary asserted to land on `weakSourceVerification`, explicitly
  **not** on `missingSourceLocator`
- a fully compliant synthetic `scholarlyReview` fixture passes the gate and is
  returned by `getPublished` / `getById`
- duplicate ids rejected; draft and `scholarlyReviewPending` excluded
- malformed assets yield `Result.isFailure` with no throw and no leaked text
- all three production indexes load deterministically with exactly zero records
- negative control: the **Learn** gate still accepts `editorialReview`
- synthetic fixtures proved test-only; no `oa-` id in any shipped asset

Rejection cases assert the specific `OfficialAnswerGateIssue`, not merely "a throw".
No unrelated growing total is frozen.

## Validation

- Focused TASK 092: **49 / 49**
- Content governance (`test/content`, incl. the new matrix row): **14 / 14**
- Learn + Assistant + content + catalog: **379 / 379** — identical to the
  TASK 091 baseline, no regression
- `flutter analyze`: **clean** (0 errors, 0 warnings, 0 infos)
- Full Flutter suite: **1639 / 1639** (1590 baseline + 49), re-run after the
  final hardening changes
- Functions: **not run** — no Functions file, dependency or lockfile changed
- Device validation: **not required** (no platform or native change)

## Critical review

- Pre-implementation (Opus): **BLOCKED** — 7 blockers. The gate reused Learn's
  and so admitted `editorialReview`; no `sourceUrl` field existed; any registered
  source including a book could ground a published record; the retrieval boundary
  filtered on `isPublished` only; `_guard` did not contain `Error`; and a merged
  test asserted the forbidden `editorialReview` success as correct. All were the
  owner's already-recorded requirements not yet implemented — no unresolved
  product or religious decision — so they were implemented rather than escalated.
- Final (Opus): **PASS WITH FOLLOW-UPS**, all 7 blockers verified closed.

## Deferred (recorded, not expanded into TASK 092)

- Assistant retrieval wiring and no-source UX — **TASK 093**. It must consume
  `getPublished` only, never `getIndex`, which deliberately exposes unpublished
  records for internal audit.
- `isGeneralInformationOnly` remains declarative; verifying that a body is not a
  personal ruling has no owning task.
- A **qualified human scholarly reviewer** for real official-answer records — still
  unowned, as it was for `art-dua-adabi`.
- Unchanged from TASK 091: `art-dua-adabi` review, and the four TASK 090
  candidates classified SCHOLARLY REVIEW REQUIRED.
