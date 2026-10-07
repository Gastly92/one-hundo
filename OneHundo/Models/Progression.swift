import Foundation

/// Pure target and progress math, kept apart
/// from SwiftData so it is easy to test.
/// `step` is the daily increase.
enum Progression {
  /// The last result plus the daily increase,
  /// capped at the goal.
  static func target(
    baseline: Int, step: Int, goal: Int
  ) -> Int {
    min(baseline + max(step, 1), goal)
  }

  /// The goal after today's test: kept if
  /// it's still ahead of `count`, otherwise
  /// raised to `count` + 10.
  static func goal(
    _ goal: Int, after count: Int
  ) -> Int {
    goal > count ? goal : count + 10
  }

  /// Days needed to go from `count` to
  /// `goal`, e.g. 5 to 100 at +1 a day is 95
  /// days.
  static func daysToGoal(
    from count: Int, goal: Int, step: Int
  ) -> Int {
    let remaining = goal - count
    guard remaining > 0 else {
      return 0
    }
    let perDay = max(step, 1)
    return (remaining + perDay - 1) / perDay
  }

  /// The enroll preview line, e.g. "At this
  /// pace you'd hit 100 in about 95 days."
  static func paceText(
    from count: Int, goal: Int, step: Int
  ) -> String {
    guard goal > count else {
      return String(localized: """
        Your goal needs to be above \(count).
        """)
    }
    let days = daysToGoal(
      from: count, goal: goal, step: step
    )
    // "1 day" / "95 days": the String Catalog
    // has the plural forms.
    let duration = String(
      localized: "\(days) days"
    )
    return String(localized: """
      At this pace you'd hit \(goal) \
      in about \(duration).
      """)
  }

  /// `current / goal`, clamped to 0...1.
  static func progress(
    current: Int, goal: Int
  ) -> Double {
    guard goal > 0 else {
      return 0
    }
    let ratio = Double(current) / Double(goal)
    return min(max(ratio, 0), 1)
  }
}
