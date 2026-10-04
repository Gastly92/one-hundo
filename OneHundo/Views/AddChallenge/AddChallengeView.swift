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
                                subtitle: active ? "In progress" : builtIn.summary
                            )
                        }
                        .disabled(active)
                        .opacity(active ? 0.5 : 1)
                        .accessibilityIdentifier("builtIn.\(builtIn.id)")
                    }
                }

                Section {
                    // The custom challenge form lands in plan step 5.
                    ChallengeChoiceRow(
                        icon: "square.and.pencil",
                        color: .gray,
                        title: "Custom challenge",
                        subtitle: "Coming soon"
                    )
                    .opacity(0.5)
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

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
