@testable import OneHundo
import XCTest

/// What a challenge's card shows.
@MainActor
final class ChallengeCardTests: XCTestCase {
  func testCardTextTryAndDone() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.log(5, day: 1)
    XCTAssertEqual(
      pushUps.todayText(day: 2),
      "Try 6 today"
    )
    pushUps.log(6, day: 2)
    XCTAssertEqual(
      pushUps.todayText(day: 2), "Done: 6"
    )
    XCTAssertEqual(
      pushUps.progressText, "6 / 100"
    )
  }

  func testCompletedCard() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.log(6, day: 2)
    XCTAssertTrue(
      pushUps.showsDoneMark(
        on: day(2), in: utc
      )
    )
    XCTAssertEqual(
      pushUps.cardDetail, "6 / 100"
    )
    // Reached on the day it was logged.
    pushUps.recordAttempt(
      count: 100, on: day(3), in: utc
    )
    XCTAssertEqual(
      pushUps.completedDate, day(3)
    )
    XCTAssertFalse(
      pushUps.showsDoneMark(
        on: day(3), in: utc
      )
    )
    XCTAssertEqual(
      pushUps.cardDetail,
      day(3).formatted(
        .dateTime.month().day().year()
      )
    )
  }
}
