import SwiftData
import SwiftUI

/// Shows one screen on its own for UI tests
/// (`-uiTesting -showScreen <id>`), with the
/// sample challenges where it needs them
/// (`AppLaunch.seededScreens`). Every view
/// in `Views/Screens/` must appear here; CI
/// (`check-screens.sh`) fails otherwise.
struct ScreenHost: View {
  let screen: ScreenID

  @Query(sort: \Challenge.createdDate)
  private var challenges: [Challenge]
  @Environment(\.now)
  private var now

  /// The seeded Push-ups challenge: started
  /// 3 days ago, with attempts.
  private var pushUps: Challenge? {
    let id = BuiltIn.pushUps.id
    return challenges.first { $0.kind == id }
  }

  /// The seeded Sit-ups, logged today.
  private var sitUps: Challenge? {
    let id = BuiltIn.sitUps.id
    return challenges.first { $0.kind == id }
  }

  /// The seeded Plank, counted in seconds.
  private var plank: Challenge? {
    challenges.first { $0.unit == .seconds }
  }

  private var lastAttempt: Attempt? {
    pushUps?.sortedAttempts.first
  }

  private static let outcome = LogOutcome(
    count: 11,
    target: 11,
    goal: 100,
    nextTarget: 12,
    isNewBest: true,
    unit: .reps
  )

  /// Push-ups misses its target of 11.
  private static let missed = LogOutcome(
    count: 8,
    target: 11,
    goal: 100,
    nextTarget: 9,
    isNewBest: false,
    unit: .reps
  )

  /// Push-ups reaches its goal of 100.
  private static let reached = LogOutcome(
    count: 100,
    target: 11,
    goal: 100,
    nextTarget: 100,
    isNewBest: true,
    unit: .reps
  )

  private static let error = """
    The file couldn't be saved because the \
    disk is full.
    """

  @ViewBuilder
  var body: some View {
    switch screen {
    case .welcome:
      // The list with no challenges yet.
      ChallengeListView()
    case .challengeList:
      ChallengeListView()
    case .calendar:
      CalendarView()
    case .calendarDay, .dayMissed:
      // Today: Sit-ups (target hit) and
      // Pull-ups (started today); with
      // Push-ups short of its target.
      NavigationStack { DayView(now) }
    case .addChallenge, .addInProgress:
      // In progress: the sample built-ins
      // are dimmed.
      AddChallengeView()
    case .customChallenge:
      NavigationStack {
        CustomChallengeView()
      }
    case .customTimed:
      // Seconds: the unit under the count.
      NavigationStack {
        CustomChallengeView(unit: .seconds)
      }
    case .tabs:
      // The app as it opens, with its tab
      // bar.
      RootView(notifier: SilentNotifier())
    case .enrollIntro:
      enroll(at: .intro)
    case .enrollTest:
      enroll(at: .test)
    case .enrollGoal:
      enroll(at: .goal)
    case .enrollReminder:
      enroll(at: .reminder)
    case .challengeDetail:
      if let pushUps {
        NavigationStack {
          ChallengeDetailView(pushUps)
        }
      }
    case .completedList:
      // Push-ups under Completed.
      ChallengeListView()
    case .completedDetail, .noHistory,
      .detailToday:
      // Reached 10, no attempts left, or
      // logged today.
      if let pushUps {
        NavigationStack {
          ChallengeDetailView(pushUps)
        }
      }
    case .logMissed:
      if let pushUps {
        LogAttemptView(
          pushUps,
          on: now,
          outcome: Self.missed
        )
      }
    case .logReplace:
      // Today is logged already.
      if let sitUps {
        LogAttemptView(sitUps, on: now)
      }
    case .logAttempt:
      if let pushUps {
        LogAttemptView(pushUps, on: now)
      }
    case .editAttempt:
      if let pushUps {
        LogAttemptView(
          pushUps,
          editing: lastAttempt,
          on: now
        )
      }
    case .logTimed:
      if let plank {
        LogAttemptView(plank, on: now)
      }
    case .logResult:
      if let pushUps {
        LogAttemptView(
          pushUps,
          on: now,
          outcome: Self.outcome
        )
      }
    case .goalReached:
      if let pushUps {
        LogAttemptView(
          pushUps,
          on: now,
          outcome: Self.reached
        )
      }
    case .newGoal:
      if let pushUps {
        NavigationStack {
          NewGoalView(pushUps, cancels: true)
        }
      }
    case .newGoalLow:
      // At the current count: too low.
      if let pushUps {
        NavigationStack {
          NewGoalView(
            pushUps, goal: 10, cancels: true
          )
        }
      }
    case .challengeSettings,
      .settingsNoReminder:
      if let pushUps {
        ChallengeSettingsView(pushUps)
      }
    case .customSettings:
      if let plank {
        ChallengeSettingsView(plank)
      }
    case .storeError:
      StoreErrorView(details: Self.error)
    }
  }

  private func enroll(
    at step: EnrollFlowView.Step
  ) -> some View {
    NavigationStack {
      EnrollFlowView(.pushUps, startAt: step)
    }
  }
}
