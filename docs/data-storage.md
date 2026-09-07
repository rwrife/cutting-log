# Local data, time, and deletion contract

Cutting Log stores structured journal data in a versioned SQLite database under the operating system's app-private application-support directory. The platform composition root supplies that directory to `NativeDatabase`; domain and repository tests supply an isolated temporary path. Optional media bytes will live in a sibling app-private media directory. Database files, write-ahead-log files, and media are not exports and must never be placed in shared storage automatically.

The data adapter does not open sockets, upload records, emit analytics, or log entity fields, notes, paths, reminder text, or other user content. SQLite statement logging remains disabled. Stable IDs are caller-generated opaque strings so backup and restore can preserve identity.

## Timestamps and timezones

All persisted instants are explicit UTC `DateTime` values. A local calendar choice for a reminder is stored as both its resolved UTC instant and the IANA timezone identifier used to resolve it. This keeps ordering deterministic while allowing a later notification adapter to explain or recalculate wall-clock behavior. The database does not infer a device timezone. Equal event timestamps are ordered by creation time and then stable ID; later entry of an older observation is supported.

The selected wall-clock time is resolved with the bundled IANA timezone data.
A spring-forward gap moves to the first valid instant; a fall-back overlap uses
the timezone library's earlier occurrence. An existing check-in keeps its
absolute instant after a device timezone change; editing resolves the newly
selected wall-clock value again. Platform delivery is inexact and may be
delayed by battery or OS policy, so the in-app due list is authoritative.

Notification permission is requested only from the first **Add check-in**
action. Denial or later revocation never blocks journaling or the due list and
is not re-prompted automatically. Startup reconciliation never requests
permission; when already authorized it repairs missing schedules, cancels
stale app-owned IDs, and cancels reminders for archived cuttings without
creating duplicates.

## Append-only history and corrections

`CuttingEvent` rows are append-only. A correction is another event whose `correctsEventId` names the superseded event. Replay excludes superseded rows but retains both rows for provenance. Stage changes cannot move backward, and stage changes after a terminal outcome are rejected. Observations remain neutral user-entered records rather than diagnoses or success predictions.

## Ownership and deletion boundaries

- Archiving a parent or cutting updates archival metadata and does not delete lineage or history.
- Parent deletion is restricted while cuttings reference it.
- Cutting-owned tags, events, reminders, and event-owned media metadata are database children.
- Export writes UTF-8 CSV files (stable columns, UTC timestamps) and a versioned ZIP backup containing `manifest.json`, canonical `journal.json`, `csv/*.csv`, and optional copied media.
- Restore is defensive: it rejects absolute paths, traversal, symlinks, duplicate IDs, invalid relationships, unsupported backup versions, oversized archives, and SHA-256 mismatches before mutation.
- Restore requires a preview (additions/conflicts/skips) and a conflict policy (`keepExisting`, `replaceExisting`, `failOnConflict`) before apply.
- Full-library erase clears all journal tables, app-private copied media, app cache entries, and attempts to cancel app-owned pending reminder notification IDs.
- Platform limitation: if Android or iOS has already copied app-private files into an OS-level/cloud device backup, local erase cannot retract those external snapshots.

Schema version 1 is represented by `test/fixtures/schema_v1.sql`. Version 2 adds the reminder timezone identifier with a conservative `UTC` value for existing rows and creates query indexes. Migration runs with foreign keys enabled and is covered by a file-backed fixture test.
