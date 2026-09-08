# Known limitations (0.1.0-rc.1)

- Physical-device accessibility walkthrough evidence is not yet bundled in-repo.
- iOS archive/TestFlight packaging requires macOS/Xcode signing credentials.
- Android store-ready signing requires a local `android/key.properties` and keystore not committed to git.
- CI artifacts are short-lived debug/simulator outputs; they are verification evidence, not store acceptance.
- Reminder delivery timing can vary by OS battery/background policy; in-app due state is authoritative.

## Product boundary reminder

Cutting Log is a user-owned observation journal and reminder tool. It does not diagnose plant conditions, prescribe treatment, recommend pesticide/fertilizer use, or predict propagation success.
