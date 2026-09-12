# Changelog

## 0.1.0-rc.1 (unreleased)

- Reached MVP feature parity for local capture, review, reminders, app-private media, and export/restore workflows.
- Added release-candidate automation:
  - `tool/build_android_release.sh` for Android release + debug fallback artifacts.
  - `tool/release_candidate.sh` to run quality checks/builds and emit checksums/evidence bundles under `artifacts/release-candidate/`.
- Added release documentation for privacy/permissions, migration+restore guarantees, third-party dependencies, known limitations, and manual accessibility evidence.
- Added Android release-signing configuration support via optional `android/key.properties` (with debug-signing fallback when unavailable).
- Added automated full-journey coverage on the real persistence stack (`test/features/home/journal_journey_test.dart`): capture → photo attach → permission-denial handling → export → complete erase → restore round-trip, plus stored-timezone check-in wall-clock guarantees.
- Added the device/simulator instrumentation journey `integration_test/offline_journal_e2e_test.dart` (fresh install through restore round-trip with screenshots) plus `docs/e2e-runbook.md` and `docs/device-evidence-log.md`.
- CI now builds and uploads Android release artifacts (`app-release.aab` + `app-release.apk`, debug-signing fallback when `android/key.properties` is absent) at every push/PR commit alongside the debug APK and iOS simulator app.
- CI now executes the instrumented device journey on every push/PR: new `android-e2e` job (API 34 `google_apis` x86_64 emulator, Pixel 5 profile) and `ios-e2e` job (named iPhone simulator, macos-15), each uploading always-on evidence artifacts (`journey-summary.json`, on-device PNG screenshots, permission dumps). The journey runs in an explicit "journey mode" that deterministically substitutes the native permission prompts and photo picker (`lib/src/platform/journey_configuration.dart`, pinned by `test/platform/journey_configuration_test.dart`); all persistence, media-store, export, erase, and restore behavior runs for real on device.
- Hardened the device journey after its first CI execution: startup now waits on the rendered shell instead of racing `pumpAndSettle` against the async database open, the journey test carries an explicit 15-minute timeout, each step streams a `JOURNEY step=` console line for stall attribution, and notification startup wiring in `main()` is timeout-bounded (15s each) so a hung platform channel can never block the journal (it falls back to in-app-only reminders, matching the denial contract).
- Repaired both device journeys after their first executions: the `android-e2e` job now grants the runner KVM access via a udev rule before booting (the hosted image ships `/dev/kvm` but the runner user lacks group membership, forcing software emulation whose 9–14-minute boots and 9-minute APK installs blew the Gradle/UTP installer's fixed 360s timeout; with KVM the boot is under a minute and the journey actually executes), and every assertion that follows a state-changing tap now waits on the rendered widget instead of assuming the async repository reload already completed (this race failed the iOS run at the timeline header and the Android run at the observation card).

## 0.1.0 (planned)

The first stable release will ship after:

- Android and iOS release candidates are built from the same verified commit.
- Manual accessibility walkthroughs are captured for TalkBack and VoiceOver.
- Release artifacts and checksums are independently verified before tagging.
