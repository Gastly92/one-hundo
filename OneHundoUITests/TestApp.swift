import XCTest

/// The app under test.
typealias App = XCUIApplication

extension XCUIApplication {
  /// Launches the app for a UI test with a
  /// fresh in-memory store, optionally
  /// filled with sample challenges.
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

  /// A challenge card on the list, by its
  /// built-in id (e.g. "pushups"). Its label
  /// holds all of the card's text.
  @MainActor
  func card(_ id: String) -> XCUIElement {
    buttons["card.\(id)"]
  }

  /// A navigation bar, by title.
  @MainActor
  func bar(_ id: String) -> XCUIElement {
    navigationBars[id]
  }

  /// Long-presses `element` once and returns
  /// its menu's `label` item, which must
  /// appear. No second press: a missed one
  /// is a real failure.
  @MainActor
  func menuItem(
    _ label: String,
    on element: XCUIElement
  ) -> XCUIElement {
    element.press(forDuration: 1.5)
    let item = buttons[label].firstMatch
    XCTAssertTrue(item.appears())
    return item
  }
}

extension XCUIElement {
  /// Waits up to `seconds` for the element
  /// to exist.
  @MainActor
  func appears(
    within seconds: TimeInterval = 5
  ) -> Bool {
    waitForExistence(timeout: seconds)
  }

  /// Waits up to `seconds` for the element
  /// to go away.
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
