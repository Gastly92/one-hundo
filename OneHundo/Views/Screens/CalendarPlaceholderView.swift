import SwiftUI

/// Stand-in until the calendar lands (plan step 7).
struct CalendarPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Nothing here yet",
                systemImage: "calendar",
                description: Text("Coming soon: your attempts, day by day.")
            )
            .navigationTitle("Calendar")
        }
    }
}
