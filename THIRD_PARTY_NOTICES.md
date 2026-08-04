# Third-Party Notices

Bismillah's application **source code** is licensed under the Mozilla Public
License 2.0 (see [`LICENSE`](LICENSE)). The bundled religious content and any
runtime-streamed media described below are **NOT** part of the MPL-2.0-licensed
source code and are governed by their own licenses and terms. Nothing in the
MPL-2.0 grant applies to the works listed in this file.

---

## Tanzil Quran Text

- **Bundled** in this repository at
  `bismillah_app/assets/quran/verses_uthmani_v1.json`.
- Source: **Tanzil Project** — Quran Text (Uthmani), **version 1.1**.
- Coverage: **114 chapters (suwar) / 6236 verses (āyāt)**.
- License: **Creative Commons Attribution 3.0 (CC BY 3.0)**.
- Source URL: <https://tanzil.net>
- The Quran text **must not be modified**. In this project the text is copied
  as-is; no normalization, diacritic removal, auto-correction, or
  addition/removal of the Basmala is performed
  (see `bismillah_app/assets/quran/NOTICE.md`).
- The original copyright and license notice **must be preserved** in any
  redistribution.
- **This work is NOT covered by the MPL-2.0 license of the source code.**

## QuranEnc Turkish Translation

- **Bundled** in this repository at
  `bismillah_app/assets/quran/translations/quranenc_turkish_rwwad_v1_0_4.json`.
- Translation name: **Türkçe Tercüme — Rowad Tercüme Merkezi**
  (translation key `turkish_rwwad`).
- Publisher: **Rowad Tercüme Merkezi** (Rowwad Translation Center).
- Version: **V1.0.4** (source version stamp `v1.0.4-xml.1`, 2025-09-28).
- Coverage: **114 chapters / 6236 translated verse records**.
- Source URL: <https://quranenc.com/tr/browse/turkish_rwwad>
- **This work is NOT covered by the MPL-2.0 license of the source code.**

### Redistribution permission (official, accessed 2026-08-04)

QuranEnc publishes a site-wide **"Terms and Policies"** block — identical on the
translation page, <https://quranenc.com/en/home>, <https://quranenc.com/en/home/about>
and <https://quranenc.com/en/home/api> — which states:

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

Accordingly, in this distribution: the translation text and footnotes are **not added to,
deleted from, or altered**; the publisher **and** the source (QuranEnc.com) are credited;
the version **V1.0.4** is stated; the transcript/version metadata is preserved inside the
bundled document; **no advertisements** appear alongside the translation; and the version
must be kept in step with the latest issued upstream version.

**Fidelity evidence:** all **6236** records were compared against the official dataset
<https://quranenc.com/downloads/sqlite/turkish_rwwad.sqlite> on 2026-08-04 using an exact
Unicode code-point comparison — **6236 exact matches for translation text and 6236 for
footnotes**, with no missing, extra or duplicated verses.

**Commercial / freemium redistribution is not explicitly addressed** by these terms —
neither permitted nor prohibited — and no commercial permission is inferred. This
distribution is **free**; the translation is **not sold and not gated** behind any
payment. Written confirmation from QuranEnc is required before it ships in an app
offering paid features.

## MP3Quran.net (Recitation Audio)

- **No MP3 or other audio files are distributed in this repository.**
- Recitation audio is accessed at **runtime via remote streaming** only
  (e.g. `https://server*.mp3quran.net/...`).
- Reciter metadata and the audio catalog/API are sourced from
  **MP3Quran.net** (<https://www.mp3quran.net>).
- Rights to the recitation audio belong to **MP3Quran.net and the respective
  rights holders**. Bismillah **claims no open redistribution license** over
  this audio.
- **The MPL-2.0 source-code license does NOT apply to this audio.**

## Diyanet Sources (Learn Content References)

- **No Diyanet PDF or publication is redistributed in this repository.**
- Learn articles are **original short summaries grounded in cited sources**,
  each carrying an **exact source locator** (work / section / page).
- **No claim** is made that Diyanet (Diyanet İşleri Başkanlığı) has endorsed,
  approved, or supported Bismillah.
- **Bismillah is not an official Diyanet application.**

## Flutter / Dart Dependencies

- Third-party Flutter and Dart packages are licensed under their own terms.
- See each package's license, and the in-app **About / Licenses** screen
  (Flutter's `showLicensePage`) for the full list of bundled package licenses.
