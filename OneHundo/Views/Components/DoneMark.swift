import SwiftUI

/// The green checkmark next to a day's text
/// once it's logged.
struct DoneMark: View {
  var body: some View {
    Image(systemName: "checkmark.circle.fill")
      .foregroundStyle(.green)
      .accessibilityHidden(true)
  }
}
