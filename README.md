<!-- Language navigation -->
**English** · [Türkçe](README_TR.md)

# Bismillah

A calm, source-grounded Islamic lifestyle companion for daily worship, Quran, and learning — built with Flutter.

[![Flutter CI](https://github.com/oguzhanbilgi/bismillah-app/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/oguzhanbilgi/bismillah-app/actions/workflows/flutter-ci.yml)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](LICENSE)

> ⚠️ **Public alpha.** This is an early public alpha (`0.1.0-alpha.1`). It is **not
> production ready**, is **not published on any app store**, and behavior may change.
> It is **not** an official Diyanet application and is **not** endorsed by Diyanet.

---

## Why Bismillah

Bismillah aims to be a companion Muslims want to open every day — calm, minimal, and
trustworthy. It focuses on consistency in worship, authentic and clearly-sourced
Islamic knowledge, and a local-first experience that respects privacy. Every religious
statement is tied to a cited source; the app never presents AI-generated text as
revelation.

## Current working features

The following are implemented and exercised by the test suite (Quran and audio flows
were additionally verified on a real device — see [Supported platforms](#supported-platforms)):

- **Today** — read-only daily overview: next prayer, weekly rhythm, and a single
  "Today's Quran" section (daily goal, streak, continue reading).
- **Prayer** — fully offline prayer-time engine (computed on-device), a calm local
  reminder toggle, mark/undo daily log, and a read-only last-7-days history.
- **Quran** — Tanzil Uthmani Arabic reader, bundled Turkish translation, resume,
  bookmarks, offline Arabic/Turkish search, verse-reference lookup, and recitation
  audio streamed from MP3Quran.net with Android background / lock-screen playback.
- **Learn** — a source-grounded knowledge base (**30 published / 2 pending scholarly
  review**), each article carrying an exact source locator and evidence.
- **Profile** — personalization summary, content-source links, privacy and data
  controls.
- **Bismillah Assistant** — a deterministic, local, source-grounded helper (see below).

## Product areas

The app has **five fixed tabs**: **Today, Prayer, Quran, Learn, Profile**. The
**Bismillah Assistant is not a sixth tab** — it is a helper layer reachable from the app,
not a bottom-navigation destination.

## Source-grounded Learn

Learn content is authored as **original short summaries grounded in cited official
sources** (primarily Diyanet works) — not verbatim copies. Each item must pass a
publication gate (`sourceBodyVerified`) requiring an **exact source locator** and an
**evidence summary** before it can be shown. Turkish is the canonical language; English
and Arabic are explanatory translations. Where scholarly opinions differ, the
differences are stated rather than hidden. See [`CONTENT_POLICY.md`](CONTENT_POLICY.md).

## Bismillah Assistant safety model

- The Assistant is **deterministic** and answers via **local source-grounded retrieval**
  over the **published Learn knowledge base only**.
- It **does not call any external generative AI API**.
- It **does not issue religious rulings** where no verified official fatwa source exists,
  and it **does not give a fatwa for personal situations** — it points users to
  qualified scholars.
- **Sensitive queries** (personal-case / verdict questions) are **not persisted**.
- Normal Assistant history is stored **locally**, capped at the most recent **20**
  messages.

The Assistant is an assistant — not a Mufti, Imam, or a replacement for scholars.

## Privacy / local-first approach

- Onboarding choices, reading progress, and bookmarks are stored **on the device**.
- Prayer times are **computed on-device**; location is used only in the foreground when
  permitted.
- The network is used for **remote recitation audio** and for opening **official source
  links** in the system browser.
- Firebase **client** configuration being present in the repo **does not** mean cloud
  sync is active for users — see [Known limitations](#known-limitations).

See [`docs/PRIVACY_MODEL.md`](docs/PRIVACY_MODEL.md) for details.

## Architecture

Clean Architecture with a **feature-first** structure. Riverpod is the single
DI/state mechanism; GoRouter is the single router; Drift + SharedPreferences provide
local persistence. The UI never imports Firebase/AI SDKs directly. See
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter **3.44.6** / Dart **3.12.2** |
| State / DI | Riverpod |
| Routing | GoRouter |
| Local database | Drift |
| Key-value storage | SharedPreferences |
| Audio | just_audio + audio_service |
| Backend (limited) | Firebase (client config only in this alpha) |

## Repository structure

```
.
├─ bismillah_app/        # Flutter application
│  ├─ lib/               # app/ · core/ · shared/ · features/
│  ├─ assets/            # Quran text/translation, Learn knowledge base
│  └─ test/              # unit + widget tests
├─ functions/            # Firebase Cloud Functions (translation proxy)
├─ docs/                 # public documentation (see below)
├─ LICENSE               # Mozilla Public License 2.0 (source code)
├─ THIRD_PARTY_NOTICES.md
├─ CONTENT_POLICY.md
├─ TRADEMARK.md
├─ SECURITY.md
└─ CONTRIBUTING.md
```

## Local setup

Prerequisites: Flutter **3.44.6** (Dart **3.12.2**) on the stable channel.

```bash
git clone https://github.com/oguzhanbilgi/bismillah-app.git
cd bismillah-app/bismillah_app
flutter pub get
```

## Development commands

```bash
cd bismillah_app
flutter analyze
flutter test
flutter run                 # on a connected device/emulator
```

Optional flavor selection: `flutter run --dart-define=FLAVOR=development`
(default: `development`; others: `staging`, `production`).

## Testing

```bash
cd bismillah_app
flutter test
```

The suite covers unit, widget, and architecture-boundary tests, plus generator
integrity checks (114 chapters / 6236 verses; verse→page mapping; search index).

## Supported platforms

- **Android** — primary target. Package id `com.bismillah.app`. Quran, offline
  search, recitation audio, and Android background / media-notification / lock-screen
  playback were verified on a **real device (Samsung Galaxy A36, Android 16)**.
- **iOS** — project files exist, but **iOS background audio has not been verified on a
  physical iOS device**, and iOS builds require macOS/Xcode.

## Known limitations

- Not published on any app store; **not production ready**.
- **Firestore / cloud sync is not an active user-facing feature** in this alpha — the
  sync queue accumulates locally but there is no push engine.
- **iOS background audio is unverified** on physical hardware.
- Premium / payment flows are **not active**; `subscription` / `premium` routes exist in
  code but are **dormant** in the UI.
- The Diyanet translation Cloud Function is **inactive** in the active flow; the bundled
  offline QuranEnc translation is the active Turkish translation source.

## Roadmap

See [`docs/ROADMAP.md`](docs/ROADMAP.md). No dates, revenue, or delivery promises are
made.

## Content sources

Bismillah bundles or references third-party religious content under their own terms —
**not** under the source-code license. See [`docs/CONTENT_SOURCES.md`](docs/CONTENT_SOURCES.md)
and [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md). In short: Quran text from the
**Tanzil Project** (CC BY 3.0), Turkish translation from **QuranEnc.com — Rowad
Tercüme Merkezi**, recitation audio streamed from **MP3Quran.net**, and Learn content
grounded in **Diyanet** sources.

## Contributing

Contributions are welcome. Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) first —
especially the religious-content policy (sourced content only). **Do not open GitHub
issues asking for a personal religious ruling (fatwa).**

## Security

Please **do not** file security vulnerabilities or credentials in public issues. See
[`SECURITY.md`](SECURITY.md) for private reporting.

## License, trademark and disclaimer

- **Source code:** Mozilla Public License 2.0 — see [`LICENSE`](LICENSE).
- **Bundled/streamed content** (Quran text, translation, audio, Learn sources) is **not**
  covered by the MPL — see [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).
- **Branding** (name, logo, icons) is **not** granted by the code license — see
  [`TRADEMARK.md`](TRADEMARK.md).
- **Disclaimer:** Bismillah is **not** an official Diyanet application and is **not**
  endorsed by Diyanet. It does not replace qualified scholars.
