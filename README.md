# Cutting Log

Cutting Log is a private, local-first iPhone journal for tracking plant propagation from a parent plant through rooting, transfer, and a final outcome.

## Features

- Parent plants with nicknames, species, notes, and icons
- Linked cuttings with method, medium, location, tags, and start dates
- Append-only observations, stage changes, outcomes, and corrections
- Optional timeline photos copied into app-private storage
- In-app check-ins with optional local notifications
- Search across plants, cuttings, and tags
- Sibling cutting summaries
- User-initiated JSON backup, CSV exports, restore, archive, and full-library erase
- No accounts, analytics, ads, network service, or Android/iPad support

## Platform

The app is written entirely in Swift and SwiftUI. It targets iOS 17 or newer and iPhone only. Data is encoded as versioned JSON in Application Support; photos are stored in the app sandbox. Apple frameworks provide the UI, photo picker, camera, notifications, and file sharing, so the app has no third-party runtime dependencies.

## Build and test

Open `ios/Runner.xcodeproj` in Xcode 16 or newer, or run:

```bash
./tool/check.sh
./tool/build_ios.sh
```

Set `IOS_TEST_DESTINATION` when the default `iPhone 16 Pro` simulator is unavailable.

## Privacy

Camera access is requested only when the camera action is used. The system photo picker does not grant broad library access. Notification permission is requested only when a check-in is added. Denial never blocks journaling.

Exports can contain personal notes and identifiers. They are created only on request and remain under user control.

## License

MIT. See [LICENSE](LICENSE).
