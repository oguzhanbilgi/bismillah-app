# TASK 090 — Learn pack: Madhhabs, Islamic calendar and remaining gaps

**Checkpoint:** CP11 — Learn and Assistant depth
**Type:** content pack (assets + tests + governance docs)
**Branch:** `task/090-learn-madhhabs-calendar`
**Starting commit:** `1c1e282` (`origin/main` at start)

## Result

The final CP11 Learn pack. **6 new published articles / 18 localized records**
populating the last two empty categories, and **one** new source record.

Per locale: **56 records, 54 published** (was 50 / 48). Populated categories
**18 → 20 of 20** — **no Learn category is empty any more**. Source registry
**7 → 8**; sources grounding published content **3 → 4 of 8**.

| ID | Category | Source | Locator |
|---|---|---|---|
| `art-mezhep-nedir` | `cat-madhhabs` | `diyanet-islam-ilmihali` | İslam İlmihali (34. Baskı, 2019), II. İslâm'da Mezhepler / A) Mezhep Nedir?, s. 29 |
| `art-dini-hukumlerin-kaynaklari` | `cat-madhhabs` | `diyanet-islam-ilmihali` | a.g.e., III. Dinî Hükümlerin Kaynakları (Şer'î Deliller), s. 33-38 |
| `art-amelde-mezhepler` | `cat-madhhabs` | `diyanet-islam-ilmihali` | a.g.e., II. İslâm'da Mezhepler / 2. Amelde Mezhepler, s. 31-32 |
| `art-hicri-takvim-nedir` | `cat-calendar` | `diyanet-vakit-hesaplama` | Hicriden Miladiye — "Hicri Takvim Hakkında Açıklama", "HİCRİ TAKVİM" girişi ve 1. madde |
| `art-hicri-aylar-ve-yil-uzunlugu` | `cat-calendar` | `diyanet-vakit-hesaplama` | a.g.s., "Hicri Kameri Takvimde aylar..." paragrafı ve izleyen iki paragraf |
| `art-hicri-takvimin-baslangici` | `cat-calendar` | `diyanet-vakit-hesaplama` (+ `diyanet-hz-muhammedin-hayati`, s. 21) | a.g.s., 1. ve 2. maddeler |

## The evidence gate blocked four candidates, and they stayed blocked

Phase A prepared ten candidates and classified each one. **Four were classified
SCHOLARLY REVIEW REQUIRED and were not published**, even though publishing them
would have been the easy way to thicken the last two categories:

- `art-gorus-farkliliklari-nasil-olusur` — would rest on the Muâz b. Cebel
  narrative (İlmihal s. 29, footnoting Ebû Dâvûd "Akdıye" 11 / Tirmizî "Ahkâm" 3),
  a report whose authenticity is itself contested. The repository's precedent is
  to **exclude** hadith grading, not to adjudicate it.
- `art-itikadi-ve-ameli-mezhep-ayrimi` — s. 29 supports one sentence; every
  expansion available in the source lives on **s. 30-31**, which is built on the
  **Ehl-i Sünnet / Ehl-i Bidat** division and names Selefiyye / Mâturîdiyye /
  Eş'ariyye. That is exactly the deviance framing the task boundaries exclude.
- `art-takvim-ve-resmi-dini-gun-tespiti` — every passage that establishes the
  point sits inside the **rü'yet-i hilâl** debate (İlmihal s. 263-271), which is
  excluded outright.
- `art-aylarin-sayisi-on-ikidir` — Tevbe 9/36-37 and its tefsir are inseparable
  from fighting the müşrikler, the Câhiliye **nesî'** practice and the rulings
  attaching to the haram months. Extracting "there are twelve months" would have
  added nothing beyond `art-hicri-aylar-ve-yil-uzunlugu` while importing a
  polemical, ruling-bearing context.

A regression test asserts all four IDs are **absent** from every locale.

## The İlmihal has no Hijri-calendar chapter — and that was reported, not papered over

`İslam İlmihali` contains the word "takvim" on exactly two pages (s. 135, prayer
timetables; s. 263, inside the moon-sighting discussion). It has **no month list,
no epoch statement and no year-length statement**. `Hz. Muhammed'in Hayatı` has
"takvim" on one page (s. 21) and never defines the calendar. The calendar category
therefore **could not** be grounded on the existing registry, and a new source was
genuinely required rather than convenient.

Endpoints that failed were recorded, not worked around: the Din İşleri Yüksek
Kurulu search returns a **WAF block page**; `vakithesaplama.diyanet.gov.tr` and
`www.diyanet.gov.tr/tr-TR/Kurumsal/Detay/10350` reset the connection;
`.../Sayfalar/HicriTakvimFarki.aspx` returns 404. None of them was used. Web
search was used only to **discover** a candidate URL; the evidence is the fetched
body alone.

## New source: `diyanet-vakit-hesaplama`

- **Work:** T.C. Diyanet İşleri Başkanlığı, *Vakit Hesaplama* —
  "Takvim Bilgileri / Tarih Dönüşümleri / Hicriden Miladiye"
- **URL:** `https://www2.diyanet.gov.tr/DinHizmetleriGenelMudurlugu/Sayfalar/HicridenMiladiye.aspx`
- **Type:** `officialPublication` — **no enum or schema change.** There is no
  `webPage` value in `KnowledgeSourceType`, and `diyanet-kuran-portali` already
  uses `officialPublication` for a web property, so this is existing practice.
- **Domain gate:** `www2.diyanet.gov.tr` is a subdomain of `diyanet.gov.tr` and
  the URL is HTTPS, so `OfficialSourceDomains.isAllowed` accepts it. **No
  allowlist change was made.**
- **Direct-body verification:** HTTP 200, 32,536 bytes, no redirect, retrieved
  2026-07-29. The cited explanation block is 2,207 normalised characters; its
  SHA-256 begins `768cd2cb1700a2cb` (whole response `c152b000232e0614`), recorded
  outside the repository so a future task can detect a silent edit.
- **Unavailable metadata was left unavailable.** The page is a maintained web
  service with **no author, edition, ISBN or publication date**. None was
  invented; `publicationInfo` states plainly that the source is an internet
  service without such an imprint and carries the bibliography the page itself
  cites. A test asserts that no `author`, `edition`, `isbn` or `publishedAt` key
  exists on the record.
- **Volatility is recorded as a limitation** in `CONTENT_SOURCE_MATRIX.md`: unlike
  a PDF this page can be edited or moved silently, and a neighbouring page in the
  same site section already 404s.

## Owner correction applied: no exact Gregorian conversion dates

The source records exact Gregorian equivalents for both Hijri epochs. On an
explicit binding owner correction these are **excluded from all shipped content** —
summary, body, key point, practical action **and** the shipped
`verification.evidenceSummary` — and are **not** replaced by another exact
Gregorian date. `art-hicri-takvimin-baslangici` now states the Hijra as the epoch,
the decision taken in Umar's time in the seventeenth year after the migration,
Muharram as the start of the year, and the fact that the lunar and solar Hijri
systems have different starting days — without a Gregorian date. The values remain
only in the internal source-review note kept outside the repository.

A dedicated test enforces this across all three locales and across prose,
`sourceLocator` and `evidenceSummary`.

## Content boundaries honoured

**Madhhabs** — no superiority or correctness ranking, no "which madhhab should I
follow", no personal fiqh ruling, no comparative verdict table, no takfir/bid'ah
language. `art-amelde-mezhepler` preserves the source's own *"Sünni Müslümanlar
arasında yaygın"* framing rather than upgrading it to "the four madhhabs", and
states in its own text that it carries no judgement about traditions not mentioned.
Excluded from that article: Abu Hanifa's refusal of the Baghdad judgeship and his
imprisonment (**political**), the "büyük ihtimalle Türk'tür" ethnic conjecture, the
evaluative claim about al-Muwatta being the first fiqh-ordered hadith book, and the
Musnad hadith count. Excluded from `art-dini-hukumlerin-kaynaklari`: the Nisâ 4/115
cehennem framing quoted for İcma, the s. 36 remark that belittling a sunnah may
lead to küfr (**takfir-adjacent**), and the killer-heir qiyas worked example
(**a disputed legal example**).

The one scholarly difference the source itself records — the majority holding
explicit ijma decisive while tacit ijma is disputed — is **stated, not hidden**,
in a `differenceOfOpinion` block, per `CONTENT_POLICY.md`.

**Calendar** — no current or future Ramadan, Eid or sacred-night date; no
moon-sighting position; no instruction about which authority to follow; no
official religious-date determination; no guaranteed virtue or reward; no
astrology. `art-hicri-takvim-nedir` states explicitly that Bismillah does not
determine the official date of any religious day. Excluded: the page's
year-conversion arithmetic (an approximation) and its remark that fasting rotates
through every day of the year over 33 years (**worship framing**).

## Locator correction, disclosed

The Phase-A packet recorded `art-dini-hukumlerin-kaynaklari` as
"s. 33, 36-38". The shipped locator is **s. 33-38**, because the Sunnah definition
(kavlî / fiilî / takrirî) that the article uses sits on **s. 34**, inside the same
numbered chapter. Nothing else changed. Same discipline as TASK 089's
`art-ahiret-nedir` s. 65 → s. 65-67 correction.

## Two more frozen-count assertions were repaired

`task_088_learn_pack_test.dart` and `task_089_learn_pack_test.dart` each asserted
`sources.length == 7`. Registering an eighth source would have failed both — the
same defect class TASK 088 fixed in TASK 087's suite. Each assertion now checks
what it actually meant: the seven post-TASK-087 source IDs are all still
registered, and **that task's own pack cites nothing outside them**. The registry
is free to grow. No verification, publication, locale-parity or review gate was
weakened.

## Boundaries preserved

- `LearnDailyPlanCatalog.v1` — **exactly 30 entries, unchanged**; none of the 6
  new IDs enters it (asserted).
- TASK 091's two `scholarlyReviewPending` records
  (`art-kuran-okumaya-baslangic`, `art-dua-adabi`) — untouched and still pending
  in all three locales (asserted).
- The empty-category UI state stays test-covered through TASK 089's synthetic
  test-only category, so populating all 20 production categories did not remove
  that coverage.
- No `beginnerPathOrder` assigned, so the beginner path stays contiguous.
- No Assistant, Quran, Prayer, persistence, Drift, Firebase, remote-sync, premium
  or monetization change. No schema, enum, storage key or envelope version change.

## Tests

- TASK 090 pack suite: **37 / 37** —
  `flutter test test/features/learn/task_090_learn_pack_test.dart`
- Content-source matrix suite: **14 / 14** — `flutter test test/content`
- Learn feature suite: see `CURRENT_BASELINE.md`
- Full Flutter suite: see `CURRENT_BASELINE.md`
- `flutter analyze`: clean
- Functions: **not re-run** — no Functions file, dependency or lockfile changed.

## Review provenance (still open)

This pack carries `verifiedBy: editorialReview` on the strength of a recorded
owner source-fidelity approval of the six final Turkish drafts against their
source bodies and exact locators. The owner stated explicitly that this is
**editorial source-fidelity approval only** — not scholar approval, fatwa review,
Diyanet approval or institutional endorsement.

The TASK 087 finding stands: the repository still does **not** define who may
perform `editorialReview`, and `CONTENT_POLICY.md` was not amended by TASK 087-090.
Defining review provenance remains an owner decision.
