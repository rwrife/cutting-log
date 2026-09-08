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

Record exact names and OS versions in your run notes.

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

## Policy reminders

- No analytics/ads/tracking.
- Optional permissions must remain in-context and non-blocking.
- Keep local-first, account-free behavior intact.
- Keep non-diagnostic/non-treatment plant-care limits prominent.
