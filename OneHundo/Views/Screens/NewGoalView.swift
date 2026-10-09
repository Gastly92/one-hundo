import SwiftData
import SwiftUI

/// After reaching a goal (or Set a new
/// goal on a completed challenge): pick a
/// new, higher goal and keep going.
/// Suggests half as much again.
struct NewGoalView: View {
  let challenge: Challenge
  /// Called after Keep going, to close the
  /// sheet.
  let onDone: (() -> Void)?
  /// Shows Cancel: opened as a sheet (from
  /// a completed challenge), not pushed
  /// from the celebration.
  let cancels: Bool

  @Environment(\.dismiss)
  private var dismiss
  @Environment(\.modelContext)
  private var modelContext
  @State private var goal: Int

  /// `goal` starts the entry somewhere
  /// other than the suggestion (UI tests).
  init(
    _ challenge: Challenge,
    goal: Int? = nil,
    cancels: Bool = false,
    onDone: (() -> Void)? = nil
  ) {
    self.challenge = challenge
    self.cancels = cancels
    self.onDone = onDone
    let start = goal
      ?? challenge.suggestedGoal
    _goal = State(initialValue: start)
  }

  private var current: Int {
    challenge.currentCount
  }

  /// "At this pace you'd hit 150 in about
  /// 50 days", or that it must be higher.
  private var note: String {
    Progression.paceText(
      from: current,
      goal: goal,
      step: challenge.dailyIncrease
    )
  }

  var body: some View {
    Form {
      Section {
        NumberEntry(
          value: $goal,
          id: "newGoal",
          range: 1...9999
        )
        .buttonStyle(.borderless)
        Text(note)
          .font(.subheadline)
          .testID("newGoalNote")
      } header: {
        SectionTitle("New goal")
      }
    }
    .scrollDismissesKeyboard(.interactively)
    .safeAreaInset(edge: .bottom) {
      keepGoingBar
    }
    .navigationTitle("Set a new goal")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if cancels { cancel }
    }
  }

  /// Closes the sheet, leaving the
  /// challenge completed.
  private var cancel: some ToolbarContent {
    ToolbarItem(
      placement: .cancellationAction
    ) {
      Button("Cancel") { dismiss() }
    }
  }

  private var keepGoingBar: some View {
    Button {
      keepGoing()
    } label: {
      Text("Keep going").fullWidth()
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .disabled(goal <= current)
    .testID("keepGoing")
    .padding()
    .background(
      Color(.systemGroupedBackground)
    )
  }

  private func keepGoing() {
    challenge.keepGoing(to: goal)
    try? modelContext.save()
    onDone?()
  }
}
