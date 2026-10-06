import SwiftData
import SwiftUI

/// Starting a built-in challenge: intro, test yourself, goal and pace,
/// reminder, Start.
struct EnrollFlowView: View {
    let builtIn: BuiltInChallenge
    /// Called after the challenge is saved, to close the Add challenge sheet.
    let onStarted: () -> Void

    @Environment(\.modelContext) private var modelContext

    enum Step: Int, CaseIterable {
        case intro, test, goal, reminder
    }

    @State private var step: Step

    /// `startAt` lets UI tests open a later step directly (see `ScreenHost`).
    init(
        builtIn: BuiltInChallenge,
        startAt step: Step = .intro,
        onStarted: @escaping () -> Void
    ) {
        self.builtIn = builtIn
        self.onStarted = onStarted
        _step = State(initialValue: step)
    }
    @State private var startingCount = 1
    @State private var goal = 100
    @State private var dailyIncrease = 1
    @State private var reminderEnabled = true
    @State private var reminderTime = EnrollFlowView.defaultReminderTime

    private static let goalChoices = [50, 100, 150, 200]

    private static var defaultReminderTime: Date {
        Calendar.current.date(
            bySettingHour: 18, minute: 0, second: 0, of: Date()
        ) ?? Date()
    }

    private var color: Color { Color(challengeColorName: builtIn.colorName) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        // Solid backgrounds: the sheet's translucent default lowers text
        // contrast.
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationTitle(builtIn.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .intro: intro
        case .test: testYourself
        case .goal: goalAndPace
        case .reminder: reminder
        }
    }

    private var bottomBar: some View {
        // The step count lives here, on a solid background: at the top of the
        // scroll view, iOS fades content under the navigation bar.
        VStack(spacing: 10) {
            Text("Step \(step.rawValue + 1) of \(Step.allCases.count)")
                .font(.subheadline.weight(.medium))
            buttons
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var buttons: some View {
        HStack(spacing: 12) {
            if step != .intro {
                Button {
                    move(by: -1)
                } label: {
                    Text("Back")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(
                            Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("enrollBackButton")
            }

            if step == .reminder {
                Button {
                    start()
                } label: {
                    Text("Start").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("enrollStartButton")
            } else {
                Button {
                    advance()
                } label: {
                    Text("Next").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(step == .goal && goal <= startingCount)
                .accessibilityIdentifier("enrollNextButton")
            }
        }
        .controlSize(.large)
    }

    private func advance() {
        if step == .test && goal <= startingCount {
            goal = startingCount + 10
        }
        move(by: 1)
    }

    private func move(by offset: Int) {
        guard let next = Step(rawValue: step.rawValue + offset) else { return }
        withAnimation { step = next }
    }

    private func start() {
        let time = Calendar.current.dateComponents(
            [.hour, .minute], from: reminderTime
        )
        let challenge = Challenge(
            kind: builtIn.id,
            name: builtIn.name,
            colorName: builtIn.colorName,
            startingCount: startingCount,
            goal: goal,
            dailyIncrease: dailyIncrease,
            reminderEnabled: reminderEnabled,
            reminderMinutes: (time.hour ?? 18) * 60 + (time.minute ?? 0)
        )
        modelContext.insert(challenge)
        // Today's test is the first attempt.
        challenge.logAttempt(count: startingCount)
        try? modelContext.save()
        onStarted()
    }
}

// The pages of each step, kept apart so the main type stays short.
extension EnrollFlowView {
    private var intro: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(builtIn.summary)
                .font(.title3)
            Text("Good form")
                .font(.headline)
            ForEach(builtIn.tips, id: \.self) { tip in
                Label(tip, systemImage: "checkmark.circle")
                    .foregroundStyle(.primary)
            }
            Text("""
                Warm up, then test yourself: do as many as you can in one go, \
                with good form.
                """)
                .foregroundStyle(.secondary)
        }
    }

    private var testYourself: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(builtIn.testQuestion)
                .font(.title2.bold())
            NumberEntry(
                value: $startingCount, range: 0...999,
                identifier: "startingCount"
            )
            Text("This is your starting point. Be honest; small steps add up.")
                .foregroundStyle(.secondary)
        }
    }

    private var goalAndPace: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Set your plan")
                    .font(.title2.bold())
                Text("""
                    You can do \(startingCount) today. \
                    How many do you want to reach?
                    """)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Goal")
                    .font(.headline)
                NumberEntry(value: $goal, range: 1...9999, identifier: "goal")
                HStack(spacing: 8) {
                    ForEach(quickGoals, id: \.self) { choice in
                        goalChip(choice)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Daily step")
                    .font(.headline)
                Stepper(value: $dailyIncrease, in: 1...10) {
                    Text("\(dailyIncrease) more each day")
                }
                .accessibilityIdentifier("dailyIncreaseStepper")
                Text("Each day's target is your last result plus this.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            planPreview
        }
    }

    /// "5 today → 6 tomorrow → 100 goal", plus how long it should take.
    private var planPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            // One sentence, so it wraps instead of clipping at large text
            // sizes.
            let today = Text("\(startingCount)").bold()
            let tomorrow = Text("\(tomorrowTarget)").bold()
            let target = Text("\(goal)").bold()
            Text("\(today) today  →  \(tomorrow) tomorrow  →  \(target) goal")
                .font(.title3)
                .monospacedDigit()
                .fixedSize(horizontal: false, vertical: true)
                .opacity(goal > startingCount ? 1 : 0.4)

            Text(paceText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(
                    goal > startingCount ? Color.primary : Color.red
                )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
    }

    /// A quick goal button; the selected one is filled.
    private func goalChip(_ choice: Int) -> some View {
        let isSelected = goal == choice
        return Button {
            goal = choice
        } label: {
            Text("\(choice)")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background(
                    isSelected ? Color.accentColor : Color(.tertiarySystemFill),
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("goalChoice.\(choice)")
    }

    private var tomorrowTarget: Int {
        Progression.target(
            baseline: startingCount, dailyIncrease: dailyIncrease, goal: goal
        )
    }

    /// The quick goal buttons above today's count.
    private var quickGoals: [Int] {
        Self.goalChoices.filter { $0 > startingCount }
    }

    private var paceText: String {
        Progression.paceText(
            from: startingCount, goal: goal, dailyIncrease: dailyIncrease
        )
    }

    private var reminder: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Daily reminder")
                .font(.title2.bold())
            Toggle("Remind me each day", isOn: $reminderEnabled)
            if reminderEnabled {
                DatePicker(
                    "Time", selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
            }
            Text("""
                Your reminder time is saved now; notifications arrive in a \
                later update.
                """)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
