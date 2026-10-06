import SwiftData
import XCTest
@testable import OneHundo

/// UTC, so dates don't depend on the test
/// machine's time zone.
let utc: Calendar = {
  var cal = Calendar(identifier: .gregorian)
  cal.timeZone = TimeZone(identifier: "UTC")!
  return cal
}()

/// Noon (or `hour`) on the given day of
/// January 2026, UTC.
func day(_ day: Int, hour: Int = 12) -> Date {
  utc.date(
    from: DateComponents(
      year: 2026, month: 1,
      day: day, hour: hour
    )
  )!
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

/// Shared setup for challenge tests: an
/// in-memory store and a Push-ups challenge
/// factory.
@MainActor
class ModelTestCase: XCTestCase {
  var container: ModelContainer!
  var context: ModelContext {
    container.mainContext
  }

  override func setUp() async throws {
    container = try AppStore.open(
      inMemory: true
    )
  }

  override func tearDown() async throws {
    container = nil
  }

  func makePushUps(
    start: Int = 5,
    goal: Int = 100,
    increase: Int = 1
  ) -> Challenge {
    let challenge = Challenge(
      kind: BuiltIn.pushUps.id,
      name: "Push-ups",
      colorName: BuiltIn.pushUps.colorName,
      startingCount: start,
      goal: goal,
      dailyIncrease: increase,
      createdDate: day(1)
    )
    context.insert(challenge)
    return challenge
  }
}
