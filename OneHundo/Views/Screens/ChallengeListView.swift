import SwiftData
import SwiftUI

struct ChallengeListView: View {
  /// A cell in the grid.
  private enum Tile: Hashable {
    case card(Challenge)
    case add
  }

  @Query(sort: \Challenge.createdDate)
  private var challenges: [Challenge]
  @State private var isAdding = false
  @State private var path: [Challenge] = []
  /// The challenge whose Log attempt sheet
  /// is open (from a card's long-press
  /// menu).
  @State private var logging: Challenge?
  /// The challenge waiting for delete
  /// confirmation.
  @State private var deleting: Challenge?
  @Environment(\.modelContext)
  private var modelContext
  @Environment(\.now)
  private var now
  @Environment(\.dynamicTypeSize)
  private var textSize

  private static let tile = RoundedRectangle(
    cornerRadius: 16
  )

  private static let dashes = StrokeStyle(
    lineWidth: 1.5, dash: [6, 4]
  )

  private var active: [Challenge] {
    challenges.filter { !$0.isCompleted }
  }

  /// Reached goals, below the active ones.
  private var completed: [Challenge] {
    challenges.filter(\.isCompleted)
  }

  var body: some View {
    NavigationStack(path: $path) {
      screen
    }
  }

  /// The grid (or the welcome screen) with
  /// its title, navigation, sheets, and
  /// delete confirmation.
  private var screen: some View {
    content
      // The plain system large title: iOS
      // keeps it steady when switching tabs.
      .navigationTitle("Challenges")
      .navigationDestination(
        for: Challenge.self
      ) { ChallengeDetailView($0) }
      .sheet(isPresented: $isAdding) {
        AddChallengeView()
      }
      .sheet(item: $logging) { logSheet($0) }
  }

  @ViewBuilder
  private var content: some View {
    if challenges.isEmpty {
      WelcomeView { isAdding = true }
    } else {
      ScrollView { grid }
    }
  }

  /// Active cards and Add challenge, then
  /// any completed ones. One `Grid` rather
  /// than `LazyVGrid`: its cells fill their
  /// row, so cards side by side match
  /// heights, and both parts share columns.
  private var grid: some View {
    Grid(
      horizontalSpacing: 12,
      verticalSpacing: 12
    ) {
      rows(active.map(Tile.card) + [.add])
      if !completed.isEmpty {
        Text("Completed")
          .font(.title2.bold())
          .accessibilityAddTraits(.isHeader)
          .fullWidth(.leading)
          .padding(.top, 8)
        rows(completed.map(Tile.card))
      }
    }
    .padding()
  }

  /// `tiles` in rows.
  private func rows(
    _ tiles: [Tile]
  ) -> some View {
    let all = GridLayout.rows(
      tiles,
      columns: GridLayout.columns(
        for: textSize
      )
    )
    return ForEach(all, id: \.self) { row in
      GridRow {
        ForEach(row, id: \.self) {
          tile($0)
        }
      }
    }
  }

  @ViewBuilder
  private func tile(
    _ tile: Tile
  ) -> some View {
    switch tile {
    case .card(let challenge):
      card(challenge)
    case .add:
      addTile
    }
  }

  /// Logs (or edits) today's attempt.
  private func logSheet(
    _ challenge: Challenge
  ) -> some View {
    let today = challenge.attempt(on: now)
    return LogAttemptView(
      challenge, editing: today, on: now
    )
  }

  /// A button, so VoiceOver reads the card
  /// as one tappable item ("Push-ups, Try 11
  /// today, 10 / 100").
  private func card(
    _ challenge: Challenge
  ) -> some View {
    Button {
      path.append(challenge)
    } label: {
      ChallengeCard(challenge: challenge)
        .contentShape(Self.tile)
    }
    .buttonStyle(.plain)
    .contextMenu { menu(for: challenge) }
    // On the card, so iOS points the
    // confirmation at it.
    .confirmationDialog(
      "Delete \(challenge.displayName)?",
      isPresented: isDeleting(challenge),
      titleVisibility: .visible
    ) {
      confirmButton(challenge)
    } message: {
      Text("""
        This deletes the challenge and \
        all its attempts. You can't undo \
        this.
        """)
    }
    .testID("card.\(challenge.kind)")
  }

  /// Whether `challenge` waits for delete
  /// confirmation.
  private func isDeleting(
    _ challenge: Challenge
  ) -> Binding<Bool> {
    Binding(
      get: { deleting == challenge },
      set: { if !$0 { deleting = nil } }
    )
  }

  /// The last card in the grid opens Add
  /// challenge (the welcome screen has its
  /// own button). It sits in the grid rather
  /// than the title bar, which keeps the
  /// title plain.
  private var addTile: some View {
    Button {
      isAdding = true
    } label: {
      // At least a card's height, even
      // alone in its row.
      ZStack {
        ChallengeCard.space
        addLabel
      }
      .frame(
        maxWidth: .infinity,
        maxHeight: .infinity
      )
      .overlay(
        Self.tile.strokeBorder(
          .secondary, style: Self.dashes
        )
      )
      .contentShape(Self.tile)
    }
    .buttonStyle(.plain)
    .testID("addTile")
  }

  private var addLabel: some View {
    VStack(spacing: 8) {
      Image(systemName: "plus.circle.fill")
        .font(.title)
        .accessibilityHidden(true)
      Text("Add challenge")
        .font(.headline)
    }
    .foregroundStyle(Color.accentColor)
    .padding()
  }

  @ViewBuilder
  private func menu(
    for challenge: Challenge
  ) -> some View {
    Button {
      logging = challenge
    } label: {
      Label(
        challenge.logButtonTitle(on: now),
        systemImage: "plus.circle"
      )
    }
    Button(role: .destructive) {
      deleting = challenge
    } label: {
      Label(
        "Delete challenge",
        systemImage: "trash"
      )
    }
  }

  private func confirmButton(
    _ challenge: Challenge
  ) -> some View {
    Button(
      "Delete challenge", role: .destructive
    ) {
      delete(challenge)
    }
  }

  private func delete(
    _ challenge: Challenge
  ) {
    modelContext.delete(challenge)
    try? modelContext.save()
    deleting = nil
  }
}
