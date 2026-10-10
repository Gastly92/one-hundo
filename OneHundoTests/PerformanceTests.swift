@testable import OneHundo
import XCTest

/// The work behind each screen stays quick
/// with a year of daily attempts. Each limit
/// is about ten times what CI's runners
/// take, so only a real slowdown fails (say,
/// work that grows much faster than the
/// history), never a slow runner.
@MainActor
final class PerformanceTests: XCTestCase {
  /// Days of history: a year.
  private static let days = 365

  /// Three challenges in `store`, each
  /// logged every day for a year.
  private func year(
    in store: TestStore
  ) -> [Challenge] {
    (0..<3).map { _ in
      let challenge = store.pushUps(
        start: 5, goal: 500
      )
      challenge.attempts = (1...Self.days)
        .map {
          Attempt(
            date: day($0), count: $0 + 5
          )
        }
      return challenge
    }
  }

  /// The day after the year.
  private var today: Date {
    day(Self.days + 1)
  }

  /// The list: each card's texts.
  func testListCards() throws {
    let store = try TestStore()
    let all = year(in: store)
    expect("List cards", under: 1) {
      for challenge in all {
        _ = challenge.todayText(
          on: today, in: utc
        )
        _ = challenge.cardDetail
        _ = challenge.progress
        _ = challenge.showsDoneMark(
          on: today, in: utc
        )
      }
    }
  }

  /// A challenge's screen: today, stats,
  /// history and chart.
  func testChallengeScreen() throws {
    let store = try TestStore()
    let all = year(in: store)
    let challenge = all[0]
    expect("Challenge screen", under: 1) {
      _ = challenge.todayText(
        on: today, in: utc
      )
      _ = challenge.personalBest
      _ = challenge.daysLogged(in: utc)
      _ = challenge.daysToGoal
      _ = challenge.sortedAttempts
      _ = challenge.oldestFirst
    }
  }

  /// The calendar: a month's markers.
  func testCalendarMonth() throws {
    let store = try TestStore()
    let all = year(in: store)
    let month = CalendarMonth(
      containing: day(Self.days), in: utc
    )
    expect("Calendar month", under: 3) {
      for date in month.days {
        _ = CalendarLog.entries(
          for: all, on: date, in: utc
        )
      }
      _ = CalendarLog.isEmpty(
        month, for: all, in: utc
      )
    }
  }

  /// Logging today's attempt.
  func testLogAttempt() throws {
    let store = try TestStore()
    let all = year(in: store)
    expect("Log attempt", under: 1) {
      all[0].recordAttempt(
        count: 400, on: today, in: utc
      )
    }
  }

  /// Runs `work` once to warm up, then times
  /// a second run and fails over `limit`
  /// seconds. The time goes in the log.
  private func expect(
    _ name: String,
    under limit: Double,
    _ work: () -> Void
  ) {
    work()
    let time = ContinuousClock()
      .measure(work)
    let seconds = time / .seconds(1)
    print("\(name): \(seconds)s")
    XCTAssertLessThan(
      seconds,
      limit,
      "\(name) took \(seconds)s"
    )
  }
}
