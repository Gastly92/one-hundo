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
      CalendarPlaceholderView()
    case .addChallenge:
      AddChallengeView()
    case .customChallengeComingSoon:
      NavigationStack {
        CustomChallengeComingSoonView()
      }
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
