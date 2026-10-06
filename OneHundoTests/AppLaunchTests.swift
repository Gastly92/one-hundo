import SwiftData
import XCTest
@testable import OneHundo

@MainActor
final class AppLaunchTests: XCTestCase {
    private struct StoreUnavailable: Error {}

    private func inMemoryStore(_: Bool) throws -> ModelContainer {
        try AppStore.makeContainer(inMemory: true)
    }

    func testNormalLaunchOpensStoreWithoutSampleData() throws {
        var askedInMemory: Bool?
        let launch = AppLaunch(arguments: ["OneHundo"]) { inMemory in
            askedInMemory = inMemory
            return try self.inMemoryStore(inMemory)
        }
        XCTAssertFalse(launch.isUITesting)
        XCTAssertEqual(askedInMemory, false)
        let container = try launch.store.get()
        XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Challenge>()), 0)
    }

    func testUITestingUsesInMemoryStore() throws {
        var askedInMemory: Bool?
        let launch = AppLaunch(arguments: ["-uiTesting"]) { inMemory in
            askedInMemory = inMemory
            return try self.inMemoryStore(inMemory)
        }
        XCTAssertTrue(launch.isUITesting)
        XCTAssertEqual(askedInMemory, true)
        let container = try launch.store.get()
        XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Challenge>()), 0)
    }

    func testSampleDataIsSeededOnlyForUITests() throws {
        let seeded = AppLaunch(
            arguments: ["-uiTesting", "-seedSampleData"],
            makeContainer: inMemoryStore
        )
        let seededContext = try seeded.store.get().mainContext
        XCTAssertEqual(try seededContext.fetchCount(FetchDescriptor<Challenge>()), 3)

        // -seedSampleData alone is ignored, so it can never touch real data.
        let real = AppLaunch(arguments: ["-seedSampleData"], makeContainer: inMemoryStore)
        XCTAssertEqual(try real.store.get().mainContext.fetchCount(FetchDescriptor<Challenge>()), 0)
    }

    func testStoreFailureIsReportedNotFatal() {
        let launch = AppLaunch(arguments: ["-uiTesting", "-seedSampleData"]) { _ in
            throw StoreUnavailable()
        }
        guard case .failure(let error) = launch.store else {
            return XCTFail("Expected the store to fail")
        }
        XCTAssertTrue(error is StoreUnavailable)
    }

    func testDefaultStoreOpens() throws {
        XCTAssertNoThrow(try AppStore.makeContainer(inMemory: true))
    }
}
