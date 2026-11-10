@testable import OneHundo
import XCTest

/// How days read on screen
/// (`Date.FormatStyle.dayText`), in US
/// English and UTC.
final class DayFormatTests: XCTestCase {
  /// Noon, Jan 15 2026 (a Thursday), UTC.
  private let now = Date(
    timeIntervalSince1970: 1_768_478_400
  )

  private let cal: Calendar = {
    var utc = Calendar(
      identifier: .gregorian
    )
    utc.timeZone = .gmt
    return utc
  }()

  private func text(
    _ day: Date, short: Bool = false
  ) -> String {
    var style = Date.FormatStyle.dayText(
      day, now: now, short: short, in: cal
    )
    .locale(Locale(identifier: "en_US"))
    style.timeZone = .gmt
    return day.formatted(style)
  }

  func testThisYearHasNoYear() {
    XCTAssertEqual(
      text(now), "Thursday, January 15"
    )
  }

  func testShortForLists() {
    XCTAssertEqual(
      text(now, short: true), "Thu, Jan 15"
    )
  }

  func testOtherYearAddsIt() {
    let lastYear = now - 365 * 86_400
    XCTAssertEqual(
      text(lastYear),
      "Wednesday, January 15, 2025"
    )
    XCTAssertEqual(
      text(lastYear, short: true),
      "Wed, Jan 15, 2025"
    )
  }
}
