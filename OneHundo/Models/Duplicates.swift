import Foundation
import SwiftData

/// A stored record with a `copyID`, its
/// own tag that's the same on every device.
protocol Tagged: AnyObject {
  var copyID: UUID? { get }
}

extension Challenge: Tagged {}
extension Attempt: Tagged {}

/// Merges the copies iCloud sync can bring
/// back: the same challenge twice (same
/// `id`), or two attempts on one day ("one
/// attempt per day" is only kept by
/// `logAttempt`). A phone and an iPad that
/// both had the data, or a reinstall that
/// syncs back, can do it.
///
/// Every device merges by itself, maybe at
/// the same time. Each keeps the copy with
/// the lowest `copyID`, so they all keep
/// the same one: two devices each keeping
/// a different copy would delete both.
enum Duplicates {
  /// Merges copies of each challenge, then
  /// each day's attempts, and saves.
  static func merge(
    in context: ModelContext
  ) throws {
    let all = try context.fetch(
      FetchDescriptor<Challenge>()
    )
    let groups = Dictionary(
      grouping: all, by: \.id
    )
    for copies in groups.values {
      let kept = merge(copies, in: context)
      mergeDays(of: kept, in: context)
    }
    if context.hasChanges {
      try context.save()
    }
  }

  /// One copy of a challenge, which takes
  /// the other copies' attempts. Its own
  /// settings stay. Returns the challenge
  /// copies left (all of them if they
  /// can't be merged).
  private static func merge(
    _ copies: [Challenge],
    in context: ModelContext
  ) -> [Challenge] {
    guard let keep = keeper(of: copies)
    else { return copies }
    for copy in copies where copy !== keep {
      let moved = copy.allAttempts
      copy.attempts = []
      keep.attempts =
        keep.allAttempts + moved
      context.delete(copy)
    }
    return [keep]
  }

  /// One attempt a day for each of
  /// `challenges`. The kept copy takes the
  /// last-logged copy's count (as logging
  /// a day again would), and the rest go.
  private static func mergeDays(
    of challenges: [Challenge],
    in context: ModelContext
  ) {
    for challenge in challenges {
      let days = Dictionary(
        grouping: challenge.allAttempts,
        by: \.day
      )
      for copies in days.values {
        merge(
          copies, of: challenge, in: context
        )
      }
    }
  }

  private static func merge(
    _ copies: [Attempt],
    of challenge: Challenge,
    in context: ModelContext
  ) {
    guard let keep = keeper(of: copies),
      let last = copies.max(by: isEarlier)
    else { return }
    keep.count = last.count
    keep.date = last.date
    keep.target = last.target
    keep.loggedAt = last.loggedAt
    let extra = copies.filter {
      $0 !== keep
    }
    challenge.attempts =
      challenge.allAttempts.filter { one in
        !extra.contains { $0 === one }
      }
    for one in extra {
      context.delete(one)
    }
  }

  /// Logged earlier (by `loggedAt`, or
  /// for 1.0 data the moment it's for), or
  /// at the same moment with a lower count.
  private static func isEarlier(
    _ first: Attempt,
    _ second: Attempt
  ) -> Bool {
    (logged(first), first.count)
      < (logged(second), second.count)
  }

  private static func logged(
    _ attempt: Attempt
  ) -> Date {
    attempt.loggedAt ?? attempt.date
  }

  /// The copy to keep: the lowest `copyID`.
  /// None if there's only one, or a copy
  /// has no tag or shares one, since then
  /// devices might not choose alike.
  private static func keeper<Copy: Tagged>(
    of copies: [Copy]
  ) -> Copy? {
    let tags = copies.compactMap {
      $0.copyID?.uuidString
    }
    guard copies.count > 1,
      tags.count == copies.count,
      Set(tags).count == tags.count
    else { return nil }
    return zip(tags, copies)
      .min { $0.0 < $1.0 }?.1
  }
}
