import SwiftData

enum AppStore {
    /// Opens the data store: on disk normally, in memory for UI tests.
    static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        try makeContainer(
            configuration: ModelConfiguration(isStoredInMemoryOnly: inMemory)
        )
    }

    /// Before 1.0 there's no migration plan: SwiftData adapts the store to
    /// simple model changes by itself, and for bigger ones the owner reinstalls
    /// the app. Plan step 9 adds versioned schemas, so App Store users' data is
    /// never lost.
    static func makeContainer(
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        try ModelContainer(
            for: Challenge.self, Attempt.self,
            configurations: configuration
        )
    }
}
