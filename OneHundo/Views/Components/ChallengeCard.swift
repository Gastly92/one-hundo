import SwiftUI

/// A challenge in the list grid: shape and
/// name, today's target, and progress.
struct ChallengeCard: View {
  let challenge: Challenge

  @Environment(\.now)
  private var now

  private var color: Color {
    challenge.color
  }
  private var symbol: String {
    challenge.marker.symbol
  }

  var body: some View {
    Self.layout(
      name: name,
      today: today,
      detail: Self.detail(
        Text(challenge.cardDetail),
        progress: challenge.progress,
        color: color
      )
    )
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

  /// An empty card's size (one line of each
  /// part), hidden. The Add challenge tile
  /// sits on it, so alone in a row it's as
  /// tall as a card at any text size.
  static var space: some View {
    let blank = Text(verbatim: " ")
    return layout(
      name: blank,
      today: blank,
      detail: detail(
        blank, progress: 0, color: .clear
      )
    )
    .hidden()
  }

  /// The parts, top to bottom, with their
  /// fonts.
  private static func layout(
    name: some View,
    today: some View,
    detail: some View
  ) -> some View {
    LeadingStack(spacing: 10) {
      name.font(.headline)
      today
        .font(.title3.bold())
        .frame(
          minHeight: 50,
          alignment: .topLeading
        )
      detail
    }
    .padding()
  }

  /// The progress text (or completion day)
  /// over a thin bar.
  private static func detail(
    _ text: Text,
    progress: Double,
    color: Color
  ) -> some View {
    LeadingStack(spacing: 4) {
      text
        .font(.caption)
        .foregroundStyle(.secondary)
        .testID("cardDetail")
      // The text above already says this;
      // a 4-point bar isn't a useful
      // target.
      ProgressView(value: progress)
        .tint(color)
        .accessibilityHidden(true)
    }
  }

  /// The name after its shape, which tells
  /// challenges apart without color.
  private var name: some View {
    HStack(alignment: .firstTextBaseline) {
      Image(systemName: symbol)
        .foregroundStyle(color)
        .accessibilityHidden(true)
      Text(challenge.displayName)
        .wrapsText()
    }
  }

  /// "Try 6 today", or a checkmark and
  /// "Done: 6". (At accessibility sizes the
  /// card has the full width, so the
  /// checkmark fits beside the text.)
  private var today: some View {
    HStack(spacing: 4) {
      if challenge.showsDoneMark(on: now) {
        DoneMark()
      }
      Text(challenge.todayText(on: now))
        .wrapsText()
    }
  }
}
