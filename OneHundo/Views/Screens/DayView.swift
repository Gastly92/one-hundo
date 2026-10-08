import SwiftData
import SwiftUI

/// One day from the calendar: each challenge
/// logged that day, its count, and whether
/// it hit that day's target. Tap one for
/// its challenge screen.
struct DayView: View {
  let day: Date

  @Query(sort: \Challenge.createdDate)
  private var challenges: [Challenge]
  @Environment(\.calendar)
  private var cal

  init(_ day: Date) {
    self.day = day
  }

  /// E.g. "Monday, January 5".
  private static let dayFormat =
    Date.FormatStyle.dateTime
      .weekday(.wide).month(.wide).day()

  var body: some View {
    List {
      let entries = CalendarLog.entries(
        for: challenges, on: day, in: cal
      )
      ForEach(entries) { row($0) }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(day, format: Self.dayFormat)
          .font(.headline)
          .testID("dayTitle")
      }
    }
  }

  private func row(
    _ entry: DayEntry
  ) -> some View {
    let challenge = entry.challenge
    let count = challenge.unit.format(
      entry.count
    )
    // The count is centered in the row, in
    // line with the chevron.
    return NavigationLink(value: challenge) {
      HStack {
        label(entry)
        Text(count)
          .font(.title3.bold())
          .monospacedDigit()
      }
    }
    .testID("dayEntry.\(challenge.kind)")
  }

  /// The shape, in line with the name, and
  /// the status below.
  private func label(
    _ entry: DayEntry
  ) -> some View {
    let challenge = entry.challenge
    let shape = challenge.marker.symbol
    return HStack(
      alignment: .firstTextBaseline
    ) {
      Image(systemName: shape)
        .foregroundStyle(challenge.color)
        .accessibilityHidden(true)
      LeadingStack(spacing: 2) {
        Text(challenge.displayName)
          .font(.headline)
        status(entry)
      }
    }
    .fullWidth(.leading)
  }

  /// "Hit the target of 6." with a check,
  /// or how it went otherwise.
  private func status(
    _ entry: DayEntry
  ) -> some View {
    HStack(
      alignment: .firstTextBaseline,
      spacing: 4
    ) {
      if entry.hitTarget { DoneMark() }
      Text(entry.status)
        .wrapsText()
    }
    .font(.subheadline)
    .foregroundStyle(.secondary)
  }
}
