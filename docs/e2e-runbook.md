# End-to-end runbook (emulator/simulator + device evidence)

This runbook produces the manual and automated device evidence required by
issue #7. Every recorded run must name the exact device/OS and commit SHA.
Record results in [device-evidence-log.md](device-evidence-log.md). No entry
exists yet: do not claim a run that was not performed.

## Automated Android journey (emulator or device)

The journey under test is `integration_test/offline_journal_e2e_test.dart`.
It drives the real app binaries (file database, app-private media, ZIP
backup) through: fresh install → parent → cutting → timeline → photo with
the platform permission outcome → check-in → export → complete erase →
restore round-trip, capturing screenshots via `takeScreenshot`.

Prerequisites:

- Flutter exactly as pinned in `.flutter-version` (3.47.2).
- Android SDK with `platform-tools`, `platforms;android-36`,
  `build-tools;36.0.0`, and an AVD named for your target, e.g.
  `api36_arm64` on `system-images;android-36;google_apis;arm64-v8a`
  (KVM required on Linux; use Apple Silicon or x86_64 hosts as available).

Run:

```bash
adb devices   # confirm the emulator/device serial
cd android
./gradlew app:connectedAndroidTest \
  -Ptarget=`pwd`/../integration_test/offline_journal_e2e_test.dart
```

Screenshots are emitted by the instrumentation runner (see the
`FlutterDeviceScreenshot` output path in the log). Copy them out of the
device logcat output directory.

## Permission denial/revocation checks (manual, Android)

Run on a named device/emulator and record each outcome:

```bash
adb shell pm clear com.rwrife.cutting_log        # fresh-install state
adb shell pm revoke com.rwrife.cutting_log android.permission.CAMERA
adb shell pm revoke com.rwrife.cutting_log android.permission.POST_NOTIFICATIONS
adb shell settings put global airplane_mode_on 1
adb shell svc wifi disable; adb shell svc data disable
adb shell cmd alarm set-timezone America/Los_Angeles   # then re-open a check-in
```

Expected behavior for every combination: the journal opens without prompts,
all capture/review/export/erase/restore features work, denied photo or
notification attempts show an explanatory in-app message, and no network
access is attempted (the release build declares no INTERNET permission;
verify with `adb shell dumpsys package com.rwrife.cutting_log | grep -A5 "requested permissions"`).

## Upgrade/migration check

1. Install an older schema-v1 fixture database or the previously released
   debug APK over the existing install (do not clear data).
2. Launch and confirm the timeline, reminders (with their stored time zones),
   and media resolve correctly (schema auto-migrates 1 → 2).
3. Export, erase, restore; confirm counts match the export manifest.

## iOS simulator journey

macOS host with Xcode 16+ and a named simulator (e.g. iPhone 17, iOS 19.x):

```bash
flutter test integration_test/offline_journal_e2e_test.dart \
  -d "iPhone 17"
```

Record OS differences versus Android in the evidence log (permission strings,
notification behavior, photo picker UX).

## Manual accessibility walkthrough (physical device required)

TalkBack (Android) and VoiceOver (iOS) walkthroughs of: home shell, parent/
cutting creation, timeline + correction, check-in create/edit/complete,
photo attach and denial messaging, export/preview/apply, erase confirmation.
Check dynamic text at maximum scale, focus order, minimum touch targets,
reduced motion, and orientation changes. A simulator result is not
physical-device evidence; label each entry with its surface.
