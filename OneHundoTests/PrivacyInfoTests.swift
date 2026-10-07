import XCTest

/// The App Store requires a privacy manifest
/// in the app. Update it when adding
/// tracking, collected data, or APIs Apple
/// lists as needing a reason (e.g.
/// UserDefaults).
final class PrivacyInfoTests: XCTestCase {
  func testManifestShipsInTheApp() throws {
    let url = try XCTUnwrap(
      Bundle.main.url(
        forResource: "PrivacyInfo",
        withExtension: "xcprivacy"
      ),
      "PrivacyInfo.xcprivacy is missing"
    )
    let data = try Data(contentsOf: url)
    let plist = try XCTUnwrap(
      PropertyListSerialization.propertyList(
        from: data, format: nil
      ) as? [String: Any]
    )
    func count(_ key: String) -> Int? {
      (plist[key] as? [Any])?.count
    }
    let tracking = plist["NSPrivacyTracking"]
    XCTAssertEqual(tracking as? Bool, false)
    let collected = count(
      "NSPrivacyCollectedDataTypes"
    )
    XCTAssertEqual(collected, 0)
    let apis = count(
      "NSPrivacyAccessedAPITypes"
    )
    XCTAssertEqual(apis, 0)
  }
}
