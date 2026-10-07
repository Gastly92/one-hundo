import SwiftData
import SwiftUI

/// Log a new attempt (today by default, or a
/// past day), or edit an existing one. After
/// saving, shows a small celebration or an
/// encouraging message.
struct LogAttemptView: View {
  let challenge: Challenge
  /// The attempt being edited, or nil to log
  /// a new one.
  let attempt: Attempt?

  @Environment(\.dismiss)
  private var dismiss
  @Environment(\.modelContext)
  private var modelContext

  @State private var count: Int
  @State private var date: Date
  @State private var outcome: LogOutcome?
  @State private var bounce = 0
  @ScaledMetric(relativeTo: .largeTitle)
  private var iconSize: CGFloat = 72

  /// E.g. "Monday, January 5".
  private static let dayFormat =
    Date.FormatStyle.dateTime
      .weekday(.wide).month().day()

  /// The latest day that can be picked.
  private let today: Date

  /// `now` is today (a new attempt's default
  /// day). `outcome` lets UI tests open the
  /// result directly (see `ScreenHost`).
  init(
    _ challenge: Challenge,
    editing attempt: Attempt? = nil,
    on now: Date = Date(),
    outcome: LogOutcome? = nil
  ) {
    self.challenge = challenge
    self.attempt = attempt
    today = now
    let start = attempt?.count
      ?? challenge.target(on: now)
    _count = State(initialValue: start)
    let day = attempt?.date ?? now
    _date = State(initialValue: day)
    _outcome = State(initialValue: outcome)
  }

  private var color: Color {
    challenge.color
  }

  private var title: Text {
    attempt == nil
      ? Text("Log attempt")
      : Text("Edit attempt")
  }

  /// Set when a new log would replace that
  /// day's attempt (one attempt per day).
  private var replacementNote: String? {
    guard attempt == nil else {
      return nil
    }
    return challenge
      .replacementNote(on: date)
  }

  var body: some View {
    NavigationStack { page }
      .sensoryFeedback(
        .success, trigger: outcome
      )
  }

  private var page: some View {
    content
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if outcome == nil { buttons }
      }
  }

  @ViewBuilder
  private var content: some View {
    if let outcome {
      result(outcome)
    } else {
      form
    }
  }

  @ToolbarContentBuilder
  private var buttons: some ToolbarContent {
    ToolbarItem(
      placement: .cancellationAction
    ) {
      Button("Cancel") { dismiss() }
    }
    ToolbarItem(
      placement: .confirmationAction
    ) {
      Button("Save") { save() }
        .testID("logSaveButton")
    }
  }

  private var form: some View {
    ScrollView {
      LeadingStack(spacing: 24) {
        Text("How many did you do?")
          .font(.title2.bold())
        NumberEntry(
          value: $count, id: "logCount"
        )
        if challenge.unit != .reps {
          Text(challenge.unit.name)
            .foregroundStyle(.secondary)
            .fullWidth()
        }
        dateRow
        if let replacementNote {
          Text(replacementNote)
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
      }
      .padding()
    }
    .scrollDismissesKeyboard(.interactively)
  }

  /// A new attempt can pick its day; an
  /// edited one keeps its own.
  @ViewBuilder
  private var dateRow: some View {
    if attempt == nil {
      DatePicker(
        "Date",
        selection: $date,
        in: ...today,
        displayedComponents: .date
      )
    } else {
      LabeledContent("Date") {
        Text(date, format: Self.dayFormat)
          .testID("attemptDate")
      }
    }
  }

  private func result(
    _ outcome: LogOutcome
  ) -> some View {
    VStack(spacing: 20) {
      Spacer()
      Image(systemName: outcome.symbol)
        .font(.system(size: iconSize))
        .foregroundStyle(color)
        .symbolEffect(.bounce, value: bounce)
        .accessibilityHidden(true)
      Text(outcome.title)
        .font(.largeTitle.bold())
        .testID("logOutcomeTitle")
      Text(outcome.message)
        .font(.title3)
        .multilineTextAlignment(.center)
        .wrapsText()
        .foregroundStyle(.secondary)
      if outcome.isNewBest { newBest }
      Spacer()
      Button {
        dismiss()
      } label: {
        Text("Done").fullWidth()
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .testID("logDoneButton")
    }
    .padding()
    .onAppear { bounce += 1 }
  }

  private var newBest: some View {
    HStack(spacing: 6) {
      Image(systemName: "star.fill")
        .foregroundStyle(color)
        .accessibilityHidden(true)
      Text("New personal best!")
        .wrapsText()
        .testID("newBestBadge")
    }
    .font(.headline)
    .padding(.horizontal, 14)
    .padding(.vertical, 8)
    .background(
      color.opacity(0.18), in: Capsule()
    )
  }

  private func save() {
    let result = challenge.recordAttempt(
      count: count, on: attempt?.date ?? date
    )
    try? modelContext.save()
    withAnimation { outcome = result }
  }
}
