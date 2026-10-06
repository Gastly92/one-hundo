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
    @ScaledMetric(relativeTo: .headline) private var addTileHeight: CGFloat = 120

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
            Group {
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
                            addTile
                        }
                        .padding()
                    }
                }
            }
            // The plain system large title: iOS keeps it steady when switching tabs.
            .navigationTitle("Challenges")
            .navigationDestination(for: Challenge.self) { challenge in
                ChallengeDetailView(challenge: challenge)
            }
            .sheet(isPresented: $isAddingChallenge) {
                AddChallengeView()
            }
            .sheet(item: $loggingChallenge) { challenge in
                LogAttemptView(challenge: challenge, attempt: challenge.attempt(on: Date()))
            }
            .confirmationDialog(
                "Delete \(deletingChallenge?.displayName ?? String(localized: "challenge"))?",
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

    /// The last card in the grid opens Add challenge (the welcome screen has its own
    /// button). It sits in the grid rather than the title bar, which keeps the title plain.
    private var addTile: some View {
        Button {
            isAddingChallenge = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .accessibilityHidden(true)
                Text("Add challenge")
                    .font(.headline)
            }
            .foregroundStyle(Color.accentColor)
            .padding()
            .frame(maxWidth: .infinity, minHeight: addTileHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            )
            .contentShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("addChallengeButton")
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
