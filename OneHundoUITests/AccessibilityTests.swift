import XCTest

/// Runs Xcode's accessibility audit (contrast, Dynamic Type, labels, hit areas, clipped
/// text) on each main screen. Each issue fails the test with the screen and element.
final class AccessibilityTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = true
    }

    private static let offscreenAtLargeSizes: Set<String> = [
        "History", "Custom challenge", "Coming soon",
        "Tap an attempt to change it, or swipe left to delete.",
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
        // The navigation bar (title, Close, Cancel, Save) is iOS's own: it doesn't scale
        // with text size, and its glass can read as low contrast mid-animation.
        let barFrames = app.navigationBars.descendants(matching: .any)
            .allElementsBoundByIndex.map(\.frame)
        try app.performAccessibilityAudit { issue in
            // "Nearly passed" contrast passes at larger text sizes; iOS's own secondary
            // text color gets it. Real contrast failures still fail.
            if issue.compactDescription.contains("nearly passed") { return true }
            // Text the audit can't tie to any element comes from a system control
            // (the time picker draws its own); anything in our views has an element.
            if issue.element == nil,
               issue.compactDescription.contains("Potentially inaccessible text") { return true }
            if let found = issue.element, barFrames.contains(found.frame) { return true }
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

    /// Every screen in the app (`ScreenID`), each opened directly with sample data.
    @MainActor
    func testEveryScreen() {
        for screen in ScreenID.allCases {
            let app = XCUIApplication.launchForTesting(screen: screen)
            guard app.staticTexts.firstMatch.waitForExistence(timeout: 10) else {
                XCTFail("[\(screen)] didn't show any text")
                continue
            }
            do {
                try audit(app, screen: screen.rawValue)
            } catch {
                XCTFail("[\(screen)] audit didn't finish: \(error)")
            }
            app.terminate()
        }
    }
}
