import SwiftData
import XCTest
@testable import OneHundo

@MainActor
final class AppLaunchTests: XCTestCase {
    private struct StoreUnavailable: Error {}

    private func memoryStore(
        _: Bool
    ) throws -> ModelContainer {
        try AppStore.open(inMemory: true)
    }

    /// A launch with an in-memory store.
    private func start(_ args: [String]) -> AppLaunch {
        AppLaunch(arguments: args, openStore: memoryStore)
    }

    /// How many challenges the launch's store holds.
    private func challenges(
        in launch: AppLaunch
    ) throws -> Int {
        let context = try launch.store.get().mainContext
        return try context.fetchCount(
            FetchDescriptor<Challenge>()
        )
    }

    func testNormalLaunchHasNoSampleData() throws {
        var askedInMemory: Bool?
        let launch = AppLaunch(arguments: ["OneHundo"]) {
            askedInMemory = $0
            return try self.memoryStore($0)
        }
        XCTAssertFalse(launch.isUITesting)
        XCTAssertEqual(askedInMemory, false)
        XCTAssertEqual(try challenges(in: launch), 0)
    }

    func testUITestingUsesInMemoryStore() throws {
        var askedInMemory: Bool?
        let launch = AppLaunch(arguments: ["-uiTesting"]) {
            askedInMemory = $0
            return try self.memoryStore($0)
        }
        XCTAssertTrue(launch.isUITesting)
        XCTAssertEqual(askedInMemory, true)
        XCTAssertEqual(try challenges(in: launch), 0)
    }

    func testSampleDataIsSeededOnlyForUITests() throws {
        let seeded = start(
            ["-uiTesting", "-seedSampleData"]
        )
        XCTAssertEqual(try challenges(in: seeded), 3)

        // -seedSampleData alone is ignored, so it can never
        // touch real data.
        let real = start(["-seedSampleData"])
        XCTAssertEqual(try challenges(in: real), 0)
    }

    func testStoreFailureIsReportedNotFatal() {
        let args = ["-uiTesting", "-seedSampleData"]
        let launch = AppLaunch(arguments: args) { _ in
            throw StoreUnavailable()
        }
        guard case .failure(let error) = launch.store else {
            return XCTFail("Expected the store to fail")
        }
        XCTAssertTrue(error is StoreUnavailable)
    }

    func testShowScreenOpensOneScreenWithItsData() throws {
        let detail = start(
            ["-uiTesting", "-showScreen", "challengeDetail"]
        )
        XCTAssertEqual(detail.screen, .challengeDetail)
        // Screens that show challenges get the sample data;
        // the rest start empty.
        XCTAssertEqual(try challenges(in: detail), 3)

        let welcome = start(
            ["-uiTesting", "-showScreen", "welcome"]
        )
        XCTAssertEqual(welcome.screen, .welcome)
        XCTAssertEqual(try challenges(in: welcome), 0)
    }

    func testShowScreenNeedsUITestingAndAKnownScreen() {
        let cases: [[String]] = [
            // Never outside UI tests.
            ["-showScreen", "welcome"],
            ["-uiTesting", "-showScreen", "noSuchScreen"],
            // No screen name after the flag.
            ["-uiTesting", "-showScreen"],
            ["-uiTesting"],
        ]
        for args in cases {
            XCTAssertNil(start(args).screen, "\(args)")
        }
    }

    func testDefaultStoreOpens() throws {
        XCTAssertNoThrow(try AppStore.open(inMemory: true))
    }
}
