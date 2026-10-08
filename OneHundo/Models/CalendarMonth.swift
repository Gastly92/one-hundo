import Foundation

/// A month in the Calendar tab: its days,
/// and where the 1st sits in its week.
struct CalendarMonth: Equatable {
  /// Midnight on the 1st.
  let start: Date
  private let cal: Calendar

  init(
    containing date: Date,
    in cal: Calendar = .current
  ) {
    self.cal = cal
    let parts = cal.dateComponents(
      [.year, .month], from: date
    )
    start = cal.date(from: parts) ?? date
  }

  /// Each day of the month, at midnight.
  var days: [Date] {
    let count = cal.range(
      of: .day, in: .month, for: start
    )?.count ?? 0
    return (0..<count).compactMap {
      cal.date(
        byAdding: .day, value: $0, to: start
      )
    }
  }

  /// A cell in the month's grid: an empty
  /// one before the 1st, or a day. Each has
  /// its own ID, which a lazy grid needs.
  enum Slot: Hashable {
    case blank(Int)
    case day(Date)
  }

  /// The grid's cells: blanks, then days.
  var slots: [Slot] {
    let blanks = (0..<leadingBlanks)
      .map(Slot.blank)
    return blanks + days.map(Slot.day)
  }

  /// Empty cells before the 1st, so it sits
  /// under its weekday.
  var leadingBlanks: Int {
    let weekday = cal.component(
      .weekday, from: start
    )
    return (weekday - cal.firstWeekday + 7)
      % 7
  }

  /// The weekday letters over the grid,
  /// from the first day of the week.
  var weekdays: [String] {
    let names =
      cal.veryShortStandaloneWeekdaySymbols
    let first = cal.firstWeekday - 1
    return Array(
      names[first...] + names[..<first]
    )
  }

  /// The month `months` later (or earlier,
  /// if negative).
  func adding(_ months: Int) -> Self {
    let date = cal.date(
      byAdding: .month,
      value: months,
      to: start
    ) ?? start
    return Self(containing: date, in: cal)
  }

  /// Whether this is `now`'s month (or
  /// later). Nothing is logged in the
  /// future, so the calendar stops here.
  func isLatest(now: Date) -> Bool {
    let current = Self(
      containing: now, in: cal
    )
    return start >= current.start
  }

  /// The month a sideways swipe of `width`
  /// points leads to: right for the month
  /// before, left for the month after (never
  /// past `now`'s). Short swipes stay.
  func swiped(
    by width: Double, now: Date
  ) -> Self {
    if width > 50 {
      return adding(-1)
    }
    if width < -50, !isLatest(now: now) {
      return adding(1)
    }
    return self
  }
}

/// One challenge's attempt on a calendar
/// day, and how it went.
struct DayEntry: Identifiable {
  let challenge: Challenge
  let count: Int
  /// That day's target.
  let target: Int
  /// The start day, when the count is the
  /// starting test rather than a try at a
  /// target.
  let isTest: Bool

  var id: UUID { challenge.id }

  var hitTarget: Bool {
    !isTest && count >= target
  }

  /// Under the name in the day view.
  var status: String {
    guard !isTest else {
      return String(
        localized: "Starting test"
      )
    }
    let goal = challenge.unit.format(target)
    return hitTarget
      ? String(localized: """
        Hit the target of \(goal).
        """)
      : String(localized: """
        The target was \(goal).
        """)
  }
}

extension Challenge {
  /// The day's attempt, if one was logged.
  func entry(
    on day: Date,
    in cal: Calendar = .current
  ) -> DayEntry? {
    guard
      let done = attempt(on: day, in: cal)
    else { return nil }
    return DayEntry(
      challenge: self,
      count: done.count,
      target: target(on: day, in: cal),
      isTest: cal.isDate(
        day, inSameDayAs: createdDate
      )
    )
  }
}

/// What the calendar shows for a day.
enum CalendarLog {
  /// Markers shown in a day's cell, at most.
  static let markers = 3

  /// Each challenge logged on `day`, in the
  /// order given.
  static func entries(
    for challenges: [Challenge],
    on day: Date,
    in cal: Calendar = .current
  ) -> [DayEntry] {
    challenges.compactMap {
      $0.entry(on: day, in: cal)
    }
  }
}
