import Foundation

/// Days as numbers, e.g. 20260407 for April
/// 7, 2026. Attempts and challenges store
/// the day they were logged or started on,
/// in the phone's time zone then, and are
/// compared by it, so a day stays put after
/// a move to another time zone.
extension Calendar {
  /// The day `date` falls on here.
  func day(of date: Date) -> Int {
    let parts = dateComponents(
      [.year, .month, .day], from: date
    )
    let year = parts.year ?? 0
    let month = parts.month ?? 0
    return year * 10_000 + month * 100
      + (parts.day ?? 0)
  }

  /// Noon on `day` here: a moment that
  /// shows as that day.
  func noon(of day: Int) -> Date {
    let parts = DateComponents(
      year: day / 10_000,
      month: day / 100 % 100,
      day: day % 100,
      hour: 12
    )
    return date(from: parts) ?? Date()
  }
}

extension Attempt {
  /// Noon on the attempt's day, here: for
  /// showing and editing it as that day.
  func noon(
    in cal: Calendar = .current
  ) -> Date {
    cal.noon(of: day)
  }
}
