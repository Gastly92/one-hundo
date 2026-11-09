/// What a fresh install shows while iCloud
/// may still be bringing challenges in
/// (`RestoreCheck`). Challenges that arrive
/// show in any phase: the list replaces it.
enum RestorePhase: Equatable, Sendable {
  /// Asking iCloud whether this account has
  /// used the app: the launch screen's logo
  /// stays (`LaunchCover`), so a new user
  /// sees no message.
  case deciding
  /// It has: the logo stays until the
  /// challenges arrive, so a returning
  /// user isn't invited to start over.
  case checking
  /// Still no challenges: the welcome
  /// screen, with a note that it's still
  /// checking.
  case slow
  /// iCloud hasn't answered in time: the
  /// welcome screen, and the note if it
  /// later says there's data.
  case unsure
  /// The welcome screen as usual.
  case done

  /// Whether the launch logo covers the
  /// app (`LaunchCover`).
  var showsLogo: Bool {
    self == .deciding || self == .checking
  }

  /// iCloud answered: `synced` if this
  /// account has used the app before.
  func decided(_ synced: Bool) -> Self {
    switch self {
    case .deciding:
      synced ? .checking : .done
    case .unsure:
      synced ? .slow : .done
    case .checking, .slow, .done:
      self
    }
  }

  /// iCloud finished bringing changes in.
  func imported() -> Self {
    .done
  }

  /// The logo's time is up.
  func timedOut() -> Self {
    self == .deciding ? .unsure : self
  }

  /// The returning user's wait is up.
  func waited() -> Self {
    self == .checking ? .slow : self
  }

  /// Waited long enough: the note goes.
  func gaveUp() -> Self {
    switch self {
    case .slow, .unsure:
      .done
    case .deciding, .checking, .done:
      self
    }
  }
}
