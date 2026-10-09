import Foundation
import SwiftData

/// Challenges for UI tests (launched with
/// -uiTesting -seedSampleData).
enum SampleData {
  /// How the sample Push-ups differs, for
  /// screens that show other states.
  enum Variant {
    case standard
    /// Its goal lowered to 10 and reached
    /// ("Reached 10").
    case completed
    /// Its attempts deleted.
    case noHistory
  }

  @MainActor
  static func insert(
    into context: ModelContext,
    now: Date = Date(),
    calendar cal: Calendar = .current,
    variant: Variant = .standard
  ) {
    // 24-hour steps: always an earlier
    // calendar day for sample data.
    func ago(_ days: Int) -> Date {
      now - Double(days) * 86_400
    }

    // Starts `builtIn` with the first log's
    // count, then logs each (days ago,
    // count).
    @discardableResult
    func add(
      _ builtIn: BuiltIn,
      _ logs: [(days: Int, count: Int)]
    ) -> Challenge {
      let first = logs[0]
      let challenge = Challenge(
        name: builtIn.name,
        colorName: builtIn.colorName,
        startingCount: first.count,
        kind: builtIn.id,
        marker: builtIn.marker,
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
      return challenge
    }

    // Logged yesterday: "Try 11 today",
    // "10 / 100".
    let pushUps = add(
      .pushUps, [(3, 8), (1, 10)]
    )
    apply(variant, to: pushUps, in: context)
    // Logged today: "Done: 20", "20 / 100".
    add(.sitUps, [(2, 15), (0, 20)])
    // Started today with a test of 3:
    // "Done: 3" (tomorrow "Try 4"),
    // "3 / 100".
    add(.pullUps, [(0, 3)])

    // A custom challenge in seconds, started
    // 4 days ago (no other challenge starts
    // that day, so the list order is fixed):
    // logged 40 yesterday, so
    // "Try 45 seconds today", "40 / 120".
    let plank = Self.plank(started: ago(4))
    context.insert(plank)
    plank.logAttempt(
      count: 30, on: ago(4), in: cal
    )
    plank.logAttempt(
      count: 40, on: ago(1), in: cal
    )

    try? context.save()
  }

  @MainActor
  private static func apply(
    _ variant: Variant,
    to pushUps: Challenge,
    in context: ModelContext
  ) {
    switch variant {
    case .standard:
      break
    case .completed:
      pushUps.goal = 10
      pushUps.complete()
    case .noHistory:
      for attempt in pushUps.allAttempts {
        context.delete(attempt)
      }
      pushUps.attempts = []
    }
  }

  /// The sample custom challenge: Plank, in
  /// seconds, from 30 up 5 a day to 120.
  private static func plank(
    started: Date
  ) -> Challenge {
    Challenge(
      name: "Plank",
      colorName: "teal",
      startingCount: 30,
      unit: .seconds,
      marker: .diamond,
      goal: 120,
      dailyIncrease: 5,
      createdDate: started
    )
  }
}
