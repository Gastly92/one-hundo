@testable import OneHundo
import SwiftData
import XCTest

/// UTC, so dates don't depend on the test
/// machine's time zone.
let utc: Calendar = {
  var cal = Calendar(identifier: .gregorian)
  cal.timeZone = .gmt
  return cal
}()

/// Noon (or `hour`) on the given day of
/// January 2026, UTC.
func day(_ day: Int, hour: Int = 12) -> Date {
  // Jan 1 2026, 00:00 UTC.
  let start: TimeInterval = 1_767_225_600
  let hours = (day - 1) * 24 + hour
  return Date(
    timeIntervalSince1970:
      start + TimeInterval(hours * 3600)
  )
}

/// Shorthands for tests: the logic on a
/// January 2026 day, in UTC.
extension Challenge {
  @discardableResult
  func log(
    _ count: Int,
    day number: Int,
    hour: Int = 12
  ) -> Attempt {
    let date = day(number, hour: hour)
    return logAttempt(
      count: count, on: date, in: utc
    )
  }

  @discardableResult
  func record(
    _ count: Int,
    day number: Int,
    hour: Int = 12
  ) -> LogOutcome {
    let date = day(number, hour: hour)
    return recordAttempt(
      count: count, on: date, in: utc
    )
  }

  func target(
    day number: Int, hour: Int = 12
  ) -> Int {
    let date = day(number, hour: hour)
    return target(on: date, in: utc)
  }

  func todayText(day number: Int) -> String {
    todayText(on: day(number), in: utc)
  }

  func attempt(day number: Int) -> Attempt? {
    attempt(on: day(number), in: utc)
  }

  func logButtonTitle(
    day number: Int
  ) -> String {
    logButtonTitle(on: day(number), in: utc)
  }

  func replacementNote(
    day number: Int, hour: Int = 12
  ) -> String? {
    let date = day(number, hour: hour)
    return replacementNote(on: date, in: utc)
  }
}

/// An in-memory store for one test, with a
/// Push-ups challenge factory. Each test
/// makes its own, so nothing is shared.
@MainActor
struct TestStore {
  let container: ModelContainer

  var context: ModelContext {
    container.mainContext
  }

  init() throws {
    container = try AppStore.open(
      inMemory: true
    )
  }

  func pushUps(
    start: Int = 5,
    goal: Int = 100,
    increase: Int = 1
  ) -> Challenge {
    let challenge = Challenge(
      name: "Push-ups",
      colorName: BuiltIn.pushUps.colorName,
      startingCount: start,
      kind: BuiltIn.pushUps.id,
      goal: goal,
      dailyIncrease: increase,
      createdDate: day(1)
    )
    context.insert(challenge)
    return challenge
  }
}
