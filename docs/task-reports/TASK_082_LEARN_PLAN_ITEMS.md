# TASK 082 — Source-Verified Learn DailyPlan Items

## 1. Executive summary

`LearnDailyPlanItemSource` is the **third and final approved core
`DailyPlanItemSource`**. When the onboarding goal `islamicKnowledge` is
present it emits **exactly one** Learn item per generated day, selected by
zero-based `dayOffset` from an explicit, immutable, versioned 30-entry
catalog (`LearnDailyPlanCatalog.v1`). Each entry costs
`estimatedMinutes = 1` (in-app interaction budget). When `islamicKnowledge`
is absent the source returns an **empty list — not a failure**.

The content stop gate **passed with no content change**: the shipped Learn
assets contain **exactly 30** articles that are `published`, carry a
`sourceBodyReview` verification record satisfying the publication gate, and
exist under the same stable IDs in **all three locales (TR/EN/AR)**. No
article was padded, duplicated, weakened or newly authored.

`CoreDailyPlanItemSource` now bundles the approved **Prayer → Quran → Learn**
order through the unchanged `CompositeDailyPlanItemSource`. Appending Learn
**does not shift** existing Prayer or Quran slots or final item IDs (proved
for all 30 days). The complete core day costs **5 minutes**, which the
`light` budget accepts **exactly**.

163 focused TASK 082 tests. Full Flutter suite **1015 → 1178**.
**Zero tracked files modified — new files only.** No article asset edit, no
Learn repository read during generation, no persistence, no Today UI, no
Drift change, no Firebase write; remote sync stays disabled.

## 2. Previous task and purpose

TASK 081 delivered `QuranDailyPlanItemSource` and the deterministic
`CompositeDailyPlanItemSource`, and explicitly reserved the third slot:
*"TASK 082 (Learn) is the first source expected to reference real content
IDs — and it may use only published, source-verified Learn article
identifiers."*

TASK 082 fills that slot. It is the first plan source that attaches a
concrete content reference (`targetRef`), so the source-verification gate is
the central constraint of this task, not an afterthought.

## 3. Product / free-tier classification

TASK 082 is **free core product**. Specifically free and ad-free:

- the basic 30-day DailyPlan
- the source-verified Learn item inside that basic plan
- opening the referenced starter Learn article
- source and reference visibility

**No Bismillah+ paywall, entitlement check, supporter tier, price, purchase
flow or upsell was added.** Future Bismillah+ Learn value (advanced learning
paths, user-selected topic weighting, extra regeneration, deeper learning
history, premium visual customization) is explicitly **out of scope here**
and was not scaffolded.

Store/marketing boundaries respected: this supports the claim that Bismillah
combines prayer, Quran and learning in one personal daily plan. It does
**not** justify a paywall by itself, must **not** be described as complete
Islamic education, and implies **no religious authority or certification**.

## 4. Closed-alpha and professional-product impact

Completing TASK 082 makes the plan engine **structurally ready for the next
orchestration stage** — all three approved core sources exist and compose
deterministically.

It does **not** make the product alpha-ready. The plan is still never
generated at runtime, never persisted, never completed and never displayed.
Alpha readiness requires generation to be connected, persisted, given
completion state, and surfaced in the Today UI. That work is TASK 083+.

## 5. Content / catalog stop gate — PASSED

All §4 gate conditions were verified against the actual asset files before
the branch was created.

| Gate | Requirement | Result |
|---|---|---|
| 4.1 Published count | exactly 30 eligible | **30** (32 total, 2 excluded) |
| 4.2 Locale identity parity | TR/EN/AR same stable ID set | **identical** |
| 4.3 Source verification | every selected article verified | **30/30** |
| 4.4 Stable ordering | canonical order exists? | **partial only** → explicit catalog created |
| 4.5 Representation | `PlanItemDraft`/`PlanItem` can hold it | **yes, no domain change** |
| 4.6 Template identity | collision-free stable identity | **yes, lossless** |

Nothing was weakened to make the task pass. No asset was edited.

## 6. Existing Learn content facts

Measured from `bismillah_app/assets/content/learn/`:

- **32** articles per locale file (`articles_tr.json`, `articles_en.json`,
  `articles_ar.json`), same ID sequence in all three.
- **30** are `reviewStatus: published`.
- **2** are `scholarlyReviewPending` and are therefore **excluded**:
  `art-kuran-okumaya-baslangic` and `art-dua-adabi`. They carry only a
  `urlExistenceCheck` verification record and cannot pass the publication
  gate.
- All 30 published articles carry `reviewedAt`, a non-empty `sourceIds`
  list, and a `verification` record whose `sourceId` is one of the six
  registered official Diyanet sources in `sources.json`.
- 9 of the 20 declared categories are populated; the plan catalog uses
  whatever is published, not a category quota.

**No article content, translation, source record or review status was
modified by this task.**

## 7. Source-verification evidence

An article is **eligible** for the plan only when all of the following hold,
evaluated through the existing production parser and domain constructor
(`LearningContentParser.parseArticles` → `LearningArticle`):

1. `reviewStatus == published`
2. `verification.sourceBodyVerified == true`
3. `verification.satisfiesPublicationGate == true`, i.e. non-empty
   `sourceLocator`, non-empty `evidenceSummary`, non-empty `verifiedAt`, and
   `verificationMethod.isStrongerThanUrlCheck`
4. `sourceIds` non-empty and containing `verification.sourceId`
5. `reviewedAt` present

Measured result: **30 eligible in TR, 30 in EN, 30 in AR**, and the three
sets are identical. All 30 use `verificationMethod: sourceBodyReview`.
The two excluded articles use `urlExistenceCheck` and fail condition 3.

This is enforced continuously — the catalog test re-derives eligibility from
the real assets on every run rather than trusting a hard-coded list.

## 8. Locale identity parity

- The TR, EN and AR files declare the **same 32 article IDs in the same
  sequence**, and the same 30 published IDs.
- `LearningContentParser.validateLocaleConsistency` passes with TR as
  canonical (no translation is published while the Turkish canonical record
  is not).
- Localized **titles, summaries and bodies differ** — that is expected and
  allowed. Only the stable machine identity is shared, and only the stable
  identity enters the plan.
- Catalog order is therefore **locale-independent**: no locale is consulted,
  no localized string is sorted, no runtime locale reaches the source.

## 9. Approved TASK 082 product decisions

These are **TASK 082 decisions**. They were not defined by earlier
documentation and are not presented as inherited.

1. **Goal-based inclusion.** Only `OnboardingFocusGoal.islamicKnowledge`
   triggers a Learn item. `learning_focused` **profile alone produces
   nothing**; `beginner`, `returning`, `advanced` and `low_time` change
   nothing; unrelated goals change nothing. The profile mapper is never
   re-run.
2. **One article per day, no cycling.** `dayOffset` *is* the catalog index.
   No modulo, no repetition, no randomness, no locale sorting, no asset-file
   order, no current date, no profile or phase reordering.
3. **`estimatedMinutes = 1`** — the minimum DailyPlan interaction allocation
   for opening or continuing the referenced starter article. It is **not**
   the time needed to study the article, a religiously sufficient study
   duration, a mandatory learning amount, a ruling, or spiritual value.
4. **Catalog order.** Entries 0–10 follow the **already-existing editorial
   `beginnerPathOrder`** field (published members only, ascending:
   1,2,3,4,5,6,7,8,9,10,13) — this part is **source-backed**. Entries 11–29
   are a **TASK 082 product decision**: the remaining 19 published articles
   grouped by the existing `categories.json` `sortOrder` (purity 3 → prayer
   4 → fasting 5 → zakat 6 → hajj 7), with the within-group sequence written
   explicitly for topic continuity.
5. **Prayer → Quran → Learn** remains the composite order — a deterministic
   product/display rule, **not a religious ranking**.

## 10. Versioned 30-item catalog

`LearnDailyPlanCatalog` (`lib/features/today/domain/value_objects/`) is an
immutable `const` value type holding an explicit ordered list of
`LearnPlanCatalogEntry`. Each entry holds **only** a stable `articleId`.

It contains **no** localized title, summary, body, translation, source text,
locale, user-facing description, reward claim, religious judgment, date, UID
or device data.

`validate()` returns a typed `LearnPlanCatalogIssue` (`entryCountMismatch`,
`blankArticleId`, `duplicateArticleId`, `unsafeArticleId`) or `null`. This
mirrors the TASK 079 `GenerationRequestIssue` pattern and required **no new
`AppFailure` subtype and no new localization key**.

`LearnDailyPlanCatalog.v1` — the production catalog, in plan order:

| # | Article ID | Source of position |
|---|---|---|
| 0 | `art-islam-nedir` | `beginnerPathOrder` 1 |
| 1 | `art-imanin-sartlari` | 2 |
| 2 | `art-islamin-sartlari` | 3 |
| 3 | `art-kelime-i-sehadet` | 4 |
| 4 | `art-abdest-nasil-alinir` | 5 |
| 5 | `art-abdestin-farzlari` | 6 |
| 6 | `art-namaza-hazirlik` | 7 |
| 7 | `art-bes-vakit-namaz` | 8 |
| 8 | `art-namazin-bolumleri` | 9 |
| 9 | `art-kuran-nedir` | 10 |
| 10 | `art-tevbe-ve-umit` | 13 (11–12 unpublished) |
| 11 | `art-abdesti-bozan-durumlar` | TASK 082 decision — purity |
| 12 | `art-abdestin-sunnetleri` | TASK 082 decision — purity |
| 13 | `art-temizligin-cesitleri` | TASK 082 decision — purity |
| 14 | `art-necaset-nedir` | TASK 082 decision — purity |
| 15 | `art-mest-uzerine-mesh` | TASK 082 decision — purity |
| 16 | `art-gusul-nasil-alinir` | TASK 082 decision — purity |
| 17 | `art-guslu-gerektiren-haller` | TASK 082 decision — purity |
| 18 | `art-teyemmum-nedir` | TASK 082 decision — purity |
| 19 | `art-namaz-vakitleri` | TASK 082 decision — prayer |
| 20 | `art-namazin-farzlari` | TASK 082 decision — prayer |
| 21 | `art-namazin-vacipleri` | TASK 082 decision — prayer |
| 22 | `art-namazin-sunnetleri` | TASK 082 decision — prayer |
| 23 | `art-cemaatle-namaz` | TASK 082 decision — prayer |
| 24 | `art-oruc-kimlere-farzdir` | TASK 082 decision — fasting |
| 25 | `art-orucu-bozan-durumlar` | TASK 082 decision — fasting |
| 26 | `art-zekatin-sartlari` | TASK 082 decision — zakat |
| 27 | `art-zekat-kimlere-verilir` | TASK 082 decision — zakat |
| 28 | `art-hac-kimlere-farzdir` | TASK 082 decision — hajj |
| 29 | `art-kurban-nedir` | TASK 082 decision — hajj |

The catalog is validated against the real assets by test: it fails if an
article becomes unpublished, is removed, loses a locale, loses required
source metadata, gains a duplicate, or if the count leaves 30.

## 11. Learn source contract

`LearnDailyPlanItemSource` is `const`, stateless apart from the injected
immutable catalog, pure and deterministic. It reads **only**
`DailyPlanDayContext` (goals + `dayOffset`) and the catalog.

It has **no** `LearningKnowledgeRepository`, no `LearningProgressRepository`,
no asset-bundle read at generation time, no SharedPreferences, no Drift, no
Firebase, no network, no `BuildContext`, no Riverpod `Ref`, no system clock,
no locale, no timezone, no randomness, no logging and no side effects. This
is asserted structurally by test over the production source files, not only
behaviourally.

The production catalog is the `const` default parameter; tests inject a
controlled catalog through the same constructor.

## 12. Goal-based inclusion

```
goals contains islamicKnowledge  -> [ one Learn PlanItemDraft ]
goals does not contain it        -> [ ] (success, not a failure)
```

`trackPrayers`, `prayOnTime`, `quranHabit` and `dhikrRoutine` are ignored.
All five goals selected still produces **exactly one** Learn contribution.
Goal `Set` insertion order does not affect output (the request normalizes to
enum declaration order, per TASK 079).

## 13. Day-offset selection

`context.dayOffset` **is** the catalog index: offset 0 → entry 0, offset 29 →
entry 29. All 30 mappings are asserted individually by table-driven test, and
the 30 resulting article IDs are proved unique — no article appears twice in
a 30-day plan.

Structurally invalid offsets are rejected rather than wrapped: `dayOffset < 0`
or `>= catalog.entries.length` returns a typed `ValidationFailure`. Because
the goal check runs first, an out-of-contract offset with no `islamicKnowledge`
goal still returns an empty success — the source never invents a failure it
was not asked to evaluate.

`dayKey`, `dailyPace`, `weekIndex`, profile and locale do not participate in
selection.

## 14. Stable article and template identities

- `targetRef` = the raw stable article ID (e.g. `art-kelime-i-sehadet`).
- `templateId` = `learn_article_<articleId>` — a **lossless** concatenation.
  The article ID is not normalized, truncated, lowercased or hashed, so two
  distinct articles can never collide on one template ID.
- No `hashCode`, no UUID, no timestamp, no locale-sensitive string and no
  hashing dependency is used. (`hashCode` appears in the catalog **only** as
  the value-equality counterpart of `operator ==`; a test pins that to the
  single override line.)
- Article IDs are verified not to contain the `:` separator used by
  `DailyPlanItemIdBuilder`, so the composed final ID stays unambiguous.

Final IDs keep the TASK 079 format, e.g. for `2026-07-26` with all four core
goals:

```
rule-engine-v1:2026-07-26:prayer_track_daily:0
rule-engine-v1:2026-07-26:prayer_on_time_daily:1
rule-engine-v1:2026-07-26:quran_continue_daily:2
rule-engine-v1:2026-07-26:learn_article_art-islam-nedir:3
```

## 15. PlanItem representation

| Field | Value |
|---|---|
| `templateId` | `learn_article_<articleId>` |
| `type` | `PlanItemType.lesson` |
| `targetRef` | stable Learn article ID |
| `sizeParam` | `null` |
| `estimatedMinutes` | `1` (draft only; never persisted) |
| `status` | `PlanItemStatus.pending` |
| `completedAt` | `null` |

The semantic meaning is: **open or continue the referenced source-verified
starter Learn article inside the DailyPlan experience.**

No title, summary, body, section text, translation, source locator, evidence
summary, verse, hadith, fatwa, completion quantity, religious score, or
reward/punishment wording is embedded. The representation gate passed with
**no domain change** — `targetRef` and `sizeParam` were already optional on
both `PlanItemDraft` and `PlanItem`, and `PlanItemType.lesson` already
existed.

Initial completion state is canonical `pending`. No article history, Learn
completion record or "is this today" check is consulted, and nothing is
mutated or persisted. Completion orchestration belongs to a later task.

## 16. Budget semantics

`estimatedMinutes` is a **generation budget value only** — it is not a
mandatory religious study duration, not a ruling, not spiritual value, and
it is **not written into the persisted plan**.

| Composition | Cost |
|---|---|
| Learn only | 1 |
| Quran + Learn | 3 |
| one Prayer + Quran + Learn | 4 |
| both Prayer + Quran + Learn (**complete core**) | **5** |

The `light` budget of 5 minutes therefore accepts the **complete core set
exactly**; `balanced` (10), `focused` (20) and `advanced`+`focused` (30) also
accept it. TASK 079 budget validation was **not weakened**: adding one extra
one-minute contribution on top of the complete core set under `light` makes
the whole 30-day generation fail, and **no partial output** is returned. Core
items are never silently dropped to fit a budget.

## 17. Profile and phase independence

For identical goals and day offset the Learn contribution is **identical
across all eight profiles** (`beginner`, `returning`, `prayer_focused`,
`quran_focused`, `dhikr_focused`, `learning_focused`, `advanced`,
`low_time`) — same article, same template ID, same type, same cost, same
initial state. The full 30-article sequence is proved identical across all
eight. An enum-coverage lock fails the suite if a future profile is left
untested.

`learning_focused` receives **no extra article**; `low_time` loses nothing;
`advanced` gains nothing; `beginner` is not given a reduced catalog. No
educational ability is inferred from a profile.

`weekIndex` 0–3 does not independently change article identity, template ID,
item type, estimated cost or completion state. The article changes from day
to day because `dayOffset` advances, not because a hidden phase rule applies.
No phase-based lesson difficulty exists.

## 18. Prayer → Quran → Learn composite integration

`CoreDailyPlanItemSource` exposes the approved core composition:

```dart
const CompositeDailyPlanItemSource(
  sources: [
    PrayerDailyPlanItemSource(),
    QuranDailyPlanItemSource(),
    LearnDailyPlanItemSource(),
  ],
)
```

It is a `const` compile-time value and a pure `withCatalog(...)` factory —
**not** a Riverpod provider, not an eager application-global singleton, and
not wired to bootstrap, onboarding completion or persistence. Bootstrap is
asserted not to reach it.

`CompositeDailyPlanItemSource` was **not modified**. Verified behaviour with
Learn added: each child is called once per day; ordering is
`prayer_track_daily` → `prayer_on_time_daily` → `quran_continue_daily` →
Learn template; cross-source duplicate template detection stays active; a
typed child failure returns **no partial contributions**.

Crucially, for **all 30 days**, the first three final item IDs produced with
Learn present are byte-identical to those produced without it — appending
Learn shifted no Prayer or Quran slot and changed no existing identity.

## 19. Thirty-day output

With the complete core composite and all four core goals, generation yields
exactly 30 per-day `DailyPlan` records with 30 continuous unique `DayKey`s,
4 items each, stable order, unique final item IDs, all items `pending` with
`completedAt == null`, the correct profile stable ID, and the day-`n` Learn
`targetRef` equal to catalog entry `n`. Running the same request **50 times**
produces byte-identical output.

Scenario coverage: `islamicKnowledge` only (1 item/day) · Quran + Learn (2) ·
Prayer(×2) + Learn (3) · Prayer + Quran + Learn (4) · all goals (4) · no
Learn goal (Learn absent).

## 20. Failure behavior

Existing `Result` / `AppFailure` conventions only. **No new `AppFailure`
subtype and no new localization key** were added — `ValidationFailure`
(`errorUnexpected`) was sufficient.

Typed failures: catalog count ≠ 30, blank article ID, duplicate article ID,
article ID containing the reserved separator, and out-of-contract day offset.
Budget overrun and composite duplicate detection keep their existing TASK
079/081 behaviour. A broken catalog fails the **entire** 30-day generation;
no partial plan is returned.

Failure objects expose no article body, localized title, raw catalog
contents, raw goals, `DayKey`, UID, device data, exception string, stack
trace, storage key or local file path. This is asserted by test.

## 21. Religious safety and privacy

- **Only published, source-verified article IDs** are used; the two pending
  articles are excluded and proved absent from the catalog.
- **No religious prose was invented.** No verse, hadith, ruling or fatwa text
  exists anywhere in this change.
- **No article body or localized title is copied into DailyPlan** — only the
  machine ID.
- No reward, punishment, obligation, spiritual score, rank or quota wording
  appears in any template ID.
- No learning quantity or completion quota is claimed (`sizeParam` stays
  `null`).
- No article reading history is read; every generated item starts incomplete.
- Generated plans and failures carry no UID, location, device identifier,
  raw onboarding payload, exception message, stack trace, storage key or
  absolute local path — asserted by test.
- Canonical Turkish content is untouched and remains no weaker than the
  translations.

## 22. Automated tests

**163 focused TASK 082 tests**, all passing:

```
flutter test test/features/today/domain/learn_daily_plan_catalog_test.dart \
             test/features/today/domain/learn_daily_plan_item_source_test.dart
```

- `learn_daily_plan_catalog_test.dart` — content eligibility gate against the
  real assets, source-verification evidence, TR/EN/AR identity parity,
  production-catalog composition, order determinism (including proof that the
  order is **not** the asset file order and **not** any localized title
  sort), template-identity rules, and broken-catalog rejection.
- `learn_daily_plan_item_source_test.dart` — goal selection, all 30
  day-offset mappings, PlanItem representation, profile independence (8
  profiles + coverage lock), phase independence, composite ordering,
  identity stability, budget, broken-catalog behaviour, 30-day integration
  (incl. 50-run determinism), structural no-side-effect checks, and
  religious-safety/privacy checks.

Full Flutter suite: **1015 → 1178**, 0 failed, 0 skipped.
Analyze: **clean** (0 errors, 0 warnings, 0 infos).

Regression suites re-run and reproduced unchanged: TASK 081 **70/70** ·
TASK 080 **62/62** · TASK 079 **63/63** · TASK 078 **78/78** ·
TASK 077 **43/43** · DailyPlan persistence **70/70** · canonical sync
**70/70** · Drift storage **11/11** · Quran feature **89/89** ·
**Learn feature 108/108** (measured, not assumed —
`flutter test test/features/learn`).

> **Correction (2026-07-27, TASK 083): POST-MERGE VERIFIED — 23/23.**
> The Node.js toolchain was reinstalled under NVM for Windows and verified
> at the start of TASK 083 (Node.js v22.22.0, npm 10.9.4). `npm test` in
> `functions/` passes **23/23**. The "PENDING (environment)" status below was
> a shell/`PATH` limitation at TASK 082 time, not a Functions regression;
> TASK 082 changed no Functions file. Git history was not rewritten.

**Functions tests were NOT RUN on this machine: Node.js is not installed**
(the Node install directory is still listed on `PATH` but no longer exists,
so `node` and `npm` are unavailable). TASK 082 changes
no Functions file, no `package.json` and no lockfile, so the expected
**23/23** baseline is unaffected; Functions CI verifies it on the PR. This is
recorded as `PENDING (environment)`, not as a passing result.

## 23. No UI, persistence, repository or remote changes

**Zero tracked files were modified.** The change is five new files:

```
lib/features/today/domain/value_objects/learn_daily_plan_catalog.dart
lib/features/today/domain/services/learn_daily_plan_item_source.dart
lib/features/today/domain/services/core_daily_plan_item_source.dart
test/features/today/domain/learn_daily_plan_catalog_test.dart
test/features/today/domain/learn_daily_plan_item_source_test.dart
```

Unchanged: Learn UI, Learn navigation, Learn article bodies, Learn
translations, `sources.json`, Quran reader, Prayer UI, onboarding UI, Today
UI, routes, localization files, notification scheduling, DailyPlan
persistence, SharedPreferences keys, envelope version, Drift schema,
migrations, generated Drift code, Firebase, Functions source, sync queue,
dependencies, `pubspec.yaml`/`pubspec.lock`, Android and iOS files.

No generated plan is saved. Nothing calls the generator at runtime. No
Learn repository is called by the generation source. Remote sync remains
disabled and no Firebase write exists.

## 24. Exact next task

Read from the canonical roadmap after implementation:

- **TASK 083 — Today task UI** (CP10), listed as the successor to TASK 082 in
  `MASTER_EXECUTION_ROADMAP.md` and `TASK_INDEX.md`.

Its purpose per the roadmap is the Today plan surface. Note the open
sequencing question for the owner: **generation is still not connected to
persistence and onboarding completion**, and the roadmap does not name a
dedicated task for that wiring between TASK 082 and TASK 083. TASK 084
(missed-day recovery and gentle rollover) and TASK 085 (30-day plan and CP10
checkpoint) follow. Required regression suites for TASK 083 are those in §22
plus the Today presentation suites.

No next-task work was started.

## 25. Roadmap-alignment requirement

After the current CP10 / core-plan sequence, a **dedicated
roadmap-alignment task** must incorporate the owner's approved commercial
decisions:

- free core versus Bismillah+ boundary
- first-month 29.99 TL then 69.99 TL pricing
- annual pricing strategy
- supporter tiers
- conditional LÖSEV process
- professional store presentation
- Instagram / Facebook / TikTok creatives
- AI-ad disclosure
- closed alpha and release gates

**These conflict with the current canonical record** and cannot be silently
merged into it: `docs/business/MONETIZATION_DECISIONS.md` currently fixes
Bismillah+ monthly at 79.99 TL with no introductory price, and contains no
LÖSEV, creative-production or AI-disclosure policy at all. The existing CP13
tasks (102 entitlement matrix, 104 Play products, 108 ethical paywall, 112
store materials) are the closest owners but none of them is a
decisions-reconciliation task.

**No task number is invented here.** Assigning the number is an owner
decision. None of these commercial features was implemented, scaffolded or
referenced in code during TASK 082.

## 26. Evidence appendix

- Starting branch/commit: `main` @ `b390141` (equal to `origin/main`);
  working tree clean apart from the known untracked `AGENTS.md`, which was
  not read, edited, staged, committed, deleted or ignored.
- Branch: `task/082-learn-plan-items`.
- Public tag `v0.1.0-alpha.1` → `c23f490` verified intact and not moved.
- Eligible published Learn articles: **30 / 30 / 30** (TR / EN / AR),
  identical ID sets; **2** excluded as `scholarlyReviewPending`.
- All 30 use `verificationMethod: sourceBodyReview`; all reference one of the
  six registered official sources in `sources.json`.
- Focused TASK 082 tests: **163 / 163**.
- Full Flutter suite: **1178 / 1178**, 0 failed, 0 skipped (was 1015).
- `flutter analyze`: **No issues found**.
- Learn feature suite (measured): **108 / 108** —
  `flutter test test/features/learn`.
- Functions (`npm test`): **POST-MERGE VERIFIED at TASK 083 — 23 / 23** on
  Node.js v22.22.0 / npm 10.9.4 (was NOT RUN at TASK 082 time because Node.js
  was absent from this machine); no Functions file, dependency or lockfile
  changed.
- Tracked files modified: **0**.
- Commits: `feat(today): add source-verified Learn plan items` and
  `docs(today): record Learn plan items`.
- Device validation: not required and not performed for this task.
