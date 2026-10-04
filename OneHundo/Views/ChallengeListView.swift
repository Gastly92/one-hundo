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
            VStack(spacing: 0) {
                header
                if activeChallenges.isEmpty {
                    emptyState
                        .frame(maxHeight: .infinity)
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
            // A custom header instead of the system bar, so the + sits on the
            // same line as the big title.
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isAddingChallenge) {
                AddChallengeView()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Challenges")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("challengesTitle")
            Spacer()
            Button {
                isAddingChallenge = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .accessibilityLabel("Add challenge")
            .accessibilityIdentifier("addChallengeButton")
        }
        .padding(.horizontal)
        .padding(.top, 8)
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
