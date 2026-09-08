# Privacy and permission disclosure

Cutting Log is an offline, account-free observation journal.

## Data handling

- Journal records are stored in app-private storage by default.
- No account login is required.
- No analytics, advertising SDKs, telemetry, or automatic upload is included.
- Export and restore happen only from explicit user actions.

## Permissions used by the app

### Android

- `POST_NOTIFICATIONS`: only for optional reminder notifications.
- `RECEIVE_BOOT_COMPLETED`: only to reconcile app-owned reminders after reboot.
- `CAMERA`: only when the user chooses camera import.

Not requested: location, contacts, microphone, Bluetooth, background network access.

### iOS

- `NSCameraUsageDescription`: only for explicit camera import.
- `NSPhotoLibraryUsageDescription`: only for explicit library photo import.

Not requested: location, contacts, microphone, Bluetooth, photo-library write access.

## Optional-permission behavior

- Denying camera/photo permissions still leaves journaling and export/restore usable.
- Denying notifications still leaves in-app due-state review usable.
- The app does not prompt for optional permissions on startup.

## Product safety limits

Cutting Log is not a diagnostic, treatment, pesticide, toxicity, or food-safety service. It records user observations and reminders only.
