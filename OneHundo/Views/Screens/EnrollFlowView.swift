import SwiftData
import SwiftUI

/// Starting a built-in challenge: intro,
/// test yourself, goal and pace, reminder,
/// Start.
struct EnrollFlowView: View {
  let builtIn: BuiltIn
  /// Called after the challenge is saved, to
  /// close the Add challenge sheet.
  let onStarted: (() -> Void)?

  @Environment(\.modelContext)
  private var modelContext

  enum Step: Int, CaseIterable {
    case intro, test, goal, reminder
  }

  @State private var step: Step

  /// `startAt` lets UI tests open a later
  /// step directly (see `ScreenHost`).
  init(
    _ builtIn: BuiltIn,
    startAt step: Step = .intro,
    onStarted: (() -> Void)? = nil
  ) {
    self.builtIn = builtIn
    self.onStarted = onStarted
    _step = State(initialValue: step)
  }

  /// Today's test result: the starting
  /// count.
  @State private var count = 1
  @State private var goal = 100
  @State private var increase = 1
  @State private var remind = true
  /// The reminder time, as `ReminderTime`
  /// keeps it for the picker.
  @State private var time = ReminderTime
    .date(minutes: ReminderTime.sixPM)

  private static let goals =
    [50, 100, 150, 200]

  private var color: Color { builtIn.color }

  var body: some View {
    ScrollView {
      LeadingStack(spacing: 24) {
        content
      }
      .padding()
      .fullWidth(.leading)
    }
    .scrollDismissesKeyboard(.interactively)
    // Solid backgrounds: the sheet's
    // translucent default lowers text
    // contrast.
    .background(Color(.systemBackground))
    .safeAreaInset(edge: .bottom) {
      bottomBar
    }
    .navigationTitle(builtIn.name)
    .navigationBarTitleDisplayMode(.inline)
  }

  @ViewBuilder
  private var content: some View {
    switch step {
    case .intro:
      intro
    case .test:
      testYourself
    case .goal:
      goalAndPace
    case .reminder:
      reminder
    }
  }

  private var bottomBar: some View {
    // The step count lives here, on a solid
    // background: at the top of the scroll
    // view, iOS fades content under the
    // navigation bar.
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
        .frame(
          maxWidth: .infinity, minHeight: 50
        )
        .background(
          Color(.secondarySystemBackground),
          in: .rect(cornerRadius: 12)
        )
    }
    .buttonStyle(.plain)
    .testID("enrollBack")
  }

  /// Next, or Start on the last step.
  @ViewBuilder
  private var forwardButton: some View {
    if step == .reminder {
      Button {
        start()
      } label: {
        Text("Start").fullWidth()
      }
      .buttonStyle(.borderedProminent)
      .testID("enrollStart")
    } else {
      Button {
        advance()
      } label: {
        Text("Next").fullWidth()
      }
      .buttonStyle(.borderedProminent)
      .disabled(step == .goal && !isValid)
      .testID("enrollNext")
    }
  }

  private func advance() {
    if step == .test {
      goal = Progression.goal(
        goal, after: count
      )
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
    let challenge = Challenge(
      name: builtIn.name,
      colorName: builtIn.colorName,
      startingCount: count,
      kind: builtIn.id,
      marker: builtIn.marker,
      goal: goal,
      dailyIncrease: increase,
      reminderEnabled: remind,
      reminderMinutes: ReminderTime.minutes(
        of: time
      )
    )
    modelContext.insert(challenge)
    // Today's test is the first attempt.
    challenge.logAttempt(count: count)
    try? modelContext.save()
    onStarted?()
  }
}

// The pages of each step, kept apart so the
// main type stays short.
extension EnrollFlowView {
  private var intro: some View {
    LeadingStack(spacing: 16) {
      Text(builtIn.summary)
        .font(.title3)
      Text("Good form")
        .font(.headline)
      ForEach(builtIn.tips, id: \.self) {
        tip($0)
      }
      Text("""
        Warm up, then test yourself: do as \
        many as you can in one go, with \
        good form.
        """)
        .foregroundStyle(.secondary)
    }
  }

  private func tip(
    _ text: String
  ) -> some View {
    Label(
      text, systemImage: "checkmark.circle"
    )
    .foregroundStyle(.primary)
  }

  private var testYourself: some View {
    LeadingStack(spacing: 24) {
      Text(builtIn.testQuestion)
        .font(.title2.bold())
      NumberEntry(
        value: $count,
        id: "testCount",
        range: 0...999
      )
      Text("""
        This is your starting point. Be \
        honest; small steps add up.
        """)
        .foregroundStyle(.secondary)
    }
  }

  private var goalAndPace: some View {
    LeadingStack(spacing: 28) {
      LeadingStack(spacing: 8) {
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
    LeadingStack(spacing: 12) {
      Text("Goal")
        .font(.headline)
      NumberEntry(
        value: $goal,
        id: "goal",
        range: 1...9999
      )
      GoalChips(
        goals: quickGoals, goal: $goal
      )
    }
  }

  private var dailyStep: some View {
    LeadingStack(spacing: 8) {
      Text("Daily step")
        .font(.headline)
      Stepper(value: $increase, in: 1...10) {
        Text("\(increase) more each day")
      }
      .testID("dailyIncreaseStepper")
      Text("""
        Each day's target is your last \
        result plus this.
        """)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
  }

  /// "5 today → 6 tomorrow → 100 goal", plus
  /// how long it should take.
  private var planPreview: some View {
    LeadingStack(spacing: 12) {
      // One sentence, so it wraps instead of
      // clipping at large text sizes.
      let now = Text("\(count)").bold()
      let next = Text("\(tomorrow)").bold()
      let end = Text("\(goal)").bold()
      Text("""
        \(now) today  →  \
        \(next) tomorrow  →  \
        \(end) goal
        """)
        .font(.title3)
        .monospacedDigit()
        .wrapsText()
        .opacity(isValid ? 1 : 0.4)

      Text(paceText)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(paceColor)
    }
    .padding()
    .fullWidth(.leading)
    .background(
      color.opacity(0.12),
      in: .rect(cornerRadius: 14)
    )
  }

  private var isValid: Bool { goal > count }

  private var paceColor: Color {
    isValid ? .primary : .red
  }

  private var tomorrow: Int {
    Progression.target(
      baseline: count,
      step: increase,
      goal: goal
    )
  }

  /// The quick goal buttons above today's
  /// count.
  private var quickGoals: [Int] {
    Self.goals.filter { $0 > count }
  }

  private var paceText: String {
    Progression.paceText(
      from: count, goal: goal, step: increase
    )
  }

  private var reminder: some View {
    LeadingStack(spacing: 24) {
      Text("Daily reminder")
        .font(.title2.bold())
      Toggle(
        "Remind me each day", isOn: $remind
      )
      if remind {
        DatePicker(
          "Time",
          selection: $time,
          displayedComponents: .hourAndMinute
        )
        // Times are moments on a fixed day
        // in GMT (see `ReminderTime`).
        .environment(\.timeZone, .gmt)
      }
      Text("""
        On days you haven't logged yet, a \
        notification reminds you at this \
        time.
        """)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
  }
}
