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
        XCTAssertTrue(app.staticTexts["welcomeTitle"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Get to 100 in one go."].exists)

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
        XCTAssertFalse(app.staticTexts["welcomeTitle"].exists)

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
    func testAddButtonIsAlignedWithTitle() {
        let app = launch()
        let title = app.staticTexts["challengesTitle"]
        let addButton = app.buttons["addChallengeButton"]
        XCTAssertTrue(title.waitForExistence(timeout: 10))
        XCTAssertTrue(addButton.exists)
        XCTAssertEqual(title.frame.midY, addButton.frame.midY, accuracy: 4)
    }

    @MainActor
    func testCalendarTabShowsPlaceholder() {
        let app = launch()
        app.tabBars.buttons["Calendar"].tap()
        let placeholder = app.staticTexts["Coming soon: your attempts, day by day."]
        XCTAssertTrue(placeholder.waitForExistence(timeout: 5))
        app.tabBars.buttons["Challenges"].tap()
        XCTAssertTrue(app.staticTexts["welcomeTitle"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLongPressCardDeletesChallenge() {
        let app = launch(seeded: true)
        let pullUps = app.staticTexts["Pull-ups"]
        XCTAssertTrue(pullUps.waitForExistence(timeout: 10))

        // The first press can land while the list is still settling: press up to
        // three times until the menu opens.
        let deleteItem = app.buttons["Delete challenge"]
        for _ in 0..<3 where !deleteItem.exists {
            pullUps.press(forDuration: 1.5)
            _ = deleteItem.waitForExistence(timeout: 3)
        }
        XCTAssertTrue(deleteItem.exists)
        XCTAssertTrue(app.buttons["Log attempt"].exists)
        deleteItem.tap()

        // The confirmation's button has the same label as the menu item, which is gone by now.
        let warning = "This deletes the challenge and all its attempts. You can't undo this."
        XCTAssertTrue(app.staticTexts[warning].waitForExistence(timeout: 5))
        app.buttons["Delete challenge"].firstMatch.tap()

        XCTAssertTrue(pullUps.waitForNonExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Push-ups"].exists)
    }

    @MainActor
    func testTabTitlesLineUp() {
        let app = launch()
        let challengesTitle = app.staticTexts["challengesTitle"]
        XCTAssertTrue(challengesTitle.waitForExistence(timeout: 10))
        let challengesFrame = challengesTitle.frame

        app.tabBars.buttons["Calendar"].tap()
        let calendarTitle = app.staticTexts["calendarTitle"]
        XCTAssertTrue(calendarTitle.waitForExistence(timeout: 5))
        XCTAssertEqual(calendarTitle.frame.minY, challengesFrame.minY, accuracy: 1)
        XCTAssertEqual(calendarTitle.frame.minX, challengesFrame.minX, accuracy: 1)
    }
}
