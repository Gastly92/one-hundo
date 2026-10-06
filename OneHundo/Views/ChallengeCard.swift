import SwiftUI

/// A challenge in the list grid: name, today's target, and progress.
struct ChallengeCard: View {
    let challenge: Challenge

    private var color: Color { Color(challengeColorName: challenge.colorName) }
    private var isDoneToday: Bool { challenge.loggedAttempt(on: Date()) != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(challenge.name)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 4) {
                if isDoneToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .accessibilityHidden(true)
                }
                Text(challenge.todayText())
                    .fixedSize(horizontal: false, vertical: true)
            }
            .font(.title3.bold())
            .frame(minHeight: 50, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.progressText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                // The text above already says this; a 4-point bar isn't a useful target.
                ProgressView(value: challenge.progress)
                    .tint(color)
                    .accessibilityHidden(true)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(color.opacity(0.3)))
    }
}
