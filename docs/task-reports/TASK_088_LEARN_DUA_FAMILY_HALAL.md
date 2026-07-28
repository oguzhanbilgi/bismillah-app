# TASK 088 — Learn Pack: Dua, Family, Halal Foundations

**Checkpoint:** CP11 (Learn and Assistant depth)
**Branch:** `task/088-learn-dua-family-halal` (from `main` @ `c133fb6`)
**Type:** content task — 4 new published Learn articles, no new source record.

## Owner decision

The roadmap defines no article count for TASK 088, and TASK 087's 3+3+3 was
explicitly **not** inherited. The owner fixed the scope after the Phase A gate at
**4 articles**: `cat-dua` 1, `cat-family` 2, `cat-halal` 1 — 12 localized records.

## Evidence gate

The Phase A gate returned **PARTIALLY READY**, and that result shaped the final
scope. Three findings drove it:

1. **Dua had no clean source at first.** The İslam İlmihali has no standalone dua
   chapter — its TOC carries only namaz-attached duas — and its one general dua
   passage at printed p. 163 **extracts with corrupted glyphs**
   (`sunmaskdkr`, `Dua'nkn kkblesi`), so it is unusable as evidence. Probes of
   Hadislerle İslâm Cilt 2/3/6/7 initially surfaced no dua chapter body. The owner
   then named the correct location and it was read directly.
2. **The Dua chapter's spine is excluded material.** With the boundary confirmed
   (Cilt 2: p. 33 previous chapter, p. 34 blank, pp. 35–37 hadith cluster, p. 38
   blank, p. 39 onward commentary), the chapter turns out to be built on
   *guaranteed acceptance and special times* — "hangi dua daha çok kabule
   şayandır" (s. 35), the Friday hour where "Allah ona dilediğini mutlaka verir"
   and "duaların en hayırlısı arefe günü" (s. 36–37), "özel zamanlar
   bahşetmiştir… duaların kabulü için birer fırsat" (s. 40), the night-descent
   hadith (s. 41). All of that is excluded, so `art-dua-nedir` rests on **s. 40
   alone**. This was disclosed before drafting rather than padded.
3. **`cat-dua` was already occupied.** `art-dua-adabi` (manners of dua) exists as
   `scholarlyReviewPending` and belongs to **TASK 091**. It was not touched, and
   the new article deliberately avoids dua etiquette.

## Articles delivered

| ID | Category | Source | Locator |
|---|---|---|---|
| `art-dua-nedir` | cat-dua | `diyanet-hadislerle-islam` | Cilt 2, "Dua: Kulluğun Özü", s. 40 |
| `art-ailenin-onemi` | cat-family | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 503 |
| `art-anne-babaya-saygi-ve-nezaket` | cat-family | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 507–508 |
| `art-helal-ve-haram-nedir` | cat-halal | `diyanet-islam-ilmihali` | 34. Baskı 2019, s. 383–384 |

**No new source record was added** — both sources were already registered, so the
registry stays at 7 (asserted by test).

## Content-safety boundaries

Every exclusion the owner set was applied and is test-enforced where mechanically
checkable:

- **Dua** — no guaranteed acceptance, no special guaranteed times, no fixed reward
  claims, no talismanic or medical framing, no long quoted dua text, and no dua
  etiquette (that is TASK 091's `art-dua-adabi`).
- **Family** — no gender-specific roles or maintenance duties (s. 504 excluded),
  no marriage validity, divorce, custody or inheritance, no family-dispute
  guidance. The second article was renamed to `art-anne-babaya-saygi-ve-nezaket`
  and narrowed to courtesy: the source's **blanket-obedience items** (answering
  when called, carrying out their instructions, pleasing them in every matter) and
  its **financial maintenance item** were deliberately dropped.
- **Halal** — definitions only. Named foods, additives, products, finance
  instruments, certification claims, madhhab differences, the
  *haram liaynihi / ligayrihi* distinction (`art-haramin-cesitleri`, out of scope
  and classified SCHOLARLY REVIEW REQUIRED) and the apostasy consequence are all
  excluded. The article attributes its definitions explicitly to the reviewed
  Diyanet İslam İlmihali and directs users with a personal case to the competent
  official authority.

One instruction was **not** followed literally: the allowed scope for the parent
article mentioned "attentive listening", which does not appear in the source body
in that form. It was omitted rather than invented, and the omission is recorded.

## Review provenance

All four records carry `verifiedBy: editorialReview` on the basis of the owner's
explicit source-fidelity approval — editorial comparison against the recorded
source bodies and locators only, expressly **not** scholar approval, fatwa review,
hadith grading or Diyanet approval. `CONTENT_POLICY.md` still does not define who
may perform `editorialReview`; the wording proposed at TASK 087 remains unapplied
and open (closest owner: TASK 094).

## Locale parity

TR canonical (`original`); EN and AR `explanatoryTranslation`. Identical stable ID
sets, category assignments and review statuses across all three locales; Arabic
titles and summaries carry no Latin characters. New articles omit
`beginnerPathOrder`, so the beginner path stays contiguous.

## Library and catalog state

Per locale: **45 records, 43 published** (was 41 / 39). Populated categories
**12 → 15 of 20**; the five still empty are `cat-women`, `cat-afterlife`,
`cat-history`, `cat-madhhabs`, `cat-calendar`. `cat-dua` is now the first category
holding a published and a pending record side by side.

`LearnDailyPlanCatalog.v1` is **untouched** — 30 entries, same order and version —
and none of the 4 new IDs enters it (asserted).

**One TASK 087 test was corrected.** The suite written last task asserted absolute
library totals (`32 + 9 = 41`, `30 + 9 = 39`), which every later Learn pack
necessarily breaks — the same frozen-count defect the TASK 082 reconciliation
addressed. Those two assertions were replaced with a growth-tolerant pair: totals
must be **at least** the TASK 087 baseline, and all nine TASK 087 articles must
still be present, published and source-verified in every locale. That strengthens
the real guarantee (TASK 087's content is untouched) while removing the false
assumption that the library never grows.

## Validation

- `flutter analyze`: **clean**
- TASK 088 suite: **29 / 29** — `flutter test test/features/learn/task_088_learn_pack_test.dart`
- TASK 087 suite: **34 / 34** (unchanged count after the correction)
- Learn + catalog suites: **211 / 211**
- Content-source matrix validator: **14 / 14**
- Full Flutter suite: **1472 → 1501**, 0 failed, 0 skipped
- Functions: **not run** — untouched; no dependency or lockfile change

## Next roadmap task

**TASK 089 — Learn pack: Women, Afterlife, Islamic history** (CP11).
