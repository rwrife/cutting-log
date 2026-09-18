import SwiftUI
import UniformTypeIdentifiers

struct AdvancedToolsView: View {
    @EnvironmentObject private var store: JournalStore
    @State private var exportURL: URL?
    @State private var showingImporter = false
    @State private var showingErase = false
    @State private var message: String?

    var body: some View {
        Form {
            Section("Your data, always user-owned") {
                Text("Backups can contain sensitive notes and photo references. Cutting Log never uploads data automatically; sharing and import are always user-initiated.")
                Button {
                    do {
                        exportURL = try store.exportBackup()
                        message = "Backup and CSV exports were created."
                    } catch {
                        message = "Could not create the backup."
                    }
                } label: {
                    Label("Create local backup (photos + JSON + CSV)", systemImage: "square.and.arrow.down")
                }
                if let exportURL {
                    ShareLink(item: exportURL) {
                        Label("Share latest backup", systemImage: "square.and.arrow.up")
                    }
                    Text(exportURL.path).font(.caption).textSelection(.enabled)
                }
            }

            Section("Restore") {
                Text("Import replaces the current library. Keep an export of the current library first.")
                Button {
                    showingImporter = true
                } label: {
                    Label("Choose Cutting Log backup", systemImage: "doc.badge.plus")
                }
            }

            Section("Local storage") {
                LabeledContent("Parents", value: "\(store.library.plants.count)")
                LabeledContent("Cuttings", value: "\(store.library.cuttings.count)")
                LabeledContent("Timeline events", value: "\(store.library.events.count)")
                LabeledContent("Check-ins", value: "\(store.library.checkIns.count)")
            }

            Section {
                Button("Delete full local library", role: .destructive) {
                    showingErase = true
                }
            } footer: {
                Text("Deleting local data cannot remove copies that you previously exported or backed up elsewhere.")
            }
        }
        .navigationTitle("Advanced data tools")
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let url = try result.get().first else { return }
                try store.importBackup(from: url)
                message = "Restore complete."
            } catch {
                message = "This backup could not be validated or restored."
            }
        }
        .confirmationDialog(
            "Delete full local library?",
            isPresented: $showingErase,
            titleVisibility: .visible
        ) {
            Button("Delete local library", role: .destructive) {
                store.eraseLibrary()
                message = "The local library was deleted."
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This erases journal records, copied photos, and check-ins from this iPhone.")
        }
        .alert(
            "Cutting Log",
            isPresented: Binding(get: { message != nil }, set: { if !$0 { message = nil } })
        ) {
            Button("OK") { message = nil }
        } message: {
            Text(message ?? "")
        }
    }
}
