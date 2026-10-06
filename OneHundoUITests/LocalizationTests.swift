import XCTest

/// Runs the app in Xcode's bounded pseudo-language, which wraps every
/// translatable string in "[# ... #]". Visible text without the brackets would
/// stay in English after translation, so each screen fails on any such text.
final class LocalizationTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    /// Fails for each visible text or button label that has letters but no
    /// brackets.
    @MainActor
    private func assertTranslatable(
        _ app: XCUIApplication,
        screen: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // System chrome and system-formatted values aren't the app's strings:
        // navigation bar buttons (e.g. Back) and date pickers.
        let pickerParts = app.datePickers.descendants(matching: .any)
        let systemFrames = (app.navigationBars.buttons.allElementsBoundByIndex
            + pickerParts.allElementsBoundByIndex)
            .map(\.frame)
        let elements = app.staticTexts.allElementsBoundByIndex
            + app.buttons.allElementsBoundByIndex
        var bracketed = 0
        for element in elements where element.exists {
            let label = element.label
            guard label.rangeOfCharacter(from: .letters) != nil else {
                continue
            }
            if label.contains("[#") { bracketed += 1; continue }
            if Self.systemTextIdentifiers.contains(element.identifier) {
                continue
            }
            if systemFrames.contains(element.frame) { continue }
            XCTFail("[\(screen)] Not translatable: '\(label)' "
                + "(id '\(element.identifier)')", file: file, line: line)
        }
        // Guards against the pseudo-language not taking effect at all.
        XCTAssertGreaterThan(
            bracketed, 0, "[\(screen)] No bracketed text found",
            file: file, line: line
        )
    }

    /// System-formatted text: dates, and the system's own error description.
    private static let systemTextIdentifiers: Set<String> = [
        "attemptRow", "attemptDate", "errorDetails",
    ]

    /// Every screen in the app (`ScreenID`), each opened directly with sample
    /// data.
    @MainActor
    func testEveryScreen() {
        for screen in ScreenID.allCases {
            let app = XCUIApplication.launchForTesting(
                screen: screen,
                arguments: ["-NSSurroundLocalizedStrings", "YES"]
            )
            let firstText = app.staticTexts.firstMatch
            guard firstText.waitForExistence(timeout: 10) else {
                XCTFail("[\(screen)] didn't show any text")
                continue
            }
            assertTranslatable(app, screen: screen.rawValue)
            app.terminate()
        }
    }
}
