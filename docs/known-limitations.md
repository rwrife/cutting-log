# Known limitations (0.1.0-rc.1)

- Physical-device accessibility walkthrough evidence is not yet bundled in-repo; `docs/device-evidence-log.md` records runs once performed (none yet).
- The automated device journey (`integration_test/offline_journal_e2e_test.dart`) has not yet been executed on a named emulator/simulator from this repository's runners; the development host lacks a usable Android emulator (no accessible KVM) and lacks macOS/Xcode for iOS.
- iOS archive/TestFlight packaging requires macOS/Xcode signing credentials.
- Android store-ready signing requires a local `android/key.properties` and keystore not committed to git; CI release artifacts are debug-signed fallbacks and are not store-ready.
- CI artifacts are short-lived debug/simulator outputs; they are verification evidence, not store acceptance.
- Reminder delivery timing can vary by OS battery/background policy; in-app due state is authoritative.

## Product boundary reminder

Cutting Log is a user-owned observation journal and reminder tool. It does not diagnose plant conditions, prescribe treatment, recommend pesticide/fertilizer use, or predict propagation success.
