import Combine
import Foundation
import UIKit
import UserNotifications

@MainActor
final class JournalStore: ObservableObject {
    @Published private(set) var library: JournalLibrary
    @Published var errorMessage: String?

    private let rootURL: URL
    private let libraryURL: URL
    private let mediaURL: URL
    private var storageBlocked = false

    init(rootURL: URL? = nil) {
        let root = rootURL ?? FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("CuttingLog", isDirectory: true)
        self.rootURL = root
        libraryURL = root.appendingPathComponent("library.json")
        mediaURL = root.appendingPathComponent("Media", isDirectory: true)
        if FileManager.default.fileExists(atPath: libraryURL.path) {
            if let loaded = Self.load(from: libraryURL) {
                library = loaded
            } else {
                library = JournalLibrary()
                storageBlocked = true
            }
        } else {
            let legacyURL = root.deletingLastPathComponent().appendingPathComponent("cutting-log.sqlite")
            do {
                library = try LegacyMigrator.migrate(
                    databaseURL: legacyURL,
                    supportURL: root.deletingLastPathComponent(),
                    mediaURL: root.appendingPathComponent("Media", isDirectory: true)
                )
            } catch {
                library = JournalLibrary()
                storageBlocked = true
            }
        }
        do {
            try FileManager.default.createDirectory(at: mediaURL, withIntermediateDirectories: true)
            if !storageBlocked, !FileManager.default.fileExists(atPath: libraryURL.path), library != JournalLibrary() {
                try write(library)
            }
        } catch {
            errorMessage = "Could not prepare private storage."
        }
        if storageBlocked {
            errorMessage = "The local journal file could not be read. It was preserved; restore a backup or erase the library to continue."
        }
    }

    var activePlants: [Plant] {
        library.plants.filter { $0.archivedAt == nil }.sorted { $0.nickname < $1.nickname }
    }

    func cuttings(for plantID: UUID) -> [Cutting] {
        library.cuttings.filter { $0.plantID == plantID && $0.archivedAt == nil }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func createPlant(nickname: String, species: String, notes: String, icon: String) {
        guard isWritable else { return }
        let name = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, name.count <= 80 else {
            errorMessage = "Parent nickname must contain 1–80 characters."
            return
        }
        library.plants.append(Plant(nickname: name, species: species.trimmed, notes: notes, icon: icon))
        persist()
    }

    func createCutting(
        plantID: UUID,
        name: String,
        method: String,
        medium: String,
        location: String,
        tags: String,
        startedAt: Date,
        initialNote: String
    ) {
        guard isWritable else { return }
        let siblings = cuttings(for: plantID)
        let proposed = name.trimmed
        let finalName = proposed.isEmpty ? nextCuttingName(in: siblings) : proposed
        guard finalName.count <= 80 else {
            errorMessage = "Cutting name must contain 1–80 characters."
            return
        }
        let normalizedTags = Array(Set(tags.split(separator: ",").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }.filter { !$0.isEmpty })).sorted()
        guard normalizedTags.count <= 20, normalizedTags.allSatisfy({ $0.count <= 40 }) else {
            errorMessage = "Use up to 20 tags of 1–40 characters."
            return
        }
        let cutting = Cutting(
            plantID: plantID,
            name: finalName,
            method: method,
            medium: medium,
            location: location.trimmed,
            tags: normalizedTags,
            startedAt: startedAt
        )
        library.cuttings.append(cutting)
        if !initialNote.trimmed.isEmpty {
            library.events.append(JournalEvent(cuttingID: cutting.id, kind: .observation, note: initialNote))
        }
        persist()
    }

    func addObservation(to cuttingID: UUID, note: String) {
        guard isWritable else { return }
        let value = note.trimmed
        guard !value.isEmpty, value.count <= 10_000 else {
            errorMessage = "Observation must contain 1–10,000 characters."
            return
        }
        library.events.append(JournalEvent(cuttingID: cuttingID, kind: .observation, note: value))
        persist()
    }

    func changeStage(for cuttingID: UUID, to stage: CuttingStage) {
        guard isWritable else { return }
        let state = library.state(for: cuttingID)
        guard state.outcome == .active else {
            errorMessage = "A stage cannot change after a final outcome."
            return
        }
        guard stage.order >= state.stage.order else {
            errorMessage = "A stage cannot move backward."
            return
        }
        library.events.append(JournalEvent(cuttingID: cuttingID, kind: .stage, stage: stage))
        persist()
    }

    func recordOutcome(for cuttingID: UUID, outcome: CuttingOutcome) {
        guard isWritable else { return }
        let current = library.state(for: cuttingID).outcome
        guard current == .active || current == outcome else {
            errorMessage = "A final outcome can only be changed with a correction."
            return
        }
        library.events.append(JournalEvent(cuttingID: cuttingID, kind: .outcome, outcome: outcome))
        persist()
    }

    func correct(_ event: JournalEvent, note: String) {
        guard isWritable else { return }
        var replacement = event
        replacement.id = UUID()
        replacement.createdAt = Date()
        replacement.note = note.trimmed
        replacement.correctsEventID = event.id
        replacement.photos = []
        library.events.append(replacement)
        persist()
    }

    func attachPhoto(_ image: UIImage, caption: String, to eventID: UUID) {
        guard isWritable else { return }
        guard let data = image.jpegData(compressionQuality: 0.85),
              let index = library.events.firstIndex(where: { $0.id == eventID }) else { return }
        let name = "\(UUID().uuidString).jpg"
        do {
            try data.write(to: mediaURL.appendingPathComponent(name), options: .atomic)
            library.events[index].photos.append(PhotoAttachment(path: name, caption: caption.trimmed))
            persist()
        } catch {
            errorMessage = "Could not copy the photo into private storage."
        }
    }

    func image(for photo: PhotoAttachment) -> UIImage? {
        UIImage(contentsOfFile: mediaURL.appendingPathComponent(photo.path).path)
    }

    func deletePhoto(_ photo: PhotoAttachment, from eventID: UUID) {
        guard isWritable else { return }
        guard let index = library.events.firstIndex(where: { $0.id == eventID }) else { return }
        try? FileManager.default.removeItem(at: mediaURL.appendingPathComponent(photo.path))
        library.events[index].photos.removeAll { $0.id == photo.id }
        persist()
    }

    func scheduleCheckIn(for cuttingID: UUID, at date: Date) async {
        guard isWritable else { return }
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        let checkIn = CheckIn(cuttingID: cuttingID, scheduledAt: date)
        library.checkIns.append(checkIn)
        persist()
        guard granted else { return }
        let content = UNMutableNotificationContent()
        content.title = "Cutting check-in"
        content.body = "Take a moment to record what you observe."
        content.sound = .default
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        let request = UNNotificationRequest(
            identifier: checkIn.id.uuidString,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        try? await center.add(request)
    }

    func complete(_ checkIn: CheckIn) {
        guard isWritable else { return }
        guard let index = library.checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        library.checkIns[index].completedAt = Date()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checkIn.id.uuidString])
        persist()
    }

    func snooze(_ checkIn: CheckIn) async {
        guard isWritable else { return }
        remove(checkIn)
        await scheduleCheckIn(for: checkIn.cuttingID, at: Date().addingTimeInterval(86_400))
    }

    func remove(_ checkIn: CheckIn) {
        guard isWritable else { return }
        library.checkIns.removeAll { $0.id == checkIn.id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checkIn.id.uuidString])
        persist()
    }

    func archive(_ cutting: Cutting) {
        guard isWritable else { return }
        guard let index = library.cuttings.firstIndex(where: { $0.id == cutting.id }) else { return }
        library.cuttings[index].archivedAt = Date()
        persist()
    }

    func exportBackup() throws -> URL {
        let exports = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Exports", isDirectory: true)
        try FileManager.default.createDirectory(at: exports, withIntermediateDirectories: true)
        let formatter = ISO8601DateFormatter()
        let stamp = formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let backup = exports.appendingPathComponent("cutting-log-\(stamp).cuttinglog", isDirectory: true)
        try? FileManager.default.removeItem(at: backup)
        try FileManager.default.createDirectory(at: backup, withIntermediateDirectories: true)
        try Self.encoder.encode(library).write(
            to: backup.appendingPathComponent("library.json"),
            options: .atomic
        )
        let backupMedia = backup.appendingPathComponent("Media", isDirectory: true)
        if FileManager.default.fileExists(atPath: mediaURL.path) {
            try FileManager.default.copyItem(at: mediaURL, to: backupMedia)
        }
        try writeCSVs(to: exports)
        return backup
    }

    func importBackup(from url: URL) throws {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        let values = try url.resourceValues(forKeys: [.isDirectoryKey])
        guard values.isDirectory == true else { throw CocoaError(.fileReadCorruptFile) }
        try Self.validatePackageRoot(url)
        let source = url.appendingPathComponent("library.json")
        let sourceValues = try source.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey])
        guard sourceValues.isRegularFile == true, (sourceValues.fileSize ?? 0) <= 50_000_000 else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let imported = try Self.decoder.decode(JournalLibrary.self, from: Data(contentsOf: source))
        guard imported.schemaVersion == 1, Self.isValid(imported) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let stagedMedia = rootURL.appendingPathComponent("Media.restore", isDirectory: true)
        try? FileManager.default.removeItem(at: stagedMedia)
        let importedMedia = url.appendingPathComponent("Media", isDirectory: true)
        if FileManager.default.fileExists(atPath: importedMedia.path) {
            try Self.validateMediaDirectory(importedMedia, library: imported)
            try FileManager.default.copyItem(at: importedMedia, to: stagedMedia)
        } else {
            try FileManager.default.createDirectory(at: stagedMedia, withIntermediateDirectories: true)
        }
        let previousMedia = rootURL.appendingPathComponent("Media.previous", isDirectory: true)
        try? FileManager.default.removeItem(at: previousMedia)
        if FileManager.default.fileExists(atPath: mediaURL.path) {
            try FileManager.default.moveItem(at: mediaURL, to: previousMedia)
        }
        do {
            try FileManager.default.moveItem(at: stagedMedia, to: mediaURL)
            try write(imported)
            try? FileManager.default.removeItem(at: previousMedia)
        } catch {
            try? FileManager.default.removeItem(at: mediaURL)
            if FileManager.default.fileExists(atPath: previousMedia.path) {
                try? FileManager.default.moveItem(at: previousMedia, to: mediaURL)
            }
            throw error
        }
        library = imported
        storageBlocked = false
        errorMessage = nil
    }

    func eraseLibrary() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        try? FileManager.default.removeItem(at: rootURL)
        try? FileManager.default.createDirectory(at: mediaURL, withIntermediateDirectories: true)
        library = JournalLibrary()
        storageBlocked = false
        persist()
    }

    private func persist() {
        guard !storageBlocked else {
            errorMessage = "Restore a backup or erase the unreadable library before making changes."
            return
        }
        do {
            try write(library)
            errorMessage = nil
        } catch {
            errorMessage = "Could not save changes to private storage."
        }
    }

    private var isWritable: Bool {
        guard !storageBlocked else {
            errorMessage = "Restore a backup or erase the unreadable library before making changes."
            return false
        }
        return true
    }

    private func write(_ value: JournalLibrary) throws {
        try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
        try Self.encoder.encode(value).write(to: libraryURL, options: .atomic)
    }

    private func nextCuttingName(in siblings: [Cutting]) -> String {
        let names = Set(siblings.map { $0.name.lowercased() })
        var index = 1
        while names.contains("cutting \(index)") { index += 1 }
        return "Cutting \(index)"
    }

    private func writeCSVs(to directory: URL) throws {
        let parents = "id,nickname,species,created_at\n" + library.plants.map {
            "\($0.id),\(Self.csv($0.nickname)),\(Self.csv($0.species)),\($0.createdAt.ISO8601Format())"
        }.joined(separator: "\n")
        let cuttings = "id,parent_id,name,method,medium,started_at\n" + library.cuttings.map {
            "\($0.id),\($0.plantID),\(Self.csv($0.name)),\(Self.csv($0.method)),\(Self.csv($0.medium)),\($0.startedAt.ISO8601Format())"
        }.joined(separator: "\n")
        let events = "id,cutting_id,kind,note,occurred_at\n" + library.events.map {
            "\($0.id),\($0.cuttingID),\($0.kind.rawValue),\(Self.csv($0.note)),\($0.occurredAt.ISO8601Format())"
        }.joined(separator: "\n")
        try parents.write(to: directory.appendingPathComponent("parents.csv"), atomically: true, encoding: .utf8)
        try cuttings.write(to: directory.appendingPathComponent("cuttings.csv"), atomically: true, encoding: .utf8)
        try events.write(to: directory.appendingPathComponent("events.csv"), atomically: true, encoding: .utf8)
    }

    private static func csv(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private static func load(from url: URL) -> JournalLibrary? {
        guard let data = try? Data(contentsOf: url),
              let library = try? decoder.decode(JournalLibrary.self, from: data) else {
            return nil
        }
        return library
    }

    private static func isValid(_ library: JournalLibrary) -> Bool {
        let plantIDs = Set(library.plants.map(\.id))
        let cuttingIDs = Set(library.cuttings.map(\.id))
        let eventIDs = Set(library.events.map(\.id))
        guard plantIDs.count == library.plants.count,
              cuttingIDs.count == library.cuttings.count,
              eventIDs.count == library.events.count,
              Set(library.checkIns.map(\.id)).count == library.checkIns.count,
              library.cuttings.allSatisfy({ plantIDs.contains($0.plantID) }),
              library.events.allSatisfy({ cuttingIDs.contains($0.cuttingID) }),
              library.checkIns.allSatisfy({ cuttingIDs.contains($0.cuttingID) }) else {
            return false
        }
        return library.events.allSatisfy { event in
            let validPhotoPaths = event.photos.allSatisfy {
                let path = $0.path
                return !path.isEmpty && path != "." && path != ".."
                    && !path.contains("/") && !path.contains("\\")
            }
            let validCorrection = event.correctsEventID.map { targetID in
                library.events.contains { $0.id == targetID && $0.cuttingID == event.cuttingID }
            } ?? true
            return validPhotoPaths && validCorrection
        }
    }

    private static func validateMediaDirectory(_ directory: URL, library: JournalLibrary) throws {
        let expected = Set(library.events.flatMap(\.photos).map(\.path))
        let files = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey],
            options: []
        )
        var totalSize = 0
        for file in files {
            let values = try file.resourceValues(
                forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]
            )
            guard values.isRegularFile == true, values.isSymbolicLink != true,
                  expected.contains(file.lastPathComponent) else {
                throw CocoaError(.fileReadCorruptFile)
            }
            totalSize += values.fileSize ?? 0
            guard totalSize <= 500_000_000 else {
                throw CocoaError(.fileReadTooLarge)
            }
        }
        guard expected.isSubset(of: Set(files.map(\.lastPathComponent))) else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    private static func validatePackageRoot(_ directory: URL) throws {
        let entries = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey],
            options: []
        )
        guard Set(entries.map(\.lastPathComponent)).isSubset(of: ["library.json", "Media"]) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        for entry in entries {
            let values = try entry.resourceValues(
                forKeys: [.isDirectoryKey, .isRegularFileKey, .isSymbolicLinkKey]
            )
            guard values.isSymbolicLink != true else { throw CocoaError(.fileReadCorruptFile) }
            if entry.lastPathComponent == "library.json", values.isRegularFile != true {
                throw CocoaError(.fileReadCorruptFile)
            }
            if entry.lastPathComponent == "Media", values.isDirectory != true {
                throw CocoaError(.fileReadCorruptFile)
            }
        }
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
