import SwiftUI

/// Shown instead of the app if the data store can't be opened (for example, the
/// phone is out of storage). Nothing is deleted; reopening the app tries again.
struct StoreErrorView: View {
    let details: String

    var body: some View {
        ContentUnavailableView {
            Label("Can't open your challenges", systemImage: "exclamationmark.triangle")
        } description: {
            // One literal (not joined with +) so it stays translatable.
            Text("""
                Your data is safe. Close the app and open it again. \
                If this keeps happening, free up some storage on your iPhone.
                """)
        } actions: {
            // The system's own error text (already in the user's language).
            Text(details)
                .accessibilityIdentifier("errorDetails")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
