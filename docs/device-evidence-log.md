# Device evidence log

Evidence entries must record the exact commit SHA, device/emulator name, OS
version, surface (emulator/simulator vs physical device), and what was
observed. Add one entry per run; never backfill from assumptions. An
emulator entry is not physical-device evidence.

**Status: PENDING — no manually verified device, emulator, or simulator runs
have been recorded for any release candidate yet.**

Note: CI executes the automated journey on every push/PR (API 34 x86_64
emulator + named iPhone simulator) and uploads raw evidence
(`journey-summary.json`, PNGs, permission dumps) as
`cutting-log-android-e2e-evidence` / `cutting-log-ios-e2e-evidence` build
artifacts. Those artifacts are not transcribed into this log until a
maintainer reviews them against the commit SHA; until then this log remains
honestly PENDING.

## Entry template

```
## YYYY-MM-DD — <commit SHA short>
- Surface: <Android emulator / iOS simulator / physical Android / physical iOS>
- Device/OS: <exact name and version>
- Runner: <integration_test/offline_journal_e2e_test.dart / manual walkthrough>
- Observed:
  - fresh install:
  - parent→cutting→timeline:
  - reminder wall clock (stored zone):
  - photo attach + permission denial/revocation:
  - airplane mode:
  - timezone change:
  - export → erase → restore round-trip:
  - accessibility walkthrough (TalkBack/VoiceOver, dynamic text, focus order,
    touch targets, reduced motion, orientation):
- Screenshots: <where stored; captured from built binaries only>
- Deviations/notes:
```
