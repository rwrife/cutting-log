import Foundation

enum CuttingStage: String, Codable, CaseIterable, Hashable, Identifiable {
    case started, callusing, rooting, transferred
    var id: Self { self }
    var title: String { rawValue.capitalized }
}

enum CuttingOutcome: String, Codable, CaseIterable, Hashable, Identifiable {
    case active, potted, gifted, unsuccessful
    var id: Self { self }
    var title: String { rawValue.capitalized }
}

enum EventKind: String, Codable, Hashable {
    case observation, stage, outcome
}

struct Plant: Codable, Identifiable, Hashable {
    var id = UUID()
    var nickname: String
    var species: String = ""
    var notes: String = ""
    var icon: String = "leaf"
    var createdAt = Date()
    var archivedAt: Date?
}

struct Cutting: Codable, Identifiable, Hashable {
    var id = UUID()
    var plantID: UUID
    var name: String
    var method: String
    var medium: String
    var location: String = ""
    var tags: [String] = []
    var startedAt = Date()
    var createdAt = Date()
    var archivedAt: Date?
}

struct JournalEvent: Codable, Identifiable, Hashable {
    var id = UUID()
    var cuttingID: UUID
    var occurredAt = Date()
    var createdAt = Date()
    var kind: EventKind
    var note: String = ""
    var stage: CuttingStage?
    var outcome: CuttingOutcome?
    var correctsEventID: UUID?
    var photos: [PhotoAttachment] = []
}

struct PhotoAttachment: Codable, Identifiable, Hashable {
    var id = UUID()
    var path: String
    var caption: String = ""
}

struct CheckIn: Codable, Identifiable, Hashable {
    var id = UUID()
    var cuttingID: UUID
    var scheduledAt: Date
    var completedAt: Date?
    var isCancelled = false
}

struct JournalLibrary: Codable, Equatable {
    var schemaVersion = 1
    var plants: [Plant] = []
    var cuttings: [Cutting] = []
    var events: [JournalEvent] = []
    var checkIns: [CheckIn] = []
}

struct CuttingState: Equatable {
    var stage: CuttingStage = .started
    var outcome: CuttingOutcome = .active
}

extension JournalLibrary {
    func events(for cuttingID: UUID) -> [JournalEvent] {
        events.filter { $0.cuttingID == cuttingID }.sorted {
            if $0.occurredAt != $1.occurredAt { return $0.occurredAt < $1.occurredAt }
            if $0.createdAt != $1.createdAt { return $0.createdAt < $1.createdAt }
            return $0.id.uuidString < $1.id.uuidString
        }
    }

    func state(for cuttingID: UUID) -> CuttingState {
        let history = events(for: cuttingID)
        let superseded = Set(history.compactMap(\.correctsEventID))
        return history.filter { !superseded.contains($0.id) }.reduce(into: CuttingState()) { state, event in
            if event.kind == .stage, let stage = event.stage, stage.order >= state.stage.order {
                state.stage = stage
            } else if event.kind == .outcome, let outcome = event.outcome {
                state.outcome = outcome
            }
        }
    }
}

extension CuttingStage {
    var order: Int { Self.allCases.firstIndex(of: self) ?? 0 }
}
