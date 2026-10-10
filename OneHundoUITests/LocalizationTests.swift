import XCTest

/// Runs the app in Xcode's bounded
/// pseudo-language, which wraps every
/// translatable string in "[# ... #]".
/// Visible text without the brackets would
/// stay in English after translation, so
/// each screen fails on any such text.
final class LocalizationTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  private static let pseudo = [
    "-NSSurroundLocalizedStrings", "YES",
  ]

  /// System-formatted text: dates (a
  /// completed card's is its detail),
  /// weekday letters, and the system's own
  /// error description.
  private static let systemIDs: Set = [
    "attemptRow", "attemptDate",
    "errorDetails", "monthTitle",
    "weekday", "dayTitle", "cardDetail",
  ]

  /// Calendar days ("day.5"): a date, and
  /// the names of challenges logged then
  /// (the sample Plank's stays as typed).
  private static let dayPrefix = "day."

  /// Text the user typed (the sample custom
  /// challenge's name), which stays as
  /// typed.
  private static let userText: Set = [
    "Plank",
  ]

  /// Every screen in the app (`ScreenID`),
  /// each opened directly with sample data.
  @MainActor
  func testEveryScreen() {
    for screen in ScreenID.allCases {
      let app = App.start(
        screen: screen,
        arguments: Self.pseudo
      )
      let text = app.staticTexts.firstMatch
      guard text.appears(within: 10) else {
        XCTFail("[\(screen)] showed no text")
        continue
      }
      check(app, on: screen)
      app.terminate()
    }
  }

  /// Where system text sits, which isn't
  /// the app's to translate: navigation bar
  /// buttons (e.g. Back), date pickers, and
  /// the history chart's axis labels
  /// (system-formatted dates and numbers).
  @MainActor
  private func systemAreas(
    _ app: XCUIApplication,
    on screen: ScreenID
  ) -> [CGRect] {
    let pickers = app.datePickers
      .descendants(matching: .any)
      .allElementsBoundByIndex
    let bars = app.navigationBars.buttons
      .allElementsBoundByIndex
    // Searching every element is slow on
    // CI's simulators (it timed out once),
    // so only where the chart is.
    let charts = screen == .challengeDetail
      ? app.descendants(matching: .any)
        .matching(identifier: "historyChart")
        .allElementsBoundByIndex
      : []
    return (bars + pickers + charts)
      .map(\.frame)
  }

  /// Fails for each visible text or button
  /// label that has letters but no brackets.
  @MainActor
  private func check(
    _ app: XCUIApplication,
    on screen: ScreenID,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let system = systemAreas(app, on: screen)
    let elements =
      app.staticTexts.allElementsBoundByIndex
      + app.buttons.allElementsBoundByIndex
    var bracketed = 0
    for element in elements {
      guard element.exists else { continue }
      let label = element.label
      let id = element.identifier
      guard label.contains(where: \.isLetter)
      else { continue }
      if label.contains("[#") {
        bracketed += 1
        continue
      }
      if Self.systemIDs.contains(id)
        || id.hasPrefix(Self.dayPrefix)
        || Self.userText.contains(label) {
        continue
      }
      let frame = element.frame
      if system.contains(where: {
        $0.contains(frame)
      }) {
        continue
      }
      XCTFail(
        "[\(screen)] Not translatable: "
          + "'\(label)' (id '\(id)')",
        file: file,
        line: line
      )
    }
    // Guards against the pseudo-language not
    // taking effect at all.
    XCTAssertGreaterThan(
      bracketed,
      0,
      "[\(screen)] No bracketed text",
      file: file,
      line: line
    )
  }
}
