import SwiftUI

struct RootView: View {
  var body: some View {
    TabView {
      ChallengeListView()
        .tabItem { challengesTab }
      CalendarPlaceholderView()
        .tabItem { calendarTab }
    }
  }

  private var challengesTab: some View {
    Label(
      "Challenges",
      systemImage: "list.bullet.rectangle"
    )
  }

  private var calendarTab: some View {
    Label("Calendar", systemImage: "calendar")
  }
}
