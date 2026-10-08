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

  private var color: Color {
    isToday ? .accentColor : .primary
  }

  var body: some View {
    VStack(spacing: 2) {
      Text(day, format: .dateTime.day())
        .fontWeight(
          isToday ? .bold : .regular
        )
        .foregroundStyle(color)
      HStack(spacing: 1) {
        ForEach(shown) { marker($0) }
      }
      .font(.caption2)
    }
    .frame(
      maxWidth: .infinity, minHeight: 44
    )
    .contentShape(Rectangle())
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
