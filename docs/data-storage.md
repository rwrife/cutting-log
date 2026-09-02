# Local data, time, and deletion contract

Cutting Log stores structured journal data in a versioned SQLite database under the operating system's app-private application-support directory. The platform composition root supplies that directory to `NativeDatabase`; domain and repository tests supply an isolated temporary path. Optional media bytes will live in a sibling app-private media directory. Database files, write-ahead-log files, and media are not exports and must never be placed in shared storage automatically.

The data adapter does not open sockets, upload records, emit analytics, or log entity fields, notes, paths, reminder text, or other user content. SQLite statement logging remains disabled. Stable IDs are caller-generated opaque strings so backup and restore can preserve identity.

## Timestamps and timezones

All persisted instants are explicit UTC `DateTime` values. A local calendar choice for a reminder is stored as both its resolved UTC instant and the IANA timezone identifier used to resolve it. This keeps ordering deterministic while allowing a later notification adapter to explain or recalculate wall-clock behavior. The database does not infer a device timezone. Equal event timestamps are ordered by creation time and then stable ID; later entry of an older observation is supported.

## Append-only history and corrections

`CuttingEvent` rows are append-only. A correction is another event whose `correctsEventId` names the superseded event. Replay excludes superseded rows but retains both rows for provenance. Stage changes cannot move backward, and stage changes after a terminal outcome are rejected. Observations remain neutral user-entered records rather than diagnoses or success predictions.

## Ownership and deletion boundaries

- Archiving a parent or cutting updates archival metadata and does not delete lineage or history.
- Parent deletion is restricted while cuttings reference it.
- Cutting-owned tags, events, reminders, and event-owned media metadata are database children. A future explicit complete-delete use case may remove that aggregate transactionally; no background cleanup or implicit deletion is exposed in this milestone.
- Media metadata deletion never proves that a media file was removed. Issue #5 must coordinate database metadata and app-private bytes as one failure-sensitive operation.
- Full-library erase must eventually remove the closed database (including `-wal`/`-shm`) and owned media directory. Export and restore must treat all incoming paths and IDs as untrusted.

Schema version 1 is represented by `test/fixtures/schema_v1.sql`. Version 2 adds the reminder timezone identifier with a conservative `UTC` value for existing rows and creates query indexes. Migration runs with foreign keys enabled and is covered by a file-backed fixture test.
