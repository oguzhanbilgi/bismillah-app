# Content Source Matrix

Canonical governance matrix for every religious and educational content class
shipped by Bismillah. Established by **TASK 086** (CP11).

This document answers, per content area: what the source is, whether it is
official/primary or reviewed secondary material, where it lives, how it is
delivered, whether the publication and source-review gates apply, what locale
coverage exists, which surfaces may consume it, and what remains unresolved.

**Relationship to other documents — this file does not replace them:**

- [`CONTENT_SOURCES.md`](CONTENT_SOURCES.md) — public attribution and delivery notice.
- [`../THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md) — formal third-party licence notices.
- [`../CONTENT_POLICY.md`](../CONTENT_POLICY.md) — the publication gate and safety policy.
- [`project-state/DO_NOT_BREAK.md`](project-state/DO_NOT_BREAK.md) — invariants every task must preserve.

Licensing and attribution facts are **stated once** in the two notice documents
above; this matrix references them and records only the governance decision.

## How to read a row

- **Source class** — `official-primary` (a named institution's own work),
  `reviewed-secondary` (original text grounded in a cited source and body-verified),
  `internal-ui-copy` (application interface wording that is **not** religious
  teaching), or `unresolved`.
- **Delivery** — `bundled-asset`, `local-generated-metadata`, `approved-remote-proxy`,
  or `not-implemented`.
- **Status** — `READY`, `READY WITH DOCUMENTED LIMITATION`, `REVIEW REQUIRED`,
  `BLOCKED`, `NOT IMPLEMENTED`. A row is `READY` only when a concrete source
  exists, required metadata is valid, publication rules pass, locale handling is
  understood, and no known licensing or source contradiction exists.
- **UNRESOLVED / UNKNOWN** means the repository does not establish the fact.
  It is never filled in from general knowledge.

## Summary

| ID | Surface | Source class | Status |
|---|---|---|---|
| `quran-arabic-text` | Quran | official-primary | READY WITH DOCUMENTED LIMITATION |
| `quran-chapter-metadata` | Quran | official-primary | READY |
| `quran-verse-page-map` | Quran | official-primary | READY |
| `quran-translation-tr` | Quran | official-primary | READY WITH DOCUMENTED LIMITATION |
| `quran-search-index` | Quran | local-derived | READY |
| `quran-recitation-audio` | Quran | official-primary | READY WITH DOCUMENTED LIMITATION |
| `quran-recitation-catalog` | Quran | official-primary | READY WITH DOCUMENTED LIMITATION |
| `quran-translation-remote-diyanet` | Quran (inactive) | official-primary | REVIEW REQUIRED |
| `learn-articles` | Learn | reviewed-secondary | READY |
| `learn-prayer-education` | Learn | reviewed-secondary | READY WITH DOCUMENTED LIMITATION |
| `learn-categories` | Learn | internal-ui-copy | READY |
| `learn-source-registry` | Learn / Assistant | official-primary | READY WITH DOCUMENTED LIMITATION |
| `learn-plan-catalog` | Today | local-derived | READY |
| `prayer-time-calculation` | Prayer / Today | local-derived | READY WITH DOCUMENTED LIMITATION |
| `prayer-name-labels` | Prayer / Today | internal-ui-copy | READY |
| `dua-content` | none | unresolved | NOT IMPLEMENTED |
| `dhikr-content` | none | unresolved | NOT IMPLEMENTED |
| `onboarding-copy` | Onboarding | internal-ui-copy | READY |
| `today-plan-item-copy` | Today | internal-ui-copy | READY |
| `assistant-retrieval-corpus` | Assistant | reviewed-secondary | READY WITH DOCUMENTED LIMITATION |
| `assistant-safety-copy` | Assistant | internal-ui-copy | READY WITH DOCUMENTED LIMITATION |
| `app-source-reference-registry` | Profile | official-primary | READY WITH DOCUMENTED LIMITATION |
| `official-answer-index` | Assistant (foundation only) | official-primary | READY WITH DOCUMENTED LIMITATION |

Counts: READY **9** · READY WITH DOCUMENTED LIMITATION **11** ·
REVIEW REQUIRED **1** · BLOCKED **0** · NOT IMPLEMENTED **2**.

---

## Rows

### quran-arabic-text

- **Surface:** Quran reader, offline search snippets
- **Content type:** Quran Arabic text (Uthmani)
- **Source name:** Tanzil Project — Quran Text (Uthmani) v1.1
- **Source class:** official-primary
- **Evidence:** `bismillah_app/assets/quran/verses_uthmani_v1.json` (header `source`, `license`, `sourceUrl`; 6236 verses), `bismillah_app/assets/quran/NOTICE.md`, `tool/generate_quran_verses.py`
- **Delivery:** bundled-asset
- **Publication status:** shipped; not governed by the Learn publication gate
- **Source review:** structural verification only — 114 chapters / 6236 verses, per-chapter counts consistent
- **TR:** not applicable (Arabic scripture text)
- **EN:** not applicable
- **AR:** yes — the single canonical text
- **Locale rule:** locale-invariant; app language never alters the Arabic text, and no transliteration is produced (asserted in `bismillah_app/test/features/settings/quran_locale_exception_test.dart`)
- **Attribution:** required — Tanzil Project, <https://tanzil.net>
- **Licensing:** CC BY 3.0, recorded in `THIRD_PARTY_NOTICES.md`
- **Consumers:** Quran, Today
- **Prohibited:** modification, normalization, diacritic removal, auto-correction, Basmala addition/removal; no verse-level analytics
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** a full byte-for-byte comparison against the upstream Tanzil distribution has **not** been completed; do not claim a completed upstream diff
- **Follow-up:** UNRESOLVED — no roadmap task owns the full-corpus upstream diff

### quran-chapter-metadata

- **Surface:** Quran chapter list and reader headers
- **Content type:** chapter (sura) catalog metadata
- **Source name:** Tanzil Project — Quran Metadata 1.0
- **Source class:** official-primary
- **Evidence:** `bismillah_app/assets/quran/chapters_v1.json` (114 chapters), `tool/generate_quran_chapters.py`
- **Delivery:** local-generated-metadata
- **Publication status:** shipped; not governed by the Learn publication gate
- **Source review:** generation-time verification — 114 chapters, 6236 total verses
- **TR:** yes — localized chapter naming in the interface layer
- **EN:** yes
- **AR:** yes
- **Locale rule:** identifiers are locale-invariant; only display labels localize
- **Attribution:** required — Tanzil Project, <https://tanzil.net/docs/quran_metadata>
- **Licensing:** covered by the Tanzil notice in `THIRD_PARTY_NOTICES.md`
- **Consumers:** Quran
- **Prohibited:** hand-editing the generated catalog
- **Status:** READY
- **Follow-up:** none

### quran-verse-page-map

- **Surface:** Quran reading progress (Mushaf page position)
- **Content type:** verse-to-page mapping
- **Source name:** Tanzil Project — Quran Metadata 1.0 (Madani pages)
- **Source class:** official-primary
- **Evidence:** `bismillah_app/assets/quran/verse_pages_v1.json` (604 pages, 6236 verse keys), `tool/generate_quran_verse_pages.py`
- **Delivery:** local-generated-metadata
- **Publication status:** shipped; not governed by the Learn publication gate
- **Source review:** generation-time verification — counts match the chapter catalog
- **TR:** not applicable
- **EN:** not applicable
- **AR:** not applicable
- **Locale rule:** locale-invariant numeric mapping
- **Attribution:** required — Tanzil Project
- **Licensing:** covered by the Tanzil notice in `THIRD_PARTY_NOTICES.md`
- **Consumers:** Quran
- **Prohibited:** presenting page numbers as a religious obligation or quota
- **Status:** READY
- **Follow-up:** none

### quran-translation-tr

- **Surface:** Quran reader translation panel
- **Content type:** Turkish Quran translation (meal) with footnotes
- **Source name:** QuranEnc.com — Türkçe Tercüme, Rowad Tercüme Merkezi (`turkish_rwwad`) V1.0.4
- **Source class:** official-primary
- **Evidence:** `bismillah_app/assets/quran/translations/quranenc_turkish_rwwad_v1_0_4.json` (metadata block; 6236 records), `bismillah_app/lib/features/quran/data/bundled_quranenc_translation_repository.dart`, `tool/generate_quranenc_translation.py`
- **Delivery:** bundled-asset
- **Publication status:** shipped as the single active translation source
- **Source review:** spot-check only — 6 suras / 491 verses compared against the live QuranEnc API; whitespace-only differences
- **TR:** yes
- **EN:** none — no English translation asset exists
- **AR:** not applicable (source text is `quran-arabic-text`)
- **Locale rule:** Quran locale exception — changing the app language does **not** translate the meal content; only the panel title and source line follow the app language
- **Attribution:** required — publisher Rowad Tercüme Merkezi, source QuranEnc.com, version shown in-app (`quranTranslationRowadLine`, `quranTranslationQuranEncLine`)
- **Licensing:** UNRESOLVED — the repository records usage restrictions (no addition, deletion or alteration; version metadata preserved) but **no explicit licence grant**; do not claim one
- **Consumers:** Quran
- **Prohibited:** altering, re-punctuating, simplifying or AI-processing the text; shipping it as an EN or AR translation
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** full-corpus upstream comparison not performed; licence terms unestablished; non-Turkish app locales have no translation in their own language
- **Follow-up:** UNRESOLVED — owner decision; no roadmap task owns translation licensing or EN/AR meal coverage

### quran-search-index

- **Surface:** Quran offline search
- **Content type:** derived matching tokens and reference aliases
- **Source name:** derived from `quran-arabic-text` and `quran-translation-tr`
- **Source class:** local-derived
- **Evidence:** `bismillah_app/assets/quran/search/quran_search_index_v1.json` (`source` block names both upstreams), `tool/generate_quran_search_index.py`
- **Delivery:** local-generated-metadata
- **Publication status:** shipped
- **Source review:** the asset itself records that it holds matching values only — display text is read from the original assets
- **TR:** yes — translation-side tokens
- **EN:** none
- **AR:** yes — Arabic-side tokens
- **Locale rule:** index is locale-invariant; the reader resolves display text per surface
- **Attribution:** inherited from the two upstream rows; the index is not separately attributable
- **Licensing:** inherited from `quran-arabic-text` and `quran-translation-tr`
- **Consumers:** Quran
- **Prohibited:** rendering index tokens as scripture or translation text
- **Status:** READY
- **Follow-up:** none

### quran-recitation-audio

- **Surface:** Quran verse and chapter recitation playback
- **Content type:** recitation audio streams and verse timings
- **Source name:** MP3Quran.net
- **Source class:** official-primary
- **Evidence:** `bismillah_app/lib/features/quran/data/mp3quran_audio_repository.dart` (`https://www.mp3quran.net/api/v3/ayat_timing`), `bismillah_app/lib/features/quran/domain/entities/quran_chapter_recitation.dart` (HTTPS-only guard)
- **Delivery:** approved-remote-proxy
- **Publication status:** shipped; streamed at runtime, **no audio file is bundled**
- **Source review:** not applicable — third-party recordings are referenced, never reproduced
- **TR:** not applicable
- **EN:** not applicable
- **AR:** yes — Arabic recitation
- **Locale rule:** locale-invariant; reciter and riwāyah labels are fixed proper names
- **Attribution:** required and shown in the reader (`MP3Quran.net`, reciter, riwāyah)
- **Licensing:** rights belong to MP3Quran.net and the respective rights holders; Bismillah claims **no redistribution licence**
- **Consumers:** Quran
- **Prohibited:** bundling, caching for redistribution, or presenting the audio as Bismillah's own
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** requires network; availability depends on a third party outside the project's control
- **Follow-up:** none

### quran-recitation-catalog

- **Surface:** Quran reciter selection
- **Content type:** timed-read reciter catalog
- **Source name:** MP3Quran.net official `reads` endpoint
- **Source class:** official-primary
- **Evidence:** `bismillah_app/lib/features/quran/data/mp3quran_reciter_catalog_repository.dart` (`https://www.mp3quran.net/api/v3/ayat_timing/reads`, 7-day local cache, hard-coded read-5 fallback)
- **Delivery:** approved-remote-proxy
- **Publication status:** shipped
- **Source review:** not applicable — catalog metadata only
- **TR:** not applicable
- **EN:** not applicable
- **AR:** yes
- **Locale rule:** locale-invariant
- **Attribution:** inherited from `quran-recitation-audio`
- **Licensing:** inherited from `quran-recitation-audio`
- **Consumers:** Quran
- **Prohibited:** fabricating a reciter entry when the endpoint fails — the fallback is an explicit known read
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** catalog freshness is bounded by the 7-day cache and degrades to a single fallback read offline
- **Follow-up:** none

### quran-translation-remote-diyanet

- **Surface:** none at runtime — the repository is wired but **inactive**
- **Content type:** Turkish Quran translation via a server-side proxy
- **Source name:** Diyanet Kuran API (token-gated), fronted by the `getQuranChapterTranslation` callable
- **Source class:** official-primary
- **Evidence:** `functions/src/index.ts`, `functions/src/diyanet.ts`, `bismillah_app/lib/features/quran/data/firebase_diyanet_quran_translation_repository.dart`, `bismillah_app/lib/features/quran/data/quran_data_providers.dart` (the active provider returns `BundledQuranEncTranslationRepository`)
- **Delivery:** approved-remote-proxy
- **Publication status:** **not consumed by the client** — the active translation is `quran-translation-tr`; the callable is never invoked in the shipped flow
- **Source review:** not applicable — no content from this path reaches a user today
- **TR:** would be TR-only if activated
- **EN:** none
- **AR:** not applicable
- **Locale rule:** would follow the same Quran locale exception
- **Attribution:** `Diyanet İşleri Başkanlığı Meali` label already exists in localization but is reserved for the inactive source
- **Licensing:** UNRESOLVED — no repository evidence establishes permission to redistribute Diyanet translation content through this proxy
- **Consumers:** none
- **Prohibited:** activating this path before licensing, App Check and the runtime drift are resolved; presenting its output as the bundled translation
- **Status:** REVIEW REQUIRED
- **Limitation:** the callable is deployed and auth-gated with a Secret Manager token, but it runs the EOL `nodejs20` runtime in the console while the repository declares `nodejs22`, and `enforceAppCheck` is still a TODO
- **Follow-up:** the runtime drift is the P1 controlled redeploy already recorded in `docs/project-state/CURRENT_BASELINE.md`; App Check is gate **G7** (TASK 134); the licensing question is UNRESOLVED and is an owner decision

### learn-articles

- **Surface:** Learn library, Learn article screen, Today Learn task titles, Assistant answers
- **Content type:** original short Islamic-knowledge summaries grounded in cited sources
- **Source name:** Diyanet İslam İlmihali (44 published articles), Hadislerle İslam (5), Hz. Muhammed'in Hayatı (3) and Vakit Hesaplama (3); the Kur'an Portalı grounds no Learn article since TASK 091
- **Source class:** reviewed-secondary
- **Evidence:** `bismillah_app/assets/content/learn/articles_tr.json`, `articles_en.json`, `articles_ar.json` (56 records each: 55 `published`, 1 `scholarlyReviewPending`), `bismillah_app/lib/features/learn/domain/entities/learning_article.dart`, `bismillah_app/lib/features/learn/data/learning_content_parser.dart`
- **Delivery:** bundled-asset
- **Publication status:** publication gate enforced in the domain entity — a `published` article cannot be constructed without `sourceBodyVerified`, an exact locator, an evidence summary and a `verifiedAt`
- **Source review:** all 55 published records carry `verificationMethod = sourceBodyReview`; the 1 remaining pending record carries `urlExistenceCheck` only and is excluded from the client
- **TR:** yes — 56 records, `translationStatus = original` (canonical language)
- **EN:** yes — 56 records, `translationStatus = explanatoryTranslation`
- **AR:** yes — 56 records, `translationStatus = explanatoryTranslation`
- **Locale rule:** the three locales carry **identical stable ID sets and identical review statuses**; the repository additionally intersects every locale against the canonical Turkish published ID set, so a translation can never publish an article the Turkish canon does not publish
- **Attribution:** required — institution, work and exact locator resolved from `learn-source-registry`
- **Licensing:** no Diyanet publication is redistributed; no endorsement is claimed
- **Consumers:** Learn, Today, Assistant
- **Prohibited:** exposing `scholarlyReviewPending` records; fabricating a title for an unresolved ID (Today falls back to a neutral label); issuing personal rulings from article text
- **Status:** READY
- **TASK 087 update:** the Hadith, Seerah and Prophets packs added **9** published articles (3 per category) on directly reviewed source bodies. `diyanet-hadislerle-islam` now grounds published content for the first time, and a new source record `diyanet-hz-muhammedin-hayati` was registered. **TASK 082's fixed 30-entry DailyPlan catalog is a curated versioned subset of the growing published Learn library, not a permanent mirror of the full library** — the 9 new articles deliberately do **not** enter `LearnDailyPlanCatalog.v1`.
- **TASK 088 update:** the Dua, Family and Halal packs added **4** published articles (`cat-dua` 1, `cat-family` 2, `cat-halal` 1) on directly reviewed source bodies, with **no new source record**. `cat-dua` now holds one published and one `scholarlyReviewPending` record side by side — `art-dua-adabi` is untouched and remains owned by TASK 091.
- **TASK 089 update:** the Women, Afterlife and Islamic-history packs added **5** published articles (`cat-afterlife` 3, `cat-women` 1, `cat-history` 1) on directly reviewed source bodies, with **no new source record**. The pointed hadith-journeys section was **rejected** as unsupported and replaced, on owner approval, with the Qur'an preservation history from the İlmihal.
- **TASK 090 update:** the final CP11 pack added **6** published articles (`cat-madhhabs` 3, `cat-calendar` 3) on directly reviewed source bodies and registered **one** new source, `diyanet-vakit-hesaplama`. Four evidenced candidates were classified **SCHOLARLY REVIEW REQUIRED** at the gate and deliberately **not** published — sensitive material is never shipped merely to fill a category. On an explicit owner correction, the exact Gregorian conversion dates recorded by the calendar source are **excluded from all shipped content** (summary, body, key point and evidence summary) and are **not** replaced by another exact Gregorian date; the published articles rest on the Hijra as the epoch, the lunar structure and the directly supported institutional history.
- **TASK 091 update:** the two long-standing `scholarlyReviewPending` records were reviewed. `art-kuran-okumaya-baslangic` was **rewritten and published**: its unsupported five-step body and its `diyanet-kuran-portali` attribution were removed, and it now rests on **İslam İlmihali (34. Baskı, 2019), Kur'an-ı Kerim'e Karşı Görevlerimiz — b) Kur'an-ı Kerim'i Öğrenmek, s. 58**, covering only what that page states: learning the Quran means learning to read it and working to understand its meaning, and tajwid is part of that learning. The same page's virtue hadith, its "farzdır" ruling and its reward framing are **excluded**. `art-dua-adabi` **remains `scholarlyReviewPending`** — its body is **not approved**, **qualified scholarly review is required**, its Arabic currently strengthens one sensitive claim relative to the Turkish canon, and narrowing its subject would duplicate the published `art-dua-nedir`; only `isFeatured` was set to `false` so a pending record cannot become a featured surface if it is ever published.
- **Follow-up:** coverage expansion **concluded** in TASK 090 — all 20 categories carry published content. One record (`art-dua-adabi`) is still pending and needs a **qualified reviewer**; no task owns that reviewer decision yet.

### learn-prayer-education

- **Surface:** Learn (prayer category), Assistant
- **Content type:** prayer-related educational text — a defined subentry of `learn-articles`, not a separate store
- **Source name:** Diyanet İslam İlmihali
- **Source class:** reviewed-secondary
- **Evidence:** `bismillah_app/assets/content/learn/articles_tr.json` — 8 published articles under `cat-prayer` and 10 under `cat-purity`
- **Delivery:** bundled-asset
- **Publication status:** identical gate to `learn-articles`
- **Source review:** `sourceBodyReview`; İslam İlmihali locators are asserted to carry a printed page reference
- **TR:** yes
- **EN:** yes
- **AR:** yes
- **Locale rule:** inherited from `learn-articles`
- **Attribution:** inherited from `learn-articles`
- **Licensing:** inherited from `learn-articles`
- **Consumers:** Learn, Assistant
- **Prohibited:** treating this text as a prayer-time authority — prayer times come from `prayer-time-calculation`, which is a separate row with a separate honesty rule
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** no dedicated prayer-guidance surface exists; this material is reachable only through the Learn library and the Assistant
- **Follow-up:** none in CP11; prayer quality work is CP12

### learn-categories

- **Surface:** Learn category browsing
- **Content type:** product taxonomy titles and short descriptions
- **Source name:** Bismillah editorial taxonomy — **not** a cited religious source
- **Source class:** internal-ui-copy
- **Evidence:** `bismillah_app/assets/content/learn/categories.json` (20 categories, `sortOrder` 1–20, per-locale titles)
- **Delivery:** bundled-asset
- **Publication status:** not subject to the article publication gate; categories with zero published articles render an explicit "in preparation" state
- **Source review:** not applicable — no religious claim is made by a category label
- **TR:** yes
- **EN:** yes
- **AR:** yes
- **Locale rule:** every category carries all three locales; titles are genuinely distinct per locale and the Arabic title contains no Latin characters (asserted)
- **Attribution:** none required
- **Licensing:** project-owned
- **Consumers:** Learn, Assistant (category titles contribute to retrieval ranking only)
- **Prohibited:** presenting a category description as sourced religious teaching
- **Status:** READY
- **Coverage:** **no category is empty.** TASK 087 populated `cat-hadith`, `cat-seerah`, `cat-prophets` (3 each), TASK 088 populated `cat-dua`, `cat-family`, `cat-halal` (1 + 2 + 1), TASK 089 populated `cat-afterlife` (3), `cat-women` (1) and `cat-history` (1), and TASK 090 populated the last two, `cat-madhhabs` (3) and `cat-calendar` (3) — raising populated categories from 9 to **20 of 20** (asserted by `flutter test test/features/learn/task_090_learn_pack_test.dart`). The "in preparation" empty state remains implemented and test-covered through a synthetic test-only category, so it cannot rot as the library grows.
- **Follow-up:** none — Learn coverage expansion is complete

### learn-source-registry

- **Surface:** Learn source card, Assistant source citation, official-guidance redirect
- **Content type:** official source records (institution, work, canonical URL, verification dates)
- **Source name:** eight T.C. Diyanet İşleri Başkanlığı sources (TASK 087 registered `diyanet-hz-muhammedin-hayati`; TASK 090 registered `diyanet-vakit-hesaplama`)
- **Source class:** official-primary
- **Evidence:** `bismillah_app/assets/content/learn/sources.json`, `bismillah_app/lib/features/learn/domain/entities/knowledge_source.dart` (`OfficialSourceDomains` — HTTPS-only allowlist restricted to `diyanet.gov.tr` and its subdomains)
- **Delivery:** bundled-asset
- **Publication status:** every source is `isOfficial`, carries `accessedAt` and `lastVerifiedAt`, and passes the domain allowlist
- **Source review:** all article verification records resolve to a registered source ID; no article references a source outside the registry
- **TR:** yes — all eight sources are Turkish-language originals
- **EN:** not applicable — source records are institutional proper names, not translated
- **AR:** not applicable
- **Locale rule:** `originalLanguage = tr` on every record is the basis of the Assistant's explanatory-translation notice
- **Attribution:** required — institution and title are rendered verbatim
- **Licensing:** reference-only; no source work is redistributed
- **Consumers:** Learn, Assistant, Profile
- **Prohibited:** citing a generic fatwa homepage as an exact locator (rejected by the parser); adding a non-`diyanet.gov.tr` source without a separate approved decision
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** **4 of 8 registered sources ground no published article** — `diyanet-kuran-portali`, `diyanet-kuran-yolu-tefsiri`, `diyanet-din-isleri-yuksek-kurulu` and `diyanet-dini-soru-hizmetleri`; the latter two are still used as Assistant guidance redirect targets. **TASK 091 changed the reason for the first one:** `diyanet-kuran-portali` previously grounded one *pending* record; after that record was re-grounded on the İlmihal it now grounds **no Learn article at all**. The record is **deliberately kept registered** — it remains the official Quran reference address shown to users and is not deleted merely because it no longer feeds a Learn article. TASK 087 activated `diyanet-hadislerle-islam` and registered `diyanet-hz-muhammedin-hayati`, so **3 of 7** sources grounded published articles (was 1 of 6); **TASK 088 and TASK 089 added no new source record**; **TASK 090 registered `diyanet-vakit-hesaplama`**, taking it to **4 of 8**. The Seerah source is an official Diyanet publication issued in the **`Çocuk Kitapları`** series (16. Baskı, Mart 2025, ISBN 978-975-19-6627-8) — its series, edition, authorship and official status are recorded explicitly in `sources.json`, and no Diyanet endorsement of the app is implied.
- **TASK 090 source-form limitation:** `diyanet-vakit-hesaplama` is the registry's first **maintained web page** rather than a fixed publication. It is an official Diyanet service page (`www2.diyanet.gov.tr`, inside the allowlisted domain) with a named, quotable section heading, but it carries **no author, edition, ISBN or publication date** — those fields are **absent, not invented**, and `publicationInfo` records explicitly that the source is a web service without such an imprint, together with the bibliography the page itself cites. Unlike a PDF it can be edited or moved silently, and a neighbouring page in the same site section already returns 404, so `accessedAt` / `lastVerifiedAt` must be re-checked by the next Learn or content task.
- **Follow-up:** TASK 092 (official-answer / fatwa-source index foundation)

### learn-plan-catalog

- **Surface:** Today (which Learn article a given plan day references)
- **Content type:** ordered list of 30 stable article identifiers
- **Source name:** derived from `learn-articles`; ordering is an approved TASK 082 product decision
- **Source class:** local-derived
- **Evidence:** `bismillah_app/lib/features/today/domain/value_objects/learn_daily_plan_catalog.dart` (30 entries), `bismillah_app/test/features/today/domain/learn_daily_plan_catalog_test.dart`
- **Delivery:** local-generated-metadata
- **Publication status:** eligibility is re-derived from the actual assets on every test run, not trusted from the list
- **Source review:** every catalog entry must be `published` **and** `sourceBodyVerified`; every unpublished article is proved absent (1 remains pending after TASK 091). The catalog is a **frozen** subset: TASK 091 published `art-kuran-okumaya-baslangic`, and the catalog was deliberately **not** changed to include it
- **TR:** not applicable — identifiers only
- **EN:** not applicable
- **AR:** not applicable
- **Locale rule:** locale-invariant by construction; the file carries no title, summary, body or translated text
- **Attribution:** not applicable — no content is copied
- **Licensing:** not applicable
- **Consumers:** Today
- **Prohibited:** copying article text into a plan; deriving order from JSON file order, localized title sorting, runtime locale or map iteration
- **Status:** READY
- **Follow-up:** none

### prayer-time-calculation

- **Surface:** Prayer tab, Today prayer summary, prayer reminders
- **Content type:** computed daily prayer times
- **Source name:** `adhan_dart` — `CalculationMethodParameters.turkiye()` preset (fajr 18°, isha 17°, method minute adjustments)
- **Source class:** local-derived
- **Evidence:** `bismillah_app/lib/features/prayer_times/data/adhan_prayer_time_calculator.dart`, `bismillah_app/lib/features/prayer_times/domain/prayer_time_calculation_method.dart`
- **Delivery:** local-generated-metadata
- **Publication status:** device-computed and fully offline; no prayer-time service is queried
- **Source review:** not applicable — this is a calculation, not a cited text; the code states explicitly that it is a **Diyanet approach and not an official/certified Diyanet time**
- **TR:** yes — the interface label is `Türkiye hesaplama yöntemi` ("Turkey calculation method"), which deliberately makes **no** official-Diyanet claim
- **EN:** yes
- **AR:** yes
- **Locale rule:** computation is locale-invariant; only labels localize
- **Attribution:** none claimed — no institution's authority is asserted
- **Licensing:** `adhan_dart` under its own package licence; see the in-app licences screen
- **Consumers:** Prayer, Today
- **Prohibited:** describing the output as official Diyanet times; adding a second precaution/offset on top of the preset; uploading location
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** the method is user-selectable since TASK 096 (20 methods, each mapping to a real `adhan_dart` preset; the Türkiye preset is a documented Diyanet-*approach* parameter set, **not** official Diyanet data), but a method still applies worldwide with no regional auto-detection, so an unsuitable choice degrades accuracy; Asr remains `standard` (Shāfiʿī shadow ratio) matching the official Turkish calendar, with `hanafi` implemented but not user-selectable
- **Follow-up:** method selection CLOSED (TASK 096, PR #49 merged); Asr/madhhab selection remains unowned

### prayer-name-labels

- **Surface:** Prayer tab, Today, reminders
- **Content type:** the five prayer names and tracking labels
- **Source name:** Bismillah interface wording
- **Source class:** internal-ui-copy
- **Evidence:** `bismillah_app/lib/features/prayer/domain/value_objects/prayer_name.dart`, `bismillah_app/lib/app/localization/app_localizations.dart`
- **Delivery:** local-generated-metadata
- **Publication status:** not subject to the publication gate
- **Source review:** not applicable
- **TR:** yes
- **EN:** yes
- **AR:** yes
- **Locale rule:** all three locales carry the full set; RTL supported
- **Attribution:** none required
- **Licensing:** project-owned
- **Consumers:** Prayer, Today
- **Prohibited:** guilt-based wording for missed prayers; presenting a tracking mark as a claim that worship was performed or accepted
- **Status:** READY
- **Follow-up:** none

### dua-content

- **Surface:** none
- **Content type:** dua texts
- **Source name:** UNRESOLVED — no source has been approved
- **Source class:** unresolved
- **Evidence:** `bismillah_app/lib/features/dua/domain/entities/dua.dart` and `bismillah_app/lib/features/dua/domain/repositories/dua_repository.dart` are the **only** dua files; there is no implementation, no data source, no asset and no route
- **Delivery:** not-implemented
- **Publication status:** none — the domain entity already requires source metadata, so a sourceless dua cannot even be represented
- **Source review:** not applicable
- **TR:** none
- **EN:** none
- **AR:** none
- **Locale rule:** not applicable
- **Attribution:** UNKNOWN
- **Licensing:** UNKNOWN
- **Consumers:** none
- **Prohibited:** inventing dua text; generating a dua plan item — `todayPlanItemDuaFallback` exists as a defensive neutral label only and no source ever emits a dua item
- **Status:** NOT IMPLEMENTED
- **Follow-up:** UNRESOLVED — open owner decision; no roadmap task owns dua content

### dhikr-content

- **Surface:** none
- **Content type:** dhikr sets and counts
- **Source name:** UNRESOLVED — no source has been approved
- **Source class:** unresolved
- **Evidence:** `bismillah_app/lib/features/dhikr/domain/entities/dhikr_set.dart`, `dhikr_session_day.dart` and `dhikr_repository.dart` are the **only** dhikr files; no implementation, asset or route exists
- **Delivery:** not-implemented
- **Publication status:** none
- **Source review:** not applicable
- **TR:** none
- **EN:** none
- **AR:** none
- **Locale rule:** not applicable
- **Attribution:** UNKNOWN
- **Licensing:** UNKNOWN
- **Consumers:** none
- **Prohibited:** inventing dhikr text or prescribing counts; the onboarding goal `dhikrRoutine` is collected but deliberately produces **no** plan item
- **Status:** NOT IMPLEMENTED
- **Follow-up:** UNRESOLVED — open owner decision; no roadmap task owns dhikr content

### onboarding-copy

- **Surface:** Onboarding (welcome, goals, journey stage, daily pace)
- **Content type:** interface questions, option labels and reassurance wording
- **Source name:** Bismillah interface wording
- **Source class:** internal-ui-copy
- **Evidence:** `bismillah_app/lib/app/localization/app_localizations.dart` (`onboarding*` keys), `bismillah_app/lib/features/onboarding/presentation/onboarding_option_labels.dart`
- **Delivery:** local-generated-metadata
- **Publication status:** not subject to the publication gate
- **Source review:** not applicable — the copy states user intentions ("track my prayers more regularly", "light / balanced / focused") and makes **no** religious claim, ruling or teaching
- **TR:** yes
- **EN:** yes
- **AR:** yes
- **Locale rule:** all three locales carry the full key set; enum names are never shown to the user
- **Attribution:** none required
- **Licensing:** project-owned
- **Consumers:** Onboarding
- **Prohibited:** classifying this copy as sourced religious teaching; adding a religious explanation to onboarding without routing it through the Learn publication gate
- **Status:** READY
- **Follow-up:** none

### today-plan-item-copy

- **Surface:** Today plan cards, recovery note, empty/corrupt/failure states
- **Content type:** neutral task labels and state explanations
- **Source name:** Bismillah interface wording
- **Source class:** internal-ui-copy
- **Evidence:** `bismillah_app/lib/app/localization/app_localizations.dart` (`todayPlan*`, `todayRecovery*` keys), `bismillah_app/lib/features/today/presentation` mapper and widgets
- **Delivery:** local-generated-metadata
- **Publication status:** not subject to the publication gate
- **Source review:** not applicable — labels such as "Continue your Quran habit" and "Daily prayer tracking" are **tracking actions**, not religious teaching, prescriptions or minimums; `estimatedMinutes` is an in-app interaction budget only
- **TR:** yes
- **EN:** yes
- **AR:** yes
- **Locale rule:** all three locales carry the full key set; Learn task titles resolve through the published-only Learn repository with a neutral fallback
- **Attribution:** none required
- **Licensing:** project-owned
- **Consumers:** Today
- **Prohibited:** treating this copy as sourced religious guidance; rendering a raw template or article ID; guilt, streak, score or rank framing
- **Status:** READY
- **Follow-up:** none

### assistant-retrieval-corpus

- **Surface:** Assistant (FAB / root route — never a sixth tab)
- **Content type:** the set of records the Assistant may ground an answer in
- **Source name:** `learn-articles` (published only) plus `learn-source-registry`
- **Source class:** reviewed-secondary
- **Evidence:** `bismillah_app/lib/features/assistant/data/local_source_grounded_assistant_repository.dart` (reads only `getAllPublished`, `getCategories`, `getSourceById`), `bismillah_app/lib/features/assistant/domain/services/assistant_retriever.dart`
- **Delivery:** bundled-asset
- **Delivery note:** reached only through the Learn repository; the asset is never parsed a second time
- **Publication status:** published-only by construction — unpublished records never enter the repository the Assistant reads from
- **Source review:** an answer card is shown only when the article's verification record resolves to a registered source; otherwise no source card is rendered
- **TR:** yes
- **EN:** yes
- **AR:** yes
- **Locale rule:** retrieval runs against the requested locale's published set, which is intersected with the canonical Turkish published IDs; an explanatory-translation notice is available for non-Turkish answers
- **Attribution:** required — institution, title, exact locator and canonical URL are rendered with the answer
- **Licensing:** inherited from `learn-articles` and `learn-source-registry`
- **Consumers:** Assistant
- **Prohibited:** consuming `scholarlyReviewPending` or draft content; consuming Quran/prayer/onboarding/Today interface copy as religious authority; issuing a personal fatwa; treating a category title as a source
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** no `officialFatwa` content exists in the corpus, so `AssistantRetriever.isVerdictCapable` can never return true today — every verdict-class query falls back to the official-guidance redirect, which is the intended safe behaviour but means the Assistant answers nothing definitively in that class
- **TASK 087–089 update:** the 18 new CP11 pack articles become retrievable **solely because they are published and source-verified**; **no Assistant provider, classifier, retrieval rule or history behaviour was changed**, and no Assistant readiness is claimed. F1 and F2 remain owned by TASK 094.
- **Follow-up:** TASK 092 and TASK 093

### assistant-safety-copy

- **Surface:** Assistant
- **Content type:** safety notices, redirect wording, badges and section titles
- **Source name:** Bismillah interface wording
- **Source class:** internal-ui-copy
- **Evidence:** `bismillah_app/lib/features/assistant/domain/value_objects/assistant_response_strings.dart`, `bismillah_app/lib/app/localization/app_localizations.dart` (`assistant*` keys)
- **Delivery:** local-generated-metadata
- **Publication status:** not subject to the publication gate
- **Source review:** not applicable — the copy states the Assistant's limits ("this is general information and applies no ruling to a personal situation") rather than teaching
- **TR:** yes
- **EN:** yes
- **AR:** yes
- **Locale rule:** all three locales carry the full key set; the domain layer never binds to localization directly
- **Attribution:** none required
- **Licensing:** project-owned
- **Consumers:** Assistant
- **Prohibited:** replacing a missing source with reassuring wording; presenting a safety notice as a ruling
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** the local history repository's `load()` now prunes any
  stored record that re-classifies as sensitive (`personalCase`,
  `halalHaramVerdict` or `worshipRule`, via the single canonical
  `AssistantQueryClassifier.isSensitiveVerdict` predicate — see **Finding F1
  (CLOSED)** below); because that classifier is keyword-based, this pruning
  **may also delete a benign record** that happens to contain a matching
  keyword — an accepted owner decision, not a defect
- **Follow-up:** none open; TASK 094 closed F1

### app-source-reference-registry

- **Surface:** Profile → Content sources screen
- **Content type:** static list of the infrastructure and official sources the app relies on
- **Source name:** Tanzil, QuranEnc/Rowad, MP3Quran.net and four Diyanet sources
- **Source class:** official-primary
- **Evidence:** `bismillah_app/lib/features/profile/domain/app_source_reference.dart` (compile-time constant list), `bismillah_app/lib/features/profile/presentation/content_sources_screen.dart`
- **Delivery:** local-generated-metadata
- **Publication status:** shipped; independent of the Learn content data
- **Source review:** not applicable — these are attribution records, not content
- **TR:** yes — purpose descriptions localize
- **EN:** yes
- **AR:** yes
- **Locale rule:** institution names are proper nouns and do not localize; only purpose text does
- **Attribution:** this row **is** the attribution surface
- **Licensing:** references the licences recorded in `THIRD_PARTY_NOTICES.md`
- **Consumers:** Profile
- **Prohibited:** listing a source here that the app does not actually use
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** the seven entries restate facts that also live in `bismillah_app/assets/content/learn/sources.json` and the notice documents, with **no test cross-checking the two** — see **Finding F2** below
- **Follow-up:** TASK 094

### official-answer-index

- **Surface:** none today — the parser, gate and asset-backed repository exist
  but are wired to no consumer; Assistant retrieval integration is **TASK 093**
- **Content type:** official Diyanet fatwa / "resmî cevap" answer index (id,
  neutral topic, neutral summary, source reference, source-body verification,
  a dedicated publication gate)
- **Source name:** T.C. Diyanet İşleri Başkanlığı Din İşleri Yüksek Kurulu —
  Fetvalar and Dinî Soru Hizmetleri (the only two approved authority sources);
  **zero shipped records reference either one today**
- **Source class:** official-primary
- **Evidence:** `bismillah_app/assets/content/official_answers/index_tr.json`, `bismillah_app/assets/content/official_answers/index_en.json`, `bismillah_app/assets/content/official_answers/index_ar.json`, `bismillah_app/lib/features/official_answers/`, `bismillah_app/test/features/official_answers/task_092_official_answer_index_test.dart`
- **Delivery:** bundled-asset
- **Publication status:** contract shipped with **zero production records**,
  delivered as fully offline local JSON with no network call; a dedicated,
  **stricter-than-`learn-articles`** publication gate exists but has nothing to
  publish yet
- **Source review:** `OfficialAnswerPublicationGate` requires `reviewStatus ==
  published` **and** `sourceBodyVerified` **and** `verifiedBy ==
  VerifiedBy.scholarlyReview` **and** an approved authority source (only
  `diyanet-din-isleri-yuksek-kurulu` / `diyanet-dini-soru-hizmetleri`, resolved
  to a `fatwa`/`officialAnswer`-typed, official `KnowledgeSource`) **and** a
  non-empty https `sourceUrl` on the allowlisted domain that is **strictly
  deeper** than the source's own `canonicalUrl` **and** a non-empty
  `sourceLocator` **and** `isGeneralInformationOnly == true`
- **TR:** yes — `index_tr.json` present, zero records
- **EN:** yes — `index_en.json` present, zero records
- **AR:** yes — `index_ar.json` present, zero records
- **Locale rule:** all three locale indexes are present and identically
  empty, so locale parity is trivially satisfied; no divergence is possible
  with zero records
- **Attribution:** would be required per record (institution, title, exact
  locator) once a real record ships; nothing is attributed today
- **Licensing:** not applicable — no content is redistributed; a future
  record would only reference an official Diyanet page
- **Consumers:** none
- **Prohibited:** publishing a record without qualified scholarly review;
  treating `isGeneralInformationOnly` as a verified fact rather than a
  declared field; wiring a consumer before TASK 093
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** zero published records exist and no consumer is wired; a
  **qualified human scholarly reviewer is REQUIRED** before any real record
  ships (no agent may record that review); and `isGeneralInformationOnly` is
  **declarative only** — nothing in the parser or gate verifies that a
  record's body is not actually a personal ruling
- **Follow-up:** **TASK 093** (Assistant retrieval ranking and no-source UX)
  owns consumer wiring; the qualified-scholarly-review gate for the first real
  record remains an open owner decision with no task number yet

---

## Findings

No P0 or P1 issue was found. Specifically, the audit found **no** published
religious content without an identifiable source, **no** source-registry entry
that fails to match shipped content, **no** locale set representing different
religious subjects, **no** review-pending content exposed as published, **no**
path by which the Assistant can reach unpublished material, and **no** evidenced
licensing conflict for content that actually ships.

### F1 — CLOSED (TASK 094): Assistant sensitive-query persistence is narrower than the classifier's own definition

- **Content area:** `assistant-safety-copy`
- **Original evidence:** `bismillah_app/lib/features/assistant/application/assistant_providers.dart` treated a query as non-persistable when it classified as `personalCase` **or** `halalHaramVerdict` only. `bismillah_app/lib/features/assistant/domain/services/assistant_query_classifier.dart` defines `isSensitiveVerdict` as `halalHaramVerdict`, `worshipRule` **or** `personalCase`. `isSensitiveVerdict` had **no production caller** — only a test referenced it.
- **Affected surface:** Assistant local history (`bismillah.assistant_history`, cap 20, device-local).
- **Resolution (TASK 094):** the persistence gate at `assistant_providers.dart:109` now calls the single canonical `AssistantQueryClassifier.isSensitiveVerdict` predicate directly — `worshipRule` is included and no second sensitivity list is restated. `SharedPrefsAssistantHistoryRepository.load()` additionally prunes any **pre-existing** sensitive record it finds in local history on read, so records written before this fix are also removed, not only new ones.
- **New accepted limitation:** the pruning re-classifies stored `text` with the same keyword-based classifier used at write time. Because the classifier is keyword-based rather than semantic, this **may also delete a benign record** that happens to contain a matching keyword — an accepted owner decision, not a defect. Pruning is bounded (at most the existing cap of 20 stored records), idempotent (a second `load()` triggers no further write), touches only the `bismillah.assistant_history` key, never logs the removed text, and writes no backup or quarantine copy.
- **Severity:** was P2; now resolved.

### F2 — Duplicate source facts with no cross-check

- **Content area:** `app-source-reference-registry`
- **Evidence:** `bismillah_app/lib/features/profile/domain/app_source_reference.dart` hard-codes institution names and canonical URLs that also appear in `bismillah_app/assets/content/learn/sources.json`. No test asserts the two agree.
- **Affected surface:** Profile → Content sources.
- **Severity:** P2 — a future source URL correction in `sources.json` would silently leave the Profile screen showing a stale address.
- **Smallest safe follow-up:** a single assertion that every Diyanet entry in the constant list matches a registry record. Owner: **TASK 094**.

### F3 — Quran translation licensing is unestablished

- **Content area:** `quran-translation-tr`
- **Evidence:** `THIRD_PARTY_NOTICES.md` and `CONTENT_SOURCES.md` record usage restrictions and required attribution for the QuranEnc/Rowad translation but state **no licence grant**, unlike the Tanzil text which is explicitly CC BY 3.0.
- **Affected surface:** Quran reader (the only translation shipped).
- **Severity:** P2 — recorded as UNRESOLVED, not as a conflict; no evidence of a violation was found.
- **Smallest safe follow-up:** obtain and record the licence or permission basis before any store release. Owner: **UNRESOLVED** — owner decision; no roadmap task owns it and none is invented here.

### F4 — Deployed Diyanet callable is client-inactive with unresolved licensing

- **Content area:** `quran-translation-remote-diyanet`
- **Evidence:** `functions/src/index.ts` deploys an auth-gated, Secret-Manager-backed callable that the client never invokes (`quran_data_providers.dart` returns the bundled repository); `enforceAppCheck` is a TODO; `docs/project-state/CURRENT_BASELINE.md` records the deployed runtime as EOL `nodejs20` against a repository baseline of `nodejs22`.
- **Affected surface:** none today; Quran if activated.
- **Severity:** P2 for content governance. The runtime drift is already tracked as a P1 operational item.
- **Smallest safe follow-up:** keep the path inactive. Runtime redeploy is the existing P1 in `CURRENT_BASELINE.md`; App Check is gate **G7** (TASK 134); licensing is an owner decision.

### F5 — Source and category coverage gaps

- **Content areas:** `learn-source-registry`, `learn-categories`
- **Evidence:** 4 of 8 registered sources ground no published article. The category half of this finding is **closed**: every one of the 20 categories now contains published content.
- **Affected surface:** Learn, Assistant.
- **Severity:** P2 — a completeness gap, not a safety defect.
- **Addressed by TASK 087–090:** populated categories 9 → **20 of 20** (**closed**); sources grounding published content 1 → **4 of 8**.
- **Remaining:** `diyanet-kuran-yolu-tefsiri`, `diyanet-din-isleri-yuksek-kurulu`, `diyanet-dini-soru-hizmetleri` and — since TASK 091 — `diyanet-kuran-portali` ground no published Learn article. The middle two are Assistant guidance-redirect targets by design, and the Quran portal remains the official Quran reference address; none is a candidate for deletion.
- **Smallest safe follow-up:** the fatwa-source index, **TASK 092**. The Learn-pack half needs no further task.

### F6 — Upstream Quran corpora were never fully diffed

- **Content areas:** `quran-arabic-text`, `quran-translation-tr`
- **Evidence:** `CONTENT_SOURCES.md` records structural verification for the Tanzil text and a 6-sura / 491-verse spot check for the translation, and explicitly forbids claiming a completed upstream diff.
- **Affected surface:** Quran.
- **Severity:** P2 — the limitation is already stated honestly in the public notice.
- **Smallest safe follow-up:** **UNRESOLVED** — no roadmap task owns a full-corpus upstream comparison.

## Assistant input boundary

The Assistant remains local and deterministic, and this matrix fixes exactly
what it may read:

- **Approved input collections:** `learn-articles` (published only, via
  `LearningKnowledgeRepository.getAllPublished`), `learn-categories` (titles used
  as a weak ranking signal only) and `learn-source-registry` (citation and the
  official-guidance redirect target).
- **Excluded collections:** every `scholarlyReviewPending` or draft record;
  `quran-arabic-text`, `quran-translation-tr` and `quran-recitation-audio`;
  `prayer-time-calculation`; `dua-content` and `dhikr-content` (which do not
  exist); and all `internal-ui-copy` rows — onboarding, Today plan, prayer labels
  and the Assistant's own safety strings are **never** religious authority.
- **Missing gates:** no `officialFatwa` content exists, so verdict-capable
  answering is unreachable today (see `assistant-retrieval-corpus`); the
  sensitive-persistence inconsistency in **F1** is open.
- **Safe fallback when no approved answer exists:** compose a neutral response
  with the no-verified-source notice and, for verdict-class queries, redirect to
  the registered official Diyanet question service. On any read failure the
  repository returns the same safe empty answer rather than improvising.

No Assistant behaviour was implemented or changed by TASK 086.
