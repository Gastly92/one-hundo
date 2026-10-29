import BaseTesting
import XCTest

extension XCUIApplication {
  /// A challenge card on the list, by its
  /// built-in id (e.g. "pushups"). Its label
  /// holds all of the card's text.
  @MainActor
  func card(_ id: String) -> XCUIElement {
    buttons["card.\(id)"]
  }

  /// A history row read as a tap: the Edit
  /// attempt sheet, closed with Cancel.
  @MainActor
  var editSheet: Tapped {
    sheet("Edit attempt", close: "Cancel")
  }
}
