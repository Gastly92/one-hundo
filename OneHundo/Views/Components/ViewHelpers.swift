import SwiftUI

extension View {
  /// Lets text grow to as many lines as it
  /// needs instead of truncating, e.g. at
  /// large text sizes.
  func wrapsText() -> some View {
    fixedSize(
      horizontal: false, vertical: true
    )
  }

  /// The accessibility identifier UI tests
  /// find this view by.
  func testID(_ id: String) -> some View {
    accessibilityIdentifier(id)
  }

  /// Takes the full width, with the content
  /// placed by `alignment`.
  func fullWidth(
    _ alignment: Alignment = .center
  ) -> some View {
    frame(
      maxWidth: .infinity,
      alignment: alignment
    )
  }
}

/// A `VStack` with its content lined up on
/// the leading edge, the most common stack
/// here.
struct LeadingStack<Content: View>: View {
  let spacing: CGFloat?
  let content: Content

  init(
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.spacing = spacing
    self.content = content()
  }

  var body: some View {
    VStack(
      alignment: .leading, spacing: spacing
    ) {
      content
    }
  }
}
