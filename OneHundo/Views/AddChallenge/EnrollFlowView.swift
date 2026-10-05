import SwiftData
import SwiftUI

/// Starting a built-in challenge: intro, test yourself, goal and pace, reminder, Start.
struct EnrollFlowView: View {
    let builtIn: BuiltInChallenge
    /// Called after the challenge is saved, to close the Add challenge sheet.
    let onStarted: () -> Void

    @Environment(\.modelContext) private var modelContext

    private enum Step: Int, CaseIterable {
        case intro, test, goal, reminder
    }

    @State private var step: Step = .intro
    @State private var startingCount = 1
    @State private var goal = 100
    @State private var dailyIncrease = 1
    @State private var reminderEnabled = true
    @State private var reminderTime = EnrollFlowView.defaultReminderTime

    private static let goalChoices = [50, 100, 150, 200]

    private static var defaultReminderTime: Date {
        Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    }

    private var color: Color { Color(challengeColorName: builtIn.colorName) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Step \(step.rawValue + 1) of \(Step.allCases.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                content
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollDismissesKeyboard(.interactively)
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

    private var intro: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: builtIn.icon)
                .font(.system(size: 64))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity)
            Text(builtIn.summary)
                .font(.title3)
            Text("Good form")
                .font(.headline)
            ForEach(builtIn.tips, id: \.self) { tip in
                Label(tip, systemImage: "checkmark.circle")
                    .foregroundStyle(.primary)
            }
            Text("Warm up, then test yourself: do as many as you can in one go, with good form.")
                .foregroundStyle(.secondary)
        }
    }

    private var testYourself: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("How many \(builtIn.name.lowercased()) can you do in one go?")
                .font(.title2.bold())
            NumberEntry(value: $startingCount, range: 0...999, identifier: "startingCount")
            Text("This is your starting point. Be honest; small steps add up.")
                .foregroundStyle(.secondary)
        }
    }

    private var goalAndPace: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Set your plan")
                    .font(.title2.bold())
                Text("You can do \(startingCount) today. How many do you want to reach?")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Goal")
                    .font(.headline)
                NumberEntry(value: $goal, range: 1...9999, identifier: "goal")
                HStack(spacing: 8) {
                    ForEach(Self.goalChoices.filter { $0 > startingCount }, id: \.self) { choice in
                        Button {
                            goal = choice
                        } label: {
                            Text("\(choice)").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(goal == choice ? Color.accentColor : Color.gray)
                        .accessibilityAddTraits(goal == choice ? .isSelected : [])
                        .accessibilityIdentifier("goalChoice.\(choice)")
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
            HStack(spacing: 8) {
                previewStep(value: startingCount, label: "Today")
                previewArrow
                previewStep(value: tomorrowTarget, label: "Tomorrow")
                previewArrow
                previewStep(value: goal, label: "Goal")
            }
            .opacity(goal > startingCount ? 1 : 0.4)
            .accessibilityElement(children: .combine)

            Text(paceText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(goal > startingCount ? Color.primary : Color.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
    }

    private var tomorrowTarget: Int {
        Progression.target(baseline: startingCount, dailyIncrease: dailyIncrease, goal: goal)
    }

    private var paceText: String {
        Progression.paceText(from: startingCount, goal: goal, dailyIncrease: dailyIncrease)
    }

    private func previewStep(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title2.bold())
                .monospacedDigit()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var previewArrow: some View {
        Image(systemName: "arrow.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
    }

    private var reminder: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Daily reminder")
                .font(.title2.bold())
            Toggle("Remind me each day", isOn: $reminderEnabled)
            if reminderEnabled {
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
            }
            Text("Your reminder time is saved now; notifications arrive in a later update.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            if step != .intro {
                Button {
                    move(by: -1)
                } label: {
                    Text("Back").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
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
        .padding()
        .background(.bar)
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
        let time = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let challenge = Challenge(
            kind: builtIn.id,
            name: builtIn.name,
            icon: builtIn.icon,
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
