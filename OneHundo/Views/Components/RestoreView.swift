import SwiftUI

private struct PhaseKey: EnvironmentKey {
  static let defaultValue = RestorePhase.done
}

extension EnvironmentValues {
  /// Whether iCloud may still be bringing
  /// challenges in (`RestoreCheck`), for the
  /// empty challenge list. Screen states set
  /// it directly.
  var restorePhase: RestorePhase {
    get { self[PhaseKey.self] }
    set { self[PhaseKey.self] = newValue }
  }
}

/// In place of the welcome screen while
/// iCloud is checked for challenges (a
/// reinstall or a new device), so a
/// returning user isn't invited to start
/// over.
struct RestoreView: View {
  var body: some View {
    VStack(spacing: 16) {
      ProgressView()
        .controlSize(.large)
      Text("""
        Checking iCloud for your \
        challenges…
        """)
        .font(.headline)
        .multilineTextAlignment(.center)
        .wrapsText()
    }
    .padding()
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
  }
}
