import SwiftData

/// What the app does at launch: read the launch arguments, open the data store,
/// and seed sample data for UI tests. Kept out of the `App` so it can be unit tested
/// with a fake store.
@MainActor
struct AppLaunch {
    let isUITesting: Bool
    /// The opened store, or the error that stopped it from opening.
    let store: Result<ModelContainer, any Error>

    typealias MakeContainer = (_ inMemory: Bool) throws -> ModelContainer

    init(arguments: [String], makeContainer: MakeContainer = AppStore.makeContainer(inMemory:)) {
        // UI tests launch with -uiTesting: an in-memory store, so every run starts clean.
        isUITesting = arguments.contains("-uiTesting")
        let inMemory = isUITesting
        store = Result { try makeContainer(inMemory) }
        let wantsSampleData = isUITesting && arguments.contains("-seedSampleData")
        if wantsSampleData, case .success(let container) = store {
            SampleData.insert(into: container.mainContext)
        }
    }
}
