import Foundation
import SwiftData

/// The stored data as the 1.0 release
/// wrote it. Frozen: never edit these
/// models. To change a stored model, copy
/// them into a `SchemaV2` (the new shape),
/// point the `Challenge` and `Attempt`
/// aliases at it, add it and a V1 → V2
/// stage to `Migrations`, and keep the test
/// that a V1 store opens (`StoreTests`).
enum SchemaV1: VersionedSchema {
  static var versionIdentifier:
    Schema.Version {
    Schema.Version(1, 0, 0)
  }

  static var models:
    [any PersistentModel.Type] {
    [Challenge.self, Attempt.self]
  }
}

/// The models the app uses: the latest
/// schema's.
typealias Challenge = SchemaV1.Challenge
typealias Attempt = SchemaV1.Attempt

/// Every stored-data version, oldest first,
/// and the steps between them.
enum Migrations: SchemaMigrationPlan {
  static var schemas:
    [any VersionedSchema.Type] {
    [SchemaV1.self]
  }

  static var stages: [MigrationStage] { [] }
}

extension SchemaV1 {
  /// A challenge the user has started, e.g.
  /// Push-ups from 5 to 100.
  ///
  /// Follows CloudKit's rules so iCloud sync
  /// can be added later without a migration:
  /// every property has a default,
  /// relationships are optional, and nothing
  /// is unique.
  @Model
  final class Challenge {
    var id = UUID()
    /// A built-in challenge id (see
    /// `BuiltIn`), or
    /// `Challenge.customKind`.
    var kind: String = "custom"
    var name: String = ""
    /// Raw value of `CountUnit`; use `unit`
    /// instead.
    var unitRaw: String = "reps"
    /// Name of a color in the app's palette.
    var colorName: String = "violet"
    /// Raw value of `Marker`; use `marker`
    /// instead.
    var markerName: String = "circle"
    var startingCount: Int = 0
    var goal: Int = 100
    var dailyIncrease: Int = 1
    var reminderEnabled: Bool = true
    /// Reminder time as minutes after
    /// midnight (18:00 by default).
    var reminderMinutes: Int = 1080
    var createdDate = Date.now
    var completedDate: Date?
    @Relationship(
      deleteRule: .cascade,
      inverse: \Attempt.challenge
    )
    var attempts: [Attempt]? = []

    init(
      name: String,
      colorName: String,
      startingCount: Int,
      kind: String = "custom",
      unit: CountUnit = .reps,
      marker: Marker = .circle,
      goal: Int = 100,
      dailyIncrease: Int = 1,
      reminderEnabled: Bool = true,
      reminderMinutes: Int = 1080,
      createdDate: Date = .now
    ) {
      self.kind = kind
      self.name = name
      self.unitRaw = unit.rawValue
      self.colorName = colorName
      self.markerName = marker.rawValue
      self.startingCount = startingCount
      self.goal = goal
      self.dailyIncrease = dailyIncrease
      self.reminderEnabled = reminderEnabled
      self.reminderMinutes = reminderMinutes
      self.createdDate = createdDate
    }
  }

  /// One logged result. There is at most
  /// one attempt per challenge per day
  /// (enforced by `Challenge.logAttempt`,
  /// since CloudKit doesn't allow unique
  /// constraints).
  @Model
  final class Attempt {
    var date = Date.now
    var count: Int = 0
    var challenge: Challenge?

    init(date: Date, count: Int) {
      self.date = date
      self.count = count
    }
  }
}
