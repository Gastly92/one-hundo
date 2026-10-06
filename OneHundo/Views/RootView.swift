import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ChallengeListView()
                .tabItem {
                    Label("Challenges", systemImage: "list.bullet.rectangle")
                }
            CalendarPlaceholderView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
        }
    }
}
