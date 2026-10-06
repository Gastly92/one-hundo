import XCTest

final class ChallengeScreenTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testLogAttemptThenReplaceSameDay() {
        let app = XCUIApplication.start(seeded: true)
        let text = app.staticTexts

        // Push-ups started 3 days ago at 8, logged 10
        // yesterday: "Try 11 today".
        let pushUps = text["Push-ups"]
        XCTAssertTrue(pushUps.appears(within: 10))
        pushUps.tap()

        let logButton = app.buttons["logAttemptButton"]
        let best = text["personalBestValue"]
        let days = text["daysLoggedValue"]
        XCTAssertTrue(logButton.appears())
        let today = text["todayText"]
        XCTAssertEqual(today.label, "Try 11 today")
        XCTAssertEqual(best.label, "10")
        XCTAssertEqual(days.label, "2")
        XCTAssertEqual(logButton.label, "Log attempt")

        // Log 13: prefilled with today's target of 11, then
        // + twice.
        logButton.tap()
        let field = app.textFields["logCount.field"]
        XCTAssertTrue(field.appears())
        XCTAssertEqual(field.text, "11")
        let increment = app.buttons["logCount.increment"]
        increment.tap()
        increment.tap()
        XCTAssertEqual(field.text, "13")
        app.buttons["logSaveButton"].tap()

        let outcome = text["logOutcomeTitle"]
        XCTAssertTrue(outcome.appears())
        XCTAssertEqual(outcome.label, "Nice work!")
        XCTAssertTrue(text["newBestBadge"].exists)
        app.buttons["logDoneButton"].tap()

        XCTAssertTrue(text["Done: 13"].appears())
        XCTAssertEqual(best.label, "13")
        XCTAssertEqual(days.label, "3")
        XCTAssertEqual(logButton.label, "Edit today")

        // Logging again the same day replaces today's
        // count.
        logButton.tap()
        XCTAssertTrue(field.appears())
        XCTAssertEqual(field.text, "13")
        increment.tap()
        app.buttons["logSaveButton"].tap()
        let done = app.buttons["logDoneButton"]
        XCTAssertTrue(done.appears())
        done.tap()

        XCTAssertTrue(text["Done: 14"].appears())
        XCTAssertEqual(days.label, "3")

        // Back on the list, the card shows today's count.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(text["14 / 100"].appears())
        XCTAssertTrue(text["Done: 14"].exists)
    }

    @MainActor
    func testTapHistoryRowEditsAttempt() {
        let app = XCUIApplication.start(seeded: true)

        // Push-ups has attempts of 8 (start) and 10
        // (yesterday).
        let pushUps = app.staticTexts["Push-ups"]
        XCTAssertTrue(pushUps.appears(within: 10))
        pushUps.tap()

        let row = app.buttons["attemptRow"].firstMatch
        XCTAssertTrue(row.appears())
        row.tap()

        let sheet = app.navigationBars["Edit attempt"]
        XCTAssertTrue(sheet.appears())
        let field = app.textFields["logCount.field"]
        XCTAssertEqual(field.text, "10")
        app.buttons["Cancel"].tap()
        let logButton = app.buttons["logAttemptButton"]
        XCTAssertTrue(logButton.appears())
    }
}
