# Contributing to Bismillah

Thank you for your interest in improving Bismillah. This is an early public alpha, and
contributions are welcome. Please read this guide first — especially the
**religious-content policy**, which is stricter than typical open-source projects.

By participating you agree to our [Code of Conduct](CODE_OF_CONDUCT.md).

## Environment setup

- Flutter **3.44.6** (Dart **3.12.2**) on the stable channel.
- Clone and fetch dependencies:

  ```bash
  git clone https://github.com/oguzhanbilgi/bismillah-app.git
  cd bismillah-app/bismillah_app
  flutter pub get
  ```

## Before you open a pull request

- **Issue-first for anything non-trivial.** Open an issue to discuss before large changes.
  Keep PRs **small and focused** — one concern per PR.
- Run and pass the local checks:

  ```bash
  cd bismillah_app
  dart format .
  flutter analyze      # must report: No issues found
  flutter test         # all tests must pass
  ```

- Write a clear commit message and PR description: what changed, why, and how you tested
  it.

## Branch naming

Use short, descriptive prefixed branches, e.g.:

- `feat/…` — new functionality
- `fix/…` — bug fixes
- `docs/…` — documentation
- `chore/…` — tooling/maintenance

## Dependencies

- **Dependency upgrades must be separate PRs** — do not mix them with feature or fix
  changes. Several versions are intentionally pinned; explain the reason for any bump.

## Religious-content contribution policy

Religious content is held to a higher bar than code.

- **No unsourced content.** Never add a Quran verse, hadith, or ruling (fatwa) without a
  cited, authoritative source.
- **Publication gate.** Learn content must satisfy `sourceBodyVerified` — the source body
  must actually be read and confirmed to support the claim. A bare URL is not enough.
- **Exact locator + evidence.** Provide an exact source locator (work / section / page)
  and a short evidence summary. A generic homepage is not a valid locator.
- **Turkish is canonical.** English and Arabic are explanatory translations and **must not
  be stronger, broader, or make claims beyond** the canonical Turkish content.
- **Don't hide differences.** Where scholarly opinions differ, state that clearly.
- **No copyrighted long-form paste.** Do not paste long copyrighted text; summaries are
  original and attributed.

**Do not open GitHub issues asking for a personal religious ruling (fatwa).** The
project and its Assistant are not a source of rulings. Please consult qualified local
scholars for personal questions. Use the **content correction** issue template only to
report an error in existing sourced content.

## Screenshots

If you include screenshots, they **must be privacy-safe**: no personal data, no real
account details, no device identifiers, and no local file paths.

## Security

Do not report security vulnerabilities in public issues — see [SECURITY.md](SECURITY.md).
