# TASK 089 — Learn Pack: Women, Afterlife, Islamic History

**Checkpoint:** CP11 (Learn and Assistant depth)
**Branch:** `task/089-learn-women-afterlife-history` (from `main` @ `17a753e`)
**Type:** content task — 5 new published Learn articles, no new source record.

## Owner decision

The roadmap defines no article count for TASK 089. After a **PARTIALLY READY**
evidence gate the owner fixed the scope at **5 articles**: `cat-afterlife` 3,
`cat-women` 1, `cat-history` 1 — 15 localized records. The optional fourth
afterlife candidate `art-olum-nedir` was explicitly **not** added (asserted).

## Articles delivered

| ID | Category | Source | Locator |
|---|---|---|---|
| `art-ahiret-nedir` | cat-afterlife | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 65–67 |
| `art-kiyametin-vakti-bilinmez` | cat-afterlife | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 66 |
| `art-ahirete-imanin-faydalari` | cat-afterlife | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 67 |
| `art-kadinlarin-ilim-talebi` | cat-women | `diyanet-hadislerle-islam` | Cilt 4, s. 240–241 |
| `art-kuranin-yazilmasi-ve-cogaltilmasi` | cat-history | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 55–56 |

**No new source record** — both sources were already registered, so the registry
stays at 7 (asserted by test).

## The pointed history section was rejected, not forced

The task named **Hadislerle İslâm, Cilt 1, ~s. 69** as the likely home of an
article on scholarly journeys (`art-ilim-yolculuklari`). Pages 66, 67, 69, 70,
71, 72, 74, 76, 78, 80 and 82 were fetched and read directly. There is **no
*rihle* chapter in that range**, and what is there is disqualified:

- **s. 66–67** — how narration began and sahâbî caution about narrating: hadith
  methodology, not a historical-development subject.
- **s. 69** — the spread of hadith *"halifeler zamanında düzenlenen askerî
  seferlerle İslâm ordularının ele geçirdiği bölgelerin tamamına"*: military and
  political history.
- **s. 70** — sahâbî counts that the source itself reports as conflicting
  (İbn Hacer 12.304; Hâkim ~4.000; Zehebî 1.500 and "asla 2.000'i bulmaz").
- **s. 71** — fitne, sects, *"Hz. Ali ve ailesine aşırı sevgi duyan çevreler,
  yoğun miktarda hadis uydurmuşlardır"*, Hz. Osman's killing, Emevî iktidarı:
  sectarian and political.
- **s. 72–82** — tedvin, tasnif and Kütüb-i sitte, discussed throughout in terms
  of *sahîh*, *zayıf* and *illetli*: authenticity grading.

The words *seyahat* and *sefer* appear on s. 76 and s. 78 only incidentally. The
proposed ID and title were therefore **dropped rather than forced onto unrelated
material**, and — on explicit owner approval — replaced with the Qur'an
preservation history from İslam İlmihali s. 55–56, which is stable, broadly
accepted, non-political chronology.

## Locator correction

`art-ahiret-nedir` is recorded as **s. 65–67**, not s. 65 as originally listed.
The "Ahiret Günü" definition the article turns on sits at the end of the
*Öldükten Sonra Dirilmek* sub-section on s. 67; citing s. 65 alone would not
point at the sentence being summarised.

## Content-safety boundaries

- **Afterlife** — excluded: the fear-toned Hacc 1–2 kıyamet scene, cennet and
  cehennem description, kabir azabı, şefaat (classified SCHOLARLY REVIEW
  REQUIRED and left out), hesap/mizan/sırat detail, personal salvation
  judgments, reward or punishment amounts, and any fear-based engagement copy.
  Also dropped: the source's "milletine ve vatanına karşı görevler" clause,
  which is open to contemporary political reading. `art-kiyametin-vakti-bilinmez`
  is deliberately a **protective** article: it states that only God knows the
  time and that the Prophet said he had no knowledge of it, which is direct
  source support against date speculation.
- **Women** — excluded: the governance narration and its surrounding discussion
  (C.4 s. 236), mahrem-travel rulings (s. 238), covering rulings, the
  war-participation clause in s. 240, s. 240's normative *"yaratılış kanununa
  aykırıdır"* social conclusion, and any superiority or deficiency claim. The
  article rests on the narration at s. 241 (Müslim, Birr, 152) in which a woman
  asks the Prophet to set aside a day to teach women, and he does.
- **History** — excluded: conquest framing, caliphal legitimacy or succession
  argument, sectarian reading, manuscript criticism, Qur'an-reading instruction,
  and any presentation of the figures as settled. The source's own hedging
  ("yaklaşık yetmiş hâfız", "yedi kadar nüsha") is preserved and test-enforced.

## Two stale fixtures fixed durably

`learn_repository_test` and `learn_screens_test` both hard-coded **`cat-history`**
as their "empty category" exemplar — a fixture that TASK 089 necessarily
invalidates by populating that category. Rather than swapping in another
soon-to-be-populated category, both now **derive** an empty category from the
shipped assets at test time, so no future Learn pack can break them. This is the
same growth-tolerance lesson as the TASK 082 catalog reconciliation and the
TASK 087 total-count correction.

## Review provenance

All five records carry `verifiedBy: editorialReview` on the owner's explicit
source-fidelity approval — editorial comparison against the recorded source
bodies and locators only, expressly **not** scholar approval, fatwa review,
hadith grading or Diyanet approval. `CONTENT_POLICY.md` still does not define who
may perform `editorialReview`; the wording proposed at TASK 087 remains
unapplied and open (closest owner: TASK 094).

## Locale parity and library state

TR canonical (`original`); EN and AR `explanatoryTranslation`. Identical stable
ID sets, category assignments and review statuses across all three locales;
Arabic titles and summaries carry no Latin characters; new articles omit
`beginnerPathOrder`.

Per locale: **50 records, 48 published** (was 45 / 43). Populated categories
**15 → 18 of 20**; only `cat-madhhabs` and `cat-calendar` remain empty, both
owned by TASK 090. The two `scholarlyReviewPending` articles remain pending for
TASK 091. `LearnDailyPlanCatalog.v1` is untouched — 30 entries, same order and
version — and none of the 5 new IDs enters it (asserted).

## Validation

- `flutter analyze`: **clean**
- TASK 089 suite: **27 / 27** — `flutter test test/features/learn/task_089_learn_pack_test.dart`
- Learn + catalog suites: **238 / 238**
- Content-source matrix validator: **14 / 14**
- Full Flutter suite: **1501 → 1528**, 0 failed, 0 skipped
- Functions: **not run** — untouched; no dependency or lockfile change

## Next roadmap task

**TASK 090 — Learn pack: Madhhabs, Islamic calendar and remaining gaps** (CP11).
