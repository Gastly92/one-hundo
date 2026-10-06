import SwiftData

/// Version 1 of the stored data: `Challenge` and `Attempt` as shipped up to 0.4.
///
/// To change a stored model: copy today's `Challenge` and `Attempt` into this enum as
/// nested types (frozen, never edited again), add `DataSchemaV2` listing the changed
/// top-level models, and add a V1 → V2 stage to `DataMigrationPlan`. Then test that
/// a V1 store opens with the new app.
enum DataSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Challenge.self, Attempt.self] }
}

/// Every stored-data version, oldest first, and the steps between them.
enum DataMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [DataSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
