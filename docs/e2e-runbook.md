# End-to-end runbook (emulator/simulator + device evidence)

This runbook produces the manual and automated device evidence required by
issue #7. Every recorded run must name the exact device/OS and commit SHA.
Record results in [device-evidence-log.md](device-evidence-log.md). An
emulator entry is not physical-device evidence.

## Automated Android journey (CI, every push/PR)

The journey under test is `integration_test/offline_journal_e2e_test.dart`.
It drives the real app binaries (file database, app-private media, ZIP
backup) through: fresh install → parent → cutting → timeline → photo attach
→ check-in → export → complete erase → restore round-trip, capturing
screenshots via `takeScreenshot` and a `journey-summary.json` step record.

**Journey mode.** Instrumented automation cannot answer native permission
dialogs or complete the system photo picker, so the journey calls
`JourneyConfiguration.enableForIntegrationTest()` before `app.main()`. That
swaps exactly three capability entry points in `lib/main.dart`:

- notification permission requests are deferred to the current state
  (no prompt; in-app check-ins remain fully real),
- optional permission requests report granted without opening settings
  (Android runners additionally `pm grant` the runtime permissions),
- photo import returns a synthetic PNG file instead of opening the picker.

Everything downstream of those three boundaries runs for real: app-private
media copy, thumbnail generation, Drift file database, ZIP/CSV export,
erase, restore. Production builds never set the flag; the real dialogs and
picker are covered by widget tests plus the manual walkthroughs below.
The scaffold itself is pinned by `test/platform/journey_configuration_test.dart`.

The CI job `android-e2e` runs this on every push/PR:

- Runner: GitHub `ubuntu-latest` (KVM-accelerated hosted runners).
- Device: API 34 `google_apis` `x86_64` emulator, Pixel 5 profile, via
  `ReactiveCircus/android-emulator-runner@v2.38.0`.
- Steps: `flutter build apk --debug`, then `connectedDebugAndroidTest`
  against the journey target.
- Evidence: the job always uploads `cutting-log-android-e2e-evidence`
  containing `journey-summary.json`, on-device PNG screenshots,
  `requested-permissions.txt` (from `dumpsys package`), `final-screen.png`,
  the Android version, and the instrumentation test results XML.

To reproduce manually on any KVM-capable host:

```bash
flutter --version   # must match .flutter-version exactly
flutter build apk --debug
adb devices   # confirm the emulator/device serial
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell pm grant com.rwrife.cutting_log android.permission.POST_NOTIFICATIONS
cd android
./gradlew app:connectedDebugAndroidTest \
  -Ptarget=`pwd`/../integration_test/offline_journal_e2e_test.dart
```

Copy evidence off the device afterwards:

```bash
mkdir -p e2e-evidence
adb exec-out "run-as com.rwrife.cutting_log tar c app_flutter files" | tar x -C e2e-evidence
```

## Automated iOS simulator journey (CI, every push/PR)

The CI job `ios-e2e` runs the same journey on `macos-15`: it selects an
available iPhone simulator by name/runtime (recorded in
`cutting-log-ios-e2e-evidence/simulator.txt`), boots it, and executes
`flutter test integration_test/offline_journal_e2e_test.dart -d <udid>`.
Evidence (journey summary + on-device PNGs + simulator identity) is pulled
from the simulator data container and always uploaded.

To reproduce manually on a macOS host with Xcode:

```bash
xcrun simctl list devices available   # pick a named iPhone
flutter test integration_test/offline_journal_e2e_test.dart -d "iPhone 16"
```

Record OS differences versus Android in the evidence log (permission
strings, notification behavior, photo picker UX). The journey's
`reminderPlatformNotificationScheduled` step records whether the platform
actually scheduled a notification — typically yes on pre-granted Android,
no on iOS simulators — as a documented OS difference.

## What the automated journeys do NOT prove

- They are not physical-device evidence.
- They do not exercise the native photo picker, camera UI, or the real
  permission-denial dialog flows (manual checks below).
- They do not replace TalkBack/VoiceOver walkthroughs.

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
Note: the debug build carries INTERNET for the Flutter tooling channel only;
release artifacts are the store-facing surface.

## Upgrade/migration check

1. Install an older schema-v1 fixture database or the previously released
   debug APK over the existing install (do not clear data).
2. Launch and confirm the timeline, reminders (with their stored time zones),
   and media resolve correctly (schema auto-migrates 1 → 2).
3. Export, erase, restore; confirm counts match the export manifest.

## Manual accessibility walkthrough (physical device required)

TalkBack (Android) and VoiceOver (iOS) walkthroughs of: home shell, parent/
cutting creation, timeline + correction, check-in create/edit/complete,
photo attach and denial messaging, export/preview/apply, erase confirmation.
Check dynamic text at maximum scale, focus order, minimum touch targets,
reduced motion, and orientation changes. A simulator result is not
physical-device evidence; label each entry with its surface.
