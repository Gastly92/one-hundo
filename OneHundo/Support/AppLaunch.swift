import SwiftData

/// What the app does at launch: read the launch arguments, open the data store,
/// and seed sample data for UI tests. Kept out of the `App` so it can be unit tested
/// with a fake store.
@MainActor
struct AppLaunch {
    let isUITesting: Bool
    /// The opened store, or the error that stopped it from opening.
    let store: Result<ModelContainer, any Error>
    /// A single screen to show instead of the app (`-showScreen <id>`, UI tests only).
    let screen: ScreenID?

    /// Screens shown with the sample challenges; the rest show an empty app.
    static let seededScreens: Set<ScreenID> = [
        .challengeList, .challengeDetail, .logAttempt, .editAttempt, .logResult,
    ]

    typealias MakeContainer = (_ inMemory: Bool) throws -> ModelContainer

    init(arguments: [String], makeContainer: MakeContainer = AppStore.makeContainer(inMemory:)) {
        // UI tests launch with -uiTesting: an in-memory store, so every run starts clean.
        isUITesting = arguments.contains("-uiTesting")
        let inMemory = isUITesting
        store = Result { try makeContainer(inMemory) }
        let screen = isUITesting ? Self.screen(in: arguments) : nil
        self.screen = screen
        let screenNeedsData = screen.map { Self.seededScreens.contains($0) } ?? false
        let wantsSampleData = isUITesting
            && (arguments.contains("-seedSampleData") || screenNeedsData)
        if wantsSampleData, case .success(let container) = store {
            SampleData.insert(into: container.mainContext)
        }
    }

    /// The screen named after `-showScreen`, if any and if it exists.
    private static func screen(in arguments: [String]) -> ScreenID? {
        guard let flag = arguments.firstIndex(of: "-showScreen"),
              flag + 1 < arguments.count
        else { return nil }
        return ScreenID(rawValue: arguments[flag + 1])
    }
}
