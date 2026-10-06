import XCTest

/// Runs the app in Xcode's bounded pseudo-language, which
/// wraps every translatable string in "[# ... #]". Visible
/// text without the brackets would stay in English after
/// translation, so each screen fails on any such text.
final class LocalizationTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    private static let pseudo = [
        "-NSSurroundLocalizedStrings", "YES",
    ]

    /// System-formatted text: dates, and the system's own
    /// error description.
    private static let systemIDs: Set<String> = [
        "attemptRow", "attemptDate", "errorDetails",
    ]

    /// Every screen in the app (`ScreenID`), each opened
    /// directly with sample data.
    @MainActor
    func testEveryScreen() {
        for screen in ScreenID.allCases {
            let app = XCUIApplication.start(
                screen: screen, arguments: Self.pseudo
            )
            let text = app.staticTexts.firstMatch
            guard text.appears(within: 10) else {
                XCTFail("[\(screen)] didn't show any text")
                continue
            }
            assertTranslatable(app, screen: screen.rawValue)
            app.terminate()
        }
    }

    /// Fails for each visible text or button label that has
    /// letters but no brackets.
    @MainActor
    private func assertTranslatable(
        _ app: XCUIApplication,
        screen: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        // System chrome and system-formatted values aren't
        // the app's strings: navigation bar buttons (e.g.
        // Back) and date pickers.
        let pickers = app.datePickers
            .descendants(matching: .any)
            .allElementsBoundByIndex
        let bars = app.navigationBars.buttons
            .allElementsBoundByIndex
        let system = (bars + pickers).map(\.frame)
        let texts = app.staticTexts.allElementsBoundByIndex
        let buttons = app.buttons.allElementsBoundByIndex
        var bracketed = 0
        let elements = texts + buttons
        for element in elements where element.exists {
            let label = element.label
            let id = element.identifier
            guard label.contains(where: \.isLetter) else {
                continue
            }
            if label.contains("[#") {
                bracketed += 1
                continue
            }
            if Self.systemIDs.contains(id) { continue }
            if system.contains(element.frame) { continue }
            XCTFail(
                "[\(screen)] Not translatable: '\(label)' "
                    + "(id '\(id)')",
                file: file, line: line
            )
        }
        // Guards against the pseudo-language not taking
        // effect at all.
        XCTAssertGreaterThan(
            bracketed, 0,
            "[\(screen)] No bracketed text found",
            file: file, line: line
        )
    }
}
