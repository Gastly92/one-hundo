import SwiftData

enum AppStore {
    /// Opens the data store: on disk normally, in memory for UI tests.
    static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        try makeContainer(configuration: ModelConfiguration(isStoredInMemoryOnly: inMemory))
    }

    /// Opens the store at its latest data version, migrating older data first.
    static func makeContainer(configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: DataSchemaV2.self),
            migrationPlan: DataMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
