import XCTest

/// The app under test.
typealias App = XCUIApplication

extension XCUIApplication {
  /// Launches the app for a UI test with a
  /// fresh in-memory store, optionally filled
  /// with sample challenges. If Thread
  /// Sanitizer finds a data race, the app
  /// stops, so the test fails.
  @MainActor
  static func start(
    seeded: Bool = false,
    arguments: [String] = []
  ) -> XCUIApplication {
    let app = XCUIApplication()
    let seed = seeded
      ? ["-seedSampleData"] : []
    app.launchArguments =
      ["-uiTesting"] + seed + arguments
    app.launchEnvironment["TSAN_OPTIONS"] =
      "halt_on_error=1"
    app.launch()
    return app
  }

  /// Launches straight into one screen (see
  /// `ScreenID` and the app's `ScreenHost`).
  @MainActor
  static func start(
    screen: ScreenID,
    arguments: [String] = []
  ) -> XCUIApplication {
    let show = [
      "-showScreen", screen.rawValue,
    ]
    return start(arguments: show + arguments)
  }

  /// A static text, by label or identifier.
  @MainActor
  func text(_ id: String) -> XCUIElement {
    staticTexts[id]
  }

  /// A button, by label or identifier.
  @MainActor
  func button(_ id: String) -> XCUIElement {
    buttons[id]
  }

  /// A text field, by identifier.
  @MainActor
  func field(_ id: String) -> XCUIElement {
    textFields[id]
  }

  /// A navigation bar, by title.
  @MainActor
  func bar(_ id: String) -> XCUIElement {
    navigationBars[id]
  }
}

extension XCUIElement {
  /// Waits up to `seconds` for the element to
  /// exist.
  @MainActor
  func appears(
    within seconds: TimeInterval = 5
  ) -> Bool {
    waitForExistence(timeout: seconds)
  }

  /// Waits up to `seconds` for the element to
  /// go away.
  @MainActor
  func disappears(
    within seconds: TimeInterval = 5
  ) -> Bool {
    waitForNonExistence(timeout: seconds)
  }

  /// A text field's current text.
  @MainActor
  var textValue: String? { value as? String }
}
