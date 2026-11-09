import SwiftUI

/// Over the whole app while a fresh install
/// asks iCloud whether it has challenges
/// (`RestorePhase.deciding`): the launch
/// screen's logo, in the same place, so
/// opening the app and waiting look like
/// one screen. Still, not a spinner: the
/// wait is short, and a spinner that comes
/// and goes looks like a glitch.
struct LaunchCover: View {
  @Environment(\.restorePhase)
  private var phase

  var body: some View {
    if phase == .deciding {
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
