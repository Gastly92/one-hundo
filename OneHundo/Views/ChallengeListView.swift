import SwiftData
import SwiftUI

struct ChallengeListView: View {
    @Query(sort: \Challenge.createdDate) private var challenges: [Challenge]
    @State private var isAddingChallenge = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    /// Completed challenges get their own section later (plan step 9).
    private var activeChallenges: [Challenge] {
        challenges.filter { $0.completedDate == nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if activeChallenges.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(activeChallenges) { challenge in
                                ChallengeCard(challenge: challenge)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Challenges")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingChallenge = true
                    } label: {
                        Label("Add challenge", systemImage: "plus")
                    }
                    .accessibilityIdentifier("addChallengeButton")
                }
            }
            .sheet(isPresented: $isAddingChallenge) {
                AddChallengePlaceholderView()
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No challenges yet", systemImage: "figure.strengthtraining.traditional")
        } description: {
            Text("Pick an exercise, test yourself, and get a little better every day.")
        } actions: {
            Button("Start your first challenge") {
                isAddingChallenge = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("startFirstChallengeButton")
        }
    }
}

/// Stand-in until the Add challenge sheet lands (plan step 3).
struct AddChallengePlaceholderView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming soon",
                systemImage: "plus.circle",
                description: Text("Starting challenges arrives in the next update.")
            )
            .navigationTitle("Add challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
