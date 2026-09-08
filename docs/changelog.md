# Changelog

## 0.1.0-rc.1 (unreleased)

- Reached MVP feature parity for local capture, review, reminders, app-private media, and export/restore workflows.
- Added release-candidate automation:
  - `tool/build_android_release.sh` for Android release + debug fallback artifacts.
  - `tool/release_candidate.sh` to run quality checks/builds and emit checksums/evidence bundles under `artifacts/release-candidate/`.
- Added release documentation for privacy/permissions, migration+restore guarantees, third-party dependencies, known limitations, and manual accessibility evidence.
- Added Android release-signing configuration support via optional `android/key.properties` (with debug-signing fallback when unavailable).

## 0.1.0 (planned)

The first stable release will ship after:

- Android and iOS release candidates are built from the same verified commit.
- Manual accessibility walkthroughs are captured for TalkBack and VoiceOver.
- Release artifacts and checksums are independently verified before tagging.
