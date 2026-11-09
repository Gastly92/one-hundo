/// What the empty challenge list shows on a
/// fresh install while iCloud may still be
/// bringing challenges in
/// (`RestoreCheck`). Challenges that arrive
/// show in any phase: the list replaces it.
enum RestorePhase: Equatable, Sendable {
  /// Asking iCloud whether this account has
  /// used the app: a blank screen, so a new
  /// user sees no message.
  case deciding
  /// It has: "Checking iCloud for your
  /// challenges…" in place of the welcome
  /// screen, so a returning user isn't
  /// invited to start over.
  case checking
  /// Still no answer: the welcome screen,
  /// with a note that it's still checking.
  case slow
  /// The welcome screen as usual.
  case done

  /// iCloud answered: `synced` if this
  /// account has used the app before.
  func decided(_ synced: Bool) -> Self {
    guard self == .deciding else {
      return self
    }
    return synced ? .checking : .done
  }

  /// iCloud finished bringing changes in.
  func imported() -> Self {
    .done
  }

  /// The first wait is over. No answer yet
  /// counts as a new user.
  func waited() -> Self {
    switch self {
    case .deciding:
      .done
    case .checking:
      .slow
    case .slow, .done:
      self
    }
  }

  /// Waited long enough: the note goes.
  func gaveUp() -> Self {
    self == .slow ? .done : self
  }
}
