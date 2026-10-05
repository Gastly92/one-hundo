import XCTest

final class ChallengeScreenTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testLogAttemptThenReplaceSameDay() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-seedSampleData"]
        app.launch()

        // Pull-ups was started today with a test of 3: "Try 4 today".
        let pullUps = app.staticTexts["Pull-ups"]
        XCTAssertTrue(pullUps.waitForExistence(timeout: 10))
        pullUps.tap()

        let logButton = app.buttons["logAttemptButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayText"].label, "Try 4 today")
        XCTAssertEqual(app.staticTexts["personalBestValue"].label, "3")
        XCTAssertEqual(app.staticTexts["daysLoggedValue"].label, "1")

        // Log 6: prefilled with today's target of 4, then + twice.
        logButton.tap()
        let field = app.textFields["logCount.field"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "4")
        let increment = app.buttons["logCount.increment"]
        increment.tap()
        increment.tap()
        XCTAssertEqual(field.value as? String, "6")
        app.buttons["logSaveButton"].tap()

        XCTAssertTrue(app.staticTexts["logOutcomeTitle"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["logOutcomeTitle"].label, "Nice work!")
        XCTAssertTrue(app.staticTexts["newBestBadge"].exists)
        app.buttons["logDoneButton"].tap()

        XCTAssertTrue(app.staticTexts["Done: 6"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["personalBestValue"].label, "6")
        XCTAssertEqual(app.staticTexts["daysLoggedValue"].label, "1")
        XCTAssertEqual(logButton.label, "Edit today")

        // Logging again the same day replaces today's count.
        logButton.tap()
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "6")
        increment.tap()
        app.buttons["logSaveButton"].tap()
        let done = app.buttons["logDoneButton"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        done.tap()

        XCTAssertTrue(app.staticTexts["Done: 7"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["daysLoggedValue"].label, "1")

        // Back on the list, the card shows today's count.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["7 / 100"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Done: 7"].exists)
    }

    @MainActor
    func testTapHistoryRowEditsAttempt() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-seedSampleData"]
        app.launch()

        // Push-ups has attempts of 8 (start) and 10 (yesterday).
        let pushUps = app.staticTexts["Push-ups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 10))
        pushUps.tap()

        let row = app.buttons["attemptRow"].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        XCTAssertTrue(app.navigationBars["Edit attempt"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.textFields["logCount.field"].value as? String, "10")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.buttons["logAttemptButton"].waitForExistence(timeout: 5))
    }
}
