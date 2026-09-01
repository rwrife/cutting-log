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

The bootstrap intentionally uses an in-memory empty repository. Drift persistence belongs to issue #2 and will implement the existing domain-facing repository boundary.
