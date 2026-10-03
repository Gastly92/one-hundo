import Foundation

/// Progress toward a daily rep goal (e.g. 100 push-ups).
struct DailyProgress: Equatable {
    let goal: Int
    private(set) var reps: Int = 0

    init(goal: Int = 100, reps: Int = 0) {
        self.goal = max(goal, 1)
        self.reps = max(reps, 0)
    }

    var remaining: Int { max(goal - reps, 0) }
    var isComplete: Bool { reps >= goal }
    var fraction: Double { min(Double(reps) / Double(goal), 1) }

    /// Logs a set of reps. Negative counts are ignored.
    mutating func log(_ count: Int) {
        guard count > 0 else { return }
        reps += count
    }
}
