import SwiftData
import SwiftUI

/// Starting a custom challenge, on one form:
/// name, unit, today's test, shape, color,
/// goal, daily step and reminder.
struct CustomChallengeView: View {
  /// Called after the challenge is saved, to
  /// close the Add challenge sheet.
  let onStarted: (() -> Void)?

  @Environment(\.modelContext)
  private var modelContext
  @State private var draft = ChallengeDraft()

  init(onStarted: (() -> Void)? = nil) {
    self.onStarted = onStarted
  }

  var body: some View {
    Form {
      CustomSections(draft: $draft)
      test
      LookSections(draft: $draft)
      PlanSections(
        draft: $draft,
        goals: draft.quickGoals,
        note: draft.paceText
      )
    }
    .scrollDismissesKeyboard(.interactively)
    .safeAreaInset(edge: .bottom) {
      startBar
    }
    .navigationTitle("Custom challenge")
    .navigationBarTitleDisplayMode(.inline)
  }

  private var test: some View {
    Section {
      Text("""
        Warm up, then do as many as you can \
        in one go. This is your starting \
        point.
        """)
        .font(.subheadline)
      NumberEntry(
        value: $draft.startingCount,
        id: "testCount",
        range: 0...999
      )
      .buttonStyle(.borderless)
      if draft.unit != .reps {
        Text(draft.unit.name)
          .foregroundStyle(.secondary)
          .fullWidth()
      }
    } header: {
      SectionTitle("Test yourself")
    }
  }

  /// Start, on a solid background below the
  /// form.
  private var startBar: some View {
    Button {
      start()
    } label: {
      Text("Start").fullWidth()
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .disabled(!draft.canStart)
    .testID("customStart")
    .padding()
    .background(
      Color(.systemGroupedBackground)
    )
  }

  private func start() {
    draft.start(into: modelContext)
    try? modelContext.save()
    onStarted?()
  }
}
