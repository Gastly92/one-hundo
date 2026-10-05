import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ChallengeListView()
                .tabItem { Label("Challenges", systemImage: "list.bullet.rectangle") }
            CalendarPlaceholderView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
        }
    }
}

/// Stand-in until the calendar lands (plan step 7).
struct CalendarPlaceholderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabHeader(title: "Calendar", identifier: "calendarTitle")
                ContentUnavailableView(
                    "Nothing here yet",
                    systemImage: "calendar",
                    description: Text("Coming soon: your attempts, day by day.")
                )
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("Calendar")
            // Same custom header as the Challenges tab, so titles line up.
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
