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

  /// Long-presses `element` and returns its
  /// menu's `label` item, which must appear.
  ///
  /// CI's free runners (3 cores, no GPU)
  /// sometimes stall for a few seconds, and
  /// a press held during a stall reaches the
  /// app as a tap: no menu, and the tap's
  /// own screen opens. Only that case, the
  /// menu missing and `tapped.opens` shown,
  /// gets one more press, after closing it.
  /// Anything else is a real failure.
  /// `press` lets a test make the first
  /// press a tap, to check this path.
  @MainActor
  func menuItem(
    _ label: String,
    on element: XCUIElement,
    ifTapped tapped: Tapped,
    press: Press = {
      $0.press(forDuration: 1.5)
    }
  ) -> XCUIElement {
    let item = buttons[label].firstMatch
    press(element)
    // The screen a tap opens can have a
    // button with the same label (the
    // challenge screen's Log attempt), so
    // the menu counts only without it.
    if item.appears(), !tapped.opens.exists {
      return item
    }
    XCTAssertTrue(
      tapped.opens.appears(),
      "No menu, and no sign of a tap"
    )
    // Not `element`'s name: it's off screen
    // now, and reading it would fail.
    print("""
      Long-press read as a tap (app \
      stalled): closing what it opened and \
      pressing again.
      """)
    tapped.close()
    XCTAssertTrue(tapped.opens.disappears())
    element.press(forDuration: 1.5)
    XCTAssertTrue(item.appears())
    return item
  }

  /// A card read as a tap: its challenge
  /// screen, closed with Back.
  @MainActor
  func screen(_ title: String) -> Tapped {
    let back = navigationBars.buttons
      .element(boundBy: 0)
    return Tapped(opens: bar(title)) {
      back.tap()
    }
  }

  /// A history row read as a tap: the Edit
  /// attempt sheet, closed with Cancel.
  @MainActor
  var editSheet: Tapped {
    let cancel = button("Cancel")
    let sheet = bar("Edit attempt")
    return Tapped(opens: sheet) {
      cancel.tap()
    }
  }
}

/// How a test presses an element.
typealias Press = @MainActor (XCUIElement)
  -> Void

/// What a press opens if the app reads it as
/// a tap, and how to close it again.
struct Tapped {
  let opens: XCUIElement
  let close: @MainActor () -> Void
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
