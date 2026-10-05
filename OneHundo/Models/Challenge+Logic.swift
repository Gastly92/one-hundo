import Foundation

extension Challenge {
    static let customKind = "custom"

    var unit: ChallengeUnit {
        get { ChallengeUnit(rawValue: unitRaw) ?? .reps }
        set { unitRaw = newValue.rawValue }
    }

    var isCustom: Bool { kind == Challenge.customKind }

    var builtIn: BuiltInChallenge? { BuiltInChallenge.with(id: kind) }

    /// Attempts, newest first.
    var sortedAttempts: [Attempt] {
        (attempts ?? []).sorted { $0.date > $1.date }
    }

    /// The attempt logged on the same calendar day as `day`, if any.
    func attempt(on day: Date, calendar: Calendar = .current) -> Attempt? {
        (attempts ?? []).first { calendar.isDate($0.date, inSameDayAs: day) }
    }

    /// The attempt that counts as "done" for `day`. On the day the challenge was
    /// started, the starting test alone doesn't count, so the card still says
    /// "Try 6 today" right after testing yourself at 5.
    func loggedAttempt(on day: Date, calendar: Calendar = .current) -> Attempt? {
        guard let logged = attempt(on: day, calendar: calendar) else { return nil }
        let isStartingTest = calendar.isDate(day, inSameDayAs: createdDate)
            && logged.count == startingCount
        return isStartingTest ? nil : logged
    }

    /// Card text for `day`: "Try 6 today", or "Done: 6" once logged.
    func todayText(on day: Date = Date(), calendar: Calendar = .current) -> String {
        if let logged = loggedAttempt(on: day, calendar: calendar) {
            return "Done: \(unit.format(logged.count))"
        }
        return "Try \(unit.format(target(on: day, calendar: calendar))) today"
    }

    /// The Today button and card menu item: "Log attempt", or "Edit today" once logged.
    func logButtonTitle(on day: Date = Date(), calendar: Calendar = .current) -> String {
        loggedAttempt(on: day, calendar: calendar) == nil ? "Log attempt" : "Edit today"
    }

    /// Shown when logging a day that already has an attempt, which a new log replaces.
    func replacementNote(on day: Date, calendar: Calendar = .current) -> String? {
        guard let existing = attempt(on: day, calendar: calendar) else { return nil }
        return "This replaces the \(unit.format(existing.count)) you logged that day."
    }

    /// Progress label, e.g. "6 / 100".
    var progressText: String { "\(currentCount) / \(goal)" }

    /// The count a day's target builds on: the latest attempt before that day,
    /// or the starting count if there is none. Missed days don't change it, and
    /// logging today doesn't move today's target.
    func baseline(before day: Date, calendar: Calendar = .current) -> Int {
        let startOfDay = calendar.startOfDay(for: day)
        let earlier = (attempts ?? []).filter { $0.date < startOfDay }
        return earlier.max { $0.date < $1.date }?.count ?? startingCount
    }

    /// The suggested count for `day`, e.g. "Try 6 today".
    func target(on day: Date = Date(), calendar: Calendar = .current) -> Int {
        Progression.target(
            baseline: baseline(before: day, calendar: calendar),
            dailyIncrease: dailyIncrease,
            goal: goal
        )
    }

    /// The latest logged count, or the starting count if nothing is logged yet.
    var currentCount: Int {
        (attempts ?? []).max { $0.date < $1.date }?.count ?? startingCount
    }

    /// Progress toward the goal, from 0 to 1 (current / goal).
    var progress: Double {
        Progression.progress(current: currentCount, goal: goal)
    }

    /// Estimated days left to reach the goal at the current pace.
    var daysToGoal: Int {
        Progression.daysToGoal(from: currentCount, goal: goal, dailyIncrease: dailyIncrease)
    }

    var isGoalReached: Bool { currentCount >= goal }

    /// The highest count ever, including the starting test.
    var personalBest: Int {
        max(startingCount, (attempts ?? []).map(\.count).max() ?? 0)
    }

    /// Number of days with an attempt (the starting test counts). Missed days are fine;
    /// this is shown instead of a streak.
    func daysLogged(calendar: Calendar = .current) -> Int {
        Set((attempts ?? []).map { calendar.startOfDay(for: $0.date) }).count
    }

    /// The best count on any day other than `day`'s, or the starting count. Logging
    /// a day replaces that day's count, so it's left out when checking for a new best.
    func best(excludingDayOf day: Date, calendar: Calendar = .current) -> Int {
        let others = (attempts ?? []).filter { !calendar.isDate($0.date, inSameDayAs: day) }
        return max(startingCount, others.map(\.count).max() ?? 0)
    }

    /// Logs a count from the Log attempt sheet and says how it went: whether it hit
    /// that day's target, whether it's a new personal best, and the next target.
    @discardableResult
    func recordAttempt(
        count: Int,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> LogOutcome {
        let dayTarget = target(on: date, calendar: calendar)
        let isNewBest = count > best(excludingDayOf: date, calendar: calendar)
        logAttempt(count: count, on: date, calendar: calendar)
        return LogOutcome(
            count: count,
            target: dayTarget,
            goal: goal,
            nextTarget: Progression.target(
                baseline: currentCount,
                dailyIncrease: dailyIncrease,
                goal: goal
            ),
            isNewBest: isNewBest,
            unit: unit
        )
    }

    /// Logs a count for the day of `date`. Logging the same day again replaces
    /// that day's count, keeping one attempt per day.
    @discardableResult
    func logAttempt(count: Int, on date: Date = Date(), calendar: Calendar = .current) -> Attempt {
        if let existing = attempt(on: date, calendar: calendar) {
            existing.count = count
            existing.date = date
            return existing
        }
        let attempt = Attempt(date: date, count: count)
        modelContext?.insert(attempt)
        if attempts == nil { attempts = [] }
        attempts?.append(attempt)
        return attempt
    }
}

/// Pure target and progress math, kept apart from SwiftData so it is easy to test.
enum Progression {
    /// The last result plus the daily increase, capped at the goal.
    static func target(baseline: Int, dailyIncrease: Int, goal: Int) -> Int {
        min(baseline + max(dailyIncrease, 1), goal)
    }

    /// Days needed to go from `count` to `goal`, e.g. 5 to 100 at +1 a day is 95 days.
    static func daysToGoal(from count: Int, goal: Int, dailyIncrease: Int) -> Int {
        let remaining = goal - count
        guard remaining > 0 else { return 0 }
        let step = max(dailyIncrease, 1)
        return (remaining + step - 1) / step
    }

    /// The enroll preview line, e.g. "At this pace you'd hit 100 in about 95 days."
    static func paceText(from count: Int, goal: Int, dailyIncrease: Int) -> String {
        guard goal > count else { return "Your goal needs to be above \(count)." }
        let days = daysToGoal(from: count, goal: goal, dailyIncrease: dailyIncrease)
        return "At this pace you'd hit \(goal) in about \(days) \(days == 1 ? "day" : "days")."
    }

    /// `current / goal`, clamped to 0...1.
    static func progress(current: Int, goal: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(max(Double(current) / Double(goal), 0), 1)
    }
}

/// What the Log attempt sheet shows after saving: a small celebration or an
/// encouraging message, plus the next target.
struct LogOutcome: Equatable {
    let count: Int
    /// That day's target.
    let target: Int
    let goal: Int
    /// The latest count plus the daily increase, capped at the goal.
    let nextTarget: Int
    let isNewBest: Bool
    let unit: ChallengeUnit

    var hitTarget: Bool { count >= target }
    var reachedGoal: Bool { count >= goal }

    var title: String {
        if reachedGoal { return "Goal reached!" }
        return hitTarget ? "Nice work!" : "Good effort!"
    }

    var message: String {
        if reachedGoal { return "You hit your goal of \(unit.format(goal))." }
        let next = "Next time, try for \(unit.format(nextTarget))."
        if hitTarget { return "You did \(unit.format(count)). \(next)" }
        return "You did \(unit.format(count)), and every one counts. \(next)"
    }

    /// SF Symbol for the result screen.
    var symbol: String {
        if reachedGoal { return "trophy.fill" }
        return hitTarget ? "hands.clap.fill" : "arrow.up.forward.circle.fill"
    }
}
