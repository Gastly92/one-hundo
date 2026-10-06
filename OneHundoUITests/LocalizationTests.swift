import XCTest

/// Runs the app in Xcode's bounded pseudo-language, which wraps every translatable
/// string in "[# ... #]". Visible text without the brackets would stay in English
/// after translation, so each screen fails on any such text.
final class LocalizationTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    @MainActor
    private func launch(seeded: Bool) -> XCUIApplication {
        XCUIApplication.launchForTesting(
            seeded: seeded,
            arguments: ["-NSSurroundLocalizedStrings", "YES"]
        )
    }

    @MainActor
    private func labelContaining(_ text: String, in app: XCUIApplication) -> XCUIElement {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    /// Fails for each visible text or button label that has letters but no brackets.
    @MainActor
    private func assertTranslatable(
        _ app: XCUIApplication,
        screen: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // System chrome and system-formatted values aren't the app's strings:
        // navigation bar buttons (e.g. Back) and date pickers.
        let systemFrames = (app.navigationBars.buttons.allElementsBoundByIndex
            + app.datePickers.descendants(matching: .any).allElementsBoundByIndex)
            .map(\.frame)
        let elements = app.staticTexts.allElementsBoundByIndex
            + app.buttons.allElementsBoundByIndex
        var bracketed = 0
        for element in elements where element.exists {
            let label = element.label
            guard label.rangeOfCharacter(from: .letters) != nil else { continue }
            if label.contains("[#") { bracketed += 1; continue }
            // Dates are formatted by the system for the user's language.
            if Self.dateIdentifiers.contains(element.identifier) { continue }
            if systemFrames.contains(element.frame) { continue }
            XCTFail("[\(screen)] Not translatable: '\(label)' "
                + "(id '\(element.identifier)')", file: file, line: line)
        }
        // Guards against the pseudo-language not taking effect at all.
        XCTAssertGreaterThan(bracketed, 0, "[\(screen)] No bracketed text found",
                             file: file, line: line)
    }

    private static let dateIdentifiers: Set<String> = ["attemptRow", "attemptDate"]

    @MainActor
    func testWelcomeAndEnrollFlow() {
        let app = launch(seeded: false)
        let start = app.buttons["startFirstChallengeButton"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        assertTranslatable(app, screen: "Welcome")

        start.tap()
        let pushUps = app.buttons["builtIn.pushups"]
        XCTAssertTrue(pushUps.waitForExistence(timeout: 5))
        assertTranslatable(app, screen: "Add challenge")

        pushUps.tap()
        let next = app.buttons["enrollNextButton"]
        for step in 1...3 {
            XCTAssertTrue(labelContaining("Step \(step) of 4", in: app)
                .waitForExistence(timeout: 5))
            assertTranslatable(app, screen: "Enroll step \(step)")
            next.tap()
        }
        XCTAssertTrue(labelContaining("Step 4 of 4", in: app).waitForExistence(timeout: 5))
        assertTranslatable(app, screen: "Enroll step 4")
    }

    @MainActor
    func testListChallengeScreenAndLogSheet() {
        let app = launch(seeded: true)
        let pushUps = labelContaining("Push-ups", in: app)
        XCTAssertTrue(pushUps.waitForExistence(timeout: 10))
        assertTranslatable(app, screen: "List")

        pushUps.tap()
        let logButton = app.buttons["logAttemptButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        assertTranslatable(app, screen: "Challenge")

        logButton.tap()
        let save = app.buttons["logSaveButton"]
        XCTAssertTrue(save.waitForExistence(timeout: 5))
        assertTranslatable(app, screen: "Log sheet")

        save.tap()
        XCTAssertTrue(app.buttons["logDoneButton"].waitForExistence(timeout: 5))
        assertTranslatable(app, screen: "Log result")
    }
}
