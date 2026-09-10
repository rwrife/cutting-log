# Known limitations (0.1.0-rc.1)

- Physical-device accessibility walkthrough evidence is not yet bundled in-repo; `docs/device-evidence-log.md` records runs once performed (none yet).
- The automated device journey (`integration_test/offline_journal_e2e_test.dart`) executes in CI on a named API 34 x86_64 emulator and a named iPhone simulator (jobs `android-e2e`/`ios-e2e`); per-commit evidence lives in the uploaded `cutting-log-*-e2e-evidence` artifacts. No entries have been transcribed into `docs/device-evidence-log.md` yet, and CI emulator/simulator runs are not physical-device evidence.
- The automated journey runs in "journey mode": the native permission prompts and system photo picker are substituted deterministically (see `docs/e2e-runbook.md`); real dialog UX is verified only by the manual walkthroughs.
- iOS archive/TestFlight packaging requires macOS/Xcode signing credentials.
- Android store-ready signing requires a local `android/key.properties` and keystore not committed to git; CI release artifacts are debug-signed fallbacks and are not store-ready.
- CI artifacts are short-lived debug/simulator outputs; they are verification evidence, not store acceptance.
- Reminder delivery timing can vary by OS battery/background policy; in-app due state is authoritative.

## Product boundary reminder

Cutting Log is a user-owned observation journal and reminder tool. It does not diagnose plant conditions, prescribe treatment, recommend pesticide/fertilizer use, or predict propagation success.
