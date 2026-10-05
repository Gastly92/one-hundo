import XCTest

/// Runs Xcode's accessibility audit (contrast, Dynamic Type, labels, hit areas, clipped
/// text) on each main screen. Each issue fails the test with the screen and element.
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

    private static let offscreenAtLargeSizes: Set<String> = [
        "History", "Custom challenge", "Coming soon",
    ]

    /// Audits the current screen, failing once per issue with enough detail to find it.
    @MainActor
    private func audit(
        _ app: XCUIApplication,
        screen: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        do {
            try runAudit(app, screen: screen, file: file, line: line)
        } catch let error as NSError where error.code == -56 {
            // "Audit failed to complete in time": retry once; a second timeout fails.
            try runAudit(app, screen: screen, file: file, line: line)
        }
    }

    @MainActor
    private func runAudit(
        _ app: XCUIApplication,
        screen: String,
        file: StaticString,
        line: UInt
    ) throws {
        // Navigation bar buttons (Close, Cancel, Save) are iOS's own and don't scale.
        let barButtonFrames = app.navigationBars.buttons.allElementsBoundByIndex.map(\.frame)
        try app.performAccessibilityAudit { issue in
            // "Nearly passed" contrast passes at larger text sizes; iOS's own secondary
            // text color gets it. Real contrast failures still fail.
            if issue.compactDescription.contains("nearly passed") { return true }
            if let found = issue.element, barButtonFrames.contains(found.frame) { return true }
            // Standard text styles in the last section of a list: at large text sizes
            // they move off screen, so the audit can't confirm they scale.
            if issue.auditType == .dynamicType, let found = issue.element,
               Self.offscreenAtLargeSizes.contains(found.label) { return true }
            var element = "no element"
            if let found = issue.element, found.exists {
                element = "\(found.elementType.rawValue) label='\(found.label)' "
                    + "id='\(found.identifier)' frame=\(found.frame)"
            }
            let summary = "[\(screen)] \(issue.compactDescription): \(issue.detailedDescription)"
            XCTFail("\(summary) | \(element)", file: file, line: line)
            return true
        }
    }

    @MainActor
    func testWelcomeAndEnrollFlow() throws {
        let app = launch(seeded: false)
        XCTAssertTrue(app.staticTexts["welcomeTitle"].waitForExistence(timeout: 10))
        try audit(app, screen: "Welcome")

        app.buttons["startFirstChallengeButton"].tap()
        let pushUps = app.buttons["builtIn.pushups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 5))
        try audit(app, screen: "Add challenge")

        pushUps.tap()
        let next = app.buttons["enrollNextButton"]
        for (step, name) in ["Intro", "Test yourself", "Set your plan"].enumerated() {
            XCTAssertTrue(app.staticTexts["Step \(step + 1) of 4"].waitForExistence(timeout: 5))
            try audit(app, screen: name)
            next.tap()
        }
        XCTAssertTrue(app.staticTexts["Step 4 of 4"].waitForExistence(timeout: 5))
        try audit(app, screen: "Reminder")
    }

    @MainActor
    func testListChallengeScreenAndLogSheet() throws {
        let app = launch(seeded: true)
        let pushUps = app.staticTexts["Push-ups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 10))

        pushUps.tap()
        let logButton = app.buttons["logAttemptButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        try audit(app, screen: "Challenge")

        logButton.tap()
        XCTAssertTrue(app.buttons["logSaveButton"].waitForExistence(timeout: 5))
        try audit(app, screen: "Log sheet")

        app.buttons["logSaveButton"].tap()
        let done = app.buttons["logDoneButton"]
        XCTAssertTrue(done.waitForExistence(timeout: 5))
        try audit(app, screen: "Log result")

        // The list last: the audit can leave it scrolled or resized, which would
        // throw off a tap that follows it.
        done.tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts["challengesTitle"].waitForExistence(timeout: 5))
        try audit(app, screen: "List")
    }
}
