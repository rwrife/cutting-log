import XCTest
@testable import Cutting_Log

final class RunnerTests: XCTestCase {
    func testDerivedStateUsesOrderedEvents() {
        let cuttingID = UUID()
        let start = Date(timeIntervalSince1970: 100)
        let library = JournalLibrary(
            events: [
                JournalEvent(
                    cuttingID: cuttingID,
                    occurredAt: start.addingTimeInterval(20),
                    kind: .outcome,
                    outcome: .potted
                ),
                JournalEvent(
                    cuttingID: cuttingID,
                    occurredAt: start,
                    kind: .stage,
                    stage: .rooting
                )
            ]
        )

        XCTAssertEqual(library.state(for: cuttingID), CuttingState(stage: .rooting, outcome: .potted))
    }

    func testCorrectionSupersedesOriginalEvent() {
        let cuttingID = UUID()
        let original = JournalEvent(cuttingID: cuttingID, kind: .stage, stage: .callusing)
        let replacement = JournalEvent(
            cuttingID: cuttingID,
            occurredAt: original.occurredAt,
            createdAt: original.createdAt.addingTimeInterval(1),
            kind: .stage,
            stage: .rooting,
            correctsEventID: original.id
        )

        let library = JournalLibrary(events: [original, replacement])

        XCTAssertEqual(library.state(for: cuttingID).stage, .rooting)
    }

    @MainActor
    func testStorePersistsParents() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }

        let store = JournalStore(rootURL: root)
        store.createPlant(nickname: "Monstera", species: "M. deliciosa", notes: "", icon: "leaf")
        let reloaded = JournalStore(rootURL: root)

        XCTAssertEqual(reloaded.activePlants.map(\.nickname), ["Monstera"])
    }

    @MainActor
    func testStoreNormalizesCuttingTags() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = JournalStore(rootURL: root)
        store.createPlant(nickname: "Pothos", species: "", notes: "", icon: "leaf")
        let plant = try! XCTUnwrap(store.activePlants.first)

        store.createCutting(
            plantID: plant.id,
            name: "",
            method: "Stem",
            medium: "Water",
            location: "",
            tags: "Window, window, Fast",
            startedAt: Date(),
            initialNote: ""
        )

        XCTAssertEqual(store.cuttings(for: plant.id).first?.name, "Cutting 1")
        XCTAssertEqual(store.cuttings(for: plant.id).first?.tags, ["fast", "window"])
    }

    @MainActor
    func testStoreRejectsBackwardStageAndConflictingOutcome() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = JournalStore(rootURL: root)
        store.createPlant(nickname: "Pothos", species: "", notes: "", icon: "leaf")
        let plant = try! XCTUnwrap(store.activePlants.first)
        store.createCutting(
            plantID: plant.id,
            name: "Cutting",
            method: "Stem",
            medium: "Water",
            location: "",
            tags: "",
            startedAt: Date(),
            initialNote: ""
        )
        let cutting = try! XCTUnwrap(store.cuttings(for: plant.id).first)

        store.changeStage(for: cutting.id, to: .rooting)
        store.changeStage(for: cutting.id, to: .started)
        XCTAssertEqual(store.library.state(for: cutting.id).stage, .rooting)

        store.recordOutcome(for: cutting.id, outcome: .potted)
        store.recordOutcome(for: cutting.id, outcome: .unsuccessful)
        XCTAssertEqual(store.library.state(for: cutting.id).outcome, .potted)
    }

    @MainActor
    func testCorruptLibraryIsPreservedAndBlocksWrites() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: root) }
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        let libraryURL = root.appendingPathComponent("library.json")
        let corruptData = Data("not json".utf8)
        try corruptData.write(to: libraryURL)

        let store = JournalStore(rootURL: root)
        store.createPlant(nickname: "Must not save", species: "", notes: "", icon: "leaf")

        XCTAssertTrue(store.activePlants.isEmpty)
        XCTAssertEqual(try Data(contentsOf: libraryURL), corruptData)
        XCTAssertNotNil(store.errorMessage)
    }
}
