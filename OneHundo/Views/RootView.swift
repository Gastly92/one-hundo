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

  /// What the reminders depend on. Any
  /// change (a log, an edit, new settings,
  /// the app coming back) schedules them
  /// again.
  private struct Sync: Equatable {
    let reminders: [Reminder]
    let phase: ScenePhase
  }

  private var sync: Sync {
    Sync(
      reminders: ReminderPlan.reminders(
        for: challenges, now: now
      ),
      phase: phase
    )
  }

  var body: some View {
    TabView {
      ChallengeListView()
        .tabItem { challengesTab }
      CalendarPlaceholderView()
        .tabItem { calendarTab }
    }
    .task(id: sync) {
      await ReminderSync.update(
        sync.reminders, with: notifier
      )
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
