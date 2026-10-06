import XCTest

final class ChallengeScreenTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testLogAttemptThenReplaceSameDay() {
        let app = XCUIApplication.launchForTesting(seeded: true)

        // Push-ups started 3 days ago at 8, logged 10 yesterday:
        // "Try 11 today".
        let pushUps = app.staticTexts["Push-ups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 10))
        pushUps.tap()

        let logButton = app.buttons["logAttemptButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["todayText"].label, "Try 11 today")
        XCTAssertEqual(app.staticTexts["personalBestValue"].label, "10")
        XCTAssertEqual(app.staticTexts["daysLoggedValue"].label, "2")
        XCTAssertEqual(logButton.label, "Log attempt")

        // Log 13: prefilled with today's target of 11, then + twice.
        logButton.tap()
        let field = app.textFields["logCount.field"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "11")
        let increment = app.buttons["logCount.increment"]
        increment.tap()
        increment.tap()
        XCTAssertEqual(field.value as? String, "13")
        app.buttons["logSaveButton"].tap()

        XCTAssertTrue(
            app.staticTexts["logOutcomeTitle"].waitForExistence(timeout: 5)
        )
        XCTAssertEqual(app.staticTexts["logOutcomeTitle"].label, "Nice work!")
        XCTAssertTrue(app.staticTexts["newBestBadge"].exists)
        app.buttons["logDoneButton"].tap()

        XCTAssertTrue(app.staticTexts["Done: 13"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["personalBestValue"].label, "13")
        XCTAssertEqual(app.staticTexts["daysLoggedValue"].label, "3")
        XCTAssertEqual(logButton.label, "Edit today")

        // Logging again the same day replaces today's count.
        logButton.tap()
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertEqual(field.value as? String, "13")
        increment.tap()
        app.buttons["logSaveButton"].tap()
        let done = app.buttons["logDoneButton"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        done.tap()

        XCTAssertTrue(app.staticTexts["Done: 14"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["daysLoggedValue"].label, "3")

        // Back on the list, the card shows today's count.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["14 / 100"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Done: 14"].exists)
    }

    @MainActor
    func testTapHistoryRowEditsAttempt() {
        let app = XCUIApplication.launchForTesting(seeded: true)

        // Push-ups has attempts of 8 (start) and 10 (yesterday).
        let pushUps = app.staticTexts["Push-ups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 10))
        pushUps.tap()

        let row = app.buttons["attemptRow"].firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()

        XCTAssertTrue(
            app.navigationBars["Edit attempt"].waitForExistence(timeout: 5)
        )
        XCTAssertEqual(app.textFields["logCount.field"].value as? String, "10")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(
            app.buttons["logAttemptButton"].waitForExistence(timeout: 5)
        )
    }
}
