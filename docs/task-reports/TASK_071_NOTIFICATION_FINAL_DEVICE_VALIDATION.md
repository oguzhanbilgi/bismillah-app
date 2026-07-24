# TASK 071 — Final Notification Device Validation

Final Samsung-device validation of the combined notification candidate in PR #14:
`flutter_local_notifications 22.1.0` (TASK 070C, commit `93d1c86`) plus the
exact-alarm permission deep-link UX (TASK 070D, commit `50dacef`), on top of the
validated manifest baseline (TASK 070A/070B).

## Environment

- Device: **Samsung Galaxy A36** (model `SM-A366B`)
- OS: **Android 16** (SDK 36)
- Timezone: Europe/Istanbul
- Candidate branch: `task/070c-notifications-22-1-0`
- Commits validated: **`93d1c86` + `50dacef`** (unchanged during validation)
- APK size: **209,507,230 bytes**
- APK SHA-256: **`a8d00a7f66ec6453104ba73076c9cd88750462c3470bf4cc0056738c252493e1`**
- APK was **not** rebuilt during validation (hash verified before install)
- Obsolete TASK 070C-only APK (`7e35da0e…`) was **not** used
- Test dates: **2026-07-23 → 2026-07-24**

## Method notes

- Update install only (`adb install -r`); no uninstall, no data clear, no downgrade.
- All permission changes were made physically by the user through system UI;
  nothing was granted or revoked via adb.
- Read-only diagnostics (`dumpsys alarm`, `dumpsys package`, `dumpsys dropbox`,
  time-bounded `logcat`).
- Device serial, raw logs, and personal user content are intentionally not
  recorded here.

## Result table

| Test | Result |
|---|---|
| Exact APK hash / size match | **PASS** |
| Samsung Galaxy A36 / Android 16 | **PASS** |
| Update-install (data-preserving `-r`) | **PASS** |
| Data preservation (onboarding, TR locale, prayer history, reminder pref, Quran position + bookmark, Today) | **PASS** |
| Notification permission | **PASS** (granted; delivery succeeded) |
| Exact access off → inexact fallback (reminders stay usable) | **PASS** |
| “Not now” flow (no settings launch, reminder stays on, no re-prompt, no false success) | **PASS** |
| Deep-link opens the app-specific “Alarms & reminders” screen (not generic app settings) | **PASS** |
| Real permission recheck on return (opening the screen not counted as success) | **PASS** |
| Exact reschedule after grant (`window=0`, `exactAllowReason=permission`, granted feedback shown) | **PASS** |
| No duplicate pending alarms (34 distinct, each prayer once) | **PASS** |
| Reminder replace (toggle → single alarm, others intact, exact preserved) | **PASS** |
| Reminder cancel (prayer alarms → 0; unrelated alarms untouched; re-enable restores full exact set) | **PASS** |
| Removed-from-recents scheduling (alarms persist, no force-stop used) | **PASS** |
| Reboot restore without opening app (full exact set rescheduled by boot receiver) | **PASS** |
| **Reboot physical delivery** (Öğle, exactly 13:16, single notification, app never opened since reboot) | **PASS** |
| Notification tap (app opens, correct screen, no crash) | **PASS** |
| Sound/vibration (default channel behavior; custom adhan is TASK 097) | **PASS** |
| Logcat clean over the delivery window | **PASS** |

## Key evidence

- Update install preserved `firstInstallTime` and app-data inodes; the user
  confirmed all local state intact and crash-free startup.
- With exact access disabled by the user, reminders scheduled inexact
  (1-hour window) and the app stayed calm — no crash, no false “exact” claim.
- The new dialog rendered correctly in Turkish (no overflow, no technical
  permission names). “Not now” closed without opening system settings and did
  not re-prompt.
- “Open permission screen” deep-linked directly to Bismillah's **Alarms &
  reminders** special-access screen. After the user granted access and
  returned, the app rechecked the capability and rescheduled the full 7-day
  set as exact (`window=0`, `exactAllowReason=permission`) with granted
  feedback — confirmed via `dumpsys alarm`.
- Replace and cancel behaved exactly as designed: single alarm per prayer,
  cancel dropped prayer alarms to zero without touching unrelated alarms,
  re-enable restored 34 distinct exact alarms.
- After a full reboot, with the app **never opened**, the boot receiver
  restored the entire exact alarm set; at **13:16:00** AlarmManager fired the
  scheduled broadcast, the system cold-started the app process for
  `ScheduledNotificationReceiver`, and the notification was posted on the
  `prayer_reminders` channel within ~0.6 s of the exact prayer time. The user
  observed a single correct Öğle notification; tapping it opened the app to
  the correct screen without crash.
- A time-bounded logcat capture spanning the delivery and tap window
  (13:10–13:29, ~82k lines) contained no FATAL EXCEPTION, SecurityException,
  ClassNotFoundException, or MissingPluginException for the app/plugin, and
  the system dropbox contained no crash/ANR entry for the package.

## Notes

- Custom adhan sound is intentionally not implemented yet (TASK 097); default
  channel sound/vibration behavior was observed and is not a blocker.
- Force-stop was not used in any required test (Android stopped-state
  behavior makes it a non-criterion).
- This validation closes the reboot-delivery gap that TASK 070B had deferred.
