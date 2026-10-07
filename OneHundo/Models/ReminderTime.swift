import Foundation

/// A daily reminder time, stored as minutes
/// after midnight (18:00 is 1080).
///
/// The time picker edits a `Date`, so each
/// time is also a moment on one fixed day in
/// GMT; the picker shows it in GMT too. GMT
/// has no daylight saving, so the time shown
/// is always the time stored.
enum ReminderTime {
  /// 18:00, the default.
  static let sixPM = 18 * 60

  private static let day = 24 * 60

  /// `minutes` after midnight, as a moment
  /// on the fixed day.
  static func date(minutes: Int) -> Date {
    Date(
      timeIntervalSinceReferenceDate:
        TimeInterval(minutes * 60)
    )
  }

  /// The minutes after midnight of a moment
  /// on the fixed day (any day works).
  static func minutes(of date: Date) -> Int {
    let seconds = date
      .timeIntervalSinceReferenceDate
    let total = Int(seconds) / 60
    return (total % day + day) % day
  }
}
