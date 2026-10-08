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
    XCTAssertEqual(labels.first, "Orange")
    XCTAssertEqual(labels.count, 10)
  }

  func testUnknownNameIsOrange() {
    let color = Color(paletteName: "plaid")
    XCTAssertEqual(color, .orange)
  }
}
