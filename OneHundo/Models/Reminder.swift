import Foundation

/// One daily reminder: a challenge's
/// notification on one day, e.g. "Push-ups"
/// / "Try for 6 today."
///
/// Each day is its own notification rather
/// than one repeating one, so a logged day
/// can be skipped and each day's text has
/// that day's target.
struct Reminder: Equatable {
  /// Unique per challenge and day.
  let id: String
  let title: String
  let body: String
  /// When it shows.
  let date: Date
}

extension Challenge {
  /// Whether it sends reminders: turned on,
  /// and not completed.
  var remindsDaily: Bool {
    reminderEnabled && !isCompleted
  }

  /// The reminder text for `day`, e.g. "Try
  /// for 6 today."
  func reminderText(
    on day: Date,
    in cal: Calendar = .current
  ) -> String {
    let count = target(on: day, in: cal)
    let text = unit.format(count)
    return String(
      localized: "Try for \(text) today."
    )
  }

  /// Its reminders for `days` days from
  /// `now`'s day, at its reminder time.
  /// Skips times already past and days
  /// already logged.
  func reminders(
    days: Int,
    from now: Date,
    in cal: Calendar = .current
  ) -> [Reminder] {
    let today = cal.startOfDay(for: now)
    let hour = reminderMinutes / 60
    let minute = reminderMinutes % 60
    return (0..<days).compactMap { offset in
      guard
        let day = cal.date(
          byAdding: .day,
          value: offset,
          to: today
        ),
        let date = cal.date(
          bySettingHour: hour,
          minute: minute,
          second: 0,
          of: day
        ),
        date > now,
        attempt(on: day, in: cal) == nil
      else { return nil }
      return Reminder(
        id: "\(id.uuidString).\(offset)",
        title: displayName,
        body: reminderText(on: day, in: cal),
        date: date
      )
    }
  }
}

/// Which reminders to schedule.
enum ReminderPlan {
  /// Days ahead to schedule. Opening the
  /// app schedules them again, so the
  /// window moves on.
  static let days = 14
  /// iOS keeps at most 64 pending
  /// notifications per app.
  static let limit = 64

  /// Every challenge's reminders, soonest
  /// first, up to `limit`.
  static func reminders(
    for challenges: [Challenge],
    now: Date,
    in cal: Calendar = .current
  ) -> [Reminder] {
    let all = challenges
      .filter(\.remindsDaily)
      .flatMap {
        $0.reminders(
          days: days, from: now, in: cal
        )
      }
    let sorted = all.sorted {
      ($0.date, $0.id) < ($1.date, $1.id)
    }
    return Array(sorted.prefix(limit))
  }
}
