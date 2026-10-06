import Foundation
import SwiftData

// How to change a stored model (add, remove, rename, or retype a property):
// 1. Copy the current `Challenge` and `Attempt` into a new `DataSchemaVn` enum as nested
//    types, like `DataSchemaV1` below. They're frozen: never edit them again.
// 2. Change the top-level models, and point the latest version at them.
// 3. Add the version and a migration stage to `DataMigrationPlan`, and update
//    `AppStore` to open the latest version.
// 4. Test that a store saved by the previous version opens with nothing lost.

// Frozen copies of old stored models: nothing but migration reads them.
// periphery:ignore
/// Version 1 of the stored data: the models as shipped up to 0.4.3, with `icon`.
/// Frozen; only used to read and migrate older stores.
enum DataSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Challenge.self, Attempt.self] }

    @Model
    final class Challenge {
        var id: UUID = UUID()
        var kind: String = "custom"
        var name: String = ""
        var unitRaw: String = "reps"
        var icon: String = "figure.strengthtraining.traditional"
        var colorName: String = "orange"
        var startingCount: Int = 0
        var goal: Int = 100
        var dailyIncrease: Int = 1
        var reminderEnabled: Bool = true
        var reminderMinutes: Int = 1080
        var createdDate: Date = Date()
        var completedDate: Date?
        @Relationship(deleteRule: .cascade, inverse: \Attempt.challenge)
        var attempts: [Attempt]? = []

        init() {}
    }

    @Model
    final class Attempt {
        var date: Date = Date()
        var count: Int = 0
        var challenge: Challenge?

        init() {}
    }
}

/// Version 2 (0.4.4): `Challenge.icon` removed. The current top-level models.
enum DataSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [Challenge.self, Attempt.self] }
}

/// Every stored-data version, oldest first, and the steps between them.
enum DataMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [DataSchemaV1.self, DataSchemaV2.self] }
    static var stages: [MigrationStage] {
        // Dropping a property needs no custom code: SwiftData does it automatically.
        [.lightweight(fromVersion: DataSchemaV1.self, toVersion: DataSchemaV2.self)]
    }
}
