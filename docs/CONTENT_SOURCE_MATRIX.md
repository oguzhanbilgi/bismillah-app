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
| `learn-categories` | Learn | internal-ui-copy | READY WITH DOCUMENTED LIMITATION |
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

Counts: READY **8** · READY WITH DOCUMENTED LIMITATION **11** ·
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
- **Source name:** Diyanet İslam İlmihali (all 30 published articles), plus Hadislerle İslam and the Kur'an Portalı on unpublished records
- **Source class:** reviewed-secondary
- **Evidence:** `bismillah_app/assets/content/learn/articles_tr.json`, `articles_en.json`, `articles_ar.json` (32 records each: 30 `published`, 2 `scholarlyReviewPending`), `bismillah_app/lib/features/learn/domain/entities/learning_article.dart`, `bismillah_app/lib/features/learn/data/learning_content_parser.dart`
- **Delivery:** bundled-asset
- **Publication status:** publication gate enforced in the domain entity — a `published` article cannot be constructed without `sourceBodyVerified`, an exact locator, an evidence summary and a `verifiedAt`
- **Source review:** all 30 published records carry `verificationMethod = sourceBodyReview`; the 2 pending records carry `urlExistenceCheck` only and are excluded from the client
- **TR:** yes — 32 records, `translationStatus = original` (canonical language)
- **EN:** yes — 32 records, `translationStatus = explanatoryTranslation`
- **AR:** yes — 32 records, `translationStatus = explanatoryTranslation`
- **Locale rule:** the three locales carry **identical stable ID sets and identical review statuses**; the repository additionally intersects every locale against the canonical Turkish published ID set, so a translation can never publish an article the Turkish canon does not publish
- **Attribution:** required — institution, work and exact locator resolved from `learn-source-registry`
- **Licensing:** no Diyanet publication is redistributed; no endorsement is claimed
- **Consumers:** Learn, Today, Assistant
- **Prohibited:** exposing `scholarlyReviewPending` records; fabricating a title for an unresolved ID (Today falls back to a neutral label); issuing personal rulings from article text
- **Status:** READY
- **Follow-up:** coverage expansion is owned by TASK 087–090; pending-article review is owned by TASK 091

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
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** **11 of 20 categories are empty** — `cat-hadith`, `cat-seerah`, `cat-prophets`, `cat-dua`, `cat-family`, `cat-halal`, `cat-women`, `cat-afterlife`, `cat-history`, `cat-madhhabs`, `cat-calendar`
- **Follow-up:** TASK 087–090 (Learn packs)

### learn-source-registry

- **Surface:** Learn source card, Assistant source citation, official-guidance redirect
- **Content type:** official source records (institution, work, canonical URL, verification dates)
- **Source name:** six T.C. Diyanet İşleri Başkanlığı sources
- **Source class:** official-primary
- **Evidence:** `bismillah_app/assets/content/learn/sources.json`, `bismillah_app/lib/features/learn/domain/entities/knowledge_source.dart` (`OfficialSourceDomains` — HTTPS-only allowlist restricted to `diyanet.gov.tr` and its subdomains)
- **Delivery:** bundled-asset
- **Publication status:** every source is `isOfficial`, carries `accessedAt` and `lastVerifiedAt`, and passes the domain allowlist
- **Source review:** all article verification records resolve to a registered source ID; no article references a source outside the registry
- **TR:** yes — all six sources are Turkish-language originals
- **EN:** not applicable — source records are institutional proper names, not translated
- **AR:** not applicable
- **Locale rule:** `originalLanguage = tr` on every record is the basis of the Assistant's explanatory-translation notice
- **Attribution:** required — institution and title are rendered verbatim
- **Licensing:** reference-only; no source work is redistributed
- **Consumers:** Learn, Assistant, Profile
- **Prohibited:** citing a generic fatwa homepage as an exact locator (rejected by the parser); adding a non-`diyanet.gov.tr` source without a separate approved decision
- **Status:** READY WITH DOCUMENTED LIMITATION
- **Limitation:** **3 of 6 registered sources are unused by any published article** — `diyanet-kuran-yolu-tefsiri`, `diyanet-din-isleri-yuksek-kurulu`, `diyanet-dini-soru-hizmetleri`; the latter two are still used as Assistant guidance redirect targets, but no published article is grounded in them
- **Follow-up:** TASK 092 (official-answer / fatwa-source index foundation)

### learn-plan-catalog

- **Surface:** Today (which Learn article a given plan day references)
- **Content type:** ordered list of 30 stable article identifiers
- **Source name:** derived from `learn-articles`; ordering is an approved TASK 082 product decision
- **Source class:** local-derived
- **Evidence:** `bismillah_app/lib/features/today/domain/value_objects/learn_daily_plan_catalog.dart` (30 entries), `bismillah_app/test/features/today/domain/learn_daily_plan_catalog_test.dart`
- **Delivery:** local-generated-metadata
- **Publication status:** eligibility is re-derived from the actual assets on every test run, not trusted from the list
- **Source review:** every catalog entry must be `published` **and** `sourceBodyVerified`; the 2 pending articles are proved absent
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
- **Limitation:** exactly one calculation method is available and accuracy degrades outside Türkiye; Asr defaults to `standard` (Shāfiʿī shadow ratio) matching the official Turkish calendar, with `hanafi` implemented but not user-selectable
- **Follow-up:** TASK 096 (prayer calculation-method selection)

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
- **Limitation:** the sensitive-query persistence rule and the classifier's own `isSensitiveVerdict` helper disagree — see **Finding F1** below
- **Follow-up:** TASK 094

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

---

## Findings

No P0 or P1 issue was found. Specifically, the audit found **no** published
religious content without an identifiable source, **no** source-registry entry
that fails to match shipped content, **no** locale set representing different
religious subjects, **no** review-pending content exposed as published, **no**
path by which the Assistant can reach unpublished material, and **no** evidenced
licensing conflict for content that actually ships.

### F1 — Assistant sensitive-query persistence is narrower than the classifier's own definition

- **Content area:** `assistant-safety-copy`
- **Evidence:** `bismillah_app/lib/features/assistant/application/assistant_providers.dart` treats a query as non-persistable when it classifies as `personalCase` **or** `halalHaramVerdict`. `bismillah_app/lib/features/assistant/domain/services/assistant_query_classifier.dart` defines `isSensitiveVerdict` as `halalHaramVerdict`, `worshipRule` **or** `personalCase`. `isSensitiveVerdict` has **no production caller** — only a test references it.
- **Affected surface:** Assistant local history (`bismillah.assistant_history`, cap 20, device-local).
- **Severity:** P2. `DO_NOT_BREAK.md` states that sensitive verdict queries are not persisted; a `worshipRule` query ("does X invalidate my fast?") is classified sensitive by the domain helper yet is written to local history.
- **Smallest safe follow-up:** have the persistence gate call `AssistantQueryClassifier.isSensitiveVerdict` instead of restating the rule, or record the narrower rule as a deliberate decision. Owner: **TASK 094** (Learn/Assistant security, language and RTL checkpoint).

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
- **Evidence:** 3 of 6 registered sources ground no published article; 11 of 20 categories contain no published article.
- **Affected surface:** Learn, Assistant.
- **Severity:** P2 — a completeness gap, not a safety defect. Empty categories render an honest "in preparation" state.
- **Smallest safe follow-up:** the CP11 Learn packs, **TASK 087–090**, and the fatwa-source index, **TASK 092**.

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
