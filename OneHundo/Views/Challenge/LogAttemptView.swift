import SwiftData
import SwiftUI

/// Log a new attempt (today by default, or a past day), or edit an existing one.
/// After saving, shows a small celebration or an encouraging message.
struct LogAttemptView: View {
    let challenge: Challenge
    /// The attempt being edited, or nil to log a new one.
    let attempt: Attempt?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var count: Int
    @State private var date: Date
    @State private var outcome: LogOutcome?
    @State private var bounce = 0

    init(challenge: Challenge, attempt: Attempt?) {
        self.challenge = challenge
        self.attempt = attempt
        _count = State(initialValue: attempt?.count ?? challenge.target())
        _date = State(initialValue: attempt?.date ?? Date())
    }

    private var color: Color { Color(challengeColorName: challenge.colorName) }

    /// The attempt a new log would replace (one attempt per day).
    private var replacedAttempt: Attempt? {
        attempt == nil ? challenge.attempt(on: date) : nil
    }

    var body: some View {
        NavigationStack {
            Group {
                if let outcome {
                    result(outcome)
                } else {
                    form
                }
            }
            .navigationTitle(attempt == nil ? "Log attempt" : "Edit attempt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if outcome == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { save() }
                            .accessibilityIdentifier("logSaveButton")
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: outcome)
    }

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("How many did you do?")
                    .font(.title2.bold())
                NumberEntry(value: $count, range: 0...9999, identifier: "logCount")
                if challenge.unit != .reps {
                    Text(challenge.unit.rawValue)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                if attempt == nil {
                    DatePicker(
                        "Date",
                        selection: $date,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                } else {
                    LabeledContent("Date") {
                        Text(date, format: .dateTime.weekday(.wide).month().day())
                    }
                }

                if let replacedAttempt {
                    let replaced = challenge.unit.format(replacedAttempt.count)
                    Text("This replaces the \(replaced) you logged that day.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func result(_ outcome: LogOutcome) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: outcome.symbol)
                .font(.system(size: 72))
                .foregroundStyle(color)
                .symbolEffect(.bounce, value: bounce)
                .accessibilityHidden(true)
            Text(outcome.title)
                .font(.largeTitle.bold())
                .accessibilityIdentifier("logOutcomeTitle")
            Text(outcome.message)
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if outcome.isNewBest {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .accessibilityHidden(true)
                    Text("New personal best!")
                        .accessibilityIdentifier("newBestBadge")
                }
                .font(.headline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(.white)
                .background(color, in: Capsule())
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Text("Done").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("logDoneButton")
        }
        .padding()
        .onAppear { bounce += 1 }
    }

    private func save() {
        let result = challenge.recordAttempt(count: count, on: attempt?.date ?? date)
        try? modelContext.save()
        withAnimation { outcome = result }
    }
}
