import SwiftUI

/// The big title at the top of each tab, with an optional button on the same line.
/// Every tab uses it, so the title stays in the same place when switching tabs.
struct TabHeader<Trailing: View>: View {
    let title: String
    let identifier: String
    @ViewBuilder var trailing: Trailing

    var body: some View {
        Text(title)
            .font(.largeTitle.bold())
            .accessibilityAddTraits(.isHeader)
            .accessibilityIdentifier(identifier)
            .frame(maxWidth: .infinity, alignment: .leading)
            // The button floats on the title's line without changing the row's
            // height, so the title sits in the same place on every tab.
            .overlay(alignment: .trailing) { trailing }
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

extension TabHeader where Trailing == EmptyView {
    init(title: String, identifier: String) {
        self.init(title: title, identifier: identifier) { EmptyView() }
    }
}
