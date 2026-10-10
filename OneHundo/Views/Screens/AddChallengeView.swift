import SwiftData
import SwiftUI

/// The first step of starting a challenge:
/// pick a built-in, or make a custom one.
struct AddChallengeView: View {
  @Environment(\.dismiss)
  private var dismiss
  @Query private var challenges: [Challenge]

  /// One active challenge per built-in; a
  /// completed one can be started again.
  private func isActive(
    _ builtIn: BuiltIn
  ) -> Bool {
    challenges.contains {
      $0.kind == builtIn.id
        && !$0.isCompleted
    }
  }

  var body: some View {
    NavigationStack {
      List {
        builtIns
        custom
      }
      .navigationTitle("Add challenge")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(
        for: BuiltIn.self
      ) { builtIn in
        EnrollFlowView(builtIn) { dismiss() }
      }
      .toolbar { close }
    }
  }

  private var builtIns: some View {
    Section {
      ForEach(BuiltIn.all) { row($0) }
    }
  }

  private func row(
    _ builtIn: BuiltIn
  ) -> some View {
    let active = isActive(builtIn)
    return NavigationLink(value: builtIn) {
      ChoiceRow(
        title: Text(builtIn.name),
        subtitle: active
          ? Text("In progress")
          : Text(builtIn.summary),
        isDimmed: active
      )
    }
    .disabled(active)
    .testID("builtIn.\(builtIn.id)")
  }

  private var custom: some View {
    Section {
      NavigationLink {
        CustomChallengeView { dismiss() }
      } label: {
        ChoiceRow(
          title: Text("Custom challenge"),
          subtitle: Text("""
            Track anything else, like squats.
            """)
        )
      }
      .testID("customChallenge")
    }
  }

  private var close: some ToolbarContent {
    ToolbarItem(
      placement: .cancellationAction
    ) {
      Button("Close") { dismiss() }
    }
  }
}

private struct ChoiceRow: View {
  let title: Text
  let subtitle: Text
  /// Unavailable rows use secondary text
  /// rather than fading the whole row, so
  /// the text keeps enough contrast to read.
  var isDimmed = false

  private var titleColor: Color {
    isDimmed ? .secondary : .primary
  }

  private var subtitleColor: Color {
    isDimmed ? .primary : .secondary
  }

  var body: some View {
    LeadingStack(spacing: 2) {
      title
        .font(.headline)
        .foregroundStyle(titleColor)
      subtitle
        .font(.subheadline)
        .foregroundStyle(subtitleColor)
    }
    .padding(.vertical, 4)
  }
}
