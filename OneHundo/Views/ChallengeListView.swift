import SwiftData
import SwiftUI

struct ChallengeListView: View {
    @Query(sort: \Challenge.createdDate) private var challenges: [Challenge]
    @State private var isAddingChallenge = false
    @State private var path: [Challenge] = []
    /// The challenge whose Log attempt sheet is open (from a card's long-press menu).
    @State private var loggingChallenge: Challenge?
    /// The challenge waiting for delete confirmation.
    @State private var deletingChallenge: Challenge?
    @Environment(\.modelContext) private var modelContext

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    /// Completed challenges get their own section later (plan step 9).
    private var activeChallenges: [Challenge] {
        challenges.filter { $0.completedDate == nil }
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                if activeChallenges.isEmpty {
                    WelcomeView { isAddingChallenge = true }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(activeChallenges) { challenge in
                                // A tap gesture rather than a NavigationLink, so the card's
                                // texts stay separate accessibility elements for UI tests.
                                ChallengeCard(challenge: challenge)
                                    .contentShape(RoundedRectangle(cornerRadius: 16))
                                    .onTapGesture { path.append(challenge) }
                                    .contextMenu { cardMenu(for: challenge) }
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
            .navigationDestination(for: Challenge.self) { challenge in
                ChallengeDetailView(challenge: challenge)
            }
            .sheet(isPresented: $isAddingChallenge) {
                AddChallengeView()
            }
            .sheet(item: $loggingChallenge) { challenge in
                LogAttemptView(challenge: challenge, attempt: challenge.loggedAttempt(on: Date()))
            }
            .confirmationDialog(
                "Delete \(deletingChallenge?.name ?? "challenge")?",
                isPresented: Binding(
                    get: { deletingChallenge != nil },
                    set: { if !$0 { deletingChallenge = nil } }
                ),
                titleVisibility: .visible,
                presenting: deletingChallenge
            ) { challenge in
                Button("Delete challenge", role: .destructive) { delete(challenge) }
            } message: { _ in
                Text("This deletes the challenge and all its attempts. You can't undo this.")
            }
        }
    }

    private var header: some View {
        TabHeader(title: "Challenges", identifier: "challengesTitle") {
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
    }

    @ViewBuilder
    private func cardMenu(for challenge: Challenge) -> some View {
        Button {
            loggingChallenge = challenge
        } label: {
            Label(
                challenge.logButtonTitle(),
                systemImage: "plus.circle"
            )
        }
        Button(role: .destructive) {
            deletingChallenge = challenge
        } label: {
            Label("Delete challenge", systemImage: "trash")
        }
    }

    private func delete(_ challenge: Challenge) {
        path.removeAll { $0 == challenge }
        modelContext.delete(challenge)
        try? modelContext.save()
        deletingChallenge = nil
    }
}
