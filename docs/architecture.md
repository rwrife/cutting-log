# Architecture boundaries

Cutting Log keeps dependencies pointing inward so the local-first core remains testable without a device.

| Boundary | Path | Responsibility |
| --- | --- | --- |
| Domain | `lib/src/domain/` | Framework-light entities, policies, repository ports, validation, and derived state. |
| Application | `lib/src/application/` | Use cases and transaction orchestration. |
| Data | `lib/src/data/` | Local database, repository adapters, migrations, IDs, clocks, and app-private files. |
| Features | `lib/src/features/` | Accessible screens and controllers grouped by user workflow. |
| Platform | `lib/src/platform/` | Injected adapters for optional notifications, media selection, sharing, and OS storage locations. |

The composition root is `lib/main.dart`; shared app theming and routing begin in `lib/src/app.dart`. Domain and application code must not import Flutter UI or platform plugins. Platform access is introduced through narrow interfaces and must never be invoked during startup. Camera/photo and notification requests remain optional and user-initiated.

The production composition root opens the versioned Drift database in the platform application-support directory and injects its `JournalDataRepository` adapter into the capture workflow. Widget and application tests use the in-memory adapter; repository and restart tests use an isolated SQLite file. Application and feature code receive the domain-facing port rather than importing Drift. See [data-storage.md](data-storage.md) for timestamp, migration, ownership, and deletion boundaries.
