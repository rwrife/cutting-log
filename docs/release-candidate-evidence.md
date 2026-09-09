# Release candidate evidence checklist

This checklist is the release gate for issue #7 and milestone M6.

## Automated command gate

Run from the repository root:

```bash
./tool/release_candidate.sh
```

The script runs:

1. `./tool/bootstrap.sh`
2. `./tool/check.sh` (format + analyze + tests)
3. `./tool/build_android.sh` (debug APK)
4. `./tool/build_android_release.sh` (release AAB/APK + debug fallback)
5. `./tool/build_ios.sh` on macOS only

And writes an evidence bundle to:

- `artifacts/release-candidate/<UTC-stamp>/`

With at least:

- `checksums.txt`
- `export-schema.sha256`
- `third-party-packages.txt`
- step logs (`*.log`)

## Device and simulator matrix (manual evidence)

Record exact names and OS versions as entries in
[device-evidence-log.md](device-evidence-log.md) (template included; no runs
recorded yet). The automated instrumentation journey
`integration_test/offline_journal_e2e_test.dart` covers the workflow rows
below on a named emulator/simulator once executed per
[e2e-runbook.md](e2e-runbook.md); it does not replace the manual rows.

| Surface | Required evidence |
| --- | --- |
| Android emulator | Parent → cutting → timeline → reminder → photo → export → erase → restore workflow, plus permission denial/revocation and airplane mode. |
| iOS simulator | Same full workflow with iOS-specific behavior notes. |
| Physical Android device | TalkBack walkthrough, touch-target checks, dynamic text, reduced motion, orientation, and truthful screenshot capture. |
| Physical iOS device | VoiceOver walkthrough, focus order, contrast, dynamic text, reduced motion, orientation, and truthful screenshot capture. |

## Documentation required before tagging

- [ ] `docs/changelog.md` updated for the candidate.
- [ ] `docs/privacy-permissions-disclosure.md` reviewed.
- [ ] `docs/migration-restore-notes.md` reviewed.
- [ ] `docs/third-party-licenses.md` reviewed against `third-party-packages.txt`.
- [ ] `docs/known-limitations.md` updated.
- [ ] `docs/export-schema-v1.json` hash published from `export-schema.sha256`.
- [ ] README quickstart/status references only existing scripts/artifacts.
- [ ] `docs/device-evidence-log.md` contains dated entries from actual emulator/simulator/device runs at the release commit.
- [ ] CI artifacts at the release commit: Android debug APK + release AAB/APK (debug-signing fallback unless a keystore was configured) and the iOS simulator app. Release artifacts are evidence, not store acceptance.

## Policy reminders

- No analytics/ads/tracking.
- Optional permissions must remain in-context and non-blocking.
- Keep local-first, account-free behavior intact.
- Keep non-diagnostic/non-treatment plant-care limits prominent.
