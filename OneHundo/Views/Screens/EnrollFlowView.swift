import SwiftData
import SwiftUI

/// Starting a built-in challenge: intro, test yourself,
/// goal and pace, reminder, Start.
struct EnrollFlowView: View {
    let builtIn: BuiltInChallenge
    /// Called after the challenge is saved, to close the
    /// Add challenge sheet.
    let onStarted: () -> Void

    @Environment(\.modelContext) private var modelContext

    enum Step: Int, CaseIterable {
        case intro, test, goal, reminder
    }

    @State private var step: Step

    /// `startAt` lets UI tests open a later step directly
    /// (see `ScreenHost`).
    init(
        _ builtIn: BuiltInChallenge,
        startAt step: Step = .intro,
        onStarted: @escaping () -> Void
    ) {
        self.builtIn = builtIn
        self.onStarted = onStarted
        _step = State(initialValue: step)
    }

    /// Today's test result: the starting count.
    @State private var count = 1
    @State private var goal = 100
    @State private var increase = 1
    @State private var remind = true
    @State private var time = EnrollFlowView.sixPM

    private static let goalChoices = [50, 100, 150, 200]

    /// The default reminder time.
    private static var sixPM: Date {
        let now = Date()
        return Calendar.current.date(
            bySettingHour: 18, minute: 0, second: 0, of: now
        ) ?? now
    }

    private var color: Color { builtIn.color }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
        // Solid backgrounds: the sheet's translucent
        // default lowers text contrast.
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
        // The step count lives here, on a solid background:
        // at the top of the scroll view, iOS fades content
        // under the navigation bar.
        VStack(spacing: 10) {
            let number = step.rawValue + 1
            let total = Step.allCases.count
            Text("Step \(number) of \(total)")
                .font(.subheadline.weight(.medium))
            HStack(spacing: 12) {
                if step != .intro { backButton }
                forwardButton
            }
            .controlSize(.large)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var backButton: some View {
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

    /// Next, or Start on the last step.
    @ViewBuilder
    private var forwardButton: some View {
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
            .disabled(step == .goal && !isGoalValid)
            .accessibilityIdentifier("enrollNextButton")
        }
    }

    private func advance() {
        if step == .test && !isGoalValid {
            goal = count + 10
        }
        move(by: 1)
    }

    private func move(by offset: Int) {
        let index = step.rawValue + offset
        guard let next = Step(rawValue: index)
        else { return }
        withAnimation { step = next }
    }

    private func start() {
        let parts = Calendar.current.dateComponents(
            [.hour, .minute], from: time
        )
        let hour = parts.hour ?? 18
        let minutes = hour * 60 + (parts.minute ?? 0)
        let challenge = Challenge(
            kind: builtIn.id,
            name: builtIn.name,
            colorName: builtIn.colorName,
            startingCount: count,
            goal: goal,
            dailyIncrease: increase,
            reminderEnabled: remind,
            reminderMinutes: minutes
        )
        modelContext.insert(challenge)
        // Today's test is the first attempt.
        challenge.logAttempt(count: count)
        try? modelContext.save()
        onStarted()
    }
}

// The pages of each step, kept apart so the main type
// stays short.
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
                Warm up, then test yourself: do as many as \
                you can in one go, with good form.
                """)
                .foregroundStyle(.secondary)
        }
    }

    private var testYourself: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(builtIn.testQuestion)
                .font(.title2.bold())
            NumberEntry(
                value: $count,
                range: 0...999,
                id: "startingCount"
            )
            Text("""
                This is your starting point. Be honest; \
                small steps add up.
                """)
                .foregroundStyle(.secondary)
        }
    }

    private var goalAndPace: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Set your plan")
                    .font(.title2.bold())
                Text("""
                    You can do \(count) today. \
                    How many do you want to reach?
                    """)
                    .foregroundStyle(.secondary)
            }
            goalPicker
            dailyStep
            planPreview
        }
    }

    private var goalPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal")
                .font(.headline)
            NumberEntry(
                value: $goal, range: 1...9999, id: "goal"
            )
            HStack(spacing: 8) {
                ForEach(quickGoals, id: \.self) {
                    goalChip($0)
                }
            }
        }
    }

    private var dailyStep: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily step")
                .font(.headline)
            Stepper(value: $increase, in: 1...10) {
                Text("\(increase) more each day")
            }
            .accessibilityIdentifier("dailyIncreaseStepper")
            Text("""
                Each day's target is your last result \
                plus this.
                """)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    /// "5 today → 6 tomorrow → 100 goal", plus how long it
    /// should take.
    private var planPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            // One sentence, so it wraps instead of clipping
            // at large text sizes.
            let now = Text("\(count)").bold()
            let next = Text("\(tomorrowTarget)").bold()
            let end = Text("\(goal)").bold()
            Text("""
                \(now) today  →  \(next) tomorrow  →  \
                \(end) goal
                """)
                .font(.title3)
                .monospacedDigit()
                .wrapsText()
                .opacity(isGoalValid ? 1 : 0.4)

            Text(paceText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(paceColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            color.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 14)
        )
    }

    /// A quick goal button; the selected one is filled.
    private func goalChip(_ choice: Int) -> some View {
        let picked = goal == choice
        let ink: Color = picked ? .white : .primary
        let fill = picked
            ? Color.accentColor
            : Color(.tertiarySystemFill)
        return Button {
            goal = choice
        } label: {
            Text("\(choice)")
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundStyle(ink)
                .background(fill, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(picked ? .isSelected : [])
        .accessibilityIdentifier("goalChoice.\(choice)")
    }

    private var isGoalValid: Bool { goal > count }

    private var paceColor: Color {
        isGoalValid ? .primary : .red
    }

    private var tomorrowTarget: Int {
        Progression.target(
            baseline: count, step: increase, goal: goal
        )
    }

    /// The quick goal buttons above today's count.
    private var quickGoals: [Int] {
        Self.goalChoices.filter { $0 > count }
    }

    private var paceText: String {
        Progression.paceText(
            from: count, goal: goal, step: increase
        )
    }

    private var reminder: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Daily reminder")
                .font(.title2.bold())
            Toggle("Remind me each day", isOn: $remind)
            if remind {
                DatePicker(
                    "Time", selection: $time,
                    displayedComponents: .hourAndMinute
                )
            }
            Text("""
                Your reminder time is saved now; \
                notifications arrive in a later update.
                """)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
