@testable import OneHundo
import SwiftUI
import XCTest

final class ChallengeColorTests: XCTestCase {
  func testKnownNamesUsePalette() {
    for swatch in Color.palette {
      let found = Color(
        paletteName: swatch.name
      )
      XCTAssertEqual(found, swatch.color)
    }
  }

  func testSwatchLabels() {
    let labels = Color.palette.map {
      String(localized: $0.label)
    }
    XCTAssertEqual(labels.first, "Violet")
    XCTAssertEqual(labels.count, 11)
  }

  /// A built-in started when Push-ups was
  /// orange shows today's violet; a custom
  /// challenge keeps its own color.
  @MainActor
  func testBuiltInUsesItsOwnColor() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.colorName = "orange"
    let shown = pushUps.color
    XCTAssertEqual(shown, .accentColor)
    pushUps.kind = Challenge.customKind
    XCTAssertEqual(pushUps.color, .orange)
  }

  func testUnknownNameIsViolet() {
    let color = Color(paletteName: "plaid")
    XCTAssertEqual(color, .accentColor)
  }
}
