import SwiftData
import SwiftUI

/// The Calendar tab: a month of days, each
/// marked with the shape of every challenge
/// logged that day. Swipe or use the arrows
/// to change month; tap a marked day for
/// its attempts.
struct CalendarView: View {
  @Query(sort: \Challenge.createdDate)
  private var challenges: [Challenge]
  @Environment(\.now)
  private var now
  @Environment(\.calendar)
  private var cal
  /// The month shown, once moved away from
  /// the current one.
  @State private var shown: CalendarMonth?

  /// Between columns, in the grid and the
  /// weekday row alike.
  private static let spacing: CGFloat = 4

  private static let columns = Array(
    repeating: GridItem(
      .flexible(), spacing: spacing
    ),
    count: 7
  )

  private var month: CalendarMonth {
    shown ?? CalendarMonth(
      containing: now, in: cal
    )
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 16) {
          header
          VStack(spacing: 8) {
            weekdays
            grid
          }
          if CalendarLog.isEmpty(
            month, for: challenges, in: cal
          ) {
            hint
          }
        }
        .padding()
      }
      .testID("calendarGrid")
      .simultaneousGesture(swipe)
      .navigationTitle("Calendar")
      .navigationDestination(
        for: Date.self
      ) { DayView($0) }
      .navigationDestination(
        for: Challenge.self
      ) { ChallengeDetailView($0) }
    }
  }

  /// The month's name between arrows.
  private var header: some View {
    HStack {
      Button {
        shown = month.adding(-1)
      } label: {
        Label(
          "Previous month",
          systemImage: "chevron.left"
        )
      }
      Spacer()
      Text(
        month.start,
        format: .dateTime.month(.wide).year()
      )
      .font(.title3.bold())
      .testID("monthTitle")
      Spacer()
      Button {
        shown = month.adding(1)
      } label: {
        Label(
          "Next month",
          systemImage: "chevron.right"
        )
      }
      .disabled(month.isLatest(now: now))
    }
    .labelStyle(.iconOnly)
    .font(.title3)
  }

  /// Under an empty month: what the
  /// calendar shows.
  private var hint: some View {
    Text("""
      Nothing logged this month. Each day \
      you log shows your challenges' shapes.
      """)
      .font(.footnote)
      .foregroundStyle(.secondary)
      .multilineTextAlignment(.center)
      .testID("calendarHint")
  }

  /// The weekday letters, one per column.
  private var weekdays: some View {
    HStack(spacing: Self.spacing) {
      let names = month.weekdays.enumerated()
      ForEach(Array(names), id: \.offset) {
        Text($0.element)
          .font(.caption.bold())
          .foregroundStyle(.secondary)
          .fullWidth()
          .testID("weekday")
      }
    }
    .accessibilityHidden(true)
  }

  private var grid: some View {
    LazyVGrid(
      columns: Self.columns, spacing: 8
    ) {
      ForEach(month.slots, id: \.self) {
        slot($0)
      }
    }
  }

  @ViewBuilder
  private func slot(
    _ slot: CalendarMonth.Slot
  ) -> some View {
    switch slot {
    case .blank:
      Color.clear
    case .day(let day):
      cell(day)
    }
  }

  /// A day; one with attempts opens them.
  @ViewBuilder
  private func cell(
    _ day: Date
  ) -> some View {
    let entries = CalendarLog.entries(
      for: challenges, on: day, in: cal
    )
    let label = CalendarDay(
      day: day,
      entries: entries,
      isToday: cal.isDate(
        day, inSameDayAs: now
      )
    )
    if entries.isEmpty {
      label
    } else {
      let number = cal.component(
        .day, from: day
      )
      NavigationLink(value: day) { label }
        .buttonStyle(.plain)
        .testID("day.\(number)")
    }
  }

  /// Sideways swipes change the month.
  private var swipe: some Gesture {
    DragGesture(minimumDistance: 30)
      .onEnded { drag in
        shown = month.swiped(
          by: drag.translation.width,
          now: now
        )
      }
  }
}
