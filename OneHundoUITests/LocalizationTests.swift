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

  /// System-formatted text: dates, and the
  /// system's own error description.
  private static let systemIDs: Set = [
    "attemptRow", "attemptDate",
    "errorDetails",
  ]

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

  /// Fails for each visible text or button
  /// label that has letters but no brackets.
  @MainActor
  private func check(
    _ app: XCUIApplication,
    on screen: ScreenID,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    // System chrome and system-formatted
    // values aren't the app's strings:
    // navigation bar buttons (e.g. Back) and
    // date pickers.
    let pickers = app.datePickers
      .descendants(matching: .any)
      .allElementsBoundByIndex
    let bars = app.navigationBars.buttons
      .allElementsBoundByIndex
    let system =
      (bars + pickers).map(\.frame)
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
        || Self.userText.contains(label) {
        continue
      }
      if system.contains(element.frame) {
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
