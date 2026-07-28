# TASK 087 — Learn Pack: Hadith, Seerah, Prophets

**Checkpoint:** CP11 (Learn and Assistant depth)
**Branch:** `task/087-learn-hadith-seerah-prophets` (from `main` @ `df1fec0`)
**Type:** content task — 9 new published Learn articles, 1 new source record,
1 new focused test suite, plus a surfaced TASK 082 test reconciliation.

## Owner decision

Article counts are **not** defined by the roadmap. The owner fixed the scope as
**3 + 3 + 3**: exactly 3 published articles in `cat-hadith`, 3 in `cat-seerah`
and 3 in `cat-prophets` — **9 new stable article IDs, 27 localized records**
(TR/EN/AR), with identical IDs and review statuses across all three locales.
The scope was not exceeded.

## Content gate

### `TASK 087 CONTENT GATE PASSED`

The gate ran **before** the branch was created and initially **blocked twice**,
which is the substance of this task:

1. **First stop (correct):** the originally proposed Seerah and Prophets sources
   were unreachable — `dijital.diyanet.gov.tr` answers HTTP/0.9 and
   `yayin.diyanet.gov.tr/File/Download?id=409` redirects to `diyanet.gov.tr/hata.html`.
   Working official substitutes were located instead of declaring the sources absent.
2. **Second stop (correct):** the proposed hadith article
   `art-guzel-ahlak-ve-yardimlasma` cited *Hadislerle İslâm, Cilt 1, s. 250*, but
   reading that page in full showed it covers the first revelation, Hz. Hatice's
   consolation and Varaka b. Nevfel — **not** a good-character teaching. The
   candidate sentence was one clause inside an unrelated narrative. The article
   was blocked rather than published against a locator its body does not support,
   and the topic was replaced **only** on explicit owner permission.

**Direct-source rule honoured.** No WebFetch summary, search snippet or model
description was used as evidence. PDFs were downloaded outside the repository and
their text extracted directly; the digital hadith work was read as rendered page
bodies. Downloads were never committed.

## Articles delivered

| ID | Category | Source | Locator |
|---|---|---|---|
| `art-hadis-ve-sunnet-nedir` | cat-hadith | `diyanet-hadislerle-islam` | Cilt 1, s. 41, 60 |
| `art-ilim-ve-hidayet-yagmuru` | cat-hadith | `diyanet-hadislerle-islam` | Cilt 1, s. 397 |
| `art-hayvanlara-merhamet` | cat-hadith | `diyanet-hadislerle-islam` | Cilt 5, s. 255–261 |
| `art-hilful-fudul` | cat-seerah | `diyanet-hz-muhammedin-hayati` | 16. Baskı 2025, s. 37–39 |
| `art-kabe-hakemligi` | cat-seerah | `diyanet-hz-muhammedin-hayati` | 16. Baskı 2025, s. 47–50 |
| `art-veda-hacci-ve-hutbesi` | cat-seerah | `diyanet-hz-muhammedin-hayati` | 16. Baskı 2025, s. 248–251 |
| `art-peygamber-kimdir` | cat-prophets | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 59–60 |
| `art-peygamberlerin-sifatlari` | cat-prophets | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 60–61 |
| `art-kuranda-adi-gecen-peygamberler` | cat-prophets | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 61 |

## New source record

`diyanet-hz-muhammedin-hayati` — *Hz. Muhammed'in Hayatı*, Prof. Dr. Casim Avcı –
Mevlâna İdris, T.C. Cumhurbaşkanlığı Diyanet İşleri Başkanlığı, Genel Yayın No 1286,
**Çocuk Kitapları 302**, 16. Baskı, İstanbul Mart 2025, ISBN 978-975-19-6627-8,
hosted under `egitimhizmetleri.diyanet.gov.tr`. The series, edition, authorship and
official status are recorded explicitly in `sources.json`; **no Diyanet endorsement
of the app is implied**. `diyanet-islam-ilmihali` was confirmed as **34. Baskı, 2019,
Ankara** from the downloaded PDF's own colophon — the exact edition existing locators
already cite.

## Evidence and review gate

All 9 articles carry `sourceBodyVerified: true`, `verificationMethod: sourceBodyReview`,
`verifiedBy: editorialReview`, an exact locator with page or volume reference, a concise
evidence summary and `verifiedAt`. Every `verification.sourceId` resolves to a registered
`sources.json` record and appears in the article's own `sourceIds`. All seven source
domains pass the HTTPS `diyanet.gov.tr` allowlist.

**Review provenance was recorded honestly.** The repository never defined who may perform
`editorialReview`, so the packet was reported as `REVIEW PROVENANCE AMBIGUOUS` and no
verified status was written until the owner performed and recorded an explicit
source-fidelity review. Proposed `CONTENT_POLICY.md` wording defining `editorialReview`
(owner/editor source-body comparison — **not** scholar approval, fatwa review, hadith
grading or Diyanet approval) was prepared and is **not** applied in this branch.

## Locale parity

TR is canonical (`translationStatus: original`); EN and AR are
`explanatoryTranslation`. All three locales carry identical stable ID sets, identical
category assignments and identical review statuses. Arabic prose is natural RTL content
and carries no Latin characters in title or summary. Verification metadata (Turkish
locator and evidence summary) is retained identically across locales, matching existing
convention.

## Content-safety boundaries

Deliberately excluded: hadith authenticity grading; personal rulings; sectarian or
madhhab argument; political comparison; reward or punishment guarantees; miracle and
end-times framing. Specific exclusions on owner instruction: the definitive 28-prophet
count and the disputed classification of Zülkarneyn, Lokman and Üzeyir (the article was
**narrowed, not substituted**); the exact Veda Haccı attendance figure in user-facing
prose (retained in evidence metadata only); the İslam İlmihali miracle narratives; the
reward-bearing rivayet on *Hadislerle İslâm* Cilt 5 s. 255; and the rulings on harmful
animals at s. 261. `art-peygamberlerin-sifatlari` was reduced to the five terms and
their definitions, without extending `ismet` to ordinary people.

## TASK 082 catalog boundary

**TASK 082's fixed 30-entry DailyPlan catalog is a curated versioned subset of the
growing published Learn library, not a permanent mirror of the full library.**

`LearnDailyPlanCatalog.v1` is **unchanged** — same 30 entries, same order, same version;
the production file is absent from this diff. None of the 9 new IDs enters the catalog,
asserted explicitly. Generator behaviour and Today plan sequencing are untouched.

Adding published articles surfaced **four** merged TASK 082 assertions that encoded
"the eligible library *equals* the catalog". These were reconciled on explicit owner
decision, in this branch, without a separate task:

- exact eligible-library count → **at least** `requiredEntryCount`, plus TR/EN/AR
  eligible ID sets asserted **identical**, not merely equal in count
- `catalogIds == eligibleIds` equality → removed; the subset invariant was **strengthened**
  to require every catalog ID to be eligible in **every** locale
- catalog-length-versus-library-length → catalog length equals `requiredEntryCount` and
  catalog IDs are unique; order determinism remains covered by its own group
- file-order comparison → now compares the catalog against the file order **of the same
  IDs**, so it stays meaningful as the library grows

Source verification, publication, locale parity and review gates were **not** weakened.
A new TASK 087 boundary group asserts the 9 IDs are absent from the catalog.

## Unchanged existing content

The 30 pre-existing published articles and the 2 `scholarlyReviewPending` articles
(`art-kuran-okumaya-baslangic`, `art-dua-adabi`) are untouched and still pending —
asserted by test. New articles carry no `beginnerPathOrder`, so the existing beginner
path stays contiguous. Totals per locale: **41 records, 39 published**. Populated
categories rose 9 → **12 of 20**; sources grounding published content rose 1 → **3 of 7**.

## Assistant boundary

No Assistant provider, query classifier, retrieval rule or history behaviour was changed.
The 9 articles become retrievable **solely** because they are published and source-verified.
No Assistant readiness is claimed; findings F1 and F2 remain owned by TASK 094.

## Validation

- `flutter analyze`: **clean**
- TASK 087 focused suite: **34 / 34** — `flutter test test/features/learn/task_087_learn_pack_test.dart`
- Catalog suite: **40 / 40** — `flutter test test/features/today/domain/learn_daily_plan_catalog_test.dart`
- Learn + catalog + item-source + Assistant: **338 / 338**
- Content-source matrix validator: **14 / 14**
- Full Flutter suite: **1436 → 1472**, 0 failed, 0 skipped
- Functions: **not run** — untouched; no dependency or lockfile change

## Next roadmap task

**TASK 088 — Learn pack: Dua, Family, Halal foundations** (CP11).
