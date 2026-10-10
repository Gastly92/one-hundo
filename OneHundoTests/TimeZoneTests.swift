@testable import OneHundo
import XCTest

/// Days follow the phone's calendar: logging
/// either side of midnight, and on the days
/// clocks change for daylight saving (US
/// Pacific, 2026).
@MainActor
final class TimeZoneTests: XCTestCase {
  private let cal = {
    var pacific = Calendar(
      identifier: .gregorian
    )
    pacific.timeZone = TimeZone(
      identifier: "America/Los_Angeles"
    ) ?? .gmt
    return pacific
  }()

  /// A local time in 2026.
  private func at(
    _ month: Int,
    _ day: Int,
    _ hour: Int,
    _ minute: Int = 0
  ) throws -> Date {
    let parts = DateComponents(
      year: 2026,
      month: month,
      day: day,
      hour: hour,
      minute: minute
    )
    let date = cal.date(from: parts)
    return try XCTUnwrap(date)
  }

  /// Logs `count` at `date`, local time.
  private func log(
    _ count: Int,
    _ challenge: Challenge,
    _ date: Date
  ) {
    challenge.logAttempt(
      count: count, on: date, in: cal
    )
  }

  func testPacificTime() {
    XCTAssertEqual(
      cal.timeZone.identifier,
      "America/Los_Angeles"
    )
  }

  /// A minute before and after midnight are
  /// two days, and the later one's target
  /// builds on the earlier one.
  func testMidnightSplitsDays() throws {
    let store = try TestStore()
    let ups = store.pushUps()
    try log(6, ups, at(4, 6, 23, 59))
    try log(7, ups, at(4, 7, 0, 1))
    XCTAssertEqual(ups.allAttempts.count, 2)
    let noon = try at(4, 7, 12)
    XCTAssertEqual(
      ups.target(on: noon, in: cal), 7
    )
  }

  /// March 8: 2 a.m. jumps to 3 a.m. The day
  /// is still one day, between its
  /// neighbors.
  func testSpringForward() throws {
    let store = try TestStore()
    let ups = store.pushUps()
    try log(6, ups, at(3, 7, 23, 30))
    try log(7, ups, at(3, 8, 3, 30))
    try log(8, ups, at(3, 9, 0, 30))
    XCTAssertEqual(ups.allAttempts.count, 3)
    let noon = try at(3, 8, 12)
    XCTAssertEqual(
      ups.attempt(on: noon, in: cal)?.count,
      7
    )
    XCTAssertEqual(
      ups.target(on: noon, in: cal), 7
    )
  }

  /// November 1: 1 a.m. to 2 a.m. happens
  /// twice. Logging in both is still one
  /// day, so the second replaces the first.
  func testFallBack() throws {
    let store = try TestStore()
    let ups = store.pushUps()
    let first = try at(11, 1, 1, 30)
    let again = first + 3600
    XCTAssertEqual(
      cal.component(.hour, from: again), 1
    )
    log(6, ups, first)
    log(7, ups, again)
    XCTAssertEqual(
      ups.allAttempts.map(\.count), [7]
    )
    let next = try at(11, 2, 12)
    XCTAssertEqual(
      ups.target(on: next, in: cal), 8
    )
  }

  /// Logged late Monday in Los Angeles, then
  /// in New York, where that moment is
  /// already Tuesday: Monday's log stays
  /// Monday's, and Tuesday's is its own.
  func testTravelKeepsDays() throws {
    let store = try TestStore()
    let ups = store.pushUps()
    try log(6, ups, at(4, 6, 23, 30))
    var east = cal
    east.timeZone = TimeZone(
      identifier: "America/New_York"
    ) ?? .gmt
    let tuesday = try at(4, 7, 17)
    ups.logAttempt(
      count: 7, on: tuesday, in: east
    )
    XCTAssertEqual(
      ups.sortedAttempts.map(\.count),
      [7, 6]
    )
    let monday = east.noon(of: 20_260_406)
    XCTAssertEqual(
      ups.attempt(on: monday, in: east)?
        .count,
      6
    )
    XCTAssertEqual(ups.daysLogged, 2)
  }

  /// The start day is the day it started,
  /// where it started.
  func testStartDayStays() throws {
    let started = try at(4, 5, 23, 30)
    let ups = Challenge(
      name: "Push-ups",
      colorName: "violet",
      startingCount: 5,
      createdDate: started,
      in: cal
    )
    XCTAssertEqual(ups.startDay, 20_260_405)
  }

  /// A day number and its noon, both ways.
  func testDayNumbers() throws {
    let date = try at(12, 31, 23, 59)
    XCTAssertEqual(
      cal.day(of: date), 20_261_231
    )
    let noon = cal.noon(of: 20_261_231)
    XCTAssertEqual(
      cal.component(.hour, from: noon), 12
    )
    XCTAssertEqual(
      cal.day(of: noon), 20_261_231
    )
  }
}
