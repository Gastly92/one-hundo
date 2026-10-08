import SwiftUI

/// A day in the calendar grid: its number,
/// and the shape of each challenge logged
/// that day (in its color, up to
/// `CalendarLog.markers`).
struct CalendarDay: View {
  let day: Date
  let entries: [DayEntry]
  let isToday: Bool

  private var shown: [DayEntry] {
    let most = CalendarLog.markers
    return Array(entries.prefix(most))
  }

  var body: some View {
    VStack(spacing: 2) {
      // Shrinks rather than breaking "26"
      // over two lines at large text. Every
      // day has the same weight, so they
      // shrink alike.
      Text(day, format: .dateTime.day())
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .foregroundStyle(
          isToday ? Color.white : .primary
        )
        .background { todayMark }
      markers
    }
    .frame(
      maxWidth: .infinity, minHeight: 44
    )
    .contentShape(Rectangle())
  }

  /// Today: a filled circle behind the
  /// number. Outside the layout, so the
  /// number lines up with the other days.
  @ViewBuilder
  private var todayMark: some View {
    if isToday {
      Circle()
        .fill(Color.accentColor)
        .padding(-6)
    }
  }

  /// Markers are shapes, not text
  /// (VoiceOver reads their names), so they
  /// stop growing where three still fit a
  /// cell. A day without any keeps an empty
  /// row of the same height, so every
  /// day's number lines up.
  private var markers: some View {
    HStack(spacing: 1) {
      if shown.isEmpty {
        Image(systemName: "circle.fill")
          .hidden()
          .accessibilityHidden(true)
      }
      ForEach(shown) { marker($0) }
    }
    .font(.caption2)
    .dynamicTypeSize(
      ...DynamicTypeSize.large
    )
  }

  /// Named for VoiceOver, so a day reads as
  /// "5, Push-ups, Sit-ups".
  private func marker(
    _ entry: DayEntry
  ) -> some View {
    let challenge = entry.challenge
    return Image(
      systemName: challenge.marker.symbol
    )
    .foregroundStyle(challenge.color)
    .accessibilityLabel(
      Text(challenge.displayName)
    )
  }
}
