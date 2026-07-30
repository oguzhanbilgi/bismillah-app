# Current Baseline

Canonical, verified snapshot of the project at the time of this documentation task.

## Source-of-truth rule

> The live Git HEAD and `origin/main` are authoritative for the current commit.
> The stored commit below records the last verified baseline **before** this
> task (TASK 092). After the TASK 092 merge, read the real current commit
> from Git — do not treat the stored value as the live HEAD.

## Repository

- Canonical repo: `https://github.com/oguzhanbilgi/bismillah-app`
- Last verified main before TASK 092: `06d1925`
- Public tag: `v0.1.0-alpha.1` → `c23f490` (verified intact; must not be moved)
- Latest completed task: **TASK 092** — Official-answer / fatwa-source index
  foundation (**CP11**). The roadmap, `TASK_INDEX.md`, this file and the state
  JSON all define TASK 092 in **one line with no acceptance criteria**, no
  storage format, no record count and no approval gate; scope was read narrowly,
  the same discipline TASK 090 and TASK 091 applied to their own underspecified
  entries. Delivered: **the index contract only, with ZERO production records**,
  **no consumer**, no UI, no network, no persistence key, no migration, no
  dependency change.
  New module `lib/features/official_answers/` — record entity carrying **no
  answer body field at all** (so it is structurally incapable of holding a
  composed ruling), per-locale index rejecting duplicate ids, a **read-only**
  repository contract with no write or compose API, a strict pure-Dart
  parser/validator throwing the existing `ContentSchemaError` with a **required**
  `validSources`, and an offline `AssetBundle` loader. Assets
  `assets/content/official_answers/index_{tr,en,ar}.json`, each exactly
  `{"schemaVersion": 1, "locale": "<x>", "answers": []}`.
  **Owner decision — a DEDICATED publication gate, deliberately stricter than
  the Learn article gate.** `SourceVerification.satisfiesPublicationGate` never
  inspects `verifiedBy`, so reusing it as the final gate would let
  `editorialReview` publish a fatwa-shaped record; it is now reused only as
  **one component**. A published, retrievable record requires **all** of:
  `reviewStatus == published`; source body verified;
  **`verifiedBy == scholarlyReview`** — `editorialReview` and
  `automatedSourceCheck` both **fail**; an **approved authority source**, meaning
  only the two authority-typed registry ids
  (`diyanet-din-isleri-yuksek-kurulu` / `fatwa`,
  `diyanet-dini-soru-hizmetleri` / `officialAnswer`) **read from `sources.json`
  rather than invented**, plus `isOfficial` and a `sourceType` check; a non-empty
  `https` `sourceUrl` passing the existing `OfficialSourceDomains` allowlist and
  on a path **strictly deeper** than the source's own `canonicalUrl`, so a bare
  fatwa landing page can never be presented as an exact answer address; a
  non-empty exact locator; a stable unique `oa-` id containing no `:`; locale
  consistency; and `isGeneralInformationOnly`. Issues are a typed
  `OfficialAnswerGateIssue` list, never free text.
  The gate runs at **both** construction and the retrieval chokepoint. The
  `final class` record has one generative constructor, no `copyWith`, no
  `fromJson` and an unmodifiable answer list, so a published-but-ungated record
  **cannot be constructed**; the retrieval filter is retained as a guard against
  a future shortcut rather than as today's only defence.
  **The Learn article gate was NOT touched** — no file under
  `lib/features/learn/` or `assets/content/learn/` is modified — and a
  **negative-control test asserts `editorialReview` still satisfies the LEARN
  gate**, so a later refactor cannot globally tighten Learn without failing the
  suite. `verifiedBy: scholarlyReview` is a **data field the gate checks, NOT
  evidence that a qualified human review occurred**; **no agent may record it**,
  and a qualified human reviewer is required before any real record ships.
  Privacy: no raw user question is stored, logged or echoed (`topic` and
  `summary` are authored asset fields); no network, Firebase, SharedPreferences,
  new storage key or migration; `getById` returns `null` for a missing or ungated
  record and **never falls back to Learn**. `_guard` now contains `Error` as well
  as `Exception`, because the record's own `ArgumentError` would otherwise escape
  and leak validation prose — failures collapse to a bare `StorageFailure`.
  **The pre-implementation Opus review returned BLOCKED with 7 blockers** (the
  gate reused Learn's and so admitted `editorialReview`; no `sourceUrl` field
  existed; any registered source including a book could ground a published
  record; the retrieval boundary filtered on `isPublished` only; `_guard` did not
  contain `Error`; and a merged test asserted the forbidden `editorialReview`
  success as correct). All seven were the owner's **already-recorded**
  requirements not yet implemented — no unresolved product or religious decision
  — so they were implemented rather than escalated. **Final Opus review: PASS
  WITH FOLLOW-UPS**, all seven verified closed.
  `docs/CONTENT_SOURCE_MATRIX.md` gains one row `official-answer-index` as the
  CP11 governance rule requires — **READY WITH DOCUMENTED LIMITATION**, because
  the contract is shipped and tested but grounds no content, so `READY` would be
  false and `NOT IMPLEMENTED` would also be false. Recorded limitations: zero
  published records; no consumer wired; a qualified human scholarly reviewer
  required before any real record; and `isGeneralInformationOnly` is
  **declarative** — nothing verifies that a body is not a personal ruling.
  `art-dua-adabi`, all Learn article content and `LearnDailyPlanCatalog.v1` (30
  entries) are unchanged. Learn state per locale is untouched at **56 records,
  55 published, 1 pending**; categories **20 of 20**; registry **8**.
  Report: `docs/task-reports/TASK_092_OFFICIAL_ANSWER_INDEX_FOUNDATION.md`
- Previous completed task: **TASK 091** — Review pending Learn articles (**CP11**).
  Scope was read from the roadmap, which defines TASK 091 in **one line with no
  acceptance criteria**, and therefore covers **only** the two long-standing
  `scholarlyReviewPending` records. The four TASK 090 candidates stay deferred;
  the two TASK 090-authored doc lines suggesting otherwise were recommendations,
  not roadmap assignments.
  Per locale: **56 records, 55 published, 1 pending** (was 56 / 54 / 2).
  Categories stay **20 of 20**, registry stays at **8**, catalog stays at **30**.
  **`art-kuran-okumaya-baslangic` was rewritten and published.** Its old body was
  unsupported by its own registered source: `diyanet-kuran-portali` is a Quran
  text/translation service with no chapter on learning to read, and the record
  carried an **empty locator and empty evidence summary**. It now rests on
  **İslam İlmihali (34. Baskı, 2019), Kur'an-ı Kerim'e Karşı Görevlerimiz —
  b) Kur'an-ı Kerim'i Öğrenmek, s. 58**, read directly, and states only what that
  page states: learning the Quran means learning to read it **and** working to
  understand its meaning, with tajwid part of that learning. Removed: the
  five-step list (on no source page), the s. 58 **virtue hadith**, the s. 58
  **"farzdır"** ruling, the reward framing, and any pace/mastery/programme or
  daily-amount claim. Title → "Kur'an'ı öğrenmek ne demektir?";
  `contentType` → `ilmihalKnowledge`; `beginnerPathOrder` **11 preserved**; slugs
  unchanged so deep links keep resolving. **No new source record.**
  **`art-dua-adabi` remains `scholarlyReviewPending`** — body, title, summary,
  source, locator and translations **untouched**; only `isFeatured` → `false`.
  Recorded honestly: **qualified scholarly review is required**, the body is
  **not approved** (empty locator/evidence, `blocker` preserved,
  `contentType: hadithBased` with no hadith), the **Arabic strengthens one
  sensitive claim** relative to the Turkish canon ("اليقين" vs "bilinci") and
  must be fixed before any publication, and narrowing the subject would
  **duplicate** the published `art-dua-nedir`. **No task owns the qualified
  reviewer decision yet.**
  `diyanet-kuran-portali` now grounds **no Learn article**; it is **deliberately
  kept registered** as the official Quran reference address.
  **Six existing assertions were re-pointed, not weakened** — three pack tests,
  the Assistant pending exemplar, the repository runtime-visibility test (now
  additionally asserting the published article **is** reachable and verified),
  and two catalog assertions that had frozen "catalog head == every published
  beginner-path member" and "orders 11 and 12 are pending". Both catalog
  assertions now encode the durable invariant instead, so a later review cannot
  break them again — same defect class TASK 088 and TASK 090 repaired.
  One stale production doc comment in `learn_daily_plan_catalog.dart` corrected;
  the catalog value itself unchanged. No Assistant, Quran, Prayer, persistence,
  Firebase, remote, premium or monetization change; no schema, enum, storage key
  or envelope-version change.
  Report: `docs/task-reports/TASK_091_REVIEW_PENDING_LEARN_ARTICLES.md`
- Previous completed task: **TASK 090** — Learn pack: Madhhabs, Islamic calendar
  and remaining gaps (**CP11**, final Learn pack). Owner scope **6 articles** —
  `cat-madhhabs` 3, `cat-calendar` 3 (18 localized records). Per locale:
  **56 records, 54 published** (was 50 / 48); populated categories
  **18 -> 20 of 20** — **no Learn category is empty any more**. **One new source
  record**: `diyanet-vakit-hesaplama` (registry **7 -> 8**; sources grounding
  published content **3 -> 4 of 8**).
  **"Remaining gaps" was read from the repository, not guessed:** the roadmap,
  `TASK_INDEX.md` and the matrix define the phrase **only** as the two empty
  categories, and define **no article count and no acceptance criteria**. The
  thin categories (`cat-faith`, `cat-akhlaq`, `cat-halal`, `cat-history`,
  `cat-women`, 1 each) are recorded nowhere as a TASK 090 obligation and were
  left alone.
  **Four evidenced candidates were classified SCHOLARLY REVIEW REQUIRED and
  were NOT published** — `art-gorus-farkliliklari-nasil-olusur` (rests on the
  contested Muâz b. Cebel narrative), `art-itikadi-ve-ameli-mezhep-ayrimi`
  (every expansion available sits in the s. 30-31 **Ehl-i Sünnet / Ehl-i
  Bidat** framing), `art-takvim-ve-resmi-dini-gun-tespiti` (only supported
  inside the excluded rü'yet-i hilâl debate) and `art-aylarin-sayisi-on-ikidir`
  (Tevbe 9/36-37 is inseparable from the war/nesî' context and haram-month
  rulings). Their absence is asserted by test — sensitive content is never
  shipped to fill a category.
  **A new source was genuinely required:** `İslam İlmihali` contains "takvim"
  on only two pages (s. 135 prayer timetables, s. 263 inside the moon-sighting
  discussion) and has **no month list, no epoch and no year-length statement**;
  `Hz. Muhammed'in Hayatı` has it on one page (s. 21) and never defines the
  calendar. `diyanet-vakit-hesaplama` is the registry's first **maintained web
  page** — `officialPublication` (no enum change; `diyanet-kuran-portali`
  already uses it for a web property), `www2.diyanet.gov.tr` passes the
  existing `OfficialSourceDomains` allowlist unchanged, and **author, edition,
  ISBN and publication date are absent, not invented** (asserted by test).
  Its volatility is recorded as a documented limitation.
  **Owner binding correction applied:** the exact Gregorian conversion dates the
  calendar source records are **excluded from all shipped content** — summary,
  body, key point **and** the shipped `evidenceSummary` — and are **not**
  replaced by another exact Gregorian date; a test enforces this across all
  three locales. The published articles rest on the Hijra as the epoch, the
  lunar structure and the directly supported institutional history.
  Excluded elsewhere: superiority/correctness rankings, "which madhhab should I
  follow", personal fiqh, comparative verdict tables, takfir/bid'ah language,
  Abu Hanifa's imprisonment and the ethnic conjecture, the Nisâ 4/115 cehennem
  framing, the killer-heir qiyas example, sacred-day virtues, moon-sighting
  positions and any official religious-date determination. The one scholarly
  difference the source itself records (sarih icma decisive, sükûtî icma
  disputed) is **stated, not hidden**, in a `differenceOfOpinion` block.
  **Three stale test fixtures were repaired durably:** `task_088` and
  `task_089` both froze `sources.length == 7` (the same defect class TASK 088
  fixed in TASK 087) and now assert the real intent — the seven post-TASK-087
  IDs stay registered and each pack cites nothing outside them, while the
  registry may grow; and `learn_screens_test`'s "Hazırlanıyor" label assertion
  was still bound to a production category staying empty, so it now uses TASK
  089's synthetic `EmptyCategoryFixtureBundle`. Empty-state coverage therefore
  survives a fully populated library.
  TASK 082 catalog untouched (30 entries); none of the 6 IDs enters it. TASK
  091's two pending records untouched. No Assistant, Quran, Prayer,
  persistence, Firebase, remote, premium or monetization change; no schema,
  enum, storage key or envelope-version change.
  Report: `docs/task-reports/TASK_090_LEARN_MADHHABS_CALENDAR.md`
- Previous completed task: **TASK 089** — Learn pack: Women, Afterlife, Islamic
  history (**CP11**). Owner scope **5 articles** — `cat-afterlife` 3,
  `cat-women` 1, `cat-history` 1 (15 localized records). Per locale:
  **50 records, 48 published** (was 45 / 43); populated categories
  **15 -> 18 of 20** — only `cat-madhhabs` and `cat-calendar` remain empty;
  **no new source record** (registry stays at **7**).
  **The pointed history section was rejected, not forced.** Hadislerle Islam
  Cilt 1 s. 66-82 contains no *rihle* chapter: s. 69 is military expansion,
  s. 70 gives openly conflicting sahâbî counts (12.304 / ~4.000 / 1.500),
  s. 71 is fitne, sects and Umayyad-era fabrication, and s. 72-82 is hadith
  authenticity grading. `art-ilim-yolculuklari` was therefore dropped and
  replaced — on owner approval — by `art-kuranin-yazilmasi-ve-cogaltilmasi`
  from Islam Ilmihali s. 55-56 (written revelation -> Hz. Ebu Bekir's single
  mushaf after Yemame -> Hz. Osman's seven copies), which is stable,
  non-political chronology.
  **One locator was corrected during drafting:** `art-ahiret-nedir` is recorded
  as **s. 65-67**, not s. 65, because the "Ahiret Gunu" definition it
  summarises sits at the end of the *Olduk ten Sonra Dirilmek* sub-section on
  s. 67. The Afterlife articles exclude cennet/cehennem description, kabir
  azabi, sefaat, mizan/sirat, personal salvation judgments and fear framing;
  the Women article excludes the governance hadith (C.4 s. 236), mahrem-travel
  rulings (s. 238), covering rulings, the war-participation clause and
  s. 240's normative social conclusion; the History article excludes conquest
  framing, caliphal legitimacy, sectarian reading and manuscript criticism, and
  preserves the source's own "yaklasik" and "yedi kadar" hedging.
  `art-olum-nedir` was **not** added (asserted).
  **Two stale empty-category fixtures were fixed durably:**
  `learn_repository_test` and `learn_screens_test` hard-coded `cat-history` as
  their empty-category exemplar, which TASK 089 populates. Both now **derive**
  an empty category from the shipped assets, so future Learn packs cannot break
  them. TASK 082 catalog untouched; none of the 5 IDs enters it. No Assistant,
  Quran, Prayer, persistence, Firebase, remote, premium or monetization change.
  Report: `docs/task-reports/TASK_089_LEARN_WOMEN_AFTERLIFE_HISTORY.md`
- Previous completed task: **TASK 088** — Learn pack: Dua, Family, Halal
  foundations (**CP11**). The roadmap defines no count and TASK 087's 3+3+3 was
  **not** inherited; after a **PARTIALLY READY** Phase A gate the owner fixed
  **4 articles** — `cat-dua` 1, `cat-family` 2, `cat-halal` 1 (12 localized
  records). Per locale: **45 records, 43 published** (was 41 / 39); populated
  categories **12 -> 15 of 20** (still empty: `cat-women`, `cat-afterlife`,
  `cat-history`, `cat-madhhabs`, `cat-calendar`); **no new source record** — the
  registry stays at **7** (asserted). **Gate findings:** the Islam Ilmihali has
  **no standalone dua chapter** and its general dua page (s. 163) **extracts with
  corrupted glyphs**, so it is unusable; the Hadislerle Islam dua chapter's spine
  is *guaranteed acceptance and special times* (s. 35-37, 40-41) which is
  excluded, so `art-dua-nedir` rests on **s. 40 alone** — disclosed rather than
  padded; and `cat-dua` was already occupied by the pending `art-dua-adabi`
  (**TASK 091**, untouched — `cat-dua` is now the first category holding a
  published and a pending record side by side). The second family article was
  renamed `art-anne-babaya-saygi-ve-nezaket` and narrowed to courtesy, dropping
  the source's blanket-obedience and maintenance items; the halal article is
  definitions only, attributes them explicitly to the Ilmihal and redirects
  personal cases to the competent authority, with `art-haramin-cesitleri` left
  out of scope as **SCHOLARLY REVIEW REQUIRED**. "Attentive listening" was
  **omitted** because it does not appear in the source body. **One TASK 087 test
  was corrected**: its absolute totals (`32+9=41`, `30+9=39`) were replaced with
  growth-tolerant assertions plus a check that all nine TASK 087 articles remain
  present, published and source-verified — the same frozen-count defect class as
  the TASK 082 reconciliation. TASK 082 catalog untouched; none of the 4 IDs
  enters it. No Assistant, Quran, Prayer, persistence, Firebase, remote, premium
  or monetization change.
  Report: `docs/task-reports/TASK_088_LEARN_DUA_FAMILY_HALAL.md`
- Previous completed task: **TASK 087** — Learn pack: Hadith, Seerah, Prophets
  (**CP11**). Owner-fixed scope **3 + 3 + 3**: **9 new published articles**,
  **27 localized records**, populating `cat-hadith`, `cat-seerah` and
  `cat-prophets`. Per locale: **41 records, 39 published** (was 32 / 30);
  populated categories **9 → 12 of 20**; sources grounding published content
  **1 → 3 of 7**. One **new source record** `diyanet-hz-muhammedin-hayati`
  (*Hz. Muhammed'in Hayatı*, Casim Avcı – Mevlâna İdris, Genel Yayın No 1286,
  **Çocuk Kitapları 302**, 16. Baskı Mart 2025, ISBN 978-975-19-6627-8) — its
  series, edition and authorship are explicit and **no Diyanet endorsement is
  implied**. `diyanet-hadislerle-islam` now grounds published content for the
  first time. **The content gate blocked twice and both blocks were correct:**
  the originally proposed Seerah/Prophets URLs are dead (`dijital.diyanet.gov.tr`
  answers HTTP/0.9; the Prophets PDF redirects to `hata.html`) and were replaced
  with working official sources; and `art-guzel-ahlak-ve-yardimlasma` was
  rejected because *Hadislerle İslâm* Cilt 1 s. 250 covers the first revelation,
  not good character — the topic was replaced only on explicit owner permission.
  **Direct-source rule honoured**: PDFs downloaded outside the repo and text
  extracted directly; no summary used as evidence; nothing committed.
  `diyanet-islam-ilmihali` confirmed as **34. Baskı, 2019** from the PDF colophon.
  Review provenance was reported as **AMBIGUOUS** (the repo never defined who may
  perform `editorialReview`) and no verified status was written until the owner
  recorded an explicit source-fidelity review; proposed `CONTENT_POLICY.md`
  wording was prepared but **not applied**. **TASK 082 catalog untouched** —
  same 30 entries, order and version; none of the 9 IDs enters it (asserted).
  **Four merged TASK 082 assertions encoding "library == catalog" were
  reconciled in this branch on owner decision** (see the catalog-boundary rule
  below); source verification, publication, locale parity and review gates were
  **not** weakened. No Assistant, Quran, Prayer, persistence, Firebase, remote,
  premium or monetization change.
  Report: `docs/task-reports/TASK_087_LEARN_HADITH_SEERAH_PROPHETS.md`
- Previous completed task: **TASK 086** — Content-source matrix (first task of
  **CP11**). Docs + one validation test; **zero production Dart or asset files
  changed**. Establishes the canonical governance matrix at
  `docs/CONTENT_SOURCE_MATRIX.md` — **22 rows**, each with a stable
  kebab-case ID, covering Quran text/metadata/page-map/translation/search/
  audio/reciter-catalog, the inactive remote Diyanet callable, Learn
  articles/prayer-education/categories/source-registry/plan-catalog,
  prayer-time calculation, prayer labels, dua, dhikr, onboarding copy, Today
  plan copy, Assistant retrieval corpus, Assistant safety copy and the Profile
  source registry. Status counts: **READY 8 · READY WITH DOCUMENTED LIMITATION
  11 · REVIEW REQUIRED 1 · BLOCKED 0 · NOT IMPLEMENTED 2**. Every claim was
  recomputed from shipped assets, not copied from prior reports.
  **No P0/P1 issue:** no published religious content lacks a source, no
  registry entry mismatches shipped content, no locale set represents different
  subjects, no review-pending content is exposed as published, the Assistant
  cannot reach unpublished material, and no evidenced licensing conflict exists
  for shipping content. **Six P2 findings** (F1–F6) are recorded in the matrix:
  F1 the Assistant persistence gate excludes `worshipRule` while the
  classifier's own `isSensitiveVerdict` includes it — and that helper has **no
  production caller** (owner **TASK 094**); F2 `app_source_reference.dart`
  duplicates `sources.json` with no cross-check (**TASK 094**); F3 QuranEnc
  translation licensing **UNRESOLVED**; F4 the deployed Diyanet callable is
  client-inactive with unresolved licensing, EOL `nodejs20` and App Check still
  a TODO; F5 3 of 6 registered sources ground no published article and 11 of 20
  categories are empty (**TASK 087–090**, **TASK 092**); F6 the Tanzil and
  QuranEnc corpora were never fully diffed upstream. **Locale result:** TR/EN/AR
  carry identical stable article ID sets **and** identical review statuses
  (recomputed); the Quran translation is **TR only** by design. **Assistant
  boundary fixed:** published Learn articles + category titles (weak ranking
  signal) + the source registry only; all `internal-ui-copy` is explicitly
  **not** religious authority. **No religious content was written, edited,
  repaired or reclassified**; no schema, key, envelope-version, Drift, Firebase,
  remote, notification, dependency or premium change.
  Report: `docs/task-reports/TASK_086_CONTENT_SOURCE_MATRIX.md`
- Previous completed task: **TASK 085** — 30-day plan and CP10 checkpoint.
  Verdict: **CP10 COMPLETE — 30-DAY LOCAL PLAN FLOW STABLE**; product gate
  **READY TO ENTER CP11**. The full chain (onboarding → profile → generator
  → core sources → atomic `savePlans` → bootstrap → Today → completion →
  restart → rollover → missed-day recovery) was validated against executed
  suites, using the **real** `SharedPrefsDailyPlanRepository` so "restart"
  means a new container **and** a new repository over the same stored bytes.
  **One checkpoint-blocking defect was found and fixed:** TASK 084's
  `unawaited(subscription.cancel())` did not contain errors, so a failing
  `cancel()` escaped as an **unhandled asynchronous error**.
  `DailyPlanController._cancelQuietly` now uses
  `unawaited(cancel().catchError((Object _) {}))`; the fix was proved
  load-bearing by reverting it and watching the audit test fail. Awaited
  cancellation was **not** restored (that is what hung the second day load in
  TASK 084), and genuine watch failures are still surfaced through
  `listen(onError:)`. Full subscription audit passed: rapid A→B→C never
  sticks in Loading, A/B events cannot replace C, 12 switches leave exactly
  **1** active listener, disposal drops it to 0, and late-resolving cancels
  cannot mutate newer state. 30 focused tests; full suite 1392 → **1422**;
  Functions **23/23** on Node v22.22.0 / npm 10.9.4. **No schema, key,
  envelope-version, Drift, Firebase, remote, notification or premium change.**
  Report: `docs/task-reports/TASK_085_CP10_30_DAY_PLAN_CHECKPOINT.md`
- Previous completed functional task: **TASK 084** — Missed-day recovery and
  gentle rollover. `TodayDayController` now owns which local calendar day
  Today shows: `start()` (bootstrap once + select day), `onAppResumed()`
  (via `WidgetsBindingObserver`; **no-op when the day is unchanged**) and a
  **one-shot** injected `DayRolloverScheduler` for local midnight — **no
  periodic polling**, one armed timer at a time, cancelled on disposal. The
  next boundary is `DateTime(y, m, d + 1)` minus the injected local now, so
  **24 hours is never assumed** (DST/month/year/leap safe); `DayKey` always
  comes from `DayKey.fromLocal(clock.nowLocal())` with no UTC conversion and
  no `DateTime.now()` (asserted at source level). A generation counter stops
  an old day's late read from overwriting a newer day.
  **Missed day** = a valid plan exists for that past `DayKey` **and** it has
  items **and** none are completed. Absent records, empty plans, corrupt
  records, today and future days are **not** user-missed and each **breaks**
  the consecutive chain; lookback is capped at the canonical 30 days.
  `MissedDayCalculator` is pure — no repository, clock, locale or write —
  and `MissedDayRecovery` is **not a streak model** (nothing persisted, no
  score/badge/rank, count never rendered).
  **Historical integrity:** nothing is auto-completed, failed, copied
  forward, deleted, reordered or re-timed; the recovery path performs zero
  writes (asserted). `TodayRecoveryNote` sits **above** the plan, blocks no
  task, opens no modal, animates nothing and uses no error colour; it hides
  naturally once any current-day task is marked — **no new persistence key**
  was added to dismiss it. At **3+** consecutive missed days the copy becomes
  a simpler warm re-entry sentence while the full plan, its Prayer → Quran →
  Learn order and the minute budget stay unchanged. A new day with no plan
  keeps the honest Empty state — nothing is generated and the range is never
  extended past day 30.
  One required fix: `DailyPlanController.loadDay` still cancels the previous
  watch subscription but **no longer awaits** it (`cancel()` does not resolve
  promptly for every stream and left the second day load stuck in Loading);
  waiting is unnecessary because `_onWatchEvent` compares the subscribed day
  and the generation counter blocks stale results.
  88 focused tests; full suite 1304 → **1392**. **No persistence key or
  envelope-version change, no Drift, no Firebase, no remote sync, no
  notifications, no streak/XP/achievements, no plan adaptation, no day-30
  renewal, no premium work.**
  Report: `docs/task-reports/TASK_084_MISSED_DAY_RECOVERY.md`
- Previous completed functional task: **TASK 083A** — Initial DailyPlan
  orchestration: the **controlled roadmap insertion** that finally connects
  onboarding → profile → generation → persistence. Until now nothing ever
  invoked the generator, so Today showed Empty for every user.
  `InitialDailyPlanOrchestrator` runs `OnboardingPreferences` →
  `OnboardingProfileMapper` → `DailyPlanGenerationRequest` →
  `DailyPlanGenerator` + `CoreDailyPlanItemSource` → **one atomic write**.
  Start day is `DayKey.fromLocal(clock.nowLocal())` — no `DateTime.now()`.
  New repository method **`savePlans(List<DailyPlan>)`** writes the whole
  batch as a **single logical envelope write** (read-all → merge → encode
  once → write once); an empty batch and duplicate `DayKey`s are rejected,
  a corrupt envelope is never overwritten, days outside the batch are
  preserved, and watch events fire only after success. **30 sequential
  `savePlan` calls are explicitly forbidden** — a partial range cannot exist.
  Typed sealed outcomes: **Created · AlreadyAvailable · OnboardingIncomplete
  · RangeConflict · GenerationFailed · PersistenceFailed**; none carries raw
  answers, plan JSON, storage keys, UID, device data or exception text.
  Idempotent: a complete matching range returns `alreadyAvailable` with
  **completion status and timestamps untouched**; a **partial** range returns
  `rangeConflict` and is **never auto-filled or overwritten** (recovery is
  TASK 084); concurrent calls share one memoized operation, so two callers
  produce exactly **one** write. Onboarding completion now returns success
  **only after** the plan exists — a failure keeps the gate closed, keeps
  preferences persisted for safe retry and shows the existing neutral
  message. `InitialDailyPlanBootstrapController` covers already-onboarded
  users with no plan: it runs **at most once per app lifecycle**, never
  inside a widget `build`, with an explicit user-driven `retry()`.
  73 focused tests; full suite 1231 → **1304**. **No storage key change, no
  envelope-version change, no Drift, no Firebase write, no remote sync, no
  premium/monetization work.**
  Report: `docs/task-reports/TASK_083A_INITIAL_DAILY_PLAN_ORCHESTRATION.md`
- Previous completed functional task: **TASK 083** — Today task UI: the first
  real surface over the TASK 077 `DailyPlanController`. `TodayPlanSection`
  renders all five states — **Loading** (non-animated neutral skeleton),
  **Empty** (neutral text, **no fake "generate plan" button**), **Available**
  (selected day, `n/total` progress, `AppProgressBar`, ordered task cards),
  **Corrupt** (calm "nothing was deleted", no retry, no auto-reset) and
  **Failure** (neutral message + `retry()`). Item titles come from the pure
  `TodayPlanItemPresentation` mapper (template ID → neutral localized text);
  Learn titles resolve through the existing **published-only**
  `LearningKnowledgeRepository`, and an unresolved/removed/failing article
  falls back to a neutral label — **no fabricated title, no crash, no raw
  template/article ID or generator version on screen**. Card order is the
  plan's own **Prayer → Quran → Learn** order (proved not re-sorted by
  localized text). **Completion is implemented**:
  `DailyPlanController.toggleItemCompletion` preserves every other plan field,
  takes `completedAt` from the injected `AppClock`, persists through the
  existing `savePlan` path, blocks duplicate writes while saving, and never
  generates a plan or touches another day — **no new storage key and no
  envelope-version change**. **Day navigation is deliberately deferred to
  TASK 084**: today's `DayKey` is selected once from the clock and exactly one
  watch subscription is opened. Free core: no paywall, ad, supporter or
  donation element. 53 focused tests; full suite 1178 → **1231**. **No plan
  generation orchestration, no persistence-format change, no Drift change, no
  Firebase write; remote sync stays disabled.**
  Report: `docs/task-reports/TASK_083_TODAY_TASK_UI.md`
- Previous completed functional task: **TASK 082** — Source-verified Learn plan
  items **and the complete Prayer → Quran → Learn core composition**.
  `LearnDailyPlanItemSource` emits **one** Learn item per generated day when
  the `islamicKnowledge` goal is present (absent ⇒ empty list, not a
  failure), costing **`estimatedMinutes = 1`** (in-app interaction budget —
  **not** required study time, a religious minimum, a ruling, reward or
  rank). The item is `PlanItemType.lesson` with `targetRef` = the **stable
  published + source-verified article ID** and `sizeParam` null. **No article
  title, summary, body, translation or source text is copied into the plan**;
  **no Learn repository, asset bundle or reading history is read during
  generation**. Selection is `dayOffset` → catalog index (no modulo, no
  repetition, no randomness, no locale/profile/phase reordering).
  `LearnDailyPlanCatalog.v1` is an immutable, explicit, versioned **30-entry**
  catalog: entries 0–10 follow the **existing editorial `beginnerPathOrder`**
  (published members only — 11 and 12 are `scholarlyReviewPending` and
  excluded); entries 11–29 are an **approved TASK 082 product decision**
  grouped by `categories.json` `sortOrder`. Content gate passed with **no
  content change**: exactly **30 eligible published + `sourceBodyReview`
  verified** articles, with **identical stable ID sets in TR/EN/AR**.
  `CoreDailyPlanItemSource` bundles the approved **Prayer → Quran → Learn**
  order (`const`, pure, no provider, no bootstrap wiring); the composite and
  generator were **unchanged**, and appending Learn **did not shift** any
  Prayer/Quran slot or final ID on any of the 30 days (tested). Complete core
  day cost = **5 minutes**, which `light` accepts exactly. Contribution is
  identical across all 8 profiles and 4 phases. 163 focused tests; full suite
  1015 → **1178**. **No persistence, Today UI, onboarding integration, Drift,
  Firebase or remote sync; no article asset edited; zero tracked files
  modified.**
  Report: `docs/task-reports/TASK_082_LEARN_PLAN_ITEMS.md`
- Previous completed functional task: **TASK 081** — Quran plan items **and
  ordered source composition**. `QuranDailyPlanItemSource` emits a single
  neutral *continuation/tracking* action `quran_continue_daily` when the
  `quranHabit` goal is present (absent ⇒ empty list, not a failure), costing
  **`estimatedMinutes = 2`** (in-app interaction budget — **not** required
  reading duration, a religious minimum, a ruling, reward or rank).
  **No surah, ayah, juz, page, translation text, reciter, audio URL or
  reading/listening quantity is assigned**; `targetRef`/`sizeParam` stay
  null. No Quran repository, progress, saved verses or audio is read.
  `CompositeDailyPlanItemSource` runs an **explicitly ordered** child list
  once per day and concatenates in **Prayer → Quran → Learn** order —
  a deterministic product rule, **not** a religious ranking. It propagates
  the first typed child failure with **no partial output**, rejects
  **cross-source** duplicate template IDs (`ValidationFailure`, no new
  failure type or l10n key), and returns an empty success for an empty child
  list. Because it implements the same single-source interface, the
  **generator needed no change**. Appending Learn later **cannot shift**
  Prayer/Quran slots or final IDs (tested). Contribution is identical across
  all 8 profiles and 4 phases. 70 focused tests; full suite 945 → **1015**.
  **No persistence, Today UI, Drift, Firebase or remote sync; zero tracked
  files modified.**
  Report: `docs/task-reports/TASK_081_QURAN_PLAN_ITEMS.md`
- Previous completed functional task: **TASK 080** — Prayer plan items: the
  **first approved `DailyPlanItemSource`**. `PrayerDailyPlanItemSource` emits
  `prayer_track_daily` (goal `trackPrayers`) and/or `prayer_on_time_daily`
  (goal `prayOnTime`), in that fixed order, each costing
  **`estimatedMinutes = 1`** (in-app *interaction* cost — **not** prayer
  duration, a religious minimum, a ruling or a rank). Items come from
  **goals, never from the profile**; `prayOnTime` does not imply
  `trackPrayers`; unrelated goals change nothing; no prayer goal ⇒ empty list
  (not a failure). Contribution is **identical across all 8 profiles and all
  4 phases** — no escalation, no beginner discount, no advanced quota.
  Representation gate passed with **no domain change**: the two actions are
  distinguished by `templateId`, which `DailyPlanItemIdBuilder` already
  composes into the final item ID. `targetRef`/`sizeParam` stay **null** — no
  prayer name and no prayer count is ever claimed. **No prayer-time
  calculation, no location, no notification, no `PrayerLog` read, no
  persistence, no Today UI, no Firebase; remote sync stays disabled; zero
  tracked files modified.** 62 focused tests; full suite 883 → **945**.
  Report: `docs/task-reports/TASK_080_PRAYER_PLAN_ITEMS.md`
- Previous completed functional task: **TASK 079** — Deterministic daily plan
  generator (**skeleton + item-source contract**): `DailyPlanGenerator` emits
  exactly **30 per-day `DailyPlan` records** from a validated
  `DailyPlanGenerationRequest` (profile · goals · pace · start `DayKey`).
  The stop gate fired first: `dhikr`/`dua`/`reflection` have **no content at
  all** (interfaces only; `assets/content/` holds only `learn/`), so producing
  items would have meant inventing worship prescriptions. The roadmap resolves
  it — Prayer/Quran/Learn items are **TASK 080/081/082**. Owner approved
  **Option B**.
  **Approved TASK 079 product decisions (NOT in the old spec):** pace budget
  `light` 5 · `balanced` 10 · `focused` 20 · **`advanced`+`focused` → 30**
  (the only profile-specific override; 15 never produced); `weekIndex` is a
  zero-based **four-phase** index — offsets 0–6→0, 7–13→1, 14–20→2, **21–29→3**
  (days 29–30 stay in phase 3; **`weekIndex` 4 is never produced**; 7/7/7/9).
  Default `EmptyDailyPlanItemSource` ⇒ 30 valid plans with **empty `items`**
  (explicitly not a failure). Stable item ID =
  `rule-engine-v1:<dayKey>:<templateId>:<slot>` — no random/timestamp/hashCode.
  63 focused tests; full suite 820 → **883**. **No persistence write, no Today
  UI, no Drift change, no Firebase write, no religious content; remote sync
  stays disabled; zero tracked files modified.**
  Report: `docs/task-reports/TASK_079_DETERMINISTIC_DAILY_PLAN_GENERATOR.md`
- Previous completed functional task: **TASK 078** — Onboarding profile mapping:
  `DailyPlanProfileType` (the **eight** canonical §10 buckets, finally given
  stable IDs: `beginner`, `returning`, `prayer_focused`, `quran_focused`,
  `dhikr_focused`, `learning_focused`, `advanced`, `low_time`) plus the pure
  `OnboardingProfileMapper`. **Input is the really implemented three-axis
  `OnboardingPreferences`** (`goals` / `journeyStage` / `dailyPace`);
  `completedAtUtc` never affects classification. The 16-question
  `OnboardingAnswers` / `OnboardingGoal` / `PersonalizationProfile` types are
  **UNUSED FUTURE SCAFFOLDING** and were not used, deleted or rewritten.
  Doc §474's derivation recipe was unusable because its inputs
  (`growthGoal`, `prayerRoutine`, `mainStruggle`) are **not collected by the
  app** — the stop gate fired and the owner approved Option A.
  **Approved TASK 078 product decision (NOT in the old spec):** priority
  1 `justBeginning`→beginner · 2 `rebuildingRoutine`→returning ·
  3 `strengtheningRoutine`+`focused`→advanced · 4 `light`→low_time ·
  5 goals by fixed order prayer→quran→dhikr→learning. 78 focused tests;
  full suite 742 → **820**. **No generation, no UI, no persistence change,
  no Firebase write, no Drift change; remote sync stays disabled; zero
  tracked files modified.**
  Report: `docs/task-reports/TASK_078_ONBOARDING_PROFILE_MAPPING.md`
- Previous completed functional task: **TASK 077** — DailyPlan state machine:
  `DailyPlanController` (`Notifier<DailyPlanState?>`) loads/observes/refreshes/
  saves one selected `DayKey` through the **unchanged** repository contract.
  Sealed states: **Loading · Empty · Available · Corrupt · Failure** (calm
  states are data, not errors). Stale results are blocked by a **generation
  (epoch) counter** (`QuranSearchController` idiom); save concurrency rule is
  **latest valid completion wins** — an older failed save can never replace a
  newer success. Included the owner-approved minimum contract correction:
  **`StorageCorruptionFailure`** added beside `StorageFailure` so corruption
  (unreadable stored data, not retryable) is distinguishable from transient
  storage-operation failures — **no signature, localization key, envelope
  version, storage key or persistence format changed**. 43 focused tests;
  TASK 076 persistence tests strengthened 67 → **70**; full suite 696 → **742**.
  **No generation, no Today UI, no Firebase write, no Drift migration; remote
  sync stays disabled.**
  Report: `docs/task-reports/TASK_077_DAILY_PLAN_STATE_MACHINE.md`
- Previous completed functional task: **TASK 076** — DailyPlan local persistence:
  the canonical **per-day** `DailyPlan` model and the existing
  `DailyPlanRepository` contract were preserved and given their first real
  implementation, backed by a **temporary versioned key-value envelope**
  (persistence version **1**, single key `bismillah.daily_plans`). The original
  brief's "single active 30-day snapshot" model was **rejected** as
  contradicting `10_DATA_MODEL` §4/§5/§7 and `11_LOCAL_DB` §3; a 30-day plan
  remains a composition of 30 per-day records and **no second DailyPlan
  abstraction exists**. Corruption returns typed failures and is never
  silently overwritten. **No Drift schema change, no dependency change, no
  generation, no Today UI, no Firebase write; remote sync stays disabled.**
  67 focused tests; full suite 629 → **696**.
  Report: `docs/task-reports/TASK_076_DAILY_PLAN_LOCAL_PERSISTENCE.md`
- Previous completed documentation task: **TASK 075** — CP09 technical
  stabilization and full regression checkpoint (verdict: **CP09 COMPLETE —
  TECHNICALLY STABLE**; product gate: **READY TO ENTER NEXT LOCAL-FIRST
  PRODUCT CHECKPOINT**; P0 = 0, P1 = 15, P2 = 12, deferred = 5; remote sync
  stays disabled.
  Report: `docs/task-reports/TASK_075_CP09_TECHNICAL_STABILIZATION_CHECKPOINT.md`)
- Previous documentation task: **TASK 074** — Firebase security and
  console readiness audit (verdict: **READY FOR LOCAL SECURITY HARDENING
  ONLY** — no Rules/App Check/emulator/staging exist yet; Functions callable
  well-guarded but deployed on EOL nodejs20 vs repo nodejs22; secret scan
  clean; P0 = 0, P1 = 6, P2 = 5.
  Report: `docs/task-reports/TASK_074_FIREBASE_SECURITY_READINESS_AUDIT.md`)
- Previous completed functional task: **TASK 073** — local sync-queue hardening:
  deterministic backoff policy (staged + FNV-1a jitter, 24h cap, attempt-8
  quarantine), privacy-safe failure classification (stable enum names only),
  policy-driven atomic `recordFailure`, bounded pruning (30-day terminal
  retention; pending work never pruned), stale-inFlight recovery and
  privacy-safe queue diagnostics. **No consumer, no remote write, no schema
  change, no migration — remote sync stays disabled.** Verdict upgraded to
  **READY FOR CONTROLLED REMOTE SYNC IMPLEMENTATION** (remote still gated by
  payload versioning, consumer, conflicts, Security Rules, App Check).
  Report: `docs/task-reports/TASK_073_LOCAL_SYNC_QUEUE_HARDENING.md`
- Next planned functional task: **TASK 093** — Assistant retrieval ranking and
  no-source UX (**CP11 — Learn and Assistant depth**). It must consume the
  official-answer repository's `getPublished` **only**, never `getIndex`, which
  deliberately exposes unpublished records for internal audit and is currently
  guarded only by a source-scan test.
  Learn **coverage** expansion is complete (TASK 090), pending-article review is
  complete (TASK 091), and the official-answer index **contract** is complete with
  zero records (TASK 092). Still open with **no owning task**: a qualified
  scholarly reviewer for `art-dua-adabi`, a qualified scholarly reviewer for any
  real official-answer record, a decision on the four TASK 090 candidates
  classified **SCHOLARLY REVIEW REQUIRED** and left unpublished, and verifying
  that an official-answer body is not a personal ruling (today
  `isGeneralInformationOnly` is declarative only).
  Still open and deliberately deferred from CP10: day-30 plan renewal, adaptive plan shrinking,
  streak/XP/achievements, manual calendar navigation, opening a Learn article
  from a task card, and TASK 083A's typed `rangeConflict` repair.

## Content source governance (fixed by TASK 086)

The canonical matrix is `docs/CONTENT_SOURCE_MATRIX.md` — **the single place**
that records, per content area, the source class, delivery method, publication
and review gates, TR/EN/AR coverage, allowed consumers and unresolved items.
Do not create a competing source-policy document: `docs/CONTENT_SOURCES.md`
(attribution/delivery notice), `THIRD_PARTY_NOTICES.md` (formal licences) and
`CONTENT_POLICY.md` (publication gate) each keep their own role, and the matrix
references them rather than restating licensing facts.

Rules fixed here: a row is **READY** only with a concrete source, valid
metadata, passing publication rules, understood locale handling and no known
licensing contradiction — religious text with missing source evidence can never
be READY. **`internal-ui-copy` is a first-class class**: onboarding wording,
Today plan labels, prayer labels and the Assistant's own safety strings are
interface copy, never sourced religious teaching, and the Assistant must never
treat them as authority. Where the repository does not establish a fact
(notably translation licensing), the matrix records **UNRESOLVED** — it is
never filled in from general knowledge. Adding or changing a content area means
updating the matrix; `flutter test test/content` fails if a row loses a
required field, uses an invalid value, or cites a path that does not exist.

## Learn catalog boundary rule (fixed by TASK 087)

**TASK 082's fixed 30-entry DailyPlan catalog is a curated versioned subset of
the growing published Learn library, not a permanent mirror of the full
library.** The canonical contract: `LearnDailyPlanCatalog.v1` stays exactly 30
ordered unique entries; every catalog ID must resolve to a published,
source-verified article in TR, EN **and** AR; locale ID sets and review states
stay identical; the library **is expected to grow** past 30; and new Learn-pack
articles must **not** enter the catalog. Four merged TASK 082 assertions that
encoded library-equals-catalog were corrected accordingly (exact count → **at
least** `requiredEntryCount` plus identical locale ID sets; `catalogIds ==
eligibleIds` → removed with the subset invariant **strengthened** to all
locales; catalog-vs-library length → catalog length plus ID uniqueness; asset
file-order comparison → restricted to the catalog's own IDs).

## Tests (verified at TASK 092)

- Flutter analyze: **clean** (0 errors, 0 warnings, 0 infos)
- Flutter test baseline: **1639 / 1639**, 0 failed, 0 skipped
  (1590 at TASK 091 + 49 TASK 092 tests). Re-run after the final hardening
  changes, not derived by arithmetic.
- TASK 092 suite: **49 / 49** — command:
  `flutter test test/features/official_answers`
- Content governance suite (includes the new `official-answer-index` matrix row):
  **14 / 14** — command: `flutter test test/content`
- Learn + Assistant + content + catalog: **379 / 379** — command:
  `flutter test test/features/learn test/features/assistant test/content
  test/features/today/domain/learn_daily_plan_catalog_test.dart`
  — **identical to the TASK 091 figure; no regression.**
- Functions at TASK 092: **not run** — no Functions file, dependency or lockfile
  changed.
- Device validation at TASK 092: **not required** (no platform or native change).

## Tests (verified at TASK 091)

- Flutter analyze: **clean** (0 errors, 0 warnings, 0 infos)
- Flutter test baseline: **1590 / 1590**, 0 failed, 0 skipped
  (1566 at TASK 090 + 24 TASK 091 tests)
- TASK 091 suite: **24 / 24** — command:
  `flutter test test/features/learn/task_091_pending_review_test.dart`
- Learn + Assistant + catalog + content suites: **379 / 379** — command:
  `flutter test test/features/learn test/features/assistant
  test/features/today/domain/learn_daily_plan_catalog_test.dart test/content`
- Functions at TASK 091: **not run** — no Functions file, dependency or lockfile
  changed.

## Tests (verified at TASK 090)

- Flutter test baseline: **1566 / 1566**, 0 failed, 0 skipped
  (measured pre-TASK-090 baseline **1529** + 37 TASK 090 pack tests)
- **Correction:** the stored TASK 089 figure **1528** was one short. The real
  pre-TASK-090 count, measured on this branch with the TASK 090 changes stashed,
  is **1529**. No test was lost; only the stored figure was wrong — the same
  class of stored-figure error as the TASK 083 `53` → `56` correction below.
  Measured the same way, the pre-TASK-090 Learn feature suite was **199** and
  Learn + catalog was **239** (stored: 238). All four TASK 090 figures below are
  from actual runs on this branch, not derived by arithmetic.
- TASK 090 Learn pack suite: **37 / 37** — command:
  `flutter test test/features/learn/task_090_learn_pack_test.dart`
- Learn feature suite: **236 / 236** — command: `flutter test test/features/learn`
- Learn + catalog suites: **276 / 276** — command:
  `flutter test test/features/learn
  test/features/today/domain/learn_daily_plan_catalog_test.dart`
- Content governance suite: **327 / 327** — command:
  `flutter test test/features/learn test/features/assistant
  test/features/profile/content_sources_test.dart test/content`
- TASK 089 Learn pack suite: **27 / 27** — command:
  `flutter test test/features/learn/task_089_learn_pack_test.dart`
- TASK 088 Learn pack suite: **29 / 29** — command:
  `flutter test test/features/learn/task_088_learn_pack_test.dart`
- TASK 087 Learn pack suite: **34 / 34** — command:
  `flutter test test/features/learn/task_087_learn_pack_test.dart`
- Learn plan catalog suite: **40 / 40** — command:
  `flutter test test/features/today/domain/learn_daily_plan_catalog_test.dart`
- Learn + catalog suites: **238 / 238**
- Previous baseline: **1436 / 1436** at TASK 086
  (1422 at TASK 085 + 14 content-source-matrix tests)
- Content-source matrix suite: **14 / 14** — command:
  `flutter test test/content`
  (validates the matrix document itself: unique stable IDs, summary/detail
  agreement, required fields, closed value sets, `Limitation` presence, no
  `UNRESOLVED` inside a `READY` row, and that **every cited repository path
  exists on disk**. Deliberately does **not** duplicate
  `learn_content_integrity_test.dart`.)
- Content governance suite: **199 / 199** — command:
  `flutter test test/features/learn test/features/assistant
  test/features/profile/content_sources_test.dart test/content`
- Previous baseline: **1422 / 1422** at TASK 085
  (1392 at TASK 084 + 30 CP10 checkpoint tests)
- CP10 checkpoint suite: **30 / 30** — command:
  `flutter test test/features/today/cp10_plan_flow_checkpoint_test.dart`
- Missed-day recovery + rollover suite: **82 / 82** — command:
  `flutter test test/features/today/domain/missed_day_recovery_test.dart
  test/features/today/application/today_day_controller_test.dart
  test/features/today/presentation/today_recovery_note_test.dart`
  (calculator 30 + rollover controller 31 + recovery note 21; the remaining
  6 TASK 084 tests live in the Today section suite)
- Today task-UI suite: **62 / 62** — command:
  `flutter test test/features/today/presentation/today_plan_section_test.dart`
  (**56** measured at TASK 083A + 6 recovery-integration tests).
  **Correction:** TASK 083 and TASK 083A both recorded this suite as
  `53`; the real post-TASK-083A count measured from merged `7b0d2b5` is
  **56**. Only this stored figure was wrong — no test was lost, and the
  full-suite totals were always correct.
- Initial plan orchestration suite: **59 / 59** — command:
  `flutter test test/features/today/application/initial_daily_plan_orchestrator_test.dart`
- Today task-UI suite: **53 / 53** — command:
  `flutter test test/features/today/presentation/today_plan_section_test.dart`
- Learn plan-item + catalog suite: **163 / 163** — command:
  `flutter test test/features/today/domain/learn_daily_plan_catalog_test.dart
  test/features/today/domain/learn_daily_plan_item_source_test.dart`
- Learn feature suite: **108 / 108** — command: `flutter test test/features/learn`
- Quran plan-item + composition suite: **70 / 70** — command:
  `flutter test test/features/today/domain/quran_daily_plan_item_source_test.dart`
- Quran feature suite: **89 / 89** — command: `flutter test test/features/quran`
- Prayer plan-item suite: **62 / 62** — command:
  `flutter test test/features/today/domain/prayer_daily_plan_item_source_test.dart`
- Daily plan generator suite: **63 / 63** — command:
  `flutter test test/features/today/domain/daily_plan_generator_test.dart`
- Onboarding profile-mapping suite: **78 / 78** — command:
  `flutter test test/features/today/domain/onboarding_profile_mapper_test.dart`
- DailyPlan state-machine suite: **43 / 43** — command:
  `flutter test test/features/today/application/daily_plan_controller_test.dart`
- DailyPlan persistence suite: **81 / 81** — command:
  `flutter test test/features/today/data`
  (70 at TASK 083 + 11 atomic `savePlans` contract tests)
- **Canonical sync-focused baseline: 70 / 70.** Exact command:
  `flutter test test/features/sync test/app/persistence_wiring_test.dart
  test/app/app_bootstrap_test.dart
  test/features/prayer/data/drift_prayer_log_repository_test.dart`
  — **`test/features/sync` alone is 52 / 52**; that figure is the sync
  directory in isolation and must never replace the official 70 baseline.
- Focused prayer-reminder suite: 26 / 26 (TASK 070D)
- Storage (Drift) tests: **11 / 11** — command: `flutter test test/core/storage`
- Functions tests (Vitest): **23 / 23** on Node.js v22.22.0 / npm 10.9.4 —
  last verified at the **TASK 085 CP10 checkpoint**. **Not re-run at TASK 086**:
  no Functions file, dependency or lockfile changed.
  No Functions file, dependency or lockfile has changed since TASK 069.
  The TASK 083 record supersedes the TASK 082 record of
  `PENDING (environment)`: the Node.js toolchain has been reinstalled under
  NVM for Windows, and the TASK 082 Functions status is now **POST-MERGE
  VERIFIED — 23/23**. Neither task changed any Functions file, dependency or
  lockfile.
- Android debug build: **SUCCESS** at TASK 075
  (`bismillah_app/build/app/outputs/flutter-apk/app-debug.apk`, 170.26 MB,
  SHA-256 `51ca8748877467b58f3b16368b6e5f23bac5eecdd7222e97595f5cc2764cde99`;
  not installed, no device test)
- Known non-blocking test warning: one `tap()` off-screen-offset warning in
  `bismillah_app/test/features/learn/learn_screens_test.dart` (test passes)
- Real-device: Quran main flows verified on **Samsung Galaxy A36 / Android 16**
- Real-device (TASK 071): combined notification candidate (22.1.0 + exact-alarm
  deep-link UX) fully validated on **Samsung Galaxy A36 / Android 16** — update-install,
  data preservation, inexact fallback, "Not now" flow, deep-link + real permission
  recheck, exact reschedule, replace/cancel, removed-from-recents, reboot restore, and
  **reboot physical delivery (exact on-time, single, tap OK, clean logcat)** all PASS.
  APK SHA-256 `a8d00a7f66ec6453104ba73076c9cd88750462c3470bf4cc0056738c252493e1`.
  This closes the reboot-delivery gap deferred by TASK 070B.
- iOS physical-device validation: **not performed (PENDING)**

## Stack

- Flutter `3.44.6` / Dart `3.12.2` (Node.js `22.22.0`, npm `10.9.4`;
  Android SDK 36.1.0, Gradle JDK 21)
- Riverpod (state/DI), GoRouter (routing)
- Drift (SQLite local DB) + SharedPreferences
- Firebase anonymous auth bootstrap; Firebase Cloud Functions
- GitHub Actions CI (Flutter CI + Functions CI)
- **Functions runtime baseline: Node.js 22** (raised from Node 20 in TASK 068)

## Persistence (current reality)

- **Drift** tables: `PrayerLogDays`, `PrayerEntries`, `SyncOperations`
  (schemaVersion 1; empty `onUpgrade` placeholder; no encryption)
- **SharedPreferences**: onboarding, Quran progress/bookmarks/preferences,
  Learn progress, Assistant history (cap 20), locale, reminders, session identity,
  **daily plans** (TASK 076)
- **Interim key-value adapters awaiting Drift** (canonical target is a Drift
  table per `11_LOCAL_DB` §3 — these are explicitly NOT the final architecture):
  - `bismillah.daily_plans` — per-day `DailyPlan` envelope, persistence
    version **1** (TASK 076). Future migration: read v1 envelope → insert one
    row per `DayKey` in a single transaction → verify counts/equality →
    remove envelope only after commit → roll back safely on failure.
    Payload/schema-versioning gate **G8** stays owned by **TASK 132**.
  - `bismillah.quran_daily_progress.*` — per-day Quran progress (TASK 047)

## Latest completed tasks

- TASK 063 — package_info_plus 10.2.1
- TASK 064 — Drift schema and persistence baseline
- TASK 065 — Merge Drift baseline
- TASK 066 — Drift official CLI toolchain alignment — **BLOCKED**
- TASK 067 — flutter-action v2.23.0
- TASK 068 — Node.js 22 Functions runtime and Functions CI (PR #9, merge `c847c4b`)
- TASK 068A — Permanent Claude project memory (PR #10, merge `c167454`)
- TASK 069 — fast-xml-parser 5.10.1 validated on Node.js 22 (Functions 23/23)
- TASK 070A — Android scheduled-notification manifest receiver contract + regression
  tests (PR #13; `flutter_local_notifications` unchanged at 22.0.1)
- TASK 070B — Samsung Galaxy A36 / Android 16 device validation of the manifest fix
  (reboot delivery deferred to TASK 071); merged via PR #13
- TASK 070C — flutter_local_notifications **22.1.0** (+ platform_interface 12.0.1)
  reapplied on the validated manifest baseline (PR #14, commit `93d1c86`)
- TASK 070D — exact-alarm permission deep-link UX with honest recheck + inexact
  fallback; TR/EN/AR copy; 6 new tests (PR #14, commit `50dacef`)
- TASK 071 — final Samsung A36 / Android 16 end-to-end validation incl. reboot
  physical delivery; PR #14 merged
- TASK 072 — sync-queue audit (docs-only): P0 = 0, P1 = 6, P2 = 4; queue producer
  (prayer log) atomic + tested (sync-focused 36/36); **no queue consumer exists**;
  remote sync currently **not enabled and not enabled-able** (no cloud_firestore)
- TASK 073 — local sync-queue hardening: backoff policy + failure taxonomy +
  recordFailure + pruning + stale-inFlight recovery + diagnostics (sync-focused
  70/70; full 629/629); closes the TASK 072 "no backoff/taxonomy" P1; remaining
  queue P1s: consumer stack, cloud_firestore + Rules/App Check, pull/conflicts,
  payload versioning, account linking
- TASK 074 — Firebase security readiness audit (docs-only): Rules/App Check/
  emulator suite/staging all ABSENT (P1 blockers before remote sync); the one
  deployed callable is auth-gated + validated + secret-managed, but runs EOL
  nodejs20 in the console (repo says nodejs22 — controlled redeploy pending);
  no tracked secrets; single dev Firebase project, Android+iOS apps registered
- TASK 075 — CP09 technical stabilization and full regression checkpoint
  (docs-only): all baselines re-run and reproduced (analyze clean, 629/629,
  70/70, 11/11, 23/23, debug APK build SUCCESS) with **no dependency or
  lockfile change**; authoritative 14-gate Firebase security order fixed
  (G1–G14); deployed `nodejs20` drift **re-verified** and promoted to a P1
  operational redeploy; npm advisories enumerated as **two independent
  chains** (5 high = `eslint` dev-only, never deployed; 8 moderate =
  `firebase-admin`/`firebase-functions` production tree; 0 critical; no
  non-breaking fix); payload-version migration (G8) confirmed to belong
  before consumer work and outside CP10. Verdict: **CP09 COMPLETE —
  TECHNICALLY STABLE**; product gate **READY TO ENTER NEXT LOCAL-FIRST
  PRODUCT CHECKPOINT** (TASK 076).
  Report: `docs/task-reports/TASK_075_CP09_TECHNICAL_STABILIZATION_CHECKPOINT.md`
- TASK 076 — DailyPlan local persistence (CP10 opens): first implementation of
  the existing `DailyPlanRepository` (`getPlan`/`watchPlan`/`savePlan`/
  `getRange`) via `SharedPrefsDailyPlanRepository` + `DailyPlanEnvelopeCodec`;
  canonical **per-day** model preserved (30-day frame = 30 records); the
  brief's conflicting 30-day snapshot model was rejected with owner approval;
  typed corruption failures, no silent overwrite, no auto-regeneration;
  privacy-minimal payload (6 canonical fields); full local reset already
  clears the envelope via the `bismillah.` prefix (no reset change needed).
  **Zero tracked files modified — new files only.**
  Report: `docs/task-reports/TASK_076_DAILY_PLAN_LOCAL_PERSISTENCE.md`
- TASK 077 — DailyPlan state machine: `DailyPlanController` +
  sealed `DailyPlanState` (Loading/Empty/Available/Corrupt/Failure); epoch
  counter blocks stale reads/writes/watch events; latest-valid-completion-wins
  save rule; `watchPlan` subscription owned by the controller and cancelled on
  day switch and disposal; bootstrap never instantiates or loads it. Added
  `StorageCorruptionFailure` (approved §10 gate correction) — failure mapping
  inspects **type only**, never `messageKey` or exception text.
  Report: `docs/task-reports/TASK_077_DAILY_PLAN_STATE_MACHINE.md`
- TASK 078 — Onboarding profile mapping: `DailyPlanProfileType` (8 buckets,
  stable IDs) + pure `OnboardingProfileMapper` over the real
  `OnboardingPreferences`; sealed result **Mapped / Incomplete** only
  (`Invalid` and `Contradictory` deliberately omitted as unreachable in the
  current model); stable neutral rule IDs (`journey_beginner`, `pace_low_time`,
  `focus_prayer`…); enum-coverage locks fail the suite if a new profile or
  focus goal is left unmapped; no provider added (pure static utility, so
  bootstrap cannot invoke it).
  Report: `docs/task-reports/TASK_078_ONBOARDING_PROFILE_MAPPING.md`
- TASK 079 — Deterministic daily plan generator: `DailyPlanGenerationRequest`
  (+ typed `GenerationRequestIssue`: `emptyGoals`, `profilePaceMismatch`),
  `DailyPlanGenerator`, and the extensible `DailyPlanItemSource` /
  `DailyPlanDayContext` / `PlanItemDraft` / `EmptyDailyPlanItemSource` /
  `DailyPlanItemIdBuilder`. Request validation rejects profile×pace
  combinations TASK 078 could never produce; the generator **never re-runs**
  the profile mapper. Local calendar arithmetic only (`DateTime(y, m, d+n)`) —
  no UTC conversion, no `Duration(hours: 24)`, DST-safe. Failures reuse
  existing types (`ValidationFailure`/`UnexpectedFailure`) — **no new
  `AppFailure` subtype and no new localization key**; source failures propagate
  unchanged and **partial plans are never returned**. No provider (pure static
  service, like the TASK 078 mapper).
  Report: `docs/task-reports/TASK_079_DETERMINISTIC_DAILY_PLAN_GENERATOR.md`
- TASK 080 — Prayer plan items: `PrayerDailyPlanItemSource` (const, stateless,
  pure; reads only `DailyPlanDayContext.goals`). Stable template IDs
  `prayer_track_daily` / `prayer_on_time_daily`; fixed order via an **explicit
  ordered list** (never `Set`/enum/map order). Source is **total** — no
  unreachable failure branch was fabricated. **No source composition was
  added**: the generator still takes a single source and Prayer is passed
  directly; composition arrives when **TASK 081** first needs Prayer → Quran →
  Learn together.
  Report: `docs/task-reports/TASK_080_PRAYER_PLAN_ITEMS.md`
- TASK 081 — Quran plan items + `CompositeDailyPlanItemSource`: composition
  arrived exactly where TASK 080 predicted. Composite is `const`, pure,
  order-from-constructor-list, one call per child per day; duplicate
  detection is scoped **across children only** (a single source repeating a
  template stays its own decision — TASK 079's `slot` already separates final
  identities). Quran source is `const`, stateless and **total**; no
  unreachable failure branch was fabricated.
  Report: `docs/task-reports/TASK_081_QURAN_PLAN_ITEMS.md`
- TASK 085 — CP10 checkpoint. The checkpoint's own value was the **audit**,
  not the tests: reviewing TASK 084's non-awaited cancellation found that
  `unawaited(future)` contains nothing, so a failing `cancel()` became an
  unhandled zone error. Containment (`catchError`) was chosen over restoring
  `await`, because awaiting is precisely what deadlocked the day switch.
  Restart scenarios deliberately use the **real** SharedPreferences
  repository — a fake would have proved nothing about persistence.
  Report: `docs/task-reports/TASK_085_CP10_30_DAY_PLAN_CHECKPOINT.md`
- TASK 083A — Initial DailyPlan orchestration (controlled roadmap insertion
  between TASK 083 and TASK 084; no task renumbered). Atomicity was solved
  **without a storage-format change**: the existing single-key envelope
  already supports read-all → merge → encode once → write once, so
  `savePlans` is a contract addition, not a migration. The orchestrator
  deliberately **classifies rather than repairs**: a partial range is a typed
  conflict, not an invitation to auto-fill, because silently completing a
  half-written range would let a stale profile overwrite real user history.
  Report: `docs/task-reports/TASK_083A_INITIAL_DAILY_PLAN_ORCHESTRATION.md`
- TASK 083 — Today task UI: first consumer of the TASK 077 state machine.
  Completion was implemented because the architecture already supported it
  safely (`AppClock` provider + existing `savePlan` + an envelope that already
  round-trips `status`/`completedAt`) — the widget never calls `savePlan`
  itself. The loading state is a **non-animated** skeleton on purpose: a
  spinner is restless and blocks every `pumpAndSettle` test that mounts Today.
  No "zero-jump" height is claimed (item count is unknown before the read);
  the skeleton only reserves a real block. Day navigation and missed-day
  handling were **deferred to TASK 084** rather than guessed.
  Report: `docs/task-reports/TASK_083_TODAY_TASK_UI.md`
- TASK 082 — Source-verified Learn plan items + `CoreDailyPlanItemSource`:
  the **three core item sources are now complete**. Learn is the first source
  that attaches a real content reference, so eligibility is re-derived from
  the actual assets on every test run (published + `sourceBodyVerified` +
  publication gate + registered source + TR/EN/AR parity) rather than trusted
  from a hard-coded list. The catalog is an explicit ordered value type, not
  a derived query: JSON file order, localized title sort, runtime locale and
  map iteration are all proved **not** to define plan order. Template ID is a
  **lossless** `learn_article_<articleId>` concatenation — no normalization,
  no `hashCode`, no hashing dependency, and article IDs are verified free of
  the `:` separator used by `DailyPlanItemIdBuilder`. Typed
  `LearnPlanCatalogIssue` mirrors TASK 079's `GenerationRequestIssue`, so
  **no new `AppFailure` subtype and no new localization key** were needed.
  `CoreDailyPlanItemSource` is a `const` value plus a pure `withCatalog`
  factory — deliberately **not** a provider, singleton or bootstrap hook.
  Report: `docs/task-reports/TASK_082_LEARN_PLAN_ITEMS.md`

## Plan content reality (fixed by TASK 079)

Of the six `PlanItemType` categories, only **`quran`** (bundled Tanzil +
QuranEnc) and **`lesson`** (`assets/content/learn/`, 30 published, source
verified) have real content. **`dhikr`, `dua` and `reflection` have none** —
`features/dhikr` and `features/dua` contain domain entities and repository
*interfaces* only, with no implementation, data source or asset. No plan
template/catalog structure exists in `lib/`. TASK 079 therefore generates the
30-day frame with **empty `items`**; approved content sources arrive in
**TASK 080 (Prayer) · TASK 081 (Quran) · TASK 082 (Learn)**. Content for
dhikr/dua/reflection remains an **open owner decision** — do not invent it.

**TASK 080 update:** the prayer slice is done and needed **no content at all** —
prayer items are app *tracking* actions carrying only a stable template ID, with
`targetRef`/`sizeParam` null (no prayer name, no prayer count). Quran and Learn
(TASK 081/082) do have real bundled content to reference by ID.

**TASK 081 update:** the Quran slice also needed **no content**. Although
bundled Quran content exists, the Quran item is a neutral *continuation*
action — no surah/ayah/juz/page/translation/reciter/audio and no reading
quantity is assigned, and no Quran repository is read. Resolving a concrete
reading position remains a later orchestration/content decision.

**TASK 082 update:** the Learn slice is the **first and only** source that
references real content IDs, and it needed **no new content** — the existing
30 published articles were exactly enough. Eligibility (published +
`sourceBodyVerified` + publication gate + registered source + TR/EN/AR
identity parity) is re-derived from the actual assets by test on every run.
The **2** `scholarlyReviewPending` articles (`art-kuran-okumaya-baslangic`,
`art-dua-adabi`) are excluded and proved absent from the catalog. Only the
stable article ID enters the plan — **no title, summary, body, translation or
source text**. **All three core item sources are now complete;** `dhikr`,
`dua` and `reflection` still have no approved content and remain an open
owner decision — do not invent it.

## Onboarding model reality (fixed by TASK 078)

The shipped onboarding is **three screens** (goals · journey stage · daily
pace), persisted as `OnboardingPreferences` under `bismillah.onboarding_*`
keys. The 16-question `OnboardingAnswers` model, `OnboardingGoal`,
`PersonalizationProfile` and `OnboardingRepository` are **UNUSED / FUTURE
EXTENDED ONBOARDING SCAFFOLDING** — never constructed, persisted or
referenced. Do not present them as active inputs, and do not map from them.
The historical "justBeginning skips the prayer-frequency question" skip rule
belongs to that unimplemented spec: **the current flow has no
prayer-frequency question**, so there is no skip or stale-answer handling to
implement.

## Firebase security gate order (authoritative — TASK 075)

Remote sync stays disabled until **all** of G1–G14 are satisfied, in order:
G1 staging environment + aliases + wrong-project guard · G2 Firestore section
in `firebase.json` · G3 Firestore Security Rules · G4 Rules unit tests ·
G5 Emulator Suite in CI · G6 server-side UID ownership · G7 App Check ·
G8 operation payload/schema versioning · G9 queue consumer + `cloud_firestore` ·
G10 remote idempotency · G11 conflict policy · G12 tombstone semantics ·
G13 account-link contract · G14 monitoring/budget/kill switch.

Roadmap owners: G3/G4/G6 → TASK 133 · G7 → TASK 134 · G9–G12 → TASK 132 ·
G13 → TASK 131. **G1, G2, G5, G8 and G14 have no task number yet** — assigning
them is an owner decision; TASK 075 deliberately invented no numbers.

## Open / known dependency status

- PR #4 — Drift 2.34.2 — **DEFERRED, must not be merged** (blocked by TASK 066
  toolchain incompatibility; TASK 075 added a second reason: `drift_dev` is
  capped at 2.34.0, so merging would desynchronise `drift` from `drift_dev`)
- Dependabot branch `dependabot/pub/bismillah_app/cloud_functions-6.3.4` —
  **UNRECORDED / NEEDS TRIAGE** (found at TASK 075; PR state UNVERIFIED
  because `gh` is not installed on the current machine)
- `flutter pub outdated` at TASK 075: **39** outdated (5 direct, 2 direct dev,
  27 transitive, 5 transitive dev). Direct: `flutter_local_notifications`
  22.1.0→22.2.0 (deliberately held at the device-validated 22.1.0),
  `drift` 2.34.1→2.34.2 (PR #4), `cloud_functions` 6.3.3→6.3.5,
  `firebase_auth` 6.5.4→6.5.6, `firebase_core` 4.12.0→4.12.1.
  **No update is required to pass CP09**; none applied.
- npm audit (Functions, TASK 075): **13 total — 0 critical, 5 high, 8
  moderate**, all transitive root advisories, **no non-breaking fix**.
  Chain A (all 5 high): `eslint` devDependency → … → `brace-expansion` —
  lint/build time only, **never deployed**. Chain B (all 8 moderate):
  `firebase-admin`/`firebase-functions` → … → `uuid` — **present in the
  deployed runtime tree**. Both need a major upgrade in a separate gated
  task; `firebase-admin` v14 must precede any remote-sync deployment.
- PR #6 — fast-xml-parser 5.10.1 — **SUPERSEDED** by TASK 069 (applied on the
  current Node.js 22 baseline; `fast-xml-parser 5.10.1`, `@nodable/entities 3.0.0`)
- actions/checkout v7 major — **DEFERRED**
- PR #3 — flutter_local_notifications 22.1.0 — **SUPERSEDED** by PR #14 (TASK 070C
  applied the same update on the validated manifest + exact-alarm UX baseline)
- Local branch `task/070-notifications-22-1-0` (local commit `a05f439`) — historical;
  superseded by the TASK 070C reapply, kept unpushed and untouched
- TASK 070 (original notification-update task) — **SUPERSEDED** by TASK 070A after a
  pre-existing Android manifest gap (missing scheduled-notification receivers) was found

## TASK 066 blocker (root cause)

- `drift_dev >= 2.34.1` requires `analyzer ^13.0.0`.
- Flutter 3.44.6's SDK-pinned test toolchain caps `analyzer < 13`.
- The Flutter SDK will not be upgraded solely to fix the Drift CLI.
- The TASK 064 runtime SQL snapshot remains the interim schema baseline.
