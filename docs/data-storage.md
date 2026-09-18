# Data storage

The app writes `library.json` under its Application Support `CuttingLog` directory. The document includes a schema version and stable UUID relationships for parents, cuttings, timeline events, and check-ins. Writes are atomic.

Imported photos are re-encoded as JPEG and copied into the private `Media` directory. Deleting a photo removes its file and reference. Erasing the library removes journal data, local photos, and pending notifications.

User-created backups are `.cuttinglog` packages containing schema-versioned JSON and copied media; CSV tables are generated alongside them. Restore accepts complete packages and replaces the current library after validating records, paths, file types, and size limits. Previously shared files and device-level backups remain outside the app's deletion boundary.

On first native launch, an existing Flutter `cutting-log.sqlite` database and its owned media are migrated into the native format. The legacy files remain in place as a recovery source.
