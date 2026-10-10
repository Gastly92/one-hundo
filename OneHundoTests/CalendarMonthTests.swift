@testable import OneHundo
import XCTest

/// The Calendar tab's months and days.
@MainActor
final class CalendarMonthTests: XCTestCase {
  /// January 2026, UTC (weeks start on
  /// Sunday).
  private let january = CalendarMonth(
    containing: day(15), in: utc
  )

  func testDaysAndFirstWeekday() {
    XCTAssertEqual(
      january.start, day(1, hour: 0)
    )
    let days = january.days
    XCTAssertEqual(days.count, 31)
    XCTAssertEqual(
      days.last, day(31, hour: 0)
    )
    // Jan 1 2026 is a Thursday: 4 blanks.
    XCTAssertEqual(january.leadingBlanks, 4)
    // Blanks, days, then blanks to six
    // weeks; each its own cell.
    let slots = january.slots
    XCTAssertEqual(slots.count, 42)
    XCTAssertEqual(slots[3], .blank(3))
    XCTAssertEqual(
      slots[4], .day(day(1, hour: 0))
    )
    XCTAssertEqual(slots[35], .blank(35))
    XCTAssertEqual(Set(slots).count, 42)
    // February 2026 starts on a Sunday.
    let february = january.adding(1)
    XCTAssertEqual(february.slots.count, 42)
    XCTAssertEqual(
      january.adding(1).days.count, 28
    )
  }

  func testWeekStartsOnFirstWeekday() {
    XCTAssertEqual(
      january.weekdays,
      ["S", "M", "T", "W", "T", "F", "S"]
    )
    var monday = utc
    monday.firstWeekday = 2
    let month = CalendarMonth(
      containing: day(15), in: monday
    )
    XCTAssertEqual(month.weekdays.first, "M")
    XCTAssertEqual(month.weekdays.last, "S")
    // Thursday is 3 days after Monday.
    XCTAssertEqual(month.leadingBlanks, 3)
  }

  func testStopsAtCurrentMonth() {
    let now = day(20)
    XCTAssertTrue(january.isLatest(now: now))
    let december = january.adding(-1)
    XCTAssertFalse(
      december.isLatest(now: now)
    )
  }

  func testSwipes() {
    let now = day(20)
    // Right: the month before.
    XCTAssertEqual(
      january.swiped(by: 80, now: now),
      january.adding(-1)
    )
    // Left stops at now's month.
    XCTAssertEqual(
      january.swiped(by: -80, now: now),
      january
    )
    let december = january.adding(-1)
    XCTAssertEqual(
      december.swiped(by: -80, now: now),
      january
    )
    // Short swipes stay.
    XCTAssertEqual(
      december.swiped(by: 20, now: now),
      december
    )
  }

  func testDayEntries() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.log(5, day: 1)
    pushUps.log(6, day: 2)
    pushUps.log(4, day: 4)
    let start = try XCTUnwrap(
      pushUps.entry(on: day(1), in: utc)
    )
    XCTAssertTrue(start.isTest)
    XCTAssertFalse(start.hitTarget)
    XCTAssertEqual(
      start.status, "Started this challenge"
    )

    let hit = try XCTUnwrap(
      pushUps.entry(on: day(2), in: utc)
    )
    XCTAssertTrue(hit.hitTarget)
    XCTAssertEqual(
      hit.status, "Hit the target of 6."
    )

    // Day 3 was missed; day 4 fell short.
    XCTAssertNil(
      pushUps.entry(on: day(3), in: utc)
    )
    let short = try XCTUnwrap(
      pushUps.entry(on: day(4), in: utc)
    )
    XCTAssertEqual(short.count, 4)
    XCTAssertFalse(short.hitTarget)
    XCTAssertEqual(
      short.status, "The target was 7."
    )
    XCTAssertEqual(short.id, pushUps.id)
  }

  func testEntriesForADay() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    let plank = store.pushUps(start: 30)
    plank.unit = .seconds
    pushUps.log(5, day: 1)
    plank.log(35, day: 2)
    let entries = CalendarLog.entries(
      for: [pushUps, plank],
      on: day(2),
      in: utc
    )
    XCTAssertEqual(
      entries.map(\.challenge.id), [plank.id]
    )
    XCTAssertEqual(
      entries.first?.status, """
        Hit the target of 31 seconds.
        """
    )
  }

  func testEmptyMonth() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    XCTAssertTrue(
      CalendarLog.isEmpty(
        january, for: [], in: utc
      )
    )
    pushUps.log(5, day: 1)
    XCTAssertFalse(
      CalendarLog.isEmpty(
        january, for: [pushUps], in: utc
      )
    )
    XCTAssertTrue(
      CalendarLog.isEmpty(
        january.adding(1),
        for: [pushUps],
        in: utc
      )
    )
  }

  /// A day keeps the target it had when it
  /// was logged, after the step changes.
  func testDayKeepsItsTarget() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.log(5, day: 1)
    pushUps.log(6, day: 2)
    pushUps.dailyIncrease = 5
    let entry = try XCTUnwrap(
      pushUps.entry(on: day(2), in: utc)
    )
    XCTAssertEqual(entry.target, 6)
    XCTAssertTrue(entry.hitTarget)
    // Logging it again uses the day's
    // target now.
    pushUps.log(7, day: 2)
    XCTAssertEqual(
      pushUps.attempt(on: day(2), in: utc)?
        .target,
      10
    )
  }
}
