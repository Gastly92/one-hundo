import SwiftData

enum AppStore {
    /// Opens the data store: on disk normally, in memory for UI tests.
    static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        try makeContainer(configuration: ModelConfiguration(isStoredInMemoryOnly: inMemory))
    }

    static func makeContainer(configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(for: Challenge.self, Attempt.self, configurations: configuration)
    }
}
