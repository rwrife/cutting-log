# Cutting Log

> Local-first mobile app for plant hobbyists to track propagation cuttings from parent plant through rooting and potting, schedule gentle check-ins, and export a photo-backed history without accounts.

## Overview

Cutting Log is a focused Android and iOS journal for plant propagation. It keeps each cutting linked to its parent plant, records stage changes and observations as an append-only timeline, and makes it easy to compare what happened across propagation attempts. The useful core stays offline and does not require an account.

## Motivation

A cutting can spend weeks moving from fresh cut to callus, roots, transfer, and an established pot. Notes and photos are often scattered across a camera roll, calendar, and memory. General plant-care apps usually center the mature plant rather than the lineage and repeated observations of individual propagation attempts. Cutting Log provides one deliberate workflow for that lifecycle without turning plant care into a social network or cloud service.

## Target users

- Indoor-plant hobbyists propagating several cuttings at once
- Gardeners comparing methods across cuttings from the same parent
- Plant-swap participants who want a portable record before gifting a rooted plant
- Beginners who want reminders to observe—not opaque care or diagnosis claims

## Concrete use cases

- Create a parent plant, then start three separately named cuttings from it.
- Record medium, vessel, location, and user-entered notes without prescriptive advice.
- Add dated observations and optional photos while a cutting calls, roots, transfers, or fails.
- Schedule a private check-in reminder and mark it done, snooze it, or remove it.
- Compare sibling cutting timelines and export selected histories as CSV plus a portable backup.
- Archive a cutting after potting or gifting while preserving its lineage and history.

## Intended workflow

1. Create or select a parent plant using a nickname; species text is optional.
2. Start a cutting with a date, method/medium, optional source note, and optional photo.
3. Record observations and explicit stage events; edits never silently rewrite prior history.
4. Optionally schedule local notifications for user-chosen check-ins.
5. Review active cuttings by due check-in, parent, stage, or recent activity.
6. Archive, mark unsuccessful, pot, or gift a cutting without deleting its timeline.
7. Export CSV for analysis or a versioned ZIP backup containing JSON and copied media; restore only after validation and preview.

## MVP features

- Parent-plant and cutting records with stable IDs and explicit lineage
- Propagation method/medium and user-defined tags
- Append-only stage and observation timeline with optional photos
- Active, archived, potted, gifted, and unsuccessful outcomes
- User-scheduled local check-in reminders with snooze and completion
- Search and filters by parent, stage, tag, outcome, and due state
- Side-by-side sibling timeline summary without success predictions
- Versioned JSON/ZIP backup and restore; CSV export for records and events
- Full delete/export controls and clear local storage status
- Keyboard, screen-reader, large-text, contrast, and non-color-only state support

## Non-goals

- Plant disease, pest, toxicity, or nutrient diagnosis
- Treatment, pesticide, fertilizer, or food-safety recommendations
- Automatic success scoring or claims that a method will work
- Social feeds, marketplace, messaging, plant identification, or cloud sync
- Background location, microphone, contacts, advertising, or telemetry
- Replacing local experts, product labels, or professional guidance for hazardous plants or chemicals

## Platforms and technology

The mobile shell uses **Flutter 3.47.2 / Dart 3.13.2** for Android and iOS, with a shared domain layer and native accessibility semantics. The exact Flutter version is recorded in `.flutter-version`, constrained in `pubspec.yaml`, and pinned in CI. **Drift over SQLite** provides versioned structured local data, **Riverpod** is planned for explicit application state, platform notification adapters will handle reminders, and media will be copied into app-private storage rather than kept as fragile references to the user's photo library.

Android is the first packaging target because it is straightforward to test and distribute; iOS remains a first-class target and must pass equivalent domain, accessibility, backup, and restore tests.

Source code follows explicit `domain`, `application`, `data`, `features`, and `platform` boundaries under `lib/src/`. See [docs/architecture.md](docs/architecture.md) for dependency rules and responsibilities.

## Local data model

The initial model is intentionally small:

- `ParentPlant`: stable ID, nickname, optional species text, notes, created/archived timestamps
- `Cutting`: stable ID, parent ID, start date, method, medium, location text, tags, current derived state
- `CuttingEvent`: stable ID, cutting ID, timestamp, event kind, note, stage/outcome payload
- `MediaAsset`: stable ID, event ID, app-private relative path, content hash, caption, capture/import metadata
- `Reminder`: stable ID, cutting ID, local schedule, status, and platform notification identifier

Current state is derived from ordered events where practical. Corrections append a replacement event that names the superseded event instead of rewriting history. Migration metadata and schema versions are present from the first database revision. See [docs/data-storage.md](docs/data-storage.md) for UTC/timezone rules, private storage, and deletion boundaries.

## Privacy, permissions, and storage

- Data is stored locally in the app sandbox by default; no account or network is required.
- No analytics, ads, third-party tracking, or remote API is planned for the MVP.
- Camera or photo-library access is requested only when the user adds a photo. Imported media is copied into app-private storage with documented metadata handling.
- Notification permission is requested only when the user first enables a reminder. Denial leaves every journaling and export feature usable.
- No location, microphone, contacts, Bluetooth, motion, or background network permission is required.
- Users can export all records, validate and preview a restore, delete individual media, or erase the complete local library.

## Export and backup

- **CSV export:** parents, cuttings, events, and reminders as documented UTF-8 tables.
- **Portable backup:** a versioned ZIP containing a manifest, canonical JSON, and referenced media with hashes.
- Restore must validate schema version, archive paths, IDs, relationships, hashes, and duplicate policy before mutation. A preview reports additions, conflicts, and skipped media.
- Export files are user-controlled and may contain personal notes or photos; the UI must warn before sharing them.

## Accessibility expectations

All primary workflows must be operable with TalkBack and VoiceOver, keyboard/switch navigation where supported, and large text without clipped controls. Stage and due states use text/icons as well as color. Controls need meaningful labels, predictable focus order, minimum touch targets, reduced-motion behavior, and locale-aware dates.

## Plant-care limitations

Cutting Log is a personal observation journal, not a botanical diagnostic, treatment, pesticide, toxicity, food-safety, or emergency service. It does not determine whether a plant is safe for children or pets and does not replace product labels or qualified local advice. Reminder dates and outcomes are user-entered records, not horticultural guarantees.

## Status and milestones

**Current status: local parent-to-cutting capture and timeline workflow.** The offline, account-free app stores parents, linked cuttings, observations, stage changes, outcomes, corrections, and archives in its versioned app-private Drift/SQLite database. Repository-owned unit/widget/data tests and Android/iOS CI build jobs are present. Reminders, owned photos, portability, signed packages, physical-device evidence, screenshots, and store releases do not exist yet.

1. Bootstrap Flutter packages and CI.
2. Implement the event-based local domain and persistence layer.
3. Deliver the parent → cutting → observation workflow.
4. Add accessible review, filtering, reminders, and sibling summaries.
5. Add media ownership, export/restore, and privacy controls.
6. Verify Android/iOS builds and package an evidence-backed first release.

See [PLAN.md](PLAN.md) and the issue tracker for executable work.

## Development quickstart

Install the exact Flutter SDK version shown in `.flutter-version` (Flutter 3.47.2, which bundles Dart 3.13.2), then run:

```bash
./tool/bootstrap.sh
./tool/check.sh
./tool/build_android.sh

# On macOS with a supported Xcode installation:
./tool/build_ios.sh
```

`tool/bootstrap.sh` rejects a mismatched Flutter version and requires the committed package lock before resolving packages. `tool/check.sh` enforces formatting, runs `flutter analyze`, and runs the unit/widget suite. The platform build scripts produce a debug APK and an unsigned iOS simulator app respectively.

GitHub Actions runs those equivalent checks for every pull request and push to `main`. CI uploads short-lived Android debug and iOS simulator artifacts; they are development evidence, not signed release packages or physical-device results.

## License

MIT. See [LICENSE](LICENSE).
