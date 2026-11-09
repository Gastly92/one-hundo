/// What the empty challenge list shows on a
/// fresh install while iCloud may still be
/// bringing challenges in
/// (`RestoreCheck`). Challenges that arrive
/// show in any phase: the list replaces it.
enum RestorePhase: Equatable, Sendable {
  /// Checking iCloud: a spinner in place of
  /// the welcome screen, so a returning user
  /// isn't invited to start over.
  case checking
  /// Still no answer: the welcome screen,
  /// with a note that it's still checking.
  case slow
  /// No connection: the welcome screen, with
  /// a note that synced challenges come once
  /// connected.
  case offline
  /// The welcome screen as usual.
  case done

  /// iCloud finished bringing changes in.
  func imported() -> Self {
    .done
  }

  /// The first wait is over.
  func waited() -> Self {
    self == .checking ? .slow : self
  }

  /// Waited long enough: the note goes. An
  /// offline note stays (it's still true).
  func gaveUp() -> Self {
    self == .slow ? .done : self
  }

  /// The connection came or went.
  func online(_ isOnline: Bool) -> Self {
    switch (self, isOnline) {
    case (.checking, false), (.slow, false):
      .offline
    case (.offline, true):
      .slow
    default:
      self
    }
  }
}
