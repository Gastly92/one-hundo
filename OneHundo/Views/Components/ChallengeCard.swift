import SwiftUI

/// A challenge in the list grid: name,
/// today's target, and progress.
struct ChallengeCard: View {
  let challenge: Challenge

  private var color: Color { challenge.color }
  private var isDoneToday: Bool {
    challenge.attempt(on: Date()) != nil
  }

  var body: some View {
    LeadingStack(spacing: 10) {
      Text(challenge.displayName)
        .font(.headline)
        .wrapsText()
      today
      LeadingStack(spacing: 4) {
        Text(challenge.progressText)
          .font(.caption)
          .foregroundStyle(.secondary)
        // The text above already says this; a
        // 4-point bar isn't a useful target.
        ProgressView(
          value: challenge.progress
        )
          .tint(color)
          .accessibilityHidden(true)
      }
    }
    .padding()
    .fullWidth(.leading)
    .background(
      Color(.secondarySystemBackground),
      in: RoundedRectangle(cornerRadius: 16)
    )
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(color.opacity(0.3))
    )
  }

  /// "Try 6 today", or a checkmark and
  /// "Done: 6".
  private var today: some View {
    HStack(spacing: 4) {
      if isDoneToday { DoneMark() }
      Text(challenge.todayText())
        .wrapsText()
    }
    .font(.title3.bold())
    .frame(
      minHeight: 50, alignment: .topLeading
    )
  }
}
