# Architecture

This document describes the **current** architecture of the Bismillah alpha as it
exists in the code — not aspirational goals.

## Overview

Bismillah is a Flutter application following **Clean Architecture** with a
**feature-first** folder structure. Each feature is a vertical slice split into
`domain/`, `application/`, `data/`, and `presentation/` layers.

```
bismillah_app/lib/
├─ app/        # composition root: bootstrap, theme, router, shell, localization
├─ core/       # cross-cutting infra: Result/Failure, analytics, privacy, storage, config
├─ shared/     # reusable widgets, sacred-content blocks, premium badge
└─ features/   # vertical slices (today, prayer, quran, learn, assistant, profile, ...)
```

## State management and DI — Riverpod

Riverpod is the **single** dependency-injection and state mechanism. Repositories and
services are exposed as providers and resolved by interface type. The UI never imports
Firebase, audio, or database SDKs directly.

## Routing — GoRouter

GoRouter is the **single** router. The app shell hosts **five fixed tabs** — Today,
Prayer, Quran, Learn, Profile. The **Bismillah Assistant is not a tab**; it is a helper
layer reachable from the app. `premium` / `subscription` routes exist but are dormant
in the alpha UI.

## Persistence — local-first

- **Drift** provides the relational local database (e.g. prayer logs, sync queue). Drift
  imports are confined to `core/storage` and `features/*/data/{local,mappers}`, enforced
  by architecture-boundary tests under `test/architecture/`.
- **SharedPreferences** stores lightweight key-value state (onboarding choices, reading
  goals, bookmarks, reader preferences, Assistant history).
- State is **local-first**: the app functions offline for its core flows.

## Quran assets and search

Quran data is bundled as offline JSON assets: the Tanzil Uthmani Arabic text
(`verses_uthmani_v1.json`), the QuranEnc Rowad Turkish translation, a verse→page map
(`verse_pages_v1.json`), and a normalized search index
(`search/quran_search_index_v1.json`). Search runs fully on-device; queries are not
sent anywhere.

## Audio — just_audio + audio_service

Recitation audio is **streamed remotely** from MP3Quran.net. A single global
`AudioPlayer` is bridged to the OS through `audio_service`
(`audio_service_quran_handler.dart`) to enable Android background / media-notification /
lock-screen playback, surfaced app-wide via a single mini-player at the shell level.
`AudioService.init` runs once at bootstrap; failure is non-fatal and degrades to an
`unavailable` audio session service. **iOS background audio is unverified on physical
hardware.**

## Learn knowledge base

Learn content is loaded from bundled JSON (`assets/content/learn/`) through a knowledge
repository and parser. Content carries a `SourceVerification` record; only items that
satisfy the publication gate (`sourceBodyVerified` + exact `sourceLocator` + evidence
summary) are shown. See [`../CONTENT_POLICY.md`](../CONTENT_POLICY.md).

## Bismillah Assistant — deterministic pipeline

The Assistant is fully deterministic and local, composed of three domain services:

1. **Classifier** (`assistant_query_classifier.dart`) — classifies a query (e.g.
   informational vs. personal-case vs. halal/haram verdict).
2. **Retriever** (`assistant_retriever.dart`) — retrieves matches from the **published**
   Learn knowledge base only.
3. **Composer** (`assistant_response_composer.dart`) — composes a grounded response with
   source references.

It calls **no external generative AI API**. It declines to issue rulings without a
verified official fatwa source, and does not persist sensitive (personal / verdict)
queries. Normal history is capped at 20 messages locally.

## Firebase — current limited role

Firebase's role in this alpha is **limited**:

- The repository contains **client** configuration only (`firebase_options.dart`,
  `android/app/google-services.json`) — public client identifiers, not authorization
  secrets.
- A Cloud Function (`functions/`) exists as a translation proxy; its Diyanet integration
  is **inactive** in the active flow, and the bundled offline translation is used instead.
- **Firestore / cloud sync is not an active user-facing feature.** The sync queue
  persists locally but there is no push engine.

## Not yet active

Sync engine, real account linking (Apple/Google/email), RevenueCat/payments, and iOS
physical-device audio validation are **not** active in this alpha.
