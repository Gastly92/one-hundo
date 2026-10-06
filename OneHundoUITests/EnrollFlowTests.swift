import XCTest

final class EnrollFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testStartPushUpsShowsCard() {
        let app = XCUIApplication.start()

        let startFirst = app.buttons["welcomeStart"]
        XCTAssertTrue(startFirst.appears(within: 10))
        startFirst.tap()

        let pushUps = app.buttons["builtIn.pushups"]
        XCTAssertTrue(pushUps.appears())
        pushUps.tap()

        // Intro.
        let next = app.buttons["enrollNextButton"]
        XCTAssertTrue(next.appears())
        next.tap()

        // Test yourself: 1 + 4 = 5.
        let plus = app.buttons["startingCount.increment"]
        XCTAssertTrue(plus.appears())
        for _ in 0..<4 { plus.tap() }
        let count = app.textFields["startingCount.field"]
        XCTAssertEqual(count.text, "5")
        next.tap()

        // Goal and pace: defaults to 100 at +1 a day; the
        // quick goal buttons change it.
        let pace100 = app.staticTexts[
            "At this pace you'd hit 100 in about 95 days."
        ]
        XCTAssertTrue(pace100.appears())
        app.buttons["goalChoice.150"].tap()
        let pace150 = app.staticTexts[
            "At this pace you'd hit 150 in about 145 days."
        ]
        XCTAssertTrue(pace150.appears())
        app.buttons["goalChoice.100"].tap()
        let goal = app.textFields["goal.field"]
        XCTAssertEqual(goal.text, "100")
        next.tap()

        // Reminder: keep the defaults and start.
        let start = app.buttons["enrollStartButton"]
        XCTAssertTrue(start.appears())
        start.tap()

        let card = app.staticTexts["Push-ups"]
        XCTAssertTrue(card.appears(within: 10))
        // The test is today's attempt; tomorrow's target is
        // 6.
        XCTAssertTrue(app.staticTexts["Done: 5"].exists)
        XCTAssertTrue(app.staticTexts["5 / 100"].exists)

        // Push-ups is now in progress, so it can't be
        // started twice.
        app.buttons["addChallengeButton"].tap()
        let again = app.buttons["builtIn.pushups"]
        XCTAssertTrue(again.appears())
        XCTAssertFalse(again.isEnabled)
        let sitUps = app.buttons["builtIn.situps"]
        XCTAssertTrue(sitUps.isEnabled)
    }
}
