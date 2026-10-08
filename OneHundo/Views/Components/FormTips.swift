import SwiftUI

/// A built-in challenge's form tips under a
/// "Good form" heading that opens and
/// closes, in the enroll intro and on the
/// challenge screen.
struct FormTips: View {
  let tips: [String]
  @Binding var isOpen: Bool

  var body: some View {
    DisclosureGroup(isExpanded: $isOpen) {
      LeadingStack(spacing: 10) {
        ForEach(tips, id: \.self) { tip in
          Label(
            tip,
            systemImage: "checkmark.circle"
          )
          .wrapsText()
        }
      }
      .padding(.top, 8)
      .fullWidth(.leading)
    } label: {
      Text("Good form")
        .font(.headline)
        .foregroundStyle(.primary)
    }
    .testID("formTips")
  }
}
