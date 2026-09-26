import Foundation

/// A rep-count challenge, e.g. 100 push-ups.
struct Challenge: Equatable {
    var name: String
    var goal: Int
    var completed: Int = 0

    var remaining: Int { max(goal - completed, 0) }
    var isComplete: Bool { completed >= goal }
    var progress: Double { goal > 0 ? min(Double(completed) / Double(goal), 1) : 0 }

    mutating func log(_ reps: Int) {
        guard reps > 0 else { return }
        completed += reps
    }
}
