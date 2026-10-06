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
                                title: builtIn.name,
                                subtitle: active
                                    ? String(localized: "In progress")
                                    : builtIn.summary,
                                isDimmed: active
                            )
                        }
                        .disabled(active)
                        .accessibilityIdentifier("builtIn.\(builtIn.id)")
                    }
                }

                Section {
                    // The custom challenge form lands in plan step 5.
                    NavigationLink {
                        CustomChallengeComingSoonView()
                    } label: {
                        ChallengeChoiceRow(
                            title: String(localized: "Custom challenge"),
                            subtitle: String(localized: "Coming soon")
                        )
                    }
                    .accessibilityIdentifier("customChallenge")
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
    let title: String
    let subtitle: String
    /// Unavailable rows use secondary text rather than fading the whole row, so the
    /// text keeps enough contrast to read.
    var isDimmed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .foregroundStyle(isDimmed ? Color.secondary : Color.primary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(isDimmed ? Color.primary : Color.secondary)
        }
        .padding(.vertical, 4)
    }
}
