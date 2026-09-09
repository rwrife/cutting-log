# Device evidence log

Evidence entries must record the exact commit SHA, device/emulator name, OS
version, surface (emulator/simulator vs physical device), and what was
observed. Add one entry per run; never backfill from assumptions. An
emulator entry is not physical-device evidence.

**Status: PENDING — no device, emulator, or simulator runs have been
recorded for any release candidate yet.**

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
