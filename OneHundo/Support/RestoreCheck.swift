import Combine
import CoreData
import Foundation
import Observation

/// Follows a fresh install while iCloud may
/// still be bringing challenges in, for the
/// empty challenge list (`RestorePhase`).
/// Active only when the store was empty at
/// launch and the build can reach iCloud.
/// It asks iCloud whether this account has
/// used the app (`CloudCheck`), showing the
/// launch logo meanwhile: no, and the
/// welcome screen shows; yes, and the logo
/// stays until iCloud's first import
/// finishes. Waits keep it from ever
/// hanging.
@MainActor
@Observable
final class RestoreCheck {
  private(set) var phase: RestorePhase

  /// How long the logo waits for iCloud's
  /// answer.
  static let decideBy = Duration.seconds(3)
  /// How long before the welcome screen
  /// shows anyway (with a note, if iCloud
  /// said there's data).
  static let wait = Duration.seconds(4)
  /// How much longer the note shows.
  static let giveUp = Duration.seconds(26)

  @ObservationIgnored private var watching =
    Set<AnyCancellable>()

  init(
    active: Bool,
    cloud: (any CloudContainer)?,
    center: NotificationCenter = .default,
    decideBy: Duration = RestoreCheck
      .decideBy,
    wait: Duration = RestoreCheck.wait,
    giveUp: Duration = RestoreCheck.giveUp
  ) {
    guard active, let cloud else {
      phase = .done
      return
    }
    phase = .deciding
    let name = NSPersistentCloudKitContainer
      .eventChangedNotification
    // iCloud posts from background threads,
    // so the handler runs anywhere and hops
    // to the main actor itself.
    center.publisher(for: name)
      .sink { @Sendable [weak self] note in
        guard Self.importEnded(note) else {
          return
        }
        Task { @MainActor in
          self?.update { $0.imported() }
        }
      }
      .store(in: &watching)
    Task { [weak self] in
      let synced = await CloudCheck
        .hasSynced(cloud)
      self?.update { $0.decided(synced) }
    }
    later(decideBy) { $0.timedOut() }
    later(wait) { $0.waited() }
    later(wait + giveUp) { $0.gaveUp() }
  }

  /// Whether `note` says an import finished.
  /// Read through key-value coding: tests
  /// can't make a real
  /// `NSPersistentCloudKitContainer.Event`.
  nonisolated static func importEnded(
    _ note: Notification
  ) -> Bool {
    let key = NSPersistentCloudKitContainer
      .eventNotificationUserInfoKey
    guard
      let event = note.userInfo?[key]
        as? NSObject
    else { return false }
    let type = event.value(forKey: "type")
      as? Int
    let end = event.value(forKey: "endDate")
    let kind = NSPersistentCloudKitContainer
      .EventType.import.rawValue
    return end != nil && type == kind
  }

  typealias Change = @Sendable (RestorePhase)
    -> RestorePhase

  /// Runs `change` after `delay`.
  private func later(
    _ delay: Duration,
    _ change: @escaping Change
  ) {
    Task { [weak self] in
      try? await Task.sleep(for: delay)
      self?.update(change)
    }
  }

  /// Applies `change`; once done, stops
  /// watching.
  private func update(_ change: Change) {
    phase = change(phase)
    if phase == .done {
      watching.removeAll()
    }
  }
}
