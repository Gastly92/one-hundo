import SwiftUI
import XCTest
@testable import OneHundo

final class ChallengeColorTests: XCTestCase {
    func testKnownNamesUsePalette() {
        for entry in Color.palette {
            XCTAssertEqual(
                Color(paletteName: entry.name), entry.color
            )
        }
    }

    func testUnknownNameFallsBackToOrange() {
        XCTAssertEqual(Color(paletteName: "plaid"), .orange)
    }
}
