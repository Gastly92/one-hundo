import SwiftData
import SwiftUI

/// After reaching a goal (or Continue on a
/// completed challenge): pick a new, higher
/// goal and keep going. Suggests half as
/// much again.
struct NewGoalView: View {
  let challenge: Challenge
  /// Called after Keep going, to close the
  /// sheet.
  let onDone: (() -> Void)?

  @Environment(\.modelContext)
  private var modelContext
  @State private var goal: Int

  init(
    _ challenge: Challenge,
    onDone: (() -> Void)? = nil
  ) {
    self.challenge = challenge
    self.onDone = onDone
    let next = Progression.nextGoal(
      after: challenge.goal
    )
    _goal = State(initialValue: next)
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
