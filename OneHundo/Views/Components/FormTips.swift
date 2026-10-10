import SwiftUI

/// A built-in challenge's form tips under a
/// "Good form" heading. On the challenge
/// screen the heading opens and closes
/// them; in the enroll intro (no `isOpen`)
/// they always show.
struct FormTips: View {
  let tips: [String]
  let isOpen: Binding<Bool>?

  init(
    tips: [String],
    isOpen: Binding<Bool>? = nil
  ) {
    self.tips = tips
    self.isOpen = isOpen
  }

  var body: some View {
    if let isOpen {
      DisclosureGroup(isExpanded: isOpen) {
        list.padding(.top, 8)
      } label: {
        heading
      }
    } else {
      LeadingStack(spacing: 8) {
        heading
        list
      }
    }
  }

  private var heading: some View {
    Text("Good form")
      .font(.headline)
      .foregroundStyle(.primary)
  }

  private var list: some View {
    LeadingStack(spacing: 10) {
      ForEach(tips, id: \.self) { tip in
        Label(
          tip,
          systemImage: "checkmark.circle"
        )
        .wrapsText()
      }
    }
    .fullWidth(.leading)
  }
}
