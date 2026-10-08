import SwiftData
import SwiftUI

struct RootView: View {
  /// Where reminders go.
  let notifier: any Notifier

  @Query private var challenges: [Challenge]
  @Environment(\.now)
  private var now
  @Environment(\.scenePhase)
  private var phase

  init(notifier: any Notifier) {
    self.notifier = notifier
  }

  /// The reminders to schedule, or nil while
  /// the app isn't in front (in the
  /// background, or behind the permission
  /// prompt). Any change (a log, an edit,
  /// new settings, the app coming back)
  /// schedules them again, so the 14 days
  /// move on.
  private var plan: [Reminder]? {
    guard phase == .active else {
      return nil
    }
    return ReminderPlan.reminders(
      for: challenges, now: now
    )
  }

  var body: some View {
    TabView {
      ChallengeListView()
        .tabItem { challengesTab }
      CalendarView()
        .tabItem { calendarTab }
    }
    .task(id: plan) {
      if let plan {
        await ReminderSync.update(
          plan, with: notifier
        )
      }
    }
  }

  private var challengesTab: some View {
    Label(
      "Challenges",
      systemImage: "list.bullet.rectangle"
    )
  }

  private var calendarTab: some View {
    Label(
      "Calendar", systemImage: "calendar"
    )
  }
}
