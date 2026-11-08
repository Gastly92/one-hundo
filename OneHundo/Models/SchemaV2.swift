import Foundation
import SwiftData

/// The stored data from 1.1 on: 1.0's
/// models plus a `copyID` on each record,
/// so merging the duplicates iCloud sync
/// can bring keeps the same copy on every
/// device, and when each attempt was
/// logged, so the later log wins
/// (`Duplicates`). Frozen once released.
enum SchemaV2: VersionedSchema {
  static var versionIdentifier:
    Schema.Version {
    Schema.Version(2, 0, 0)
  }

  static var models:
    [any PersistentModel.Type] {
    [Challenge.self, Attempt.self]
  }

  /// Tags every record the 1.0 release
  /// wrote. Each device tags its own data
  /// before sync uploads it, so copies
  /// from two devices never share a tag.
  static func tag(
    _ context: ModelContext
  ) throws {
    let challenges = try context.fetch(
      FetchDescriptor<Challenge>()
    )
    let attempts = try context.fetch(
      FetchDescriptor<Attempt>()
    )
    for challenge in challenges {
      challenge.copyID = UUID()
    }
    for attempt in attempts {
      attempt.copyID = UUID()
    }
    try context.save()
  }
}

extension SchemaV2 {
  /// A challenge the user has started, e.g.
  /// Push-ups from 5 to 100.
  ///
  /// Follows CloudKit's rules: every
  /// property has a default or is optional,
  /// relationships are optional, and
  /// nothing is unique.
  @Model
  final class Challenge {
    var id = UUID()
    /// This copy's own tag (see
    /// `Duplicates`). Never changed.
    var copyID: UUID?
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
    /// The day it started on, where it
    /// started (`Calendar.day(of:)`), so
    /// that day stays the start day after
    /// a move to another time zone.
    var startDay: Int = 0
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
      createdDate: Date = .now,
      in cal: Calendar = .current
    ) {
      copyID = UUID()
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
      startDay = cal.day(of: createdDate)
    }
  }

  /// One logged result. There is at most
  /// one attempt per challenge per day
  /// (enforced by `Challenge.logAttempt`,
  /// since CloudKit doesn't allow unique
  /// constraints).
  @Model
  final class Attempt {
    /// The moment it was logged for.
    var date = Date.now
    /// The day it counts for, where it was
    /// logged (`Calendar.day(of:)`). Days
    /// are compared by this, so a log stays
    /// on its day after a move to another
    /// time zone.
    var day: Int = 0
    var count: Int = 0
    /// That day's target when it was
    /// logged, so history keeps it after the
    /// goal or daily step changes.
    var target: Int = 0
    var challenge: Challenge?
    /// This copy's own tag (see
    /// `Duplicates`). Never changed.
    var copyID: UUID?
    /// When it was last logged or edited,
    /// so merging two devices' logs of a
    /// day keeps the later one. None in
    /// 1.0 data.
    var loggedAt: Date?

    init(
      date: Date,
      count: Int,
      target: Int,
      in cal: Calendar = .current,
      at now: Date = .now
    ) {
      copyID = UUID()
      loggedAt = now
      self.date = date
      day = cal.day(of: date)
      self.count = count
      self.target = target
    }
  }
}
