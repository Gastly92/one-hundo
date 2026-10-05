import SwiftData
import SwiftUI

/// The first step of starting a challenge: pick a built-in (or, later, a custom one).
struct AddChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var challenges: [Challenge]

    /// One active challenge per built-in; a completed one can be started again.
    private func isActive(_ builtIn: BuiltInChallenge) -> Bool {
        challenges.contains { $0.kind == builtIn.id && $0.completedDate == nil }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(BuiltInChallenge.all) { builtIn in
                        let active = isActive(builtIn)
                        NavigationLink(value: builtIn) {
                            ChallengeChoiceRow(
                                icon: builtIn.icon,
                                color: Color(challengeColorName: builtIn.colorName),
                                title: builtIn.name,
                                subtitle: active ? "In progress" : builtIn.summary,
                                isDimmed: active
                            )
                        }
                        .disabled(active)
                        .accessibilityIdentifier("builtIn.\(builtIn.id)")
                    }
                }

                Section {
                    // The custom challenge form lands in plan step 5. A disabled button,
                    // like the in-progress built-ins, so it reads as unavailable.
                    Button {} label: {
                        ChallengeChoiceRow(
                            icon: "square.and.pencil",
                            color: .gray,
                            title: "Custom challenge",
                            subtitle: "Coming soon",
                            isDimmed: true
                        )
                    }
                    .disabled(true)
                }
            }
            .navigationTitle("Add challenge")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: BuiltInChallenge.self) { builtIn in
                EnrollFlowView(builtIn: builtIn) { dismiss() }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct ChallengeChoiceRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    /// Unavailable rows use secondary text rather than fading the whole row, so the
    /// text keeps enough contrast to read.
    var isDimmed = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isDimmed ? Color.secondary : color)
                .frame(width: 36)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(isDimmed ? Color.secondary : Color.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(isDimmed ? Color.primary : Color.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
