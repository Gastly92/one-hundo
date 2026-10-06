import SwiftData
import XCTest
@testable import OneHundo

/// Targets, progress, card text, and stats.
final class ChallengeTests: ModelTestCase {
  func testTargetStartsFromTest() {
    let pushUps = makePushUps()
    XCTAssertEqual(pushUps.target(day: 1), 6)
    XCTAssertEqual(pushUps.currentCount, 5)
  }

  func testTargetAfterNormalDay() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    pushUps.log(6, day: 2)
    XCTAssertEqual(pushUps.target(day: 3), 7)
  }

  func testTargetAfterShortDay() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    XCTAssertEqual(pushUps.target(day: 2), 6)
    pushUps.log(4, day: 2)
    XCTAssertEqual(pushUps.target(day: 3), 5)
  }

  func testMissedDaysDoNotChangeTarget() {
    let pushUps = makePushUps()
    pushUps.log(6, day: 2)
    XCTAssertEqual(pushUps.target(day: 3), 7)
    XCTAssertEqual(pushUps.target(day: 10), 7)
  }

  func testLoggingTodayKeepsTodaysTarget() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    pushUps.log(6, day: 2, hour: 8)
    let evening = pushUps.target(
      day: 2, hour: 20
    )
    XCTAssertEqual(evening, 6)
    XCTAssertEqual(pushUps.target(day: 3), 7)
  }

  func testTargetIsCappedAtGoal() {
    let pushUps = makePushUps(
      start: 95, increase: 10
    )
    let target = pushUps.target(day: 1)
    XCTAssertEqual(target, 100)
  }

  func testLoggingSameDayReplacesAttempt() {
    let pushUps = makePushUps()
    pushUps.log(6, day: 2, hour: 9)
    pushUps.log(8, day: 2, hour: 18)
    XCTAssertEqual(pushUps.attempts?.count, 1)
    let day2 = pushUps.attempt(day: 2)
    XCTAssertEqual(day2?.count, 8)
    XCTAssertEqual(pushUps.currentCount, 8)
  }

  func testProgressAndDaysToGoal() {
    let pushUps = makePushUps()
    XCTAssertEqual(pushUps.daysToGoal, 95)
    pushUps.log(20, day: 2)
    XCTAssertEqual(
      pushUps.progress, 0.2, accuracy: 0.0001
    )
    XCTAssertEqual(pushUps.daysToGoal, 80)
    XCTAssertFalse(pushUps.isGoalReached)
    pushUps.log(100, day: 3)
    XCTAssertTrue(pushUps.isGoalReached)
  }

  func testAttemptsSavedNewestFirst() throws {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    pushUps.log(6, day: 2)
    try context.save()
    let all = FetchDescriptor<Attempt>()
    let saved = try context.fetch(all)
    XCTAssertEqual(saved.count, 2)
    let counts = pushUps.sortedAttempts
      .map(\.count)
    XCTAssertEqual(counts, [6, 5])
  }

  func testCardTextTryAndDone() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    XCTAssertEqual(
      pushUps.todayText(day: 2), "Try 6 today"
    )
    pushUps.log(6, day: 2)
    XCTAssertEqual(
      pushUps.todayText(day: 2), "Done: 6"
    )
    XCTAssertEqual(
      pushUps.progressText, "6 / 100"
    )
  }

  func testStartDayIsDone() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    XCTAssertEqual(
      pushUps.todayText(day: 1), "Done: 5"
    )
    XCTAssertEqual(
      pushUps.todayText(day: 2), "Try 6 today"
    )

    // Logging again on the start day replaces
    // the test.
    pushUps.log(6, day: 1, hour: 18)
    XCTAssertEqual(
      pushUps.todayText(day: 1), "Done: 6"
    )
    XCTAssertEqual(pushUps.target(day: 2), 7)
  }

  func testCardTextUsesUnit() {
    let plank = makePushUps(start: 45)
    plank.unit = .seconds
    XCTAssertEqual(
      plank.todayText(day: 2),
      "Try 46 seconds today"
    )
    XCTAssertEqual(
      CountUnit.minutes.format(1), "1 minute"
    )
    XCTAssertEqual(
      CountUnit.reps.format(12), "12"
    )
  }

  func testBuiltInLookupAndUnit() {
    let pushUps = makePushUps()
    XCTAssertEqual(
      pushUps.builtIn?.name, "Push-ups"
    )
    XCTAssertFalse(pushUps.isCustom)
    XCTAssertEqual(pushUps.unit, .reps)
    pushUps.unit = .seconds
    XCTAssertEqual(pushUps.unitRaw, "seconds")
    XCTAssertEqual(
      BuiltIn.all.map(\.id),
      ["pushups", "situps", "pullups"]
    )
  }

  func testBestIncludesStartingTest() {
    let pushUps = makePushUps()
    XCTAssertEqual(pushUps.personalBest, 5)
    pushUps.log(5, day: 1)
    pushUps.log(9, day: 2)
    pushUps.log(7, day: 3)
    XCTAssertEqual(pushUps.personalBest, 9)
  }

  func testDaysLoggedCountsDistinctDays() {
    let pushUps = makePushUps()
    XCTAssertEqual(daysLogged(pushUps), 0)
    pushUps.log(5, day: 1)
    pushUps.log(6, day: 2, hour: 8)
    pushUps.log(7, day: 2, hour: 20)
    pushUps.log(7, day: 5)
    XCTAssertEqual(daysLogged(pushUps), 3)
  }

  func testUnitFormatting() {
    let reps = CountUnit.reps
    let secs = CountUnit.seconds
    let mins = CountUnit.minutes
    XCTAssertEqual(reps.format(1), "1")
    XCTAssertEqual(secs.format(1), "1 second")
    XCTAssertEqual(
      secs.format(45), "45 seconds"
    )
    XCTAssertEqual(mins.format(1), "1 minute")
    XCTAssertEqual(
      mins.format(3), "3 minutes"
    )
  }

  func testNilAttemptsCountAsNone() {
    let pushUps = makePushUps()
    pushUps.attempts = nil
    XCTAssertTrue(pushUps.allAttempts.isEmpty)
    XCTAssertEqual(pushUps.currentCount, 5)
    XCTAssertEqual(daysLogged(pushUps), 0)
  }

  func testUnknownUnitIsReps() {
    let pushUps = makePushUps()
    pushUps.unitRaw = "laps"
    XCTAssertEqual(pushUps.unit, .reps)
  }

  private func daysLogged(
    _ challenge: Challenge
  ) -> Int {
    challenge.daysLogged(in: utc)
  }
}
