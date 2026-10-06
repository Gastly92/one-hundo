import SwiftData
import SwiftUI

/// Shows one screen on its own for UI tests
/// (`-uiTesting -showScreen <id>`), with the sample
/// challenges where it needs them
/// (`AppLaunch.seededScreens`). Every view in
/// `Views/Screens/` must appear here; CI
/// (`check-screens.sh`) fails otherwise.
struct ScreenHost: View {
    let screen: ScreenID

    @Query(sort: \Challenge.createdDate)
    private var challenges: [Challenge]

    /// The seeded Push-ups challenge: started 3 days ago,
    /// with attempts.
    private var pushUps: Challenge? {
        let id = BuiltInChallenge.pushUps.id
        return challenges.first { $0.kind == id }
    }

    private static let sampleOutcome = LogOutcome(
        count: 11, target: 11, goal: 100,
        nextTarget: 12, isNewBest: true, unit: .reps
    )

    private static let sampleError = """
        The file couldn't be saved because the disk is \
        full.
        """

    @ViewBuilder
    var body: some View {
        switch screen {
        case .welcome:
            NavigationStack {
                WelcomeView(onStart: {})
                    .navigationTitle("Challenges")
            }
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
                    ChallengeDetailView(challenge: pushUps)
                }
            }
        case .logAttempt:
            if let pushUps {
                LogAttemptView(pushUps)
            }
        case .editAttempt:
            if let pushUps {
                let last = pushUps.sortedAttempts.first
                LogAttemptView(pushUps, editing: last)
            }
        case .logResult:
            if let pushUps {
                LogAttemptView(
                    pushUps, outcome: Self.sampleOutcome
                )
            }
        case .storeError:
            StoreErrorView(details: Self.sampleError)
        }
    }

    private func enroll(
        at step: EnrollFlowView.Step
    ) -> some View {
        NavigationStack {
            EnrollFlowView(.pushUps, startAt: step) {}
        }
    }
}
