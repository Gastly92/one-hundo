import XCTest

final class ChallengeListTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(seeded: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"] + (seeded ? ["-seedSampleData"] : [])
        app.launch()
        return app
    }

    @MainActor
    func testEmptyStateShowsOnFirstLaunch() {
        let app = launch()
        XCTAssertTrue(app.staticTexts["No challenges yet"].waitForExistence(timeout: 10))

        let startButton = app.buttons["startFirstChallengeButton"]
        XCTAssertTrue(startButton.exists)
        startButton.tap()
        XCTAssertTrue(app.navigationBars["Add challenge"].waitForExistence(timeout: 5))
        app.buttons["Close"].tap()

        app.buttons["addChallengeButton"].tap()
        XCTAssertTrue(app.navigationBars["Add challenge"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testSeededChallengesShowAsCards() {
        let app = launch(seeded: true)
        XCTAssertTrue(app.staticTexts["Push-ups"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["No challenges yet"].exists)

        // Logged yesterday: target is yesterday's 10 + 1.
        XCTAssertTrue(app.staticTexts["Try 11 today"].exists)
        XCTAssertTrue(app.staticTexts["10 / 100"].exists)

        // Logged today.
        XCTAssertTrue(app.staticTexts["Sit-ups"].exists)
        XCTAssertTrue(app.staticTexts["Done: 20"].exists)
        XCTAssertTrue(app.staticTexts["20 / 100"].exists)

        // Started today with a test of 3: the test alone isn't "done".
        XCTAssertTrue(app.staticTexts["Pull-ups"].exists)
        XCTAssertTrue(app.staticTexts["Try 4 today"].exists)
    }

    @MainActor
    func testCalendarTabShowsPlaceholder() {
        let app = launch()
        app.tabBars.buttons["Calendar"].tap()
        XCTAssertTrue(app.staticTexts["Coming soon: your attempts, day by day."].waitForExistence(timeout: 5))
        app.tabBars.buttons["Challenges"].tap()
        XCTAssertTrue(app.staticTexts["No challenges yet"].waitForExistence(timeout: 5))
    }
}
