import XCTest

extension XCUIApplication {
    /// Launches the app for a UI test with a fresh
    /// in-memory store, optionally filled with sample
    /// challenges. If Thread Sanitizer finds a data race,
    /// the app stops, so the test fails.
    @MainActor
    static func start(
        seeded: Bool = false,
        arguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        let seed = seeded ? ["-seedSampleData"] : []
        app.launchArguments =
            ["-uiTesting"] + seed + arguments
        let tsan = "halt_on_error=1"
        app.launchEnvironment["TSAN_OPTIONS"] = tsan
        app.launch()
        return app
    }

    /// Launches straight into one screen (see `ScreenID`
    /// and the app's `ScreenHost`).
    @MainActor
    static func start(
        screen: ScreenID, arguments: [String] = []
    ) -> XCUIApplication {
        let show = ["-showScreen", screen.rawValue]
        return start(arguments: show + arguments)
    }
}

extension XCUIElement {
    /// Waits up to `seconds` for the element to exist.
    @MainActor
    func appears(within seconds: TimeInterval = 5) -> Bool {
        waitForExistence(timeout: seconds)
    }

    /// Waits up to `seconds` for the element to go away.
    @MainActor
    func disappears(
        within seconds: TimeInterval = 5
    ) -> Bool {
        waitForNonExistence(timeout: seconds)
    }

    /// A text field's current text.
    @MainActor
    var text: String? { value as? String }
}
