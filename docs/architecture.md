# Architecture

Cutting Log is a native SwiftUI iPhone app with no third-party runtime dependencies.

- `Models.swift` defines the Codable journal records and deterministic derived cutting state.
- `JournalStore.swift` owns mutations, versioned JSON persistence, private photo files, notifications, CSV export, backup import, and deletion.
- `HomeView.swift` provides journal search and parent/cutting capture.
- `CuttingDetailView.swift` provides timelines, photos, stages, outcomes, corrections, and check-ins.
- `AdvancedToolsView.swift` provides explicit export, restore, and erase controls.
- `HelpView.swift` contains the offline guide and limitations.

The `JournalStore` is injected with SwiftUI's environment and is the single source of truth.
