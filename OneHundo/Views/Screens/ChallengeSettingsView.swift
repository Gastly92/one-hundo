import SwiftData
import SwiftUI

/// A challenge's settings, from the gear on
/// its screen: goal, daily step and
/// reminder (plus name, unit and color for
/// custom ones), and Delete challenge.
struct ChallengeSettingsView: View {
  let challenge: Challenge
  /// Called once Delete is confirmed. The
  /// challenge screen deletes it after this
  /// sheet closes, so nothing shows a
  /// deleted challenge.
  let onDelete: (() -> Void)?

  @Environment(\.dismiss)
  private var dismiss
  @Environment(\.modelContext)
  private var modelContext
  @State private var draft: ChallengeDraft
  @State private var confirming = false

  init(
    _ challenge: Challenge,
    onDelete: (() -> Void)? = nil
  ) {
    self.challenge = challenge
    self.onDelete = onDelete
    _draft = State(
      initialValue: ChallengeDraft(challenge)
    )
  }

  private var goalNote: String {
    draft.goalText(
      current: challenge.currentCount
    )
  }

  var body: some View {
    NavigationStack { page }
  }

  private var page: some View {
    form
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { buttons }
      .confirmationDialog(
        "Delete \(challenge.displayName)?",
        isPresented: $confirming,
        titleVisibility: .visible
      ) {
        Button(
          "Delete challenge",
          role: .destructive
        ) { delete() }
      } message: {
        Text("""
          This deletes the challenge and \
          all its attempts. You can't undo \
          this.
          """)
      }
  }

  private var form: some View {
    Form {
      if challenge.isCustom {
        CustomSections(draft: $draft)
      }
      PlanSections(
        draft: $draft,
        goals: ChallengeDraft.goals,
        note: goalNote
      )
      Section {
        Button(
          "Delete challenge",
          role: .destructive
        ) {
          confirming = true
        }
        .testID("deleteChallenge")
      }
    }
    .scrollDismissesKeyboard(.interactively)
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
        .disabled(!draft.canSave)
        .testID("settingsSave")
    }
  }

  private func save() {
    draft.apply(to: challenge)
    try? modelContext.save()
    dismiss()
  }

  private func delete() {
    onDelete?()
    dismiss()
  }
}
