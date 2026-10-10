import Foundation
@testable import OneHundo
import SwiftData

/// A month of training for the App Store
/// screenshots (`AppStoreTests`): the three
/// built-ins and a custom Plank, each
/// logged most days up to `now`.
@MainActor
struct Showcase {
  let context: ModelContext
  let now: Date
  private let cal = Calendar.current

  static func insert(
    into context: ModelContext,
    now: Date
  ) {
    Self(context: context, now: now)
      .insertAll()
  }

  private func insertAll() {
    // 27 days, resting once a week:
    // "Try 41 today", "40 / 100".
    let rests = [8, 15, 22]
    add(
      .pushUps,
      on: (1...27).reversed().filter {
        !rests.contains($0)
      }
    ) { 15 + $0 + $0 / 8 }
    // Every other day: "Try 16 today".
    add(
      .pullUps,
      on: Array(
        stride(from: 25, through: 1, by: -2)
      )
    ) { 3 + $0 }
    // Logged today: "Done: 42".
    add(
      .sitUps,
      on: (0...20).reversed().filter {
        ![4, 10, 17].contains($0)
      }
    ) { 25 + $0 }

    // Every day for two weeks, 5 seconds
    // more each: "95 / 120".
    let plank = Challenge(
      name: "Plank",
      colorName: "teal",
      startingCount: 30,
      unit: .seconds,
      marker: .diamond,
      goal: 120,
      dailyIncrease: 5,
      createdDate: ago(14),
      in: cal
    )
    let days = (1...14).reversed()
    log(plank, on: Array(days)) {
      30 + 5 * $0
    }

    try? context.save()
  }

  private func ago(_ days: Int) -> Date {
    now - Double(days) * 86_400
  }

  /// A built-in started on the first of
  /// `days` with the first count.
  private func add(
    _ kind: BuiltIn,
    on days: [Int],
    count: (Int) -> Int
  ) {
    let challenge = Challenge(
      name: kind.name,
      colorName: kind.colorName,
      startingCount: count(0),
      kind: kind.id,
      marker: kind.marker,
      createdDate: ago(days[0]),
      in: cal
    )
    log(challenge, on: days, count: count)
  }

  /// Logs `challenge` on each of `days`
  /// (days ago, oldest first), the n-th
  /// log's count given by `count`.
  private func log(
    _ challenge: Challenge,
    on days: [Int],
    count: (Int) -> Int
  ) {
    context.insert(challenge)
    for (index, back) in days.enumerated() {
      challenge.logAttempt(
        count: count(index),
        on: ago(back),
        in: cal
      )
    }
  }
}
