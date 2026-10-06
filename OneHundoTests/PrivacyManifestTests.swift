import XCTest

/// The App Store requires a privacy manifest in the app. Update it when adding
/// tracking, collected data, or APIs Apple lists as needing a reason (e.g.
/// UserDefaults).
final class PrivacyManifestTests: XCTestCase {
    func testManifestShipsInTheApp() throws {
        let url = try XCTUnwrap(
            Bundle.main.url(
                forResource: "PrivacyInfo", withExtension: "xcprivacy"
            ),
            "PrivacyInfo.xcprivacy is missing from the app bundle"
        )
        let data = try Data(contentsOf: url)
        let plist = try XCTUnwrap(
            PropertyListSerialization.propertyList(
                from: data, format: nil
            ) as? [String: Any]
        )
        XCTAssertEqual(plist["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual(
            (plist["NSPrivacyCollectedDataTypes"] as? [Any])?.count, 0
        )
        XCTAssertEqual((plist["NSPrivacyAccessedAPITypes"] as? [Any])?.count, 0)
    }
}
