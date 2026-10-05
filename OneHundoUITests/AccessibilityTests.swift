import XCTest

/// Runs Xcode's accessibility audit (contrast, Dynamic Type, labels, hit areas, clipped
/// text) on each main screen. A failing audit names the issue and the element.
final class AccessibilityTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    @MainActor
    private func launch(seeded: Bool) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"] + (seeded ? ["-seedSampleData"] : [])
        app.launch()
        return app
    }

    @MainActor
    func testWelcomeAndEnrollFlow() throws {
        let app = launch(seeded: false)
        XCTAssertTrue(app.staticTexts["welcomeTitle"].waitForExistence(timeout: 10))
        try app.performAccessibilityAudit()

        app.buttons["startFirstChallengeButton"].tap()
        let pushUps = app.buttons["builtIn.pushups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()

        pushUps.tap()
        let next = app.buttons["enrollNextButton"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        // Intro, test yourself, set your plan.
        for _ in 0..<3 {
            try app.performAccessibilityAudit()
            next.tap()
        }
        // Reminder.
        XCTAssertTrue(app.buttons["enrollStartButton"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()
    }

    @MainActor
    func testListChallengeScreenAndLogSheet() throws {
        let app = launch(seeded: true)
        let pushUps = app.staticTexts["Push-ups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 10))
        try app.performAccessibilityAudit()

        pushUps.tap()
        let logButton = app.buttons["logAttemptButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()

        logButton.tap()
        XCTAssertTrue(app.buttons["logSaveButton"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()

        app.buttons["logSaveButton"].tap()
        XCTAssertTrue(app.buttons["logDoneButton"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()
    }
}
