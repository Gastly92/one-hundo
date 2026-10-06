import SwiftUI
import XCTest
@testable import OneHundo

final class ChallengeColorTests: XCTestCase {
    func testKnownNamesUsePalette() {
        for entry in Color.challengePalette {
            XCTAssertEqual(Color(challengeColorName: entry.name), entry.color)
        }
    }

    func testUnknownNameFallsBackToOrange() {
        XCTAssertEqual(Color(challengeColorName: "plaid"), .orange)
    }
}
