import SwiftData

enum AppStore {
    static func makeContainer(inMemory: Bool) -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(
                for: Challenge.self, Attempt.self,
                configurations: configuration
            )
        } catch {
            fatalError("Could not create the data store: \(error)")
        }
    }
}
