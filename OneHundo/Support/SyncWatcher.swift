import Combine
import CoreData
import Foundation
import SwiftData

/// Handles what iCloud sync brings in.
/// After each change from elsewhere (another
/// device's data arriving, maybe with the
/// app in the background), it merges
/// duplicates and schedules reminders
/// again, since synced challenges may have
/// new settings or a day logged elsewhere.
/// (`RootView` only reschedules while the
/// app is in front.) Watches until it's
/// let go.
@MainActor
final class SyncWatcher {
  private var watching: Set<AnyCancellable>
    = []

  /// Changes to the store from outside the
  /// app, and iCloud's own sync steps.
  private static let names:
    [Notification.Name] = [
      .NSPersistentStoreRemoteChange,
      NSPersistentCloudKitContainer
        .eventChangedNotification,
    ]

  init(
    store: ModelContainer,
    notifier: any Notifier,
    center: NotificationCenter = .default,
    clock: @escaping @Sendable () -> Date
      = Date.init
  ) {
    let changes = Self.names.map {
      center.publisher(for: $0)
    }
    Publishers.MergeMany(changes)
      .sink { _ in
        Task { @MainActor in
          try? Self.update(
            store, notifier, now: clock()
          )
        }
      }
      .store(in: &watching)
  }

  /// Merges duplicates, then replaces the
  /// pending reminders with the current
  /// plan. Doesn't ask for permission: this
  /// can run in the background.
  private static func update(
    _ store: ModelContainer,
    _ notifier: any Notifier,
    now: Date
  ) throws {
    let context = store.mainContext
    try Duplicates.merge(in: context)
    let all = try context.fetch(
      FetchDescriptor<Challenge>()
    )
    let plan = ReminderPlan.reminders(
      for: all, now: now
    )
    notifier.replace(
      with: plan.map { $0.request() }
    )
  }
}
