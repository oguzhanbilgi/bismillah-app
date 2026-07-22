# Privacy Model

Bismillah is **local-first**. This document describes how the alpha handles data, based
on the actual code.

## What stays on the device

- **Onboarding choices, reading progress, streaks, and bookmarks** are stored locally
  (SharedPreferences and the Drift local database). Reading progress and verse keys are
  **not** sent to analytics or a backend.
- **Prayer logs** and the sync queue live in the local database.

## Prayer times

Prayer times are **computed on-device** (no server call for calculation). Location is
used **only in the foreground when permission is granted**; there is no day-zero
permission wall.

## When the network is used

- **Remote recitation audio** is streamed from MP3Quran.net during playback.
- **Official source links** are opened in the **system browser** (via `url_launcher`).

No worship data is required to leave the device for the core flows to work.

## Bismillah Assistant

- The Assistant uses **local, deterministic retrieval** over the published Learn
  knowledge base. It does **not** call an external generative AI API.
- **Normal Assistant history** is stored **locally**, capped at the most recent **20**
  messages.
- **Sensitive queries** (personal-case / ruling questions) are **not persisted**.

## Reset controls

The Profile area provides controls to reset/clear local data (e.g. Assistant history and
personalization). Because data is local, clearing it on-device removes it.

## Firebase and cloud sync

The repository contains Firebase **client** configuration
(`firebase_options.dart`, `google-services.json`). These are public client identifiers,
**not** authorization secrets, and their presence **does not** mean cloud sync is active.
**Firestore / cloud sync is not an active user-facing feature** in this alpha — the sync
queue accumulates locally with no push engine.

## Analytics / telemetry

The codebase includes a typed analytics/privacy layer (`PrivacyGuard`, typed
`AnalyticsEvent`) designed so that PII and raw worship data cannot be emitted to
telemetry. In this alpha, no third-party analytics backend is wired as an active
user-facing pipeline. No claims are made beyond what the code implements.
