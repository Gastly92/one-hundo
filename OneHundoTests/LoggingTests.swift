@testable import OneHundo
import XCTest

/// Logging an attempt: the outcome (target
/// hit, new best, next target), its wording,
/// and the Log attempt sheet's button title
/// and replacement note.
final class LoggingTests: ModelTestCase {
  func testHittingTargetIsNewBest() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    let outcome = pushUps.record(6, day: 2)
    XCTAssertEqual(outcome.target, 6)
    XCTAssertTrue(outcome.hitTarget)
    XCTAssertTrue(outcome.isNewBest)
    XCTAssertEqual(outcome.nextTarget, 7)
    XCTAssertEqual(
      outcome.title, "Nice work!"
    )
    XCTAssertEqual(
      outcome.message,
      "You did 6. Next time, try for 7."
    )
  }

  func testFallingShort() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    pushUps.log(6, day: 2)
    let outcome = pushUps.record(4, day: 3)
    XCTAssertEqual(outcome.target, 7)
    XCTAssertFalse(outcome.hitTarget)
    XCTAssertFalse(outcome.isNewBest)
    XCTAssertEqual(outcome.nextTarget, 5)
    XCTAssertEqual(
      outcome.title, "Good effort!"
    )
    XCTAssertEqual(outcome.message, """
      You did 4, and every one counts. \
      Next time, try for 5.
      """)
  }

  func testMatchingBestIsNotNewBest() {
    let pushUps = makePushUps()
    pushUps.log(8, day: 2)
    let same = pushUps.record(8, day: 3)
    XCTAssertFalse(same.isNewBest)
    let more = pushUps.record(9, day: 4)
    XCTAssertTrue(more.isNewBest)
  }

  func testRelogComparesOtherDays() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    pushUps.record(7, day: 2, hour: 9)
    // Re-logging day 2 with 6: still above
    // the earlier best of 5, and replaces the
    // 7.
    let outcome = pushUps.record(
      6, day: 2, hour: 18
    )
    XCTAssertTrue(outcome.isNewBest)
    XCTAssertEqual(outcome.target, 6)
    XCTAssertEqual(pushUps.attempts?.count, 2)
    XCTAssertEqual(pushUps.personalBest, 6)
  }

  func testBeatingTestOnStartDay() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1, hour: 8)
    let outcome = pushUps.record(
      6, day: 1, hour: 18
    )
    XCTAssertTrue(outcome.isNewBest)
    XCTAssertEqual(pushUps.attempts?.count, 1)
  }

  func testReachingGoal() {
    let pushUps = makePushUps(
      start: 98, increase: 5
    )
    let outcome = pushUps.record(100, day: 2)
    XCTAssertTrue(outcome.reachedGoal)
    XCTAssertEqual(
      outcome.title, "Goal reached!"
    )
    XCTAssertEqual(
      outcome.message,
      "You hit your goal of 100."
    )
    XCTAssertEqual(outcome.nextTarget, 100)
  }

  func testOutcomeMessageUsesUnit() {
    let plank = makePushUps(start: 45)
    plank.unit = .seconds
    let outcome = plank.record(46, day: 2)
    XCTAssertEqual(outcome.message, """
      You did 46 seconds. \
      Next time, try for 47 seconds.
      """)
  }

  func testLogButtonTitle() {
    let pushUps = makePushUps()
    pushUps.log(5, day: 1)
    // The starting test counts as that day's
    // attempt.
    XCTAssertEqual(
      pushUps.logButtonTitle(day: 1),
      "Edit today"
    )
    pushUps.log(6, day: 2)
    XCTAssertEqual(
      pushUps.logButtonTitle(day: 2),
      "Edit today"
    )
    XCTAssertEqual(
      pushUps.logButtonTitle(day: 3),
      "Log attempt"
    )
  }

  func testReplacementNote() {
    let plank = makePushUps(start: 30)
    plank.unit = .seconds
    let before = plank.replacementNote(day: 2)
    XCTAssertNil(before)
    plank.log(31, day: 2)
    let note = plank.replacementNote(
      day: 2, hour: 20
    )
    XCTAssertEqual(note, """
      This replaces the 31 seconds you \
      logged that day.
      """)
  }

  func testOutcomeSymbols() {
    let pushUps = makePushUps(
      start: 98, increase: 1
    )
    XCTAssertEqual(
      pushUps.record(90, day: 2).symbol,
      "arrow.up.forward.circle.fill"
    )
    XCTAssertEqual(
      pushUps.record(91, day: 3).symbol,
      "hands.clap.fill"
    )
    XCTAssertEqual(
      pushUps.record(100, day: 4).symbol,
      "trophy.fill"
    )
  }
}
