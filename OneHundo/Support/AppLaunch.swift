import SwiftData

/// What the app does at launch: read the launch arguments,
/// open the data store, and seed sample data for UI tests.
/// Kept out of the `App` so it can be unit tested with a
/// fake store.
@MainActor
struct AppLaunch {
    let isUITesting: Bool
    /// The opened store, or the error that stopped it from
    /// opening.
    let store: Result<ModelContainer, any Error>
    /// A single screen to show instead of the app
    /// (`-showScreen <id>`, UI tests only).
    let screen: ScreenID?

    /// Screens shown with the sample challenges; the rest
    /// show an empty app.
    static let seededScreens: Set<ScreenID> = [
        .challengeList, .challengeDetail,
        .logAttempt, .editAttempt, .logResult,
    ]

    typealias OpenStore =
        (_ inMemory: Bool) throws -> ModelContainer

    init(
        arguments args: [String],
        openStore: OpenStore = AppStore.open(inMemory:)
    ) {
        // UI tests launch with -uiTesting: an in-memory
        // store, so every run starts clean.
        isUITesting = args.contains("-uiTesting")
        let inMemory = isUITesting
        store = Result { try openStore(inMemory) }
        let screen = isUITesting
            ? Self.screen(in: args) : nil
        self.screen = screen
        let needsData = Self.seededScreens.contains {
            $0 == screen
        }
        let seedFlag = args.contains("-seedSampleData")
        if isUITesting, seedFlag || needsData,
           case .success(let container) = store {
            SampleData.insert(into: container.mainContext)
        }
    }

    /// The screen named after `-showScreen`, if any and if
    /// it exists.
    private static func screen(
        in args: [String]
    ) -> ScreenID? {
        guard let flag = args.firstIndex(of: "-showScreen"),
              flag + 1 < args.count
        else { return nil }
        return ScreenID(rawValue: args[flag + 1])
    }
}
