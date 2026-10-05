import XCTest

final class EnrollFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testStartPushUpsShowsCard() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let startFirst = app.buttons["startFirstChallengeButton"]
        XCTAssertTrue(startFirst.waitForExistence(timeout: 10))
        startFirst.tap()

        let pushUps = app.buttons["builtIn.pushups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 5))
        pushUps.tap()

        // Intro.
        let next = app.buttons["enrollNextButton"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        next.tap()

        // Test yourself: 1 + 4 = 5.
        let increment = app.buttons["startingCount.increment"]
        XCTAssertTrue(increment.waitForExistence(timeout: 5))
        for _ in 0..<4 { increment.tap() }
        XCTAssertEqual(app.textFields["startingCount.field"].value as? String, "5")
        next.tap()

        // Goal and pace: defaults to 100 at +1 a day; the quick goal buttons change it.
        XCTAssertTrue(app.staticTexts["At this pace you'd hit 100 in about 95 days."].waitForExistence(timeout: 5))
        app.buttons["goalChoice.150"].tap()
        XCTAssertTrue(app.staticTexts["At this pace you'd hit 150 in about 145 days."].waitForExistence(timeout: 5))
        app.buttons["goalChoice.100"].tap()
        XCTAssertEqual(app.textFields["goal.field"].value as? String, "100")
        next.tap()

        // Reminder: keep the defaults and start.
        let start = app.buttons["enrollStartButton"]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        start.tap()

        XCTAssertTrue(app.staticTexts["Push-ups"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Try 6 today"].exists)
        XCTAssertTrue(app.staticTexts["5 / 100"].exists)

        // Push-ups is now in progress, so it can't be started twice.
        app.buttons["addChallengeButton"].tap()
        let pushUpsAgain = app.buttons["builtIn.pushups"]
        XCTAssertTrue(pushUpsAgain.waitForExistence(timeout: 5))
        XCTAssertFalse(pushUpsAgain.isEnabled)
        XCTAssertTrue(app.buttons["builtIn.situps"].isEnabled)
    }
}
