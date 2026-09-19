import Foundation
import SQLite3

enum LegacyMigrator {
    static func migrate(databaseURL: URL, supportURL: URL, mediaURL: URL) throws -> JournalLibrary {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            return JournalLibrary()
        }
        var database: OpaquePointer?
        guard sqlite3_open_v2(databaseURL.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              let database else {
            throw CocoaError(.fileReadCorruptFile)
        }
        defer { sqlite3_close(database) }

        let parentColumns = try rows(database, sql: "PRAGMA table_info(parent_plants)")
            .compactMap { $0.string("name") }
        let iconColumn = parentColumns.contains("icon_key") ? "icon_key" : "NULL AS icon_key"
        let plantRows = try rows(
            database,
            sql: "SELECT id, nickname, species_text, notes, \(iconColumn), created_at_utc, archived_at_utc FROM parent_plants"
        )
        let cuttingRows = try rows(database, sql: "SELECT id, parent_id, name, method, medium, location, started_at_utc, created_at_utc, archived_at_utc FROM cuttings")
        let tagRows = try rows(database, sql: "SELECT cutting_id, tag FROM cutting_tags")
        let eventRows = try rows(database, sql: "SELECT id, cutting_id, occurred_at_utc, created_at_utc, kind, note, stage, outcome, corrects_event_id FROM cutting_events")
        let mediaRows = try rows(database, sql: "SELECT id, event_id, relative_path, caption FROM media_assets ORDER BY imported_at_utc")
        let reminderRows = try rows(database, sql: "SELECT id, cutting_id, scheduled_for_utc, status, completed_at_utc FROM reminders")

        let plantMap = Dictionary(uniqueKeysWithValues: plantRows.compactMap { row in
            row.string("id").map { ($0, stableID($0)) }
        })
        let cuttingMap = Dictionary(uniqueKeysWithValues: cuttingRows.compactMap { row in
            row.string("id").map { ($0, stableID($0)) }
        })
        let eventMap = Dictionary(uniqueKeysWithValues: eventRows.compactMap { row in
            row.string("id").map { ($0, stableID($0)) }
        })
        let tags = Dictionary(grouping: tagRows, by: { $0.string("cutting_id") ?? "" })
        var library = JournalLibrary()

        library.plants = plantRows.compactMap { row in
            guard let oldID = row.string("id"), let id = plantMap[oldID],
                  let nickname = row.string("nickname") else { return nil }
            return Plant(
                id: id,
                nickname: nickname,
                species: row.string("species_text") ?? "",
                notes: row.string("notes") ?? "",
                icon: mapIcon(row.string("icon_key")),
                createdAt: row.date("created_at_utc") ?? Date(),
                archivedAt: row.date("archived_at_utc")
            )
        }
        library.cuttings = cuttingRows.compactMap { row in
            guard let oldID = row.string("id"), let id = cuttingMap[oldID],
                  let oldParentID = row.string("parent_id"), let plantID = plantMap[oldParentID],
                  let name = row.string("name") else { return nil }
            return Cutting(
                id: id,
                plantID: plantID,
                name: name,
                method: row.string("method") ?? "Stem",
                medium: row.string("medium") ?? "",
                location: row.string("location") ?? "",
                tags: tags[oldID, default: []].compactMap { $0.string("tag") }.sorted(),
                startedAt: row.date("started_at_utc") ?? Date(),
                createdAt: row.date("created_at_utc") ?? Date(),
                archivedAt: row.date("archived_at_utc")
            )
        }
        library.events = eventRows.compactMap { row in
            guard let oldID = row.string("id"), let id = eventMap[oldID],
                  let oldCuttingID = row.string("cutting_id"), let cuttingID = cuttingMap[oldCuttingID],
                  let rawKind = row.string("kind"), let kind = EventKind(rawValue: rawKind) else { return nil }
            return JournalEvent(
                id: id,
                cuttingID: cuttingID,
                occurredAt: row.date("occurred_at_utc") ?? Date(),
                createdAt: row.date("created_at_utc") ?? Date(),
                kind: kind,
                note: row.string("note") ?? "",
                stage: row.string("stage").flatMap(CuttingStage.init(rawValue:)),
                outcome: row.string("outcome").flatMap(CuttingOutcome.init(rawValue:)),
                correctsEventID: row.string("corrects_event_id").flatMap { eventMap[$0] }
            )
        }
        library.checkIns = reminderRows.compactMap { row in
            guard row.string("status") == "pending",
                  let oldID = row.string("id"), let oldCuttingID = row.string("cutting_id"),
                  let cuttingID = cuttingMap[oldCuttingID],
                  let scheduledAt = row.date("scheduled_for_utc") else { return nil }
            return CheckIn(
                id: stableID(oldID),
                cuttingID: cuttingID,
                scheduledAt: scheduledAt,
                completedAt: row.date("completed_at_utc")
            )
        }

        try FileManager.default.createDirectory(at: mediaURL, withIntermediateDirectories: true)
        for row in mediaRows {
            guard let oldEventID = row.string("event_id"), let eventID = eventMap[oldEventID],
                  let index = library.events.firstIndex(where: { $0.id == eventID }),
                  let relativePath = row.string("relative_path"),
                  isSafeRelativePath(relativePath) else { continue }
            let source = supportURL.appendingPathComponent(relativePath)
            guard FileManager.default.fileExists(atPath: source.path) else { continue }
            let destinationName = "\(UUID().uuidString).jpg"
            try FileManager.default.copyItem(
                at: source,
                to: mediaURL.appendingPathComponent(destinationName)
            )
            library.events[index].photos.append(
                PhotoAttachment(path: destinationName, caption: row.string("caption") ?? "")
            )
        }
        return library
    }

    private static func rows(_ database: OpaquePointer, sql: String) throws -> [[String: SQLiteValue]] {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            throw CocoaError(.fileReadCorruptFile)
        }
        defer { sqlite3_finalize(statement) }
        var output: [[String: SQLiteValue]] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            var row: [String: SQLiteValue] = [:]
            for index in 0..<sqlite3_column_count(statement) {
                let name = String(cString: sqlite3_column_name(statement, index))
                switch sqlite3_column_type(statement, index) {
                case SQLITE_INTEGER:
                    row[name] = .integer(sqlite3_column_int64(statement, index))
                case SQLITE_FLOAT:
                    row[name] = .double(sqlite3_column_double(statement, index))
                case SQLITE_TEXT:
                    row[name] = .text(String(cString: sqlite3_column_text(statement, index)))
                default:
                    row[name] = .null
                }
            }
            output.append(row)
        }
        return output
    }

    private static func stableID(_ value: String) -> UUID {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in value.utf8 {
            hash = (hash ^ UInt64(byte)) &* 0x100000001b3
        }
        let suffix = String(format: "%012llx", hash & 0xffffffffffff)
        return UUID(uuidString: "00000000-0000-5000-8000-\(suffix)")!
    }

    private static func mapIcon(_ key: String?) -> String {
        switch key {
        case "forest", "park": return "tree"
        case "local_florist", "spa": return "camera.macro"
        case "water_drop": return "drop"
        case "wb_sunny": return "sun.max"
        case "terrain": return "mountain.2"
        case "emoji_nature": return "ladybug"
        default: return "leaf"
        }
    }

    private static func isSafeRelativePath(_ value: String) -> Bool {
        !value.hasPrefix("/") && !value.contains("\\")
            && value.split(separator: "/").allSatisfy { $0 != "." && $0 != ".." }
    }
}

private enum SQLiteValue {
    case integer(Int64)
    case double(Double)
    case text(String)
    case null
}

private extension Dictionary where Key == String, Value == SQLiteValue {
    func string(_ key: String) -> String? {
        guard case let .text(value)? = self[key] else { return nil }
        return value
    }

    func date(_ key: String) -> Date? {
        switch self[key] {
        case let .integer(value):
            let seconds = value > 10_000_000_000 ? Double(value) / 1_000_000 : Double(value)
            return Date(timeIntervalSince1970: seconds)
        case let .double(value):
            return Date(timeIntervalSince1970: value)
        default:
            return nil
        }
    }
}
