import Foundation
import SwiftData

// SwiftData's @Model reads each stored
// property's type from its annotation, so
// they stay written out.
// swiftlint:disable redundant_type_annotation

/// A challenge the user has started, e.g.
/// Push-ups from 5 to 100.
///
/// Follows CloudKit's rules so iCloud sync
/// can be added later without a migration:
/// every property has a default,
/// relationships are optional, and nothing is
/// unique.
@Model
final class Challenge {
  var id: UUID = UUID()
  /// A built-in challenge id (see `BuiltIn`),
  /// or `Challenge.customKind`.
  var kind: String = "custom"
  var name: String = ""
  /// Raw value of `CountUnit`; use `unit`
  /// instead.
  var unitRaw: String = "reps"
  /// Name of a color in the app's palette.
  var colorName: String = "orange"
  var startingCount: Int = 0
  var goal: Int = 100
  var dailyIncrease: Int = 1
  var reminderEnabled: Bool = true
  /// Reminder time as minutes after midnight
  /// (18:00 by default).
  var reminderMinutes: Int = 1080
  var createdDate: Date = Date()
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
    goal: Int = 100,
    dailyIncrease: Int = 1,
    reminderEnabled: Bool = true,
    reminderMinutes: Int = 1080,
    createdDate: Date = Date()
  ) {
    self.kind = kind
    self.name = name
    self.unitRaw = unit.rawValue
    self.colorName = colorName
    self.startingCount = startingCount
    self.goal = goal
    self.dailyIncrease = dailyIncrease
    self.reminderEnabled = reminderEnabled
    self.reminderMinutes = reminderMinutes
    self.createdDate = createdDate
  }
}

/// One logged result. There is at most one
/// attempt per challenge per day (enforced by
/// `Challenge.logAttempt`, since CloudKit
/// doesn't allow unique constraints).
@Model
final class Attempt {
  var date: Date = Date()
  var count: Int = 0
  var challenge: Challenge?

  init(date: Date, count: Int) {
    self.date = date
    self.count = count
  }
}
// swiftlint:enable redundant_type_annotation

enum CountUnit: String, CaseIterable {
  case reps, seconds, minutes

  /// A count with its unit for labels: "6"
  /// for reps, "46 seconds", "1 minute". The
  /// String Catalog holds the plural forms
  /// ("1 second" / "2 seconds").
  func format(_ count: Int) -> String {
    switch self {
    case .reps:
      count.formatted()
    case .seconds:
      String(localized: "\(count) seconds")
    case .minutes:
      String(localized: "\(count) minutes")
    }
  }

  /// The unit's name, shown under the number
  /// when logging, e.g. "seconds".
  var name: String {
    switch self {
    case .reps:
      String(localized: "reps")
    case .seconds:
      String(localized: "seconds")
    case .minutes:
      String(localized: "minutes")
    }
  }
}
