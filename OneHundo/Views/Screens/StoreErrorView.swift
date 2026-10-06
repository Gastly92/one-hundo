import SwiftUI

/// Shown instead of the app if the data store can't be opened (for example, the
/// phone is out of storage). Nothing is deleted; reopening the app tries again.
///
/// A scrolling page rather than `ContentUnavailableView`, which can't grow or
/// scroll, so its text got clipped and stopped scaling at large text sizes.
struct StoreErrorView: View {
    let details: String

    @ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 48

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: iconSize))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Text("Can't open your challenges")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                // One literal (not joined with +) so it stays translatable.
                Text("""
                    Your data is safe. Close the app and open it again. \
                    If this keeps happening, free up some storage on your \
                    iPhone.
                    """)
                // The system's own error text (already in the user's language).
                Text(details)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("errorDetails")
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(24)
            .padding(.top, 60)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemBackground))
    }
}
