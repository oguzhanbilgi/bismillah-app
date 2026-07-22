# Content Policy

This policy governs the religious content in Bismillah (Quran text,
translations, Learn articles, duas, and Assistant answers). It reflects the
verification model already enforced in the codebase.

## Publication gate

- Content has a lifecycle status: `draft`, `inReview`, `published`,
  `retracted`. **The client only ever consumes `published` content.**
- Publishing a Learn item requires **`sourceBodyVerified = true`**. A URL that
  merely exists on an official domain is **not** sufficient — the source body
  must be read and confirmed to support the claim.
- Every published item must carry an **exact source locator** (a specific
  work / section / page / fatwa page — not a generic homepage) and a short
  **evidence summary** of what the source actually says.

## Canonical content and translations

- **Turkish** is the canonical content language.
- **English and Arabic** texts are provided as **explanatory translations** of
  the canonical Turkish content.
- Where scholarly opinions differ, the **differences are not hidden**; the app
  states that multiple opinions exist and encourages consulting trusted local
  scholars.

## What we never do

- We **do not generate** Quran verses, hadith, or fatwas without a cited source.
- The **Assistant is not a source of religious rulings** (it is not a Mufti or
  Imam). It teaches, explains, and encourages, and it distinguishes between
  Quran, Hadith, scholarly opinion, and AI explanation.
- We **do not issue rulings** where no verified official fatwa source exists.
- We make **no claim of Diyanet endorsement**; Bismillah is not an official
  Diyanet application.

## Corrections and ongoing review

- Content errors and correction requests can be reported through the project's
  public issue tracker. Please include the affected item and the exact source
  reference.
- **Scholarly review is an ongoing process.** Published content may be
  re-reviewed and `retracted` if an issue is found.
