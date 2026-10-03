import XCTest

final class HelloMessageTests: XCTestCase {
    @MainActor
    func testHelloMessageIsShown() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Hello One Hundo"].waitForExistence(timeout: 10))
    }
}
