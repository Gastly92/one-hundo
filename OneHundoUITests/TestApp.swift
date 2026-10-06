import XCTest

extension XCUIApplication {
    /// Launches the app for a UI test with a fresh in-memory store, optionally filled
    /// with sample challenges. If Thread Sanitizer finds a data race, the app stops,
    /// so the test fails.
    @MainActor
    static func launchForTesting(
        seeded: Bool = false,
        arguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"] + (seeded ? ["-seedSampleData"] : []) + arguments
        app.launchEnvironment["TSAN_OPTIONS"] = "halt_on_error=1"
        app.launch()
        return app
    }
}
