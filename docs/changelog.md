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

## 0.1.0 (planned)

The first stable release will ship after:

- Android and iOS release candidates are built from the same verified commit.
- Manual accessibility walkthroughs are captured for TalkBack and VoiceOver.
- Release artifacts and checksums are independently verified before tagging.
