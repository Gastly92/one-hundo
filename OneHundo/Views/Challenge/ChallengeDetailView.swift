import SwiftData
import SwiftUI

/// One challenge: progress ring and stats, today's target with Log attempt, and
/// the attempt history (swipe to edit or delete).
struct ChallengeDetailView: View {
    let challenge: Challenge

    @Environment(\.modelContext) private var modelContext
    @State private var logRequest: LogRequest?
    @ScaledMetric(relativeTo: .largeTitle) private var countSize: CGFloat = 44
    @ScaledMetric(relativeTo: .largeTitle) private var ringSize: CGFloat = 180

    /// Opens the Log attempt sheet, for a new attempt or for editing one.
    private struct LogRequest: Identifiable {
        let id = UUID()
        let attempt: Attempt?
    }

    private var color: Color { Color(challengeColorName: challenge.colorName) }

    var body: some View {
        // Read once per render so the Today section and button agree.
        let todayAttempt = challenge.loggedAttempt(on: Date())

        List {
            Section {
                header
            }
            .listRowBackground(Color.clear)

            Section {
                HStack(spacing: 6) {
                    if todayAttempt != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .accessibilityHidden(true)
                    }
                    Text(challenge.todayText())
                        .accessibilityIdentifier("todayText")
                }
                .font(.title2.bold())

                Button {
                    logRequest = LogRequest(attempt: todayAttempt)
                } label: {
                    Text(todayAttempt == nil ? "Log attempt" : "Edit today")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .listRowSeparator(.hidden)
                .accessibilityIdentifier("logAttemptButton")
            } header: {
                sectionHeader("Today")
            }

            Section {
                if challenge.sortedAttempts.isEmpty {
                    Text("No attempts yet")
                        .foregroundStyle(.secondary)
                }
                ForEach(challenge.sortedAttempts) { attempt in
                    attemptRow(attempt)
                }
                if !challenge.sortedAttempts.isEmpty {
                    // A row rather than a section footer, which has low contrast and
                    // doesn't scale with text size.
                    Text("Tap an attempt to change it, or swipe left to delete.")
                        .font(.footnote)
                        .listRowSeparator(.hidden)
                }
            } header: {
                sectionHeader("History")
            }
        }
        .navigationTitle(challenge.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .sheet(item: $logRequest) { request in
            LogAttemptView(challenge: challenge, attempt: request.attempt)
        }
    }

    /// Section titles in a standard text style, so they scale and read clearly.
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
            .textCase(nil)
    }

    private var header: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 14)
                Circle()
                    .trim(from: 0, to: challenge.progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: challenge.progress)
                VStack(spacing: 2) {
                    Text("\(challenge.currentCount)")
                        .font(.system(size: countSize, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("of \(challenge.goal)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: min(ringSize, 280), height: min(ringSize, 280))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Progress")
            .accessibilityValue(challenge.progressText)

            HStack {
                stat(
                    "Personal best",
                    value: challenge.unit.format(challenge.personalBest),
                    id: "personalBestValue"
                )
                Divider().frame(height: 32)
                stat("Days logged", value: "\(challenge.daysLogged())", id: "daysLoggedValue")
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func stat(_ title: String, value: String, id: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
                .monospacedDigit()
                .accessibilityIdentifier(id)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func attemptRow(_ attempt: Attempt) -> some View {
        Button {
            logRequest = LogRequest(attempt: attempt)
        } label: {
            HStack {
                Text(
                    attempt.date,
                    format: .dateTime.weekday(.abbreviated).month(.abbreviated).day()
                )
                Spacer()
                Text(challenge.unit.format(attempt.count))
                    .bold()
                    .monospacedDigit()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
        .accessibilityHint("Edit this attempt")
        .accessibilityIdentifier("attemptRow")
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                delete(attempt)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                logRequest = LogRequest(attempt: attempt)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button {
                logRequest = LogRequest(attempt: attempt)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                delete(attempt)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func delete(_ attempt: Attempt) {
        challenge.attempts?.removeAll { $0 == attempt }
        modelContext.delete(attempt)
        try? modelContext.save()
    }
}
