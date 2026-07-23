# TASK 070B — Notification Device Validation

Real-device validation of the Android scheduled-notification manifest contract
added by TASK 070A (`ScheduledNotificationReceiver`,
`ScheduledNotificationBootReceiver`, `RECEIVE_BOOT_COMPLETED`). No dependency
change: `flutter_local_notifications` stayed at `22.0.1`.

## Environment

- Device: **Samsung Galaxy A36** (model `SM-A366B`)
- OS: **Android 16** (SDK 36)
- Timezone: Europe/Istanbul
- Tested source commit: **`074ec01`** (PR #13 head; unchanged during validation)
- Candidate APK size: **209,507,983 bytes**
- Candidate APK SHA-256: **`ab86da0b5cd323cc1a219faefb408fa94ac3a6696908a4ba26c378dd6d231717`**
- APK was **not** rebuilt during validation (hash verified before install)
- Test date: **2026-07-23**

## Method notes

- Update install only (`adb install -r`); no uninstall, no data clear, no downgrade.
- Permissions granted by the user through system UI; not forced via adb.
- Read-only diagnostics (`dumpsys alarm`, `dumpsys package`, bounded `logcat`).
- Device serial, personal user content, and raw log dumps are intentionally not
  recorded here.

## Result table

| Test | Result |
|---|---|
| Exact APK hash / size match | **PASS** |
| Samsung Galaxy A36 / Android 16 | **PASS** |
| Update-install (data-preserving `-r`) | **PASS** |
| Onboarding preserved | **PASS** |
| Prayer history preserved | **PASS** |
| Reminder settings preserved | **PASS** |
| Quran local state (position + bookmark) preserved | **PASS** |
| Notification runtime permission | **PASS** (granted; delivery succeeded) |
| Exact-alarm special access flow | **PASS** (on grant, reminders rescheduled as exact) |
| MY_PACKAGE_REPLACED reschedule (without opening app) | **PASS** |
| Removed-from-recents delivery (Öğle 13:16) | **PASS** |
| Correct notification content + tap opens without crash | **PASS** |
| No duplicate notification / no duplicate pending alarm | **PASS** (33–34 distinct alarms, each once) |
| Reminder replace (toggle → single alarm, others intact) | **PASS** |
| Reminder cancel (pending prayer alarms removed; others untouched) | **PASS** |
| Reboot restore without opening app (alarms rescheduled exact) | **PASS** |
| **Reboot notification delivery** | **DEFERRED / NOT OBSERVED** |
| Logcat clean (no FATAL/SecurityException/ClassNotFound/MissingPlugin) | **PASS** |

## Key evidence

- After `adb install -r`, `firstInstallTime` and app data inodes were preserved
  (update, not fresh install); the app opened without crash and all local state
  was intact.
- The new install declares `ScheduledNotificationBootReceiver` (with the
  `BOOT_COMPLETED` / `MY_PACKAGE_REPLACED` / `QUICKBOOT_POWERON` intent filter)
  and the alarms target `ScheduledNotificationReceiver`; the pre-fix build did not
  declare these.
- After the update, with the app **not opened**, the prayer alarms were present in
  AlarmManager — evidence the boot/replace receiver handled `MY_PACKAGE_REPLACED`.
- Notification permission was granted; exact-alarm special access was initially off
  (alarms scheduled inexact, 1-hour window), and after the user granted "Alarms &
  reminders" the reminders rescheduled as exact (`window=0`,
  `exactAllowReason=permission`). This matches the intended fallback design.
- Öğle (13:16) reminder was delivered with the app removed from recents: single
  notification, correct prayer, tap opened the app without crash; afterward the
  13:16 alarm was consumed (no longer pending).
- Toggling a prayer reminder off/on replaced the alarm without duplication
  (each prayer time present exactly once); disabling removed all prayer alarms
  while leaving unrelated app alarms untouched.
- After a full device reboot, with the app **not opened**, today's prayer alarms
  were rescheduled as exact — the boot receiver restored them without user launch.

## Deferred item and risk

- **Reboot notification delivery** was **not physically observed** in this task
  (the post-reboot prayer trigger time was hours away and the wait was declined).
- **Risk acceptance: approved by the product owner.** The reboot *restore* step
  (the harder half — alarms rescheduled exact without opening the app) passed, and
  a normal removed-from-recents delivery through the same declared receiver passed
  the same day, so residual risk is low but not zero.
- **Required follow-up: TASK 071** — final Samsung Galaxy A36 / Android 16
  end-to-end validation (including reboot notification delivery) after the
  `flutter_local_notifications 22.1.0` dependency update (TASK 070C) lands.

## Note on force-stop

Android places an app in a stopped state after a user "Force stop"; broadcasts
(including scheduled-alarm delivery) are then withheld until the next manual
launch. Force-stop is therefore **not** a pass criterion and was not used for any
required test.
