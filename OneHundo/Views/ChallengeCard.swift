import SwiftUI

/// A challenge in the list grid: icon and name, today's target, and progress.
struct ChallengeCard: View {
    let challenge: Challenge

    private var color: Color { Color(challengeColorName: challenge.colorName) }
    private var isDoneToday: Bool { challenge.loggedAttempt(on: Date()) != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: challenge.icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .accessibilityHidden(true)
                Text(challenge.name)
                    .font(.headline)
                    .lineLimit(1)
            }

            HStack(spacing: 4) {
                if isDoneToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .accessibilityHidden(true)
                }
                Text(challenge.todayText())
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .font(.title3.bold())
            .frame(minHeight: 50, alignment: .topLeading)

            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.progressText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: challenge.progress)
                    .tint(color)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(color.opacity(0.3)))
    }
}
