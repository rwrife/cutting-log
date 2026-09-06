# Media ownership and photo import policy

Cutting Log treats timeline photos as **owned local assets**:

- Source files from camera or library are copied into app-private storage.
- UI and repositories store only app-relative paths (`media/originals/...`).
- External URIs are never persisted for long-term rendering.

## Import rules

`AppPrivateMediaStore` enforces:

- Supported formats: JPEG and PNG.
- Max source size: 12 MB.
- Max decoded dimensions: 4096 x 4096.
- Orientation normalization on import (`bakeOrientation`).
- Thumbnail generation (`media/thumbnails/<asset-id>.jpg`, max edge 512px).
- Hashing: SHA-256 of the normalized stored original.

## Metadata behavior

- Captions are optional free text (trimmed, up to domain limits).
- Capture timestamp is tracked as `capturedAtUtc`.
- Import timestamp is tracked as `importedAtUtc`.
- EXIF payload is intentionally removed by decode/re-encode during import.

## Reliability and cleanup

Import uses staged temp files (`media/staging`) and atomic finalize into
`media/originals` and `media/thumbnails`.

On failures (decode errors, storage failures, repository write errors), staged
files are cleaned up and no dangling metadata is committed.

`MediaWorkflow.inspectStorage()` reports:

- tracked asset count and bytes,
- missing metadata-backed files,
- orphaned files not referenced by metadata.

User actions can remove one media asset or clear all local media; cleanup is
never silent and always user-triggered.

## Permission timing

Permissions are requested only from explicit Add Photo user actions:

- Camera import requests camera permission.
- Photo-library import requests photo permission on iOS.
- Notification permission flow remains independent for reminders.
