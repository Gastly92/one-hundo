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

    func testPlanGoesFromVersionOneToTwo() {
        XCTAssertEqual(DataSchemaV1.versionIdentifier, Schema.Version(1, 0, 0))
        XCTAssertEqual(DataSchemaV2.versionIdentifier, Schema.Version(2, 0, 0))
        XCTAssertEqual(DataMigrationPlan.schemas.count, 2)
        XCTAssertEqual(DataMigrationPlan.stages.count, 1)
        let names = Schema(versionedSchema: DataSchemaV2.self).entities.map(\.name).sorted()
        XCTAssertEqual(names, ["Attempt", "Challenge"])
        let fields = Schema(versionedSchema: DataSchemaV2.self).entities
            .first { $0.name == "Challenge" }?.attributes.map(\.name) ?? []
        XCTAssertFalse(fields.contains("icon"))
    }

    /// Data saved by 0.4 (version 1, with `icon`, no version info in the store) opens
    /// with this build, with nothing lost.
    func testStoreFromVersionOneOpens() throws {
        try autoreleasepool {
            // How 0.4 opened its store: the models directly, no migration plan.
            let old = try ModelContainer(
                for: DataSchemaV1.Challenge.self, DataSchemaV1.Attempt.self,
                configurations: ModelConfiguration(url: storeURL)
            )
            let challenge = DataSchemaV1.Challenge()
            challenge.kind = "pushups"
            challenge.name = "Push-ups"
            challenge.icon = "figure.strengthtraining.functional"
            challenge.startingCount = 5
            old.mainContext.insert(challenge)
            let attempt = DataSchemaV1.Attempt()
            attempt.count = 7
            challenge.attempts?.append(attempt)
            try old.mainContext.save()
        }

        let container = try AppStore.makeContainer(
            configuration: ModelConfiguration(url: storeURL)
        )
        let challenges = try container.mainContext.fetch(FetchDescriptor<Challenge>())
        XCTAssertEqual(challenges.map(\.name), ["Push-ups"])
        XCTAssertEqual(challenges.first?.kind, "pushups")
        XCTAssertEqual(challenges.first?.startingCount, 5)
        XCTAssertEqual(challenges.first?.allAttempts.map(\.count), [7])
    }

    /// A store already at version 2 opens again (the usual launch).
    func testStoreAtVersionTwoReopens() throws {
        try autoreleasepool {
            let first = try AppStore.makeContainer(
                configuration: ModelConfiguration(url: storeURL)
            )
            first.mainContext.insert(
                Challenge(kind: "situps", name: "Sit-ups", colorName: "blue", startingCount: 10)
            )
            try first.mainContext.save()
        }
        let again = try AppStore.makeContainer(configuration: ModelConfiguration(url: storeURL))
        let names = try again.mainContext.fetch(FetchDescriptor<Challenge>()).map(\.name)
        XCTAssertEqual(names, ["Sit-ups"])
    }
}
