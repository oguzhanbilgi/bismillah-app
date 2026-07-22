# Do Not Break

Behaviors every future task must preserve. Breaking any of these requires an
explicit, separately approved design/safety task.

## Navigation

- Exactly five tabs: **Today, Prayer, Quran, Learn, Profile**.
- The **Assistant is never a sixth tab**; it remains a FAB / root route.

## Religious content safety

- No unsourced verse, hadith, ruling, or fatwa anywhere.
- Learn published content requires source verification (`sourceBodyVerified` +
  exact source locator + evidence summary).
- Pending content must never appear as published; the client consumes only `published`.
- The Assistant uses **published-only** retrieval.
- The Assistant does not issue personal fatwas and refuses personalized verdict queries.
- Sensitive verdict queries are not persisted.
- No external generative AI without a separately approved architecture and safety task.
- Canonical Turkish content must not be weaker than the English/Arabic translations;
  scholarly differences are stated, not hidden.

## Quran

- Preserve the bundled, unmodified Tanzil Uthmani Arabic text.
- Preserve the bundled QuranEnc (Rowad) Turkish translation.
- Preserve local bookmarks, reading position, and progress (device-local).
- Preserve Android background audio, media notification, and lock-screen controls.
- Remote Quran audio remains MP3Quran-based (streamed; no bundled audio).
- No verse-level analytics; verse keys never leave the device.

## Prayer

- Prayer times remain device-computed / local.
- Preserve mark/undo and the seven-day history.
- Do not upload location or prayer details without an explicit approved design.
- No guilt-based missed-prayer messaging.

## Privacy

- Local / offline-first for core flows.
- No secrets in the repository (Firebase client config is not a secret).
- No sensitive-query analytics.
- No silent cloud sync.
- No destructive migration without migration tests and a rollback strategy.

## Monetization

- Core worship tools remain free.
- No ads in Quran, Prayer, or sacred Learn content.
- No guilt, fear, or religious-superiority framing in paywalls.
- Paying users do not receive more authoritative religious answers.
- "Destekçi" is a product/support tier, not spiritual superiority.
- No fake discounts or countdown timers.

## Localization

- TR / EN / AR and RTL remain supported.
- No UI change that silently breaks RTL or large fonts.

## Engineering

- One narrow branch per task; verify starting branch/commit before editing.
- Do not touch untracked `AGENTS.md`.
- No random dependency upgrades; no build output committed.
- Architecture boundaries: UI must not import Firebase/DB/audio SDKs directly;
  Drift imports stay in the storage/data layers.
