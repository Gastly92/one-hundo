@testable import OneHundo
import SwiftData
import XCTest

/// Stored data survives app updates.
@MainActor
final class StoreTests: XCTestCase {
  /// A store file of this test's own.
  private let url = URL.temporaryDirectory
    .appending(path: UUID().uuidString)

  /// A store the 1.0 release wrote (models
  /// frozen in `SchemaV1`) opens in this
  /// version, through its migrations, with
  /// nothing lost. Keep this test as later
  /// versions add schemas.
  func testVersion1StoreOpens() throws {
    defer { removeStore() }
    try autoreleasepool {
      let old = try ModelContainer(
        for: Schema(
          versionedSchema: SchemaV1.self
        ),
        configurations: ModelConfiguration(
          url: url
        )
      )
      let pushUps = SchemaV1.Challenge(
        name: "Push-ups",
        colorName: "violet",
        startingCount: 5,
        createdDate: day(1)
      )
      old.mainContext.insert(pushUps)
      pushUps.attempts = [
        SchemaV1.Attempt(
          date: day(2), count: 6
        ),
      ]
      try old.mainContext.save()
    }

    let store = try AppStore.open(
      ModelConfiguration(url: url)
    )
    let all = try store.mainContext.fetch(
      FetchDescriptor<Challenge>()
    )
    XCTAssertEqual(
      all.map(\.name), ["Push-ups"]
    )
    let attempts = all.first?.attempts ?? []
    XCTAssertEqual(
      attempts.map(\.count), [6]
    )
    XCTAssertEqual(
      attempts.first?.date, day(2)
    )
  }

  /// The plan starts at 1.0, with nothing
  /// to migrate yet.
  func testPlanStartsAtVersion1() {
    XCTAssertEqual(
      SchemaV1.versionIdentifier,
      Schema.Version(1, 0, 0)
    )
    XCTAssertEqual(
      Migrations.schemas.count, 1
    )
    XCTAssertTrue(Migrations.stages.isEmpty)
  }

  /// The store and SQLite's side files.
  private func removeStore() {
    for end in ["", "-shm", "-wal"] {
      let file = URL(
        fileURLWithPath: url.path() + end
      )
      try? FileManager.default
        .removeItem(at: file)
    }
  }
}
