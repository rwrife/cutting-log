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

    init(rootURL: URL? = nil) {
        let root = rootURL ?? FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("CuttingLog", isDirectory: true)
        self.rootURL = root
        libraryURL = root.appendingPathComponent("library.json")
        mediaURL = root.appendingPathComponent("Media", isDirectory: true)
        library = Self.load(from: libraryURL)
        do {
            try FileManager.default.createDirectory(at: mediaURL, withIntermediateDirectories: true)
        } catch {
            errorMessage = "Could not prepare private storage."
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
        let value = note.trimmed
        guard !value.isEmpty, value.count <= 10_000 else {
            errorMessage = "Observation must contain 1–10,000 characters."
            return
        }
        library.events.append(JournalEvent(cuttingID: cuttingID, kind: .observation, note: value))
        persist()
    }

    func changeStage(for cuttingID: UUID, to stage: CuttingStage) {
        guard library.state(for: cuttingID).outcome == .active else {
            errorMessage = "A stage cannot change after a final outcome."
            return
        }
        library.events.append(JournalEvent(cuttingID: cuttingID, kind: .stage, stage: stage))
        persist()
    }

    func recordOutcome(for cuttingID: UUID, outcome: CuttingOutcome) {
        library.events.append(JournalEvent(cuttingID: cuttingID, kind: .outcome, outcome: outcome))
        persist()
    }

    func correct(_ event: JournalEvent, note: String) {
        var replacement = event
        replacement.id = UUID()
        replacement.createdAt = Date()
        replacement.note = note.trimmed
        replacement.correctsEventID = event.id
        replacement.photoPath = nil
        library.events.append(replacement)
        persist()
    }

    func attachPhoto(_ image: UIImage, caption: String, to eventID: UUID) {
        guard let data = image.jpegData(compressionQuality: 0.85),
              let index = library.events.firstIndex(where: { $0.id == eventID }) else { return }
        let name = "\(UUID().uuidString).jpg"
        do {
            try data.write(to: mediaURL.appendingPathComponent(name), options: .atomic)
            library.events[index].photoPath = name
            library.events[index].photoCaption = caption.trimmed
            persist()
        } catch {
            errorMessage = "Could not copy the photo into private storage."
        }
    }

    func image(for event: JournalEvent) -> UIImage? {
        guard let path = event.photoPath else { return nil }
        return UIImage(contentsOfFile: mediaURL.appendingPathComponent(path).path)
    }

    func deletePhoto(from eventID: UUID) {
        guard let index = library.events.firstIndex(where: { $0.id == eventID }),
              let path = library.events[index].photoPath else { return }
        try? FileManager.default.removeItem(at: mediaURL.appendingPathComponent(path))
        library.events[index].photoPath = nil
        library.events[index].photoCaption = ""
        persist()
    }

    func scheduleCheckIn(for cuttingID: UUID, at date: Date) async {
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
        guard let index = library.checkIns.firstIndex(where: { $0.id == checkIn.id }) else { return }
        library.checkIns[index].completedAt = Date()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checkIn.id.uuidString])
        persist()
    }

    func snooze(_ checkIn: CheckIn) async {
        remove(checkIn)
        await scheduleCheckIn(for: checkIn.cuttingID, at: Date().addingTimeInterval(86_400))
    }

    func remove(_ checkIn: CheckIn) {
        library.checkIns.removeAll { $0.id == checkIn.id }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [checkIn.id.uuidString])
        persist()
    }

    func archive(_ cutting: Cutting) {
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
        let backup = exports.appendingPathComponent("cutting-log-\(stamp).json")
        try Self.encoder.encode(library).write(to: backup, options: .atomic)
        try writeCSVs(to: exports)
        return backup
    }

    func importBackup(from url: URL) throws {
        let accessed = url.startAccessingSecurityScopedResource()
        defer { if accessed { url.stopAccessingSecurityScopedResource() } }
        let imported = try Self.decoder.decode(JournalLibrary.self, from: Data(contentsOf: url))
        guard imported.schemaVersion == 1 else {
            throw CocoaError(.fileReadCorruptFile)
        }
        library = imported
        persist()
    }

    func eraseLibrary() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        try? FileManager.default.removeItem(at: rootURL)
        try? FileManager.default.createDirectory(at: mediaURL, withIntermediateDirectories: true)
        library = JournalLibrary()
        persist()
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(at: rootURL, withIntermediateDirectories: true)
            try Self.encoder.encode(library).write(to: libraryURL, options: .atomic)
            errorMessage = nil
        } catch {
            errorMessage = "Could not save changes to private storage."
        }
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

    private static func load(from url: URL) -> JournalLibrary {
        guard let data = try? Data(contentsOf: url),
              let library = try? decoder.decode(JournalLibrary.self, from: data) else {
            return JournalLibrary()
        }
        return library
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
