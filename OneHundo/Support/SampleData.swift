import Foundation
import SwiftData

/// Challenges for UI tests (launched with
/// -uiTesting -seedSampleData).
enum SampleData {
  @MainActor
  static func insert(
    into context: ModelContext,
    now: Date = Date(),
    calendar cal: Calendar = .current
  ) {
    // 24-hour steps: always an earlier
    // calendar day for sample data.
    func ago(_ days: Int) -> Date {
      now - Double(days) * 86_400
    }

    // Starts `builtIn` with the first log's
    // count, then logs each (days ago,
    // count).
    func add(
      _ builtIn: BuiltIn,
      _ logs: [(days: Int, count: Int)]
    ) {
      let first = logs[0]
      let challenge = Challenge(
        kind: builtIn.id,
        name: builtIn.name,
        colorName: builtIn.colorName,
        startingCount: first.count,
        createdDate: ago(first.days)
      )
      context.insert(challenge)
      for log in logs {
        challenge.logAttempt(
          count: log.count,
          on: ago(log.days),
          in: cal
        )
      }
    }

    // Logged yesterday: "Try 11 today",
    // "10 / 100".
    add(.pushUps, [(3, 8), (1, 10)])
    // Logged today: "Done: 20", "20 / 100".
    add(.sitUps, [(2, 15), (0, 20)])
    // Started today with a test of 3:
    // "Done: 3" (tomorrow "Try 4"),
    // "3 / 100".
    add(.pullUps, [(0, 3)])

    try? context.save()
  }
}
