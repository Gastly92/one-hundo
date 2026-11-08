@testable import OneHundo
import SwiftData
import XCTest

/// Merging the copies iCloud sync can bring
/// back (`Duplicates`).
@MainActor
final class DuplicatesTests: XCTestCase {
  /// Two copies of one challenge become
  /// one, the lowest tag's, with both
  /// copies' days.
  func testChallengeCopiesMerge() throws {
    let store = try TestStore()
    let first = store.pushUps()
    first.log(6, day: 2)
    let second = copy(of: first, in: store)
    second.log(7, day: 3)
    let low = try lowestTag(first, second)

    try Duplicates.merge(in: store.context)

    let left = try challenges(in: store)
    XCTAssertEqual(left.count, 1)
    let kept = try XCTUnwrap(left.first)
    XCTAssertEqual(
      kept.copyID?.uuidString, low
    )
    let days = kept.oldestFirst.map(\.day)
    let want = [2, 3].map {
      utc.day(of: day($0))
    }
    XCTAssertEqual(days, want)
    XCTAssertEqual(
      try attempts(in: store), 2
    )
  }

  /// Your phone logs 20 at 8 pm; at 9 pm
  /// the iPad edits the day to 25 (an edit
  /// is stored at noon). The edit wins:
  /// it was logged later.
  func testLaterEditWins() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    add(
      20,
      day: 2,
      to: pushUps,
      hour: 20,
      loggedAt: day(2, hour: 20)
    )
    add(
      25,
      day: 2,
      to: pushUps,
      loggedAt: day(2, hour: 21)
    )

    try Duplicates.merge(in: store.context)

    let left = pushUps.allAttempts
    XCTAssertEqual(left.map(\.count), [25])
    XCTAssertEqual(
      left.first?.loggedAt, day(2, hour: 21)
    )
  }

  /// Two 1.0 attempts on one day (no log
  /// time) become one: the lowest tag's,
  /// with the later moment's count.
  func testOldDataKeepsLaterMoment() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    let morning = add(
      6, day: 2, to: pushUps, hour: 8
    )
    let evening = add(
      8, day: 2, to: pushUps, hour: 20
    )
    let low = try lowestTag(morning, evening)

    try Duplicates.merge(in: store.context)

    let left = pushUps.allAttempts
    XCTAssertEqual(left.count, 1)
    let kept = try XCTUnwrap(left.first)
    XCTAssertEqual(
      kept.copyID?.uuidString, low
    )
    XCTAssertEqual(kept.count, 8)
    XCTAssertEqual(
      kept.date, day(2, hour: 20)
    )
    XCTAssertEqual(
      try attempts(in: store), 1
    )
  }

  /// Logged at the same moment: the higher
  /// count stays.
  func testSameMomentKeepsHigher() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    add(9, day: 2, to: pushUps)
    add(7, day: 2, to: pushUps)

    try Duplicates.merge(in: store.context)

    let counts = pushUps.allAttempts.map(
      \.count
    )
    XCTAssertEqual(counts, [9])
  }

  /// Copies of the same day from two copies
  /// of a challenge end up as one attempt.
  func testCopiesMergeTheirDays() throws {
    let store = try TestStore()
    let first = store.pushUps()
    first.log(6, day: 2)
    let second = copy(of: first, in: store)
    second.log(6, day: 2)

    try Duplicates.merge(in: store.context)

    let left = try challenges(in: store)
    XCTAssertEqual(left.count, 1)
    XCTAssertEqual(
      try attempts(in: store), 1
    )
  }

  /// Without a tag, or with a shared one,
  /// devices might keep different copies,
  /// so nothing merges.
  func testUntaggedCopiesStay() throws {
    let store = try TestStore()
    let first = store.pushUps()
    let second = copy(of: first, in: store)
    second.copyID = nil
    let pushUps = store.pushUps()
    let one = add(6, day: 2, to: pushUps)
    let two = add(7, day: 2, to: pushUps)
    two.copyID = one.copyID

    try Duplicates.merge(in: store.context)

    XCTAssertEqual(
      try challenges(in: store).count, 3
    )
    XCTAssertEqual(
      pushUps.allAttempts.count, 2
    )
  }

  /// Different challenges and different
  /// days are left alone.
  func testDistinctDataStays() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.log(6, day: 2)
    pushUps.log(7, day: 3)
    store.pushUps().log(5, day: 2)
    try store.context.save()

    try Duplicates.merge(in: store.context)

    XCTAssertFalse(store.context.hasChanges)
    XCTAssertEqual(
      try challenges(in: store).count, 2
    )
    XCTAssertEqual(
      try attempts(in: store), 3
    )
  }

  /// Logging stamps the time, and logging
  /// the day again moves it.
  func testLoggingStampsTime() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    let first = pushUps.logAttempt(
      count: 6,
      on: day(2),
      in: utc,
      at: day(2, hour: 20)
    )
    XCTAssertEqual(
      first.loggedAt, day(2, hour: 20)
    )
    let again = pushUps.logAttempt(
      count: 7,
      on: day(2),
      in: utc,
      at: day(3, hour: 9)
    )
    XCTAssertIdentical(again, first)
    XCTAssertEqual(
      first.loggedAt, day(3, hour: 9)
    )
  }

  /// A new copy of `challenge` (same `id`,
  /// its own tag), as another device's
  /// upload would bring.
  private func copy(
    of challenge: Challenge,
    in store: TestStore
  ) -> Challenge {
    let copy = store.pushUps()
    copy.id = challenge.id
    return copy
  }

  /// An attempt added as sync would add it,
  /// not through `logAttempt` (which keeps
  /// one per day).
  @discardableResult
  private func add(
    _ count: Int,
    day number: Int,
    to challenge: Challenge,
    hour: Int = 12,
    loggedAt: Date? = nil
  ) -> Attempt {
    let attempt = Attempt(
      date: day(number, hour: hour),
      count: count,
      target: count,
      in: utc
    )
    attempt.loggedAt = loggedAt
    challenge.modelContext?.insert(attempt)
    challenge.attempts =
      challenge.allAttempts + [attempt]
    return attempt
  }

  private func lowestTag(
    _ records: any Tagged...
  ) throws -> String? {
    let tags = try records.map {
      try XCTUnwrap($0.copyID?.uuidString)
    }
    return tags.min()
  }

  private func challenges(
    in store: TestStore
  ) throws -> [Challenge] {
    try store.context.fetch(
      FetchDescriptor<Challenge>()
    )
  }

  private func attempts(
    in store: TestStore
  ) throws -> Int {
    try store.context.fetchCount(
      FetchDescriptor<Attempt>()
    )
  }
}
