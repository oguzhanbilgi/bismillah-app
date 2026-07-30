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

## What `editorialReview` means (and does not mean)

Learn content carries a `verifiedBy` field with one of three values:
`editorialReview`, `automatedSourceCheck`, or `scholarlyReview`.

- **`editorialReview` means an owner/editor source-fidelity and
  presentation review only** — the person doing the review read the cited
  source body directly and confirmed the article's claims match what that
  source page actually says, and checked that the wording is presented
  clearly. **It is explicitly NOT qualified scholarly review, fatwa review,
  hadith grading, legal review, Diyanet approval, or any form of
  institutional endorsement.**
- As of this writing, no content record carrying `editorialReview` has
  received qualified scholarly review. **Qualified human scholarly review
  remains required before any `editorialReview` content can be treated as
  religiously authoritative**, and is required unconditionally for content
  the app itself classifies as normative worship guidance (see
  `docs/LEARN_CONTENT_REVIEW.md`).
- `scholarlyReview` is a separate, stronger gate reserved for content that
  has actually undergone qualified scholarly review. It is not
  interchangeable with `editorialReview`, and the two are never merged into
  one meaning.
- This section defines what the `editorialReview` label means. **It does
  not change the publication status of any existing content, and it grants
  no approval — retroactive or prospective — for any record.**
- **This definition states the requirement going forward.** It does **not**
  re-verify the historical review provenance of records already published
  under the `editorialReview` label before this definition was written —
  TASK 087 recorded that provenance as **AMBIGUOUS**, and this section does
  not resolve that ambiguity for any existing record.

## Corrections and ongoing review

- Content errors and correction requests can be reported through the project's
  public issue tracker. Please include the affected item and the exact source
  reference.
- **Scholarly review is an ongoing process.** Published content may be
  re-reviewed and `retracted` if an issue is found.
