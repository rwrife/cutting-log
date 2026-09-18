# Data storage

The app writes `library.json` under its Application Support `CuttingLog` directory. The document includes a schema version and stable UUID relationships for parents, cuttings, timeline events, and check-ins. Writes are atomic.

Imported photos are re-encoded as JPEG and copied into the private `Media` directory. Deleting a photo removes its file and reference. Erasing the library removes journal data, local photos, and pending notifications.

User-created backups are JSON documents in `Documents/Exports`; CSV tables are generated alongside them. Restore accepts schema version 1 JSON and replaces the current library. Previously shared files and device-level backups remain outside the app's deletion boundary.
