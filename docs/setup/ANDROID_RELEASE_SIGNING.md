# Android Release Signing

How Bismillah signs Android release builds, and how to set that up, back it up
and recover it. Established by **ALPHA-R1**.

Scope: signing configuration and local signed-build verification only.
**Google Play Console enrollment is NOT part of this document or of ALPHA-R1.**

## 1. What changed and why

Before ALPHA-R1 the release build type was configured with
`signingConfig = signingConfigs.getByName("debug")` — the Flutter template
default. Every `flutter build apk --release` and `flutter build appbundle
--release` was therefore signed with the **Android debug certificate**
(`CN=Android Debug`), a certificate that is generated automatically, is
identical in intent across every developer machine, and whose private key is
not owner-controlled. Such an artifact cannot be uploaded to Google Play and
must never be distributed.

Release builds now use a real, owner-controlled **upload key**, and there is
**no fallback to the debug certificate**: when credentials are absent the
release build fails.

## 2. Upload key vs Play app-signing key

Two different keys are involved once the app is on Google Play. Confusing them
is the most common and most expensive signing mistake.

| | Upload key | Play app-signing key |
|---|---|---|
| Created by | You (this document) | Google, at Play App Signing enrollment |
| Held by | You, locally + encrypted backups | Google |
| Used for | Signing the AAB **you upload** to Play | Signing the APKs Play **delivers to devices** |
| If lost | Recoverable — Play support can reset it | **Not recoverable.** Without Play App Signing this would end the app's upgrade path |
| Rotatable | Yes, via Play Console | Effectively no |

Because Play App Signing is used, the upload key is a **replaceable
credential**, not a permanent one. That is a safety net, not a reason to be
careless: losing it still means a Play Console support process and downtime.

The key created here is the **upload key**.

## 3. Files that must NEVER enter Git

| File | Why |
|---|---|
| `*.jks`, `*.keystore` | The private key itself |
| `*.p12`, `*.pepk` | Exported key material |
| `bismillah_app/android/key.properties` | Contains both passwords, the alias and a local path |
| `key.properties.local` | Same, alternate local name |
| Any release APK / AAB / mapping file | Build output; also large |

These are ignored by three files: the repository-root `.gitignore` (signing
material only), `bismillah_app/.gitignore` and
`bismillah_app/android/.gitignore`.

`bismillah_app/android/key.properties.example` **is tracked** — it holds
placeholders only.

> Git-ignoring cannot un-track an already committed file. If key material is
> ever committed, treat the key as **compromised**: rotate the upload key
> through Play Console and generate a new one.

Also never place the real keystore **path**, alias, fingerprint or passwords in
a tracked file. The fingerprint is not secret, but keeping it out of the
repository avoids advertising which key to target.

## 4. Where the keystore lives

**Outside the Git repository**, in a directory only the owner can read. A
location inside `C:\dev\Bismillah\` is wrong even when git-ignored, because a
future `rm -rf` of the working tree, a clean clone or a stray `git clean -xdf`
would destroy it.

Recommended shape (adapt to your machine):

```text
<secure-local-dir>/bismillah/upload-keystore.jks
```

## 5. Creating the upload key

Run this **yourself, in an interactive terminal**. `keytool` prompts for both
passwords with hidden input. Do **not** pass `-storepass` or `-keypass` on the
command line — that writes the passwords into your shell history and into the
process list.

```bash
keytool -genkeypair -v -keystore "<secure-local-dir>/bismillah/upload-keystore.jks" -storetype JKS -keyalg RSA -keysize 4096 -validity 10000 -alias <your-stable-alias>
```

Notes:

- `-validity 10000` (~27 years) is the Play requirement: the certificate must
  stay valid well past 2033.
- RSA 4096 is accepted by Play and is the safer long-lived choice.
- Choose the alias once and never change it — it goes into `key.properties`
  on every machine.
- Use a long, unique, randomly generated password from a password manager.
  You may reuse the same value for store and key password; you may also set
  them differently. Do not invent a memorable password.
- The certificate's Distinguished Name (name, unit, organization, city, state,
  country) is embedded in every release you ship and is **publicly visible**.
  Enter organizational values, not private personal details.

Read back the non-secret certificate details (this prompts for the store
password, hidden):

```bash
keytool -list -v -keystore "<secure-local-dir>/bismillah/upload-keystore.jks" -alias <your-stable-alias>
```

Record from the output: alias, **SHA-256 fingerprint**, validity dates, and the
certificate subject. Keep them with the backup, not in the repository.

## 6. Backup and recovery

Store, in a password manager and/or encrypted vault:

1. The keystore **file**
2. The keystore password
3. The key password
4. The alias
5. The SHA-256 fingerprint

Keep **two encrypted backups in separate locations** — for example a password
manager's secure file storage plus an encrypted archive on separate physical
media. Two copies in the same place is one copy.

Verify a backup by restoring it to a scratch directory and running the
`keytool -list -v` command above. An untested backup is not a backup.

Never email the keystore, never put it in a shared drive unencrypted, and never
paste passwords into a chat, an issue, a build log or an AI session.

## 7. Local configuration

Copy the template and fill it in:

```bash
cp bismillah_app/android/key.properties.example bismillah_app/android/key.properties
```

```properties
storeFile=<absolute path to the keystore, forward slashes, outside the repo>
storePassword=<keystore password>
keyAlias=<your stable alias>
keyPassword=<key password>
```

Alternatively, set environment variables instead of the file — preferred on a
shared machine or in a future release pipeline:

| Property | Environment variable |
|---|---|
| `storeFile` | `BISMILLAH_UPLOAD_STORE_FILE` |
| `storePassword` | `BISMILLAH_UPLOAD_STORE_PASSWORD` |
| `keyAlias` | `BISMILLAH_UPLOAD_KEY_ALIAS` |
| `keyPassword` | `BISMILLAH_UPLOAD_KEY_PASSWORD` |

`key.properties` takes precedence when both are present. A relative `storeFile`
is resolved against `bismillah_app/android/`; an absolute path is used as-is.

## 8. Setting up a second computer

1. Clone the repository as usual (see `NEW_COMPUTER_SETUP.md`).
2. Restore the keystore from an encrypted backup to a secure local directory —
   **it is not in Git and never will be**.
3. Copy `key.properties.example` to `key.properties` and fill in the restored
   values, including that machine's own keystore path.
4. Confirm the fingerprint matches the recorded SHA-256 (§10). A mismatch means
   the wrong keystore was restored — stop and investigate; do not upload.
5. Build and verify (§9).

No tracked file contains a machine-specific path, so nothing in the repository
needs editing.

## 9. Building signed releases

```bash
flutter build apk --release
```

```bash
flutter build appbundle --release
```

Outputs:

- APK — `bismillah_app/build/app/outputs/flutter-apk/app-release.apk`
- AAB — `bismillah_app/build/app/outputs/bundle/release/app-release.aab`

Both are git-ignored build outputs.

**Play uploads use the AAB.** The APK is for local and device validation.

## 10. Verifying the signing certificate

APK, with `apksigner` from the Android SDK build-tools:

```bash
apksigner verify --print-certs -v bismillah_app/build/app/outputs/flutter-apk/app-release.apk
```

AAB — an app bundle is a JAR-signed zip, so use `keytool`:

```bash
keytool -printcert -jarfile bismillah_app/build/app/outputs/bundle/release/app-release.aab
```

For both, confirm:

- The signer DN is **not** `CN=Android Debug`.
- The SHA-256 fingerprint equals the recorded upload-key fingerprint.
- For the APK, `apksigner` reports `Verifies`.

## 11. Missing-credentials behaviour

With no `key.properties` and no environment variables, a release build fails at
`:app:packageRelease` with an actionable message naming exactly which inputs are
missing (never their values) and pointing here. It does **not** fall back to the
debug certificate and produces **no** release artifact.

Debug builds, `flutter pub get`, `flutter analyze` and `flutter test` are
unaffected and need no credentials. **CI needs no signing secrets** — the
Flutter CI workflow runs analyze and test only and never builds an Android
release.

## 12. Key rotation

- **Upload key** — rotatable. Request a replacement in Play Console
  (Setup → App integrity → App signing), then register the new key and start
  signing uploads with it. Old releases are unaffected because Play re-signs
  everything with the unchanged app-signing key.
- **Play app-signing key** — treat as permanent. Rotating it is heavily
  restricted and breaks upgrade paths for existing installs.
- After any rotation: update both encrypted backups, update the recorded
  SHA-256, and update `key.properties` on every development machine.

## 13. If the upload key is lost or compromised

1. Do not attempt to recreate "the same" key — a regenerated keystore is a
   **different** certificate with a different fingerprint.
2. Contact Google Play support and request an **upload key reset**. This is
   possible **only because Play App Signing holds the app-signing key**.
3. Generate a fresh upload key (§5), send the new certificate as Play instructs,
   and wait for it to become active before uploading again.
4. If the loss was a compromise rather than a deletion, treat any artifact
   signed with the old key as untrusted and rotate immediately.
5. Record the incident and refresh backups.

Before Play App Signing enrollment there is no reset path — which is why the
backup procedure in §6 applies from the moment the key is created, not from
first upload.

## 14. R8, shrinking and `mapping.txt`

Release builds **are** minified, obfuscated and resource-shrunk. This is worth
stating explicitly because nothing in this repository configures it — reading
`android/app/build.gradle.kts` alone suggests the opposite.

The **Flutter Gradle Plugin** turns it on, not an AGP default (AGP defaults
`minifyEnabled` to `false`) and not project configuration. In
`FlutterPlugin.kt`, guarded by `shouldShrinkResources(project)`:

- `release.isMinifyEnabled = true` — R8 runs, as task `minifyReleaseWithR8`
- `release.isShrinkResources = isBuiltAsApp(project)` — true for `:app`, so
  resource shrinking runs
- ProGuard config = AGP's `proguard-android-optimize.txt` + Flutter's bundled
  `flutter_proguard_rules.pro`
- A project-level `android/app/proguard-rules.pro` is appended **only if it
  exists**. It does not exist here, and no speculative rules have been added.

Consequences to respect:

- **`mapping.txt` is generated** at
  `bismillah_app/build/app/outputs/mapping/release/mapping.txt` (tens of MB),
  alongside `seeds.txt`, `usage.txt`, `resources.txt` and `configuration.txt`.
- That file is the **only** way to deobfuscate a production stack trace.
  It is git-ignored build output, so before any Play release the mapping for
  that exact build must be retained (uploaded to Play / Crashlytics or archived
  with the release). Losing it makes crash reports unreadable.
- R8 can be disabled per-build with `flutter build apk --release -Pshrink=false`
  — useful when diagnosing a suspected shrinking/reflection problem. Do not
  make that the default without a separate validated decision.

## 15. Not covered here

- Play Console app creation, Play App Signing enrollment, and registering the
  upload certificate (a later ALPHA task).
- Release-mode device validation (**ALPHA-R2**).
- Adding project ProGuard/R8 keep rules, and a `mapping.txt` retention pipeline.
- Product flavors, release version-code strategy, and CI release pipelines.
