import SwiftData
import XCTest
@testable import OneHundo

@MainActor
final class DataSchemaTests: XCTestCase {
    private var storeURL: URL!

    override func setUp() async throws {
        storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("test.store")
        try? FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
    }

    func testPlanStartsAtVersionOne() {
        XCTAssertEqual(DataSchemaV1.versionIdentifier, Schema.Version(1, 0, 0))
        XCTAssertEqual(DataMigrationPlan.schemas.count, 1)
        XCTAssertTrue(DataMigrationPlan.stages.isEmpty)
        let names = Schema(versionedSchema: DataSchemaV1.self).entities.map(\.name).sorted()
        XCTAssertEqual(names, ["Attempt", "Challenge"])
    }

    /// Data saved by 0.4 (no version info in the store) still opens, with nothing lost.
    func testStoreFromBeforeVersioningOpens() throws {
        try autoreleasepool {
            let old = try ModelContainer(
                for: Challenge.self, Attempt.self,
                configurations: ModelConfiguration(url: storeURL)
            )
            let challenge = Challenge(
                kind: "pushups", name: "Push-ups", colorName: "orange", startingCount: 5
            )
            old.mainContext.insert(challenge)
            challenge.attempts?.append(Attempt(date: Date(), count: 7))
            try old.mainContext.save()
        }

        let container = try AppStore.makeContainer(
            configuration: ModelConfiguration(url: storeURL)
        )
        let challenges = try container.mainContext.fetch(FetchDescriptor<Challenge>())
        XCTAssertEqual(challenges.map(\.name), ["Push-ups"])
        XCTAssertEqual(challenges.first?.allAttempts.map(\.count), [7])
    }
}
