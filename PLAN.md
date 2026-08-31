# Cutting Log implementation plan

## Product scope

Cutting Log is a small, local-first mobile propagation journal. Its vertical slice is: create a parent plant, start a linked cutting, append an observation/stage event, schedule an optional local check-in, review the timeline, and export user-owned data. The MVP succeeds without network access or optional permissions.

## Architecture

```text
Flutter views + accessibility semantics
              |
Application use cases / Riverpod controllers
              |
Pure Dart domain (entities, events, validation, queries)
              |
Repository ports
       +------+----------------+
       |                       |
Drift/SQLite adapters     Media file store
       |                       |
 local DB + migrations    app-private files
       |
Notification adapter      Export/restore adapter
```

Boundaries:

- `domain`: framework-light entities, immutable events, state derivation, validation, and queries
- `application`: use cases and transaction orchestration
- `data`: Drift schema/migrations, repositories, app-private media, clocks and IDs
- `features`: parent/cutting capture, timeline, review, reminders, export/restore, settings/privacy
- `platform`: notifications, camera/photo picker, share sheet, filesystem locations

Adapters must be injectable so domain and backup behavior can run in ordinary Dart tests without a device.

## Technology choices

- **Flutter/Dart:** one accessible Android/iOS UI and a mature test/build ecosystem.
- **Drift + SQLite:** typed queries, explicit migrations, transactions, and offline durability.
- **Riverpod:** testable dependency injection and predictable async state without hiding persistence.
- **go_router:** explicit routes and deep-link-safe navigation without requiring cloud services.
- **Platform notification APIs through an adapter:** local reminders only; denied permission degrades cleanly.
- **Versioned JSON + ZIP and CSV:** portable, inspectable user exports; no proprietary cloud backup dependency.
- **App-private media copies + content hashes:** predictable ownership, backup integrity, and deletion semantics.

No optional AI is planned. Propagation outcomes are too context-dependent for an opaque predictor, and the journal is useful through deterministic records and comparisons.

## Milestones and dependency order

### M1 — Reproducible shell

- Pin Flutter/Dart versions and bootstrap workspace packages.
- Establish formatting, static analysis, unit/widget tests, Android debug build, and macOS-hosted iOS simulator build in CI.
- Add architecture notes and contribution commands.

### M2 — Local event model

- Define parents, cuttings, events, media metadata, reminders, IDs, validation, and state derivation.
- Implement Drift schema, migrations, transaction-safe repositories, and fixture builders.
- Test ordering, edit/correction policy, archive/outcome transitions, migration, and restart durability.

### M3 — Primary capture workflow

- Build accessible parent creation/selection.
- Start a cutting and append notes, observations, stage changes, and outcomes.
- Show a deterministic timeline and preserve lineage.
- Cover use cases with domain, repository, controller, and widget tests.

### M4 — Review and reminders

- Add active/due filters, search, tags, parent grouping, and sibling timeline summaries.
- Add user-created local check-ins, snooze/completion, timezone handling, and denied-permission behavior.
- Verify TalkBack/VoiceOver semantics, focus order, large text, non-color states, and reduced motion.

### M5 — Photos, ownership, and portability

- Add just-in-time camera/photo selection and copy media into app-private storage.
- Define metadata handling, orphan cleanup, hashes, deletion, and storage reporting.
- Implement CSV export and versioned ZIP/JSON backup/restore with path and relationship validation, preview, rollback, and corruption tests.

### M6 — Packaging and first release

- Run clean Android and iOS builds from pinned environments.
- Exercise fresh-install, upgrade/migration, denied-permission, backup round-trip, and offline acceptance checks.
- Produce checksummed artifacts, release notes, privacy documentation, licenses, and truthful screenshots from built software.

## Testing strategy

### Automated

- **Pure Dart unit tests:** validators, event ordering/state derivation, filters, due dates, reminder state, export serialization, and schema compatibility.
- **Repository tests:** in-memory and file-backed SQLite transactions, migrations, restart durability, referential integrity, and duplicate handling.
- **Property/fuzz tests:** malformed backup JSON, hostile ZIP paths, duplicate IDs, timestamp boundaries, and event sequences.
- **Widget/golden tests:** primary flows, empty/error states, large text, high contrast, localization, and non-color-only meaning.
- **Integration tests:** parent → cutting → event → reminder → export → clean restore; media deletion; permission denial; no-network operation.
- **CI:** format, analyze, test, Android debug build, and iOS simulator build on a supported macOS runner.

### Manual evidence before release

- TalkBack and VoiceOver walkthroughs of every primary task.
- Multiple screen sizes, dynamic text scales, light/dark and high-contrast checks.
- Camera/photo and notification permission request/denial/revocation on real Android and iOS devices.
- Timezone/DST reminder behavior and cold-start handling.
- Backup to a user-selected location, restore on a clean install, CSV inspection, and complete erase verification.
- Airplane-mode operation with no unexpected network requests.

Manual evidence must name the device/OS/app revision. A simulator run is not a physical-device result.

## Packaging and distribution

- Android: signed AAB for store/repository distribution plus a checksummed APK for test releases.
- iOS: archived IPA/TestFlight candidate from a pinned macOS/Xcode environment; no claim of App Store publication until accepted.
- Keep signing credentials out of the repository and document reproducible unsigned/debug builds.
- Release archives include changelog, privacy statement, export schema, migration notes, third-party licenses, and checksums.

## Data and permission plan

- SQLite and copied media live under platform app-private storage.
- Camera/photo-library and notification permissions are requested in context and remain optional.
- Sharing/export invokes the platform picker only after explicit user action.
- Backups use schema versions and content hashes. Restore is previewed and transactionally applied.
- The app has no account, analytics, ad identifier, contacts, location, microphone, Bluetooth, or background network requirement.

## Key risks and mitigations

| Risk | Mitigation |
|---|---|
| Timeline edits destroy provenance | Prefer correction events or explicit audited replacement rules; test derivation deterministically. |
| Media references break or backups balloon | Copy into owned storage, hash/dedupe, expose storage totals, validate manifests, and allow selective cleanup. |
| Reminder behavior differs across OS versions | Isolate adapter, store app-level state, test timezone/DST and denied/revoked permission, document OS limits. |
| Restore corrupts an existing library | Validate first, preview conflict policy, extract safely, use transactions/staging, and retain rollback evidence. |
| Plant stages imply scientific certainty | Use user-entered labels and neutral observations; never predict success, diagnose, or prescribe treatment. |
| Accessibility regresses in photo/timeline UI | Semantics and large-text widget tests plus release-gated TalkBack/VoiceOver walkthroughs. |
| Scope expands into general plant care | Keep mature-plant scheduling, identification, shopping, community, and cloud sync outside the MVP. |

## Explicit non-goals

- Automated plant identification, diagnosis, treatment, toxicity, fertilizer, pesticide, or food-safety advice
- Success prediction, prescriptive schedules, or scientific trial claims
- General garden planning or mature-plant watering management
- Cloud accounts, shared live households, social feeds, marketplace, or messaging
- Wearables, environmental sensors, Bluetooth devices, background location, or always-on network access
- Desktop/web app, server backend, subscriptions, ads, or AI features in the MVP
