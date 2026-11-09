import SwiftUI

private struct PhaseKey: EnvironmentKey {
  static let defaultValue = RestorePhase.done
}

extension EnvironmentValues {
  /// Whether iCloud may still be bringing
  /// challenges in (`RestoreCheck`), for a
  /// fresh install. Screen states set it
  /// directly.
  var restorePhase: RestorePhase {
    get { self[PhaseKey.self] }
    set { self[PhaseKey.self] = newValue }
  }
}

/// Over the whole app while a fresh install
/// asks iCloud whether it has challenges,
/// and while they arrive
/// (`RestorePhase.showsLogo`): the launch
/// screen's logo, in the same place, so
/// opening the app and waiting look like
/// one screen. Still, not a spinner: the
/// wait is short, and a spinner that comes
/// and goes looks like a glitch.
struct LaunchCover: View {
  @Environment(\.restorePhase)
  private var phase

  var body: some View {
    if phase.showsLogo {
      Image(.launchLogo)
        .accessibilityHidden(true)
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity
        )
        .background(.background)
        .ignoresSafeArea()
        // VoiceOver says why it waits.
        .accessibilityRepresentation {
          Text("Opening One Hundo…")
        }
    }
  }
}
