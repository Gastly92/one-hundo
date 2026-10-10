import Foundation
import SwiftData

/// What the custom challenge form and the
/// settings screen edit, kept apart from the
/// stored challenge until Start or Save.
struct ChallengeDraft {
  /// The quick goal buttons.
  static let goals = [50, 100, 150, 200]

  var name = ""
  var unit = CountUnit.reps
  var colorName = "violet"
  var marker = Marker.star
  /// Today's test (new challenges only).
  var startingCount = 1
  var goal = 100
  var increase = 1
  var remind = true
  /// Minutes after midnight (see
  /// `ReminderTime`).
  var minutes = ReminderTime.sixPM

  /// The reminder time as the time picker
  /// edits it.
  var time: Date {
    get {
      ReminderTime.date(minutes: minutes)
    }
    set {
      minutes = ReminderTime.minutes(
        of: newValue
      )
    }
  }

  private var cleanName: String {
    name.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
  }

  /// Start (custom form): needs a name, and
  /// a goal above today's test.
  var canStart: Bool {
    !cleanName.isEmpty
      && goal > startingCount
  }

  /// Save (settings): needs a name. (A
  /// built-in's is never empty.)
  var canSave: Bool { !cleanName.isEmpty }

  /// Quick goals above today's test.
  var quickGoals: [Int] {
    Self.goals.filter { $0 > startingCount }
  }

  /// Under the goal in the custom form.
  var paceText: String {
    Progression.paceText(
      from: startingCount,
      goal: goal,
      step: increase
    )
  }

  /// Under the goal in settings. A goal at
  /// or below `current` (the latest count)
  /// counts as reached.
  func goalText(current: Int) -> String {
    guard goal > current else {
      let count = unit.format(current)
      return String(localized: """
        You're at \(count), so this goal \
        counts as reached.
        """)
    }
    return Progression.paceText(
      from: current,
      goal: goal,
      step: increase
    )
  }

  /// Starts a custom challenge, with today's
  /// test as its first attempt.
  @discardableResult
  func start(
    into context: ModelContext,
    on date: Date = Date(),
    in cal: Calendar = .current
  ) -> Challenge {
    let challenge = Challenge(
      name: cleanName,
      colorName: colorName,
      startingCount: startingCount,
      unit: unit,
      marker: marker,
      goal: goal,
      dailyIncrease: increase,
      reminderEnabled: remind,
      reminderMinutes: minutes,
      createdDate: date,
      in: cal
    )
    context.insert(challenge)
    challenge.logAttempt(
      count: startingCount, on: date, in: cal
    )
    return challenge
  }

  /// Saves settings. Name, unit, shape and
  /// color only change on custom
  /// challenges.
  func apply(to challenge: Challenge) {
    if challenge.isCustom {
      challenge.name = cleanName
      challenge.unit = unit
      challenge.colorName = colorName
      challenge.marker = marker
    }
    challenge.goal = goal
    challenge.dailyIncrease = increase
    challenge.reminderEnabled = remind
    challenge.reminderMinutes = minutes
    // A goal at or below the current count
    // counts as reached.
    if challenge.isGoalReached {
      challenge.complete()
    }
  }
}

// In an extension, so `ChallengeDraft()`
// still makes a new custom challenge's
// defaults.
extension ChallengeDraft {
  /// A challenge's current settings.
  init(_ challenge: Challenge) {
    name = challenge.name
    unit = challenge.unit
    colorName = challenge.colorName
    marker = challenge.marker
    startingCount = challenge.startingCount
    goal = challenge.goal
    increase = challenge.dailyIncrease
    remind = challenge.reminderEnabled
    minutes = challenge.reminderMinutes
  }
}
