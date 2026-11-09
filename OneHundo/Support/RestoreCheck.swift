import Combine
import CoreData
import Foundation
import Network
import Observation

/// Follows a fresh install while iCloud may
/// still be bringing challenges in, for the
/// empty challenge list (`RestorePhase`).
/// Active only when the store was empty at
/// launch. It ends when iCloud's first
/// import finishes, and two waits keep it
/// from ever hanging (iCloud signed out,
/// slow, or not posting its events).
@MainActor
@Observable
final class RestoreCheck {
  private(set) var phase: RestorePhase

  /// How long the spinner shows before the
  /// welcome screen (with a note).
  static let wait = Duration.seconds(4)
  /// How much longer the note shows.
  static let giveUp = Duration.seconds(26)

  private let giveUp: Duration
  /// The connection, as it changes.
  private let net = NWPathMonitor()
  @ObservationIgnored private var watching =
    Set<AnyCancellable>()

  init(
    active: Bool,
    center: NotificationCenter = .default,
    wait: Duration = RestoreCheck.wait,
    giveUp: Duration = RestoreCheck.giveUp
  ) {
    phase = active ? .checking : .done
    self.giveUp = giveUp
    guard active else {
      return
    }
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
    net.pathUpdateHandler = { [weak self] in
      let isUp = $0.status == .satisfied
      Task { @MainActor in
        self?.connection(isUp)
      }
    }
    net.start(queue: .main)
    later(wait) { $0.waited() }
    later(wait + giveUp) { $0.gaveUp() }
  }

  /// The connection came or went. Back
  /// online, the "still checking" note
  /// gets a wait of its own.
  func connection(_ isOnline: Bool) {
    let before = phase
    update { $0.online(isOnline) }
    if before == .offline, phase == .slow {
      later(giveUp) { $0.gaveUp() }
    }
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
      net.cancel()
      watching.removeAll()
    }
  }
}
