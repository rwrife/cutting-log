# Migration and restore notes

## Schema history

- **Schema v1**: baseline parent/cutting/event/media/reminder tables (`test/fixtures/schema_v1.sql`).
- **Schema v2**: adds `time_zone_id` support for reminders and supporting indexes.

All migrations run with foreign keys enabled and are covered by file-backed repository tests.

## Restore guarantees

`PortabilityWorkflow` restore is fail-closed:

- Rejects unsupported backup versions.
- Rejects absolute paths, traversal paths, and symlinks in archives.
- Rejects duplicate IDs and invalid parent/child relationships.
- Verifies SHA-256 for media payloads before apply.
- Requires preview + explicit conflict policy before mutation.
- Applies changes transactionally.

## Conflict policies

- `keepExisting`: import non-conflicting records, skip conflicts.
- `replaceExisting`: clear library rows and replace with archive snapshot.
- `failOnConflict`: block apply when any conflicting IDs exist.

## Erase behavior

`eraseLibrary` clears:

- all journal tables,
- app-private media originals/thumbnails,
- portability cache entries,
- pending app-owned notification IDs (best effort).

Platform caveat: if OS-level cloud backup has already copied private files, local erase cannot retract those external snapshots.
