# Content Sources

Bismillah bundles or references third-party religious content under **their own terms**,
**not** under the Mozilla Public License 2.0 that covers the source code. See
[`../THIRD_PARTY_NOTICES.md`](../THIRD_PARTY_NOTICES.md) for the formal notices.

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
- **Verification:** A **spot-check of 6 suras / 491 verses** against the live QuranEnc API
  matched the bundled text (only multi-space/whitespace differences; no semantic change).
- **Manual review item:** A **full-corpus** upstream comparison has **not** been performed.
  Only the spot-check above is claimed.

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
- **Din İşleri Yüksek Kurulu (Fetvalar)** — <https://kurul.diyanet.gov.tr/tr/fetvalar>
- **Dinî Soru Hizmetleri** — <https://kurul.diyanet.gov.tr/>

For each Learn item, verification requires `sourceBodyVerified` with an exact source
locator and an evidence summary before publication. Current Learn status: **30 published /
2 pending scholarly review**.

## Flutter / Dart dependencies

Third-party packages are licensed under their own terms; see each package's license and
the in-app **About / Licenses** screen.
