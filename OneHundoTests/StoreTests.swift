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
        createdDate: day(1),
        in: utc
      )
      old.mainContext.insert(pushUps)
      pushUps.attempts = [
        SchemaV1.Attempt(
          date: day(2),
          count: 6,
          target: 6,
          in: utc
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

  /// Migrating 1.0 data tags every record
  /// with its own `copyID` (`Duplicates`),
  /// and leaves `loggedAt` empty.
  func testVersion1DataGetsTags() throws {
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
      for name in ["Push-ups", "Squats"] {
        let challenge = SchemaV1.Challenge(
          name: name,
          colorName: "violet",
          startingCount: 5,
          in: utc
        )
        old.mainContext.insert(challenge)
        challenge.attempts = [1, 2].map {
          SchemaV1.Attempt(
            date: day($0),
            count: 6,
            target: 6,
            in: utc
          )
        }
      }
      try old.mainContext.save()
    }

    // Kept: a context outlives its store
    // only by crashing.
    let store = try AppStore.open(
      ModelConfiguration(url: url)
    )
    let context = store.mainContext
    let challenges = try context.fetch(
      FetchDescriptor<Challenge>()
    )
    let attempts = try context.fetch(
      FetchDescriptor<Attempt>()
    )
    let tags =
      challenges.compactMap(\.copyID)
      + attempts.compactMap(\.copyID)
    XCTAssertEqual(tags.count, 6)
    XCTAssertEqual(Set(tags).count, 6)
    // No log time to make up: merging
    // falls back to each attempt's date.
    let untimed = attempts.allSatisfy {
      $0.loggedAt == nil
    }
    XCTAssertTrue(untimed)
  }

  /// Opening the store merges copies (here
  /// two of one challenge).
  func testOpeningMergesCopies() throws {
    defer { removeStore() }
    try autoreleasepool {
      let store = try ModelContainer(
        for: Schema(
          versionedSchema: SchemaV2.self
        ),
        configurations: ModelConfiguration(
          url: url
        )
      )
      let first = Challenge(
        name: "Push-ups",
        colorName: "violet",
        startingCount: 5,
        in: utc
      )
      let second = Challenge(
        name: "Push-ups",
        colorName: "violet",
        startingCount: 5,
        in: utc
      )
      second.id = first.id
      store.mainContext.insert(first)
      store.mainContext.insert(second)
      try store.mainContext.save()
    }

    let store = try AppStore.open(
      ModelConfiguration(url: url)
    )
    let all = FetchDescriptor<Challenge>()
    let count = try store.mainContext
      .fetchCount(all)
    XCTAssertEqual(count, 1)
  }

  /// 1.0's schema, then 1.1's with tags,
  /// one step between them.
  func testPlanVersions() {
    XCTAssertEqual(
      SchemaV1.versionIdentifier,
      Schema.Version(1, 0, 0)
    )
    XCTAssertEqual(
      SchemaV2.versionIdentifier,
      Schema.Version(2, 0, 0)
    )
    XCTAssertEqual(
      Migrations.schemas.count, 2
    )
    XCTAssertEqual(
      Migrations.stages.count, 1
    )
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
