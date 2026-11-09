import SwiftUI

/// The challenge list before any challenge
/// exists: what the app does in three steps,
/// and one button to start. A note on top
/// while iCloud is still checked for
/// challenges (`RestorePhase`).
struct WelcomeView: View {
  let phase: RestorePhase
  let onStart: () -> Void

  var body: some View {
    ScrollView {
      LeadingStack(spacing: 28) {
        note
        header
        steps
        startButton
      }
      .padding()
      .padding(.top, 8)
    }
  }

  private var header: some View {
    LeadingStack(spacing: 8) {
      Text("Get to 100 in one go.")
        .font(.title.bold())
        .testID("welcomeTitle")
      Text("""
        100 push-ups, sit-ups, or anything \
        else, one small step a day.
        """)
        .font(.title3)
        .foregroundStyle(.secondary)
    }
  }

  /// Quiet, not blocking: the button still
  /// works.
  @ViewBuilder
  private var note: some View {
    switch phase {
    case .slow:
      noteLabel(
        """
        Still checking iCloud for your \
        challenges…
        """,
        icon: "icloud"
      )
    case .deciding, .checking, .unsure,
      .done:
      EmptyView()
    }
  }

  private func noteLabel(
    _ text: LocalizedStringKey,
    icon: String
  ) -> some View {
    Label(text, systemImage: icon)
      .font(.subheadline)
      .foregroundStyle(.secondary)
      .wrapsText()
      .testID("restoreNote")
  }

  private var steps: some View {
    LeadingStack(spacing: 22) {
      step(
        number: 1,
        icon: "stopwatch",
        title: "Test yourself",
        detail: """
          Do as many as you can in one go. \
          Say that's 5.
          """
      )
      step(
        number: 2,
        icon: "arrow.up.right",
        title: "Do one more each day",
        detail: """
          Tomorrow, try 6. \
          The app keeps track of your target.
          """
      )
      step(
        number: 3,
        icon: "trophy",
        title: "Reach 100",
        detail: """
          Small steps add up. Missed a day? \
          No problem, pick up where you \
          left off.
          """
      )
    }
  }

  private var startButton: some View {
    Button(action: onStart) {
      Text("Start your first challenge")
        .fullWidth()
    }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
    .testID("welcomeStart")
  }

  private func step(
    number: Int,
    icon: String,
    title: LocalizedStringKey,
    detail: LocalizedStringKey
  ) -> some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(Color.accentColor)
        .frame(width: 48, height: 48)
        .background(
          Color.accentColor.opacity(0.15),
          in: Circle()
        )
        .accessibilityHidden(true)
      LeadingStack(spacing: 4) {
        Text("\(number). \(Text(title))")
          .font(.headline)
        Text(detail)
          .foregroundStyle(.secondary)
          .wrapsText()
      }
    }
    .accessibilityElement(children: .combine)
  }
}
