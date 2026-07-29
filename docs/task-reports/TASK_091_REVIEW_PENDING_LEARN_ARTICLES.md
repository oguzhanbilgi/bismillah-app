# TASK 091 — Review pending Learn articles

**Checkpoint:** CP11 — Learn and Assistant depth
**Type:** content review (assets + tests + governance docs)
**Branch:** `task/091-review-pending-learn-articles`
**Starting commit:** `b174789` (`origin/main` at start)

## Scope

The roadmap defines TASK 091 as exactly one line — "Review pending Learn
articles" — with **no acceptance criteria**. The audit confirmed it covers only
the two long-standing `scholarlyReviewPending` records. The four candidates
blocked during TASK 090 are **not** part of this task and remain deferred; two
TASK 090-authored documentation lines that suggested otherwise were
recommendations, not roadmap assignments.

## Result

Per locale: **56 records, 55 published, 1 `scholarlyReviewPending`**
(was 56 / 54 / 2). Categories stay **20 of 20**; the source registry stays at
**8**; `LearnDailyPlanCatalog.v1` stays at exactly **30** entries.

| Record | Outcome |
|---|---|
| `art-kuran-okumaya-baslangic` | **Rewritten and published** on İslam İlmihali s. 58 |
| `art-dua-adabi` | **Remains pending** — body not approved; only `isFeatured` changed to `false` |

## art-kuran-okumaya-baslangic

**Preserved:** stable ID, slug, `cat-quran-learning`, `beginnerPathOrder: 11`,
`relatedArticleIds`, `isFeatured: false`, record schema.

**Source replaced.** Was `diyanet-kuran-portali` with an **empty locator and an
empty evidence summary** — the portal is a Quran text and translation service and
contains no chapter on learning to read, so nothing in the old body was supported
by its own registered source. It is now:

`İslam İlmihali (34. Baskı, 2019), Kur'an-ı Kerim'e Karşı Görevlerimiz —
b) Kur'an-ı Kerim'i Öğrenmek, s. 58`

read directly from the PDF body. **No new source record was required.**

**The article now states only what s. 58 states:** that "learning the Quran" is
listed among the duties towards the Quran; that the source defines it as learning
to read it *and* working to understand its meaning; and that the same passage says
tajwid must be learned in order to read without error — presented as part of that
learning, not as a separate obligation.

**Removed completely:** the previous five-step list (elif-bâ → vowel marks →
listening to short suras → words and verses → find a teacher), which appeared on no
source page; every claim resting on the Quran portal; the s. 58 virtue hadith
("En hayırlınız, Kur'an'ı öğrenen ve onu başkalarına öğretendir", Buhârî
"Fezâ'ilu'l-Kur'ân" 21 / Tirmizî 15) with its "övülmüş" framing and the
early-Muslims memorisation account; the s. 58 ruling "namaz sahih olacak kadar
Kur'an öğrenmek **farzdır**" and the kıraat/namaz validity sentence carrying it;
the page's reward framing ("Dünya ve ahirette mutluluğa götüren yol…", "sözlerin en
yücesi"); items (a) and (c) of the same list; and any fixed reading requirement,
pace, mastery or programme claim. The closing paragraph states explicitly that the
article proposes no programme, duration, pace or daily amount, and directs personal
questions to the competent authority or a trusted teacher.

**Metadata changes:** title → "Kur'an'ı öğrenmek ne demektir?" (EN "What does
learning the Qur'an mean?", AR "ما معنى تعلّم القرآن؟"); `contentType`
`generalTeaching` → `ilmihalKnowledge`; `estimatedMinutes` 4 → 3; keywords updated
(`elif ba` dropped — it no longer appears in the body); the whole `verification`
block rewritten (`sourceBodyVerified: true`, real locator, real evidence summary,
`verifiedBy: editorialReview`, `verificationMethod: sourceBodyReview`, `blocker`
removed). Slugs were **not** changed, so existing deep links keep resolving.

EN and AR are faithful translations of the approved Turkish and add no claim; the
section shape is identical across the three locales (asserted).

## art-dua-adabi

**Kept `scholarlyReviewPending` in TR, EN and AR. Title, summary, body, source,
locator, verification record and translations were not touched.** The only change
is `isFeatured: true → false`.

Recorded honestly:

- **Qualified scholarly review is required.** The subject is dua etiquette —
  normative worship guidance — which does not qualify for owner editorial review.
- **The body is not approved.** It remains unsourced: empty `sourceLocator`, empty
  `evidenceSummary`, `sourceBodyVerified: false`, and its recorded `blocker` is
  deliberately preserved. It declares `contentType: hadithBased` while quoting no
  hadith, and it carries a normative five-item adab checklist plus an
  acceptance/answer claim.
- **The Arabic currently strengthens one sensitive claim.** TR says the *awareness*
  ("bilinci esastır") that an answer comes at the fitting time; AR says "الأصل هو
  **اليقين**" — *certainty*. `CONTENT_POLICY.md` forbids a translation being
  stronger than the canonical Turkish. **Not edited here** (the owner scoped this
  task to `isFeatured` only); it must be fixed before any future publication.
- **Narrowing the subject would duplicate `art-dua-nedir`.** Strip the normative
  checklist and the acceptance claim and what remains is "what dua is", already
  published by TASK 088 in the same `cat-dua` category.

**Why `isFeatured` mattered.** There was no leak — `getFeatured` reads the
published-only index — but the flag meant that publishing the record would have
made it a front-page featured article *and* beginner-path item 12 in the same
moment, with no separate decision. A test now asserts that **no locale contains a
featured-but-unpublished record**.

Its `beginnerPathOrder: 12` is retained, so the beginner path stays contiguous
(1..13) and no renumbering was needed.

## Tests

New suite `test/features/learn/task_091_pending_review_test.dart` — **24 tests**
covering: identity and `beginnerPathOrder` preserved; published status; source is
`diyanet-islam-ilmihali`; the portal no longer feeds the article while its registry
record survives; locator carries **s. 58** and the section heading; publication-gate
fields filled and `blocker` removed; `contentType`; the new title in all three
locales with no Latin characters in the Arabic; the five-step content absent (no
`steps` block, no `items`, key terms gone); virtue / reward / "farzdır" absent;
speed, mastery, programme and daily-amount claims absent; TR/EN/AR carrying the
same narrowed meaning **and** the same section shape; `art-dua-adabi` pending in all
locales with `isFeatured: false` and its body/source/locator untouched; no
featured-but-unpublished record in any locale; no unpublished record in the plan
catalog; catalog still exactly 30 with unchanged endpoints; **56 / 55 / 1** per
locale; all 20 categories still populated; no source record deleted; beginner path
contiguous; cross-locale consistency.

**Six existing assertions were re-pointed, not weakened** — each had used one of
the two pending records as its exemplar, and TASK 091 is precisely the task that
resolves one of them:

- `task_087` `stillPendingIds`, `task_089` and `task_090` pending checks → now
  assert `art-dua-adabi` only, with the pending **count deliberately not frozen**.
- `assistant_repository_test` "pending content never reaches retrieval" → exemplar
  moved to `art-dua-adabi`.
- `learn_repository_test` "unverified content is invisible at runtime" → keeps the
  `dua-adabi` assertions and now additionally asserts the Quran article **is**
  reachable **and** source-body verified. This strengthens the test.
- `learn_daily_plan_catalog_test`: two assertions had frozen "the catalog head
  equals every published beginner-path member" and "orders 11 and 12 are pending".
  Both now assert the durable invariant instead — the catalog head is a set of
  eligible published beginner-path members in ascending order, and **no**
  unpublished beginner-path member is in the catalog — so a later review cannot
  break them again. This is the same frozen-figure defect class TASK 088 and
  TASK 090 repaired.

One production comment in `learn_daily_plan_catalog.dart` was corrected: it
asserted that beginner-path members 11 and 12 are pending, which is no longer true.
The catalog itself is unchanged.

## Results

- TASK 091 suite: **24 / 24**
- Learn + Assistant + catalog + content suites: **379 / 379**
- Full Flutter suite: **1566 → 1590**, 0 failed, 0 skipped
- `flutter analyze`: clean
- Functions: **not run** — no Functions file, dependency or lockfile changed.

## Governance

`CONTENT_SOURCE_MATRIX.md` updated: `learn-articles` counts (55 published / 1
pending, İlmihal now grounding 44), a TASK 091 update note, the
`learn-source-registry` limitation (the Quran portal now grounds nothing and is
**kept registered on purpose**), the `learn-plan-catalog` review line, and finding
**F5**. `CONTENT_SOURCES.md` status line updated. **`CONTENT_POLICY.md` was not
edited** — formal `editorialReview` wording remains owned by **TASK 094**, and the
TASK 087 finding that the repository never defines who may perform
`editorialReview` is still open.

## Review provenance

The owner recorded an explicit **source-fidelity approval** of the rewritten
Turkish draft against İslam İlmihali s. 58. That is editorial source-fidelity
approval only — **not** scholar approval, fatwa review, Diyanet approval or
institutional endorsement. No such review is claimed anywhere in this task, and
`art-dua-adabi` is explicitly recorded as still needing a qualified reviewer.
