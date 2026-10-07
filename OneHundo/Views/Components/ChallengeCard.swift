import SwiftUI

/// A challenge in the list grid: name,
/// today's target, and progress.
struct ChallengeCard: View {
  let challenge: Challenge

  @Environment(\.now)
  private var now
  @Environment(\.dynamicTypeSize)
  private var textSize

  private var color: Color {
    challenge.color
  }
  private var isDoneToday: Bool {
    challenge.attempt(on: now) != nil
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
        // The text above already says this;
        // a 4-point bar isn't a useful
        // target.
        ProgressView(
          value: challenge.progress
        )
          .tint(color)
          .accessibilityHidden(true)
      }
    }
    .padding()
    // Fills its grid cell, so cards in a
    // row match heights.
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
      alignment: .topLeading
    )
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
  /// "Done: 6". At the largest text sizes
  /// the checkmark goes above, so the text
  /// isn't squeezed into breaking mid-word.
  private var today: some View {
    let stack = textSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(
        alignment: .leading, spacing: 4
      ))
      : AnyLayout(HStackLayout(spacing: 4))
    return stack {
      if isDoneToday { DoneMark() }
      Text(challenge.todayText(on: now))
        .wrapsText()
    }
    .font(.title3.bold())
    .frame(
      minHeight: 50, alignment: .topLeading
    )
  }
}
