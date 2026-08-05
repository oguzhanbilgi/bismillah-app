# New Computer Setup

How to continue Bismillah development on a fresh machine. Use a generic
`<repo-path>` placeholder for any local path; never commit machine-specific paths.

## Clone

```powershell
git clone https://github.com/oguzhanbilgi/bismillah-app.git
cd bismillah-app
git checkout main
git pull --ff-only origin main
```

## Verify

```powershell
git status
git rev-parse HEAD
git log -5 --oneline
```

The live Git HEAD is authoritative for the current commit.

## Flutter setup

- Required Flutter version: **3.44.6** (Dart **3.12.2**), stable channel.

```powershell
flutter doctor
cd bismillah_app
flutter pub get
flutter analyze                  # expect: No issues found
flutter test                     # full suite
flutter test test/core/storage   # Drift/storage suite
```

Canonical sync-focused suite — run it with **exactly** these four paths:

```powershell
flutter test test/features/sync test/app/persistence_wiring_test.dart test/app/app_bootstrap_test.dart test/features/prayer/data/drift_prayer_log_repository_test.dart
```

## Functions setup

- Required Node.js version: **22.x** (current merged baseline since TASK 068).

```powershell
cd functions
node --version           # expect v22.x
npm ci
npm run lint
npm run build
npm test                 # Vitest
```

If no Node version manager is installed, use `fnm`, `nvm-windows`, `volta`, or an
official `node:22` Docker image. Do not validate Functions on Node 20 or Node 25 and
claim Node 22 was verified.

## Expected verification baseline

Toolchain:

- Flutter **3.44.6**, Dart **3.12.2** (stable channel)
- Node.js **22.x**

Verified results:

| Check | Expected |
|---|---|
| `flutter analyze` | clean (No issues found) |
| Full Flutter suite | **629 / 629** |
| Canonical sync-focused suite (four-path command above) | **70 / 70** |
| `test/features/sync` **alone** | **52 / 52** |
| Drift storage suite (`test/core/storage`) | **11 / 11** |
| Functions suite (Vitest) | **23 / 23** |

Two cautions:

- **70 is the official sync baseline**, not 52. The 52 figure is
  `test/features/sync` in isolation and must never replace it.
- **These counts are a floor, not a constant.** Later tasks add tests, so a
  higher number is expected progress, not a failure — a *lower* number or any
  failure is a stop condition. **`docs/project-state/CURRENT_BASELINE.md` is
  authoritative** for the current figures; the table above is a convenience
  snapshot and may lag it.

## Claude Code

From the repository root:

```powershell
claude
```

Then load and inspect the project memory:

```text
/memory
```

Suggested first prompt (read-only):

```text
Read the loaded project memory, report the current main commit,
current task, next task, test baselines, major guardrails and blockers.
Do not edit files.
```

## Secrets (never in Git — transfer securely)

These do not come from GitHub and must be restored from a password manager or an
encrypted secure backup:

- Android release (upload) keystore, its passwords and its alias — restore
  procedure in `ANDROID_RELEASE_SIGNING.md`
- Apple certificates
- App Store Connect keys
- RevenueCat secret keys
- Firebase admin / service-account credentials
- DIB token (Diyanet API token — lives only in Firebase Secret Manager)
- Google Play service-account file

Firebase **client** config (`google-services.json`, `firebase_options.dart`) is a
public client identifier and is already in the repo — it is not a secret.
