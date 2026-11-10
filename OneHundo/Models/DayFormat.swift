import Foundation

extension Date.FormatStyle {
  /// "Thursday, January 15".
  private static let long = Self.dateTime
    .weekday(.wide)
    .month(.wide)
    .day()

  /// "Thu, Jan 15".
  private static let short = Self.dateTime
    .weekday(.abbreviated)
    .month(.abbreviated)
    .day()

  /// How a day reads on screen: long, or
  /// short for lists. A day in another
  /// year than `now` adds its year
  /// ("Thursday, January 15, 2025"), so a
  /// day logged last year isn't read as
  /// this year's. Each locale orders and
  /// spells the parts its own way.
  static func dayText(
    _ day: Date,
    now: Date,
    short: Bool = false,
    in cal: Calendar = .current
  ) -> Self {
    let style = short ? Self.short : long
    let thisYear = cal.isDate(
      day,
      equalTo: now,
      toGranularity: .year
    )
    return thisYear ? style : style.year()
  }
}
