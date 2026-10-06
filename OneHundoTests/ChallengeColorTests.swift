import SwiftUI
import XCTest
@testable import OneHundo

final class ChallengeColorTests: XCTestCase {
  func testKnownNamesUsePalette() {
    for (name, color) in Color.palette {
      let found = Color(paletteName: name)
      XCTAssertEqual(found, color)
    }
  }

  func testUnknownNameIsOrange() {
    let color = Color(paletteName: "plaid")
    XCTAssertEqual(color, .orange)
  }
}
