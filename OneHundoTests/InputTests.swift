@testable import OneHundo
import XCTest

/// Number field input and reminder times.
final class InputTests: XCTestCase {
  private let range = 0...999

  func testCleanKeepsDigits() {
    let typed = NumberText.clean(
      "1a2", in: range
    )
    XCTAssertEqual(typed.text, "12")
    XCTAssertEqual(typed.value, 12)
  }

  func testCleanClampsToRange() {
    let high = NumberText.clean(
      "5000", in: range
    )
    XCTAssertEqual(high.text, "999")
    XCTAssertEqual(high.value, 999)
    let low = NumberText.clean(
      "0", in: 1...10
    )
    XCTAssertEqual(low.value, 1)
  }

  func testCleanWithoutDigits() {
    let empty = NumberText.clean(
      "", in: range
    )
    XCTAssertEqual(empty.text, "")
    XCTAssertNil(empty.value)
    let letters = NumberText.clean(
      "ab", in: range
    )
    XCTAssertEqual(letters.text, "")
    XCTAssertNil(letters.value)
  }

  func testReminderTimeRoundTrips() {
    for minutes in [0, 1, 1080, 1439] {
      let date = ReminderTime.date(
        minutes: minutes
      )
      XCTAssertEqual(
        ReminderTime.minutes(of: date),
        minutes
      )
    }
    XCTAssertEqual(ReminderTime.sixPM, 1080)
  }

  func testReminderTimeOnOtherDays() {
    // A day later, or a day earlier: same
    // time of day.
    let later = Date(
      timeIntervalSinceReferenceDate:
        86_400 + 90 * 60
    )
    XCTAssertEqual(
      ReminderTime.minutes(of: later), 90
    )
    let earlier = Date(
      timeIntervalSinceReferenceDate:
        -86_400 + 90 * 60
    )
    XCTAssertEqual(
      ReminderTime.minutes(of: earlier), 90
    )
  }
}
