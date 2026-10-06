import XCTest

final class ChallengeListTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testEmptyStateShowsOnFirstLaunch() {
        let app = XCUIApplication.start()
        let title = app.staticTexts["welcomeTitle"]
        XCTAssertTrue(title.appears(within: 10))
        XCTAssertEqual(title.label, "Get to 100 in one go.")

        let start = app.buttons["welcomeStart"]
        XCTAssertTrue(start.exists)
        start.tap()
        let sheet = app.navigationBars["Add challenge"]
        XCTAssertTrue(sheet.appears())
        app.buttons["Close"].tap()
        XCTAssertTrue(start.appears())
    }

    @MainActor
    func testSeededChallengesShowAsCards() {
        let app = XCUIApplication.start(seeded: true)
        let text = app.staticTexts
        XCTAssertTrue(text["Push-ups"].appears(within: 10))
        XCTAssertFalse(text["welcomeTitle"].exists)

        // Logged yesterday: target is yesterday's 10 + 1.
        XCTAssertTrue(text["Try 11 today"].exists)
        XCTAssertTrue(text["10 / 100"].exists)

        // Logged today.
        XCTAssertTrue(text["Sit-ups"].exists)
        XCTAssertTrue(text["Done: 20"].exists)
        XCTAssertTrue(text["20 / 100"].exists)

        // Started today with a test of 3: the test is
        // today's attempt.
        XCTAssertTrue(text["Pull-ups"].exists)
        XCTAssertTrue(text["Done: 3"].exists)
    }

    @MainActor
    func testAddChallengeTileOpensAddChallenge() {
        let app = XCUIApplication.start(seeded: true)
        let tile = app.buttons["addChallengeButton"]
        XCTAssertTrue(tile.appears(within: 10))
        // The title bar stays plain: no buttons.
        let bar = app.navigationBars["Challenges"]
        XCTAssertEqual(bar.buttons.count, 0)
        tile.tap()
        let sheet = app.navigationBars["Add challenge"]
        XCTAssertTrue(sheet.appears())
    }

    @MainActor
    func testCalendarTabShowsPlaceholder() {
        let app = XCUIApplication.start()
        let tabs = app.tabBars.buttons
        tabs["Calendar"].tap()
        let soon = app.staticTexts[
            "Coming soon: your attempts, day by day."
        ]
        XCTAssertTrue(soon.appears())
        tabs["Challenges"].tap()
        let title = app.staticTexts["welcomeTitle"]
        XCTAssertTrue(title.appears())
    }

    @MainActor
    func testLongPressCardDeletesChallenge() {
        let app = XCUIApplication.start(seeded: true)
        let pullUps = app.staticTexts["Pull-ups"]
        XCTAssertTrue(pullUps.appears(within: 10))

        // The first press can land while the list is still
        // settling: press up to three times until the menu
        // opens.
        let deleteItem = app.buttons["Delete challenge"]
        for _ in 0..<3 where !deleteItem.exists {
            pullUps.press(forDuration: 1.5)
            _ = deleteItem.appears(within: 3)
        }
        XCTAssertTrue(deleteItem.exists)
        XCTAssertTrue(app.buttons["Edit today"].exists)
        deleteItem.tap()

        // The confirmation's button has the same label as
        // the menu item, which is gone by now.
        let warning = """
            This deletes the challenge and all its \
            attempts. You can't undo this.
            """
        XCTAssertTrue(app.staticTexts[warning].appears())
        app.buttons["Delete challenge"].firstMatch.tap()

        XCTAssertTrue(pullUps.disappears())
        XCTAssertTrue(app.staticTexts["Push-ups"].exists)
    }

    @MainActor
    func testTabTitlesLineUp() {
        let app = XCUIApplication.start()
        let first = title(of: "Challenges", in: app)
        XCTAssertTrue(first.appears(within: 10))
        let before = first.frame

        app.tabBars.buttons["Calendar"].tap()
        let second = title(of: "Calendar", in: app)
        XCTAssertTrue(second.appears())
        let after = second.frame
        XCTAssertEqual(after.minY, before.minY, accuracy: 1)
        XCTAssertEqual(after.minX, before.minX, accuracy: 1)
    }

    /// A tab's large title.
    @MainActor
    private func title(
        of tab: String, in app: XCUIApplication
    ) -> XCUIElement {
        app.navigationBars[tab].staticTexts[tab].firstMatch
    }
}
