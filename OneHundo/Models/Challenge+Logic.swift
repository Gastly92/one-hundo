import Foundation

extension Challenge {
  static let customKind = "custom"

  var unit: CountUnit {
    get {
      CountUnit(rawValue: unitRaw) ?? .reps
    }
    set { unitRaw = newValue.rawValue }
  }

  var isCustom: Bool {
    kind == Self.customKind
  }

  var builtIn: BuiltIn? {
    BuiltIn.with(id: kind)
  }

  /// The name to show: a built-in's name in
  /// the user's language (the stored name is
  /// in whatever language it was started in),
  /// or a custom challenge's own name.
  var displayName: String {
    builtIn?.name ?? name
  }

  /// All attempts, in no particular order,
  /// treating a nil relationship as none.
  /// (Written without `?? []`: SwiftData
  /// returns [] for nil, so that fallback
  /// could never run in tests and would fail
  /// the coverage gate.)
  var allAttempts: [Attempt] {
    let lists = [attempts].compactMap { $0 }
    return Array(lists.joined())
  }

  /// Attempts, newest first.
  var sortedAttempts: [Attempt] {
    allAttempts.sorted { $0.date > $1.date }
  }

  /// The attempt logged on the same calendar
  /// day as `day`, if any. That day counts as
  /// done, including the start day: the
  /// starting test is that day's attempt.
  func attempt(
    on day: Date,
    in cal: Calendar = .current
  ) -> Attempt? {
    allAttempts.first {
      cal.isDate($0.date, inSameDayAs: day)
    }
  }

  /// Card text for `day`: "Try 6 today", or
  /// "Done: 6" once logged.
  func todayText(
    on day: Date = Date(),
    in cal: Calendar = .current
  ) -> String {
    if let done = attempt(on: day, in: cal) {
      let text = unit.format(done.count)
      return String(
        localized: "Done: \(text)"
      )
    }
    let next = target(on: day, in: cal)
    let text = unit.format(next)
    return String(
      localized: "Try \(text) today"
    )
  }

  /// The Today button and card menu item:
  /// "Log attempt", or "Edit today" once
  /// logged.
  func logButtonTitle(
    on day: Date = Date(),
    in cal: Calendar = .current
  ) -> String {
    attempt(on: day, in: cal) == nil
      ? String(localized: "Log attempt")
      : String(localized: "Edit today")
  }

  /// Shown when logging a day that already
  /// has an attempt, which a new log
  /// replaces.
  func replacementNote(
    on day: Date,
    in cal: Calendar = .current
  ) -> String? {
    guard let old = attempt(on: day, in: cal)
    else { return nil }
    let count = unit.format(old.count)
    return String(localized: """
      This replaces the \(count) you logged \
      that day.
      """)
  }

  /// Progress label, e.g. "6 / 100".
  var progressText: String {
    "\(currentCount) / \(goal)"
  }

  /// The count a day's target builds on: the
  /// latest attempt before that day, or the
  /// starting count if there is none. Missed
  /// days don't change it, and logging today
  /// doesn't move today's target.
  func baseline(
    before day: Date,
    in cal: Calendar = .current
  ) -> Int {
    let start = cal.startOfDay(for: day)
    let earlier = allAttempts.filter {
      $0.date < start
    }
    let last = latest(of: earlier)
    return last?.count ?? startingCount
  }

  /// The suggested count for `day`, e.g.
  /// "Try 6 today".
  func target(
    on day: Date = Date(),
    in cal: Calendar = .current
  ) -> Int {
    let base = baseline(before: day, in: cal)
    return Progression.target(
      baseline: base,
      step: dailyIncrease,
      goal: goal
    )
  }

  /// The latest logged count, or the starting
  /// count if nothing is logged yet.
  var currentCount: Int {
    let last = latest(of: allAttempts)
    return last?.count ?? startingCount
  }

  /// Progress toward the goal, from 0 to 1
  /// (current / goal).
  var progress: Double {
    Progression.progress(
      current: currentCount, goal: goal
    )
  }

  /// Estimated days left to reach the goal at
  /// the current pace.
  var daysToGoal: Int {
    Progression.daysToGoal(
      from: currentCount,
      goal: goal,
      step: dailyIncrease
    )
  }

  var isGoalReached: Bool {
    currentCount >= goal
  }

  /// The highest count ever, including the
  /// starting test.
  var personalBest: Int {
    best(of: allAttempts)
  }

  /// Number of days with an attempt (the
  /// starting test counts). Missed days are
  /// fine; this is shown instead of a streak.
  func daysLogged(
    in cal: Calendar = .current
  ) -> Int {
    let days = allAttempts.map {
      cal.startOfDay(for: $0.date)
    }
    return Set(days).count
  }

  /// The best count on any day other than
  /// `day`'s, or the starting count. Logging
  /// a day replaces that day's count, so it's
  /// left out when checking for a new best.
  func best(
    excludingDayOf day: Date,
    in cal: Calendar = .current
  ) -> Int {
    let others = allAttempts.filter {
      !cal.isDate($0.date, inSameDayAs: day)
    }
    return best(of: others)
  }

  /// Logs a count from the Log attempt sheet
  /// and says how it went: whether it hit
  /// that day's target, whether it's a new
  /// personal best, and the next target.
  @discardableResult
  func recordAttempt(
    count: Int,
    on date: Date = Date(),
    in cal: Calendar = .current
  ) -> LogOutcome {
    let dayTarget = target(on: date, in: cal)
    let top = best(
      excludingDayOf: date, in: cal
    )
    logAttempt(
      count: count, on: date, in: cal
    )
    return LogOutcome(
      count: count,
      target: dayTarget,
      goal: goal,
      nextTarget: Progression.target(
        baseline: currentCount,
        step: dailyIncrease,
        goal: goal
      ),
      isNewBest: count > top,
      unit: unit
    )
  }

  /// Logs a count for the day of `date`.
  /// Logging the same day again replaces that
  /// day's count, keeping one attempt per
  /// day.
  @discardableResult
  func logAttempt(
    count: Int,
    on date: Date = Date(),
    in cal: Calendar = .current
  ) -> Attempt {
    if let old = attempt(on: date, in: cal) {
      old.count = count
      old.date = date
      return old
    }
    let new = Attempt(
      date: date, count: count
    )
    modelContext?.insert(new)
    if attempts == nil { attempts = [] }
    attempts?.append(new)
    return new
  }

  /// The most recent of `attempts`, if any.
  private func latest(
    of attempts: [Attempt]
  ) -> Attempt? {
    attempts.max { $0.date < $1.date }
  }

  /// The highest of `attempts` and the
  /// starting count.
  private func best(
    of attempts: [Attempt]
  ) -> Int {
    let top = attempts.map(\.count).max() ?? 0
    return max(startingCount, top)
  }
}

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

  /// Days needed to go from `count` to
  /// `goal`, e.g. 5 to 100 at +1 a day is 95
  /// days.
  static func daysToGoal(
    from count: Int, goal: Int, step: Int
  ) -> Int {
    let remaining = goal - count
    guard remaining > 0 else { return 0 }
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
    guard goal > 0 else { return 0 }
    let ratio = Double(current) / Double(goal)
    return min(max(ratio, 0), 1)
  }
}

/// What the Log attempt sheet shows after
/// saving: a small celebration or an
/// encouraging message, plus the next target.
struct LogOutcome: Equatable {
  let count: Int
  /// That day's target.
  let target: Int
  let goal: Int
  /// The latest count plus the daily
  /// increase, capped at the goal.
  let nextTarget: Int
  let isNewBest: Bool
  let unit: CountUnit

  var hitTarget: Bool { count >= target }
  var reachedGoal: Bool { count >= goal }

  var title: String {
    if reachedGoal {
      String(localized: "Goal reached!")
    } else if hitTarget {
      String(localized: "Nice work!")
    } else {
      String(localized: "Good effort!")
    }
  }

  var message: String {
    let done = unit.format(count)
    if reachedGoal {
      let goalText = unit.format(goal)
      return String(localized: """
        You hit your goal of \(goalText).
        """)
    }
    let nextText = unit.format(nextTarget)
    let next = String(localized: """
      Next time, try for \(nextText).
      """)
    if hitTarget {
      return String(localized: """
        You did \(done). \(next)
        """)
    }
    return String(localized: """
      You did \(done), and every one \
      counts. \(next)
      """)
  }

  /// SF Symbol for the result screen.
  var symbol: String {
    if reachedGoal { return "trophy.fill" }
    return hitTarget
      ? "hands.clap.fill"
      : "arrow.up.forward.circle.fill"
  }
}
