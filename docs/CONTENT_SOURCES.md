# Content Sources

Bismillah bundles or references third-party religious content under **their own terms**,
**not** under the Mozilla Public License 2.0 that covers the source code. See
[`../THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md) for the formal notices.

This file is the **attribution and delivery notice**. For the per-area governance
view — source class, publication and review gates, locale coverage, which surfaces
may consume each content class, and what is still unresolved — see
[`CONTENT_SOURCE_MATRIX.md`](CONTENT_SOURCE_MATRIX.md). Licensing facts are stated
here and in the third-party notices; the matrix references them rather than
restating them.

## Tanzil Quran Text

- **Delivery:** Bundled (`bismillah_app/assets/quran/verses_uthmani_v1.json`).
- **Use:** Arabic Quran reader and offline search snippets.
- **Version/status:** Tanzil Project — Uthmani, version 1.1 (114 chapters / 6236 verses).
- **License / attribution:** Creative Commons Attribution 3.0 (CC BY 3.0), source
  <https://tanzil.net>. Text is used unmodified.
- **Verification:** Structural verification complete — 114 chapters / 6236 verses,
  per-chapter counts consistent, metadata intact.
- **Manual review item:** A full byte-for-byte comparison against the upstream Tanzil
  distribution has **not** been completed (the official download endpoint was not
  reachable during preparation). **Do not claim** a completed full upstream diff.

## QuranEnc Rowwad Turkish Translation

- **Delivery:** Bundled
  (`bismillah_app/assets/quran/translations/quranenc_turkish_rwwad_v1_0_4.json`).
- **Use:** Turkish translation shown in the Quran reader (active offline translation).
- **Version/status:** "Türkçe Tercüme — Rowad Tercüme Merkezi" (`turkish_rwwad`),
  version V1.0.4 (source stamp `v1.0.4-xml.1`, 2025-09-28), 6236 verse records.
- **Attribution:** Publisher Rowad Tercüme Merkezi (Rowwad Translation Center), source
  <https://quranenc.com/tr/browse/turkish_rwwad>. Text and footnotes used without
  addition, deletion, or alteration.
- **Verification:** **Full-corpus comparison performed** (TASK 097B-B, 2026-08-04). All
  **6236** records were compared against the current official dataset
  <https://quranenc.com/downloads/sqlite/turkish_rwwad.sqlite> using an **exact Unicode
  code-point comparison with no normalisation, trimming or whitespace collapsing**:
  - translation text — **6236 exact**, 0 whitespace-only, 0 representation-only,
    0 punctuation/content differences;
  - footnotes — **6236 exact** (29 non-empty on both sides);
  - key sets — both sides equal the canonical 6236-verse set; 0 missing, 0 extra,
    0 duplicate.
  Version identity also reconciles: the official record reports `version 1.0.4`,
  `last_update 1759071052` (2025-09-28 14:50:52 UTC), and the bundled asset records
  `2025-09-28 17:50:52 (v1.0.4-xml.1)` — the same instant at UTC+3.
  This **supersedes** the earlier 6-sura / 491-verse spot-check: its whitespace deltas
  came from the live web API's response formatting, not from the dataset.

### Redistribution terms (official, accessed 2026-08-04)

QuranEnc publishes a **site-wide "Terms and Policies"** block — identical text on the
translation page, the home page, the About page and the API page:

> "Contents of the translations can be downloaded and re-published, with the following
> terms and conditions:
> 1. No modification, addition, or deletion of the content.
> 2. Clearly referring to the publisher and the source (QuranEnc.com).
> 3. Mentioning the version number when re-publishing the translation.
> 4. Keeping the transcript information inside the document.
> 5. Notifying the source (QuranEnc.com) of any note on the translation.
> 6. Updating the translation according to the latest version issued from the source
>    (QuranEnc.com).
> 7. Inappropriate advertisements must not be included when displaying translations of
>    the meanings of the Noble Quran."

Official pages consulted (all accessed **2026-08-04**):

| Page title | URL | Locator |
|---|---|---|
| Türkçe Tercüme - Rowad Tercüme Merkezi - Kur'an-ı Kerim Ansiklopedisi | <https://quranenc.com/tr/browse/turkish_rwwad> | "Terms and Policies" block |
| Encyclopedia of the Noble Quran (home) | <https://quranenc.com/en/home> | "Terms and Policies"; "Developers' Services" |
| About | <https://quranenc.com/en/home/about> | "Terms and Policies"; "Objectives" |
| QuranEnc.com API | <https://quranenc.com/en/home/api> | "Terms and Policies" (no additional conditions) |
| Translations list (JSON) | <https://quranenc.com/api/v1/translations/list/?localization=en> | record `key: turkish_rwwad` |

The developer section states its services aim "to provide the content they need to create
software applications related to the Noble Quran", and the About page lists as an
objective "Providing a variety of electronic versions of the, translations, exegeses, and
other related information that can be used on smart devices, applications, and systems".

**How Bismillah complies**

| Condition | Status |
|---|---|
| 1 — no modification, addition or deletion | Met. `tool/generate_quranenc_translation.py` verifies and transcodes only; full-corpus exact match proves it for all 6236 records. |
| 2 — clearly refer to publisher **and** source | Met. Publisher *Rowad Tercüme Merkezi* and source *QuranEnc.com* are shown in the Quran reader and recorded in every notice file. |
| 3 — mention the version | Met. **V1.0.4** shown in-app and in all notices. |
| 4 — keep the transcript information in the document | Met. The bundled asset retains the full metadata block. |
| 5 — notify the source of any note on the translation | Not engaged; no issue has been raised. This is **issue reporting**, not a notice-of-redistribution or approval requirement. |
| 6 — update to the latest issued version | Currently compliant (bundled V1.0.4 == official 1.0.4). **Ongoing obligation; no monitoring process exists yet.** |
| 7 — no inappropriate advertisements alongside the translation | Met and structurally protected — `docs/project-state/DO_NOT_BREAK.md` forbids ads in Quran. |

**Commercial / freemium redistribution is not explicitly addressed** by these terms. It is
neither permitted nor prohibited in writing, and **no commercial permission is inferred
here**. Written confirmation from QuranEnc (contact form
<https://quranenc.com/en/home/contact_us>, or `info@quranenc.com`) is required before the
translation ships in an app offering paid features. The Android closed alpha is **free**,
and the translation is **never sold and never gated** behind any payment.

## MP3Quran.net (Recitation Audio)

- **Delivery:** **Remote streaming only** — no audio files are bundled in this repository.
- **Use:** Verse and continuous-chapter recitation playback.
- **Attribution:** Reciter metadata and audio catalog/API from MP3Quran.net
  (<https://www.mp3quran.net>).
- **Rights:** Audio rights belong to MP3Quran.net and the respective rights holders.
  Bismillah claims **no open redistribution license** over this audio.

## Diyanet Sources (Learn content)

No Diyanet PDF or publication is redistributed. Learn articles are **original short
summaries grounded in these sources**, each with an exact locator. Bismillah claims **no
Diyanet endorsement** and is **not** an official Diyanet application. Sources referenced:

- **Diyanet İslam İlmihali** — <https://diniyayinlar.diyanet.gov.tr/>
- **Diyanet Kur'an-ı Kerim Portalı** — <https://kuran.diyanet.gov.tr/>
- **Kur'an Yolu Türkçe Meâl ve Tefsir** — <https://kuran.diyanet.gov.tr/Tefsir/>
- **Hadislerle İslam** — <https://hadislerleislam.diyanet.gov.tr/>
- **Hz. Muhammed'in Hayatı** — <https://egitimhizmetleri.diyanet.gov.tr/>
- **Vakit Hesaplama (Hicrî takvim açıklaması)** —
  <https://www2.diyanet.gov.tr/DinHizmetleriGenelMudurlugu/Sayfalar/HicridenMiladiye.aspx>
- **Din İşleri Yüksek Kurulu (Fetvalar)** — <https://kurul.diyanet.gov.tr/tr/fetvalar>
- **Dinî Soru Hizmetleri** — <https://kurul.diyanet.gov.tr/>

For each Learn item, verification requires `sourceBodyVerified` with an exact source
locator and an evidence summary before publication. Current Learn status: **55 published /
1 pending scholarly review**.

## Flutter / Dart dependencies

Third-party packages are licensed under their own terms; see each package's license and
the in-app **About / Licenses** screen.
