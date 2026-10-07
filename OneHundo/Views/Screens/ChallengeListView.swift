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
  @ScaledMetric(relativeTo: .headline)
  private var tileHeight: CGFloat = 120

  private static let tile = RoundedRectangle(
    cornerRadius: 16
  )

  private static let dashes = StrokeStyle(
    lineWidth: 1.5, dash: [6, 4]
  )

  /// Completed challenges get their own
  /// section later (plan step 9).
  private var active: [Challenge] {
    challenges.filter {
      $0.completedDate == nil
    }
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
      .confirmationDialog(
        "Delete \(deletingName)?",
        isPresented: isDeleting,
        titleVisibility: .visible,
        presenting: deleting
      ) { challenge in
        confirmButton(challenge)
      } message: { _ in
        Text("""
          This deletes the challenge and \
          all its attempts. You can't undo \
          this.
          """)
      }
  }

  @ViewBuilder
  private var content: some View {
    if active.isEmpty {
      WelcomeView { isAdding = true }
    } else {
      ScrollView { grid }
    }
  }

  /// A `Grid` rather than `LazyVGrid`: its
  /// cells fill their row, so cards side by
  /// side match heights.
  private var grid: some View {
    Grid(
      horizontalSpacing: 12,
      verticalSpacing: 12
    ) {
      ForEach(rows, id: \.self) { row in
        GridRow {
          ForEach(row, id: \.self) {
            tile($0)
          }
        }
      }
    }
    .padding()
  }

  /// The cards, then Add challenge, in rows.
  private var rows: [[Tile]] {
    let tiles = active.map(Tile.card)
    return GridLayout.rows(
      tiles + [.add],
      columns: GridLayout.columns(
        for: textSize
      )
    )
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
    .testID("card.\(challenge.kind)")
  }

  private var isDeleting: Binding<Bool> {
    Binding(
      get: { deleting != nil },
      set: { if !$0 { deleting = nil } }
    )
  }

  private var deletingName: String {
    let word = String(localized: "challenge")
    return deleting?.displayName ?? word
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
      VStack(spacing: 8) {
        Image(systemName: "plus.circle.fill")
          .font(.title)
          .accessibilityHidden(true)
        Text("Add challenge")
          .font(.headline)
      }
      .foregroundStyle(Color.accentColor)
      .padding()
      .frame(
        maxWidth: .infinity,
        minHeight: tileHeight,
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
