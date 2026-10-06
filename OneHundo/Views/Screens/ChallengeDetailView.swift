import SwiftData
import SwiftUI

/// One challenge: progress ring and stats, today's target
/// with Log attempt, and the attempt history (swipe to edit
/// or delete).
struct ChallengeDetailView: View {
    let challenge: Challenge

    @Environment(\.modelContext) private var modelContext
    @State private var sheet: LogSheet?
    @ScaledMetric(relativeTo: .largeTitle)
    private var countSize: CGFloat = 44
    @ScaledMetric(relativeTo: .largeTitle)
    private var ringSize: CGFloat = 180

    /// Opens the Log attempt sheet, for a new attempt or
    /// for editing one.
    private struct LogSheet: Identifiable {
        let id = UUID()
        let attempt: Attempt?
    }

    private static let ringStroke = StrokeStyle(
        lineWidth: 14, lineCap: .round
    )

    /// E.g. "Mon, Jan 5".
    private static let dayFormat = Date.FormatStyle
        .dateTime.weekday(.abbreviated)
        .month(.abbreviated).day()

    private var color: Color { challenge.color }

    var body: some View {
        List {
            Section { header }
                .listRowBackground(Color.clear)
            today
            history
        }
        .navigationTitle(challenge.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        // A detail screen: no tab bar, which would also
        // fade the bottom rows.
        .toolbar(.hidden, for: .tabBar)
        .sheet(item: $sheet) {
            LogAttemptView(challenge, editing: $0.attempt)
        }
    }

    private func showLog(for attempt: Attempt?) {
        sheet = LogSheet(attempt: attempt)
    }

    /// Section titles in a standard text style, so they
    /// scale and read clearly.
    private func sectionHeader(
        _ title: LocalizedStringKey
    ) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
            .textCase(nil)
    }

    private var header: some View {
        VStack(spacing: 20) {
            ring
            stats
        }
        .frame(maxWidth: .infinity)
    }

    private var ring: some View {
        let size = min(ringSize, 280)
        let progress = challenge.progress
        return ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 14)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: Self.ringStroke)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            VStack(spacing: 2) {
                Text("\(challenge.currentCount)")
                    .font(.system(
                        size: countSize,
                        weight: .bold,
                        design: .rounded
                    ))
                    .monospacedDigit()
                Text("of \(challenge.goal)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue(challenge.progressText)
    }

    private var stats: some View {
        let best = challenge.personalBest
        let days = challenge.daysLogged()
        return HStack {
            stat(
                "Personal best",
                value: challenge.unit.format(best),
                id: "personalBestValue"
            )
            Divider().frame(height: 32)
            stat(
                "Days logged",
                value: "\(days)",
                id: "daysLoggedValue"
            )
        }
    }

    private func stat(
        _ title: LocalizedStringKey,
        value: String,
        id: String
    ) -> some View {
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

    /// Today's target and the Log attempt button. Reads
    /// today's attempt once so both agree.
    private var today: some View {
        let attempt = challenge.attempt(on: Date())
        return Section {
            HStack(spacing: 6) {
                if attempt != nil { DoneMark() }
                Text(challenge.todayText())
                    .accessibilityIdentifier("todayText")
            }
            .font(.title2.bold())
            logButton(attempt)
        } header: {
            sectionHeader("Today")
        }
    }

    private func logButton(
        _ attempt: Attempt?
    ) -> some View {
        Button {
            showLog(for: attempt)
        } label: {
            Text(challenge.logButtonTitle())
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .listRowSeparator(.hidden)
        .accessibilityIdentifier("logAttemptButton")
    }

    private var history: some View {
        let attempts = challenge.sortedAttempts
        return Section {
            if attempts.isEmpty {
                Text("No attempts yet")
                    .foregroundStyle(.secondary)
            }
            ForEach(attempts) { attemptRow($0) }
            if !attempts.isEmpty {
                // A row rather than a section footer, which
                // has low contrast and doesn't scale with
                // text size.
                Text("""
                    Tap an attempt to change it, or swipe \
                    left to delete.
                    """)
                    .font(.footnote)
                    .listRowSeparator(.hidden)
            }
        } header: {
            sectionHeader("History")
        }
    }

    private func attemptRow(
        _ attempt: Attempt
    ) -> some View {
        Button {
            showLog(for: attempt)
        } label: {
            HStack {
                Text(attempt.date, format: Self.dayFormat)
                    .accessibilityIdentifier("attemptDate")
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
            deleteButton(attempt)
            editButton(attempt)
                .tint(.blue)
        }
        .contextMenu {
            editButton(attempt)
            deleteButton(attempt)
        }
    }

    private func editButton(
        _ attempt: Attempt
    ) -> some View {
        Button {
            showLog(for: attempt)
        } label: {
            Label("Edit", systemImage: "pencil")
        }
    }

    private func deleteButton(
        _ attempt: Attempt
    ) -> some View {
        Button(role: .destructive) {
            delete(attempt)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func delete(_ attempt: Attempt) {
        challenge.attempts?.removeAll { $0 == attempt }
        modelContext.delete(attempt)
        try? modelContext.save()
    }
}
