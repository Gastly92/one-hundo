import SwiftData
import XCTest
@testable import OneHundo

@MainActor
final class AppLaunchTests: XCTestCase {
  private struct StoreDown: Error {}

  private func memory(
    _: Bool
  ) throws -> ModelContainer {
    try AppStore.open(inMemory: true)
  }

  /// A launch with an in-memory store.
  private func start(
    _ args: [String]
  ) -> AppLaunch {
    AppLaunch(arguments: args, open: memory)
  }

  /// How many challenges the launch's store
  /// holds.
  private func count(
    _ launch: AppLaunch
  ) throws -> Int {
    let store = try launch.store.get()
    return try store.mainContext.fetchCount(
      FetchDescriptor<Challenge>()
    )
  }

  func testNormalLaunchIsEmpty() throws {
    var asked: Bool?
    let launch = AppLaunch(
      arguments: ["OneHundo"]
    ) {
      asked = $0
      return try self.memory($0)
    }
    XCTAssertFalse(launch.isUITesting)
    XCTAssertEqual(asked, false)
    XCTAssertEqual(try count(launch), 0)
  }

  func testUITestingIsInMemory() throws {
    var asked: Bool?
    let launch = AppLaunch(
      arguments: ["-uiTesting"]
    ) {
      asked = $0
      return try self.memory($0)
    }
    XCTAssertTrue(launch.isUITesting)
    XCTAssertEqual(asked, true)
    XCTAssertEqual(try count(launch), 0)
  }

  func testSampleDataOnlyInUITests() throws {
    let seeded = start(
      ["-uiTesting", "-seedSampleData"]
    )
    XCTAssertEqual(try count(seeded), 3)

    // -seedSampleData alone is ignored, so it
    // can never touch real data.
    let real = start(["-seedSampleData"])
    XCTAssertEqual(try count(real), 0)
  }

  func testStoreFailureIsNotFatal() {
    let launch = AppLaunch(
      arguments: [
        "-uiTesting", "-seedSampleData",
      ]
    ) { _ in
      throw StoreDown()
    }
    XCTAssertThrowsError(
      try launch.store.get()
    ) { XCTAssertTrue($0 is StoreDown) }
  }

  func testShowScreenWithItsData() throws {
    let detail = start([
      "-uiTesting",
      "-showScreen", "challengeDetail",
    ])
    XCTAssertEqual(
      detail.screen, .challengeDetail
    )
    // Screens that show challenges get the
    // sample data; the rest start empty.
    XCTAssertEqual(try count(detail), 3)

    let welcome = start(
      ["-uiTesting", "-showScreen", "welcome"]
    )
    XCTAssertEqual(welcome.screen, .welcome)
    XCTAssertEqual(try count(welcome), 0)
  }

  func testShowScreenNeedsUITesting() {
    let cases: [[String]] = [
      // Never outside UI tests.
      ["-showScreen", "welcome"],
      ["-uiTesting", "-showScreen", "nope"],
      // No screen name after the flag.
      ["-uiTesting", "-showScreen"],
      ["-uiTesting"],
    ]
    for args in cases {
      let screen = start(args).screen
      XCTAssertNil(screen, "\(args)")
    }
  }

  func testDefaultStoreOpens() throws {
    XCTAssertNoThrow(
      try AppStore.open(inMemory: true)
    )
  }
}
