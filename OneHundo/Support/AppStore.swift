import SwiftData

enum AppStore {
  /// Opens the data store: on disk with
  /// iCloud sync normally, in memory and
  /// never synced for UI tests.
  ///
  /// `.automatic` syncs with the private
  /// database of the iCloud container the
  /// app is signed with. Builds without
  /// it (CI's), no iCloud account, or
  /// iCloud off for the app in iOS
  /// Settings: it works on the phone alone.
  static func open(
    inMemory: Bool
  ) throws -> ModelContainer {
    try open(ModelConfiguration(
      isStoredInMemoryOnly: inMemory,
      cloudKitDatabase: syncs && !inMemory
        ? .automatic : .none
    ))
  }

  #if CLOUDKIT_SCHEMA
  /// The schema build (`CloudKitSchema`)
  /// keeps the user's data off iCloud's
  /// Development environment.
  private static let syncs = false
  #else
  private static let syncs = true
  #endif

  /// Opens the store at the latest schema,
  /// migrating older data first (see
  /// `SchemaV1`), and merges duplicates
  /// (`Duplicates`).
  static func open(
    _ configuration: ModelConfiguration
  ) throws -> ModelContainer {
    let store = try ModelContainer(
      for: Schema(
        versionedSchema: SchemaV2.self
      ),
      migrationPlan: Migrations.self,
      configurations: configuration
    )
    // A failed merge leaves the copies;
    // the app still opens.
    try? Duplicates.merge(
      in: ModelContext(store)
    )
    return store
  }
}
