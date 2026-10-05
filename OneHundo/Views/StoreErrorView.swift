import SwiftUI

/// Shown instead of the app if the data store can't be opened (for example, the
/// phone is out of storage). Nothing is deleted; reopening the app tries again.
struct StoreErrorView: View {
    let details: String

    var body: some View {
        ContentUnavailableView {
            Label("Can't open your challenges", systemImage: "exclamationmark.triangle")
        } description: {
            Text("Your data is safe. Close the app and open it again. "
                + "If this keeps happening, free up some storage on your iPhone.")
        } actions: {
            Text(details)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
