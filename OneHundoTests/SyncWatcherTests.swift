import CoreData
@testable import OneHundo
import UserNotifications
import XCTest

/// Records each reminder update, and says
/// when one happens.
@MainActor
private final class Recorder: Notifier {
  var updates: [[UNNotificationRequest]] = []
  var onUpdate: () -> Void = {
    // Set by each test.
  }

  func ask() {
    // The watcher never asks.
  }

  func replace(
    with requests: [UNNotificationRequest]
  ) {
    updates.append(requests)
    onUpdate()
  }
}

/// What happens when iCloud sync brings
/// changes in (`SyncWatcher`).
@MainActor
final class SyncWatcherTests: XCTestCase {
  /// A change from elsewhere merges the
  /// copies it brought and reschedules
  /// reminders.
  func testChangeMergesAndReschedules()
    throws {
    let store = try TestStore()
    let first = store.pushUps()
    let copy = store.pushUps()
    copy.id = first.id
    try store.context.save()

    let updates = changes(
      in: store,
      posting: .NSPersistentStoreRemoteChange
    )

    let left = try store.context.fetch(
      FetchDescriptor<Challenge>()
    )
    XCTAssertEqual(left.count, 1)
    let want = ReminderPlan.reminders(
      for: left, now: day(1, hour: 8)
    )
    XCTAssertFalse(want.isEmpty)
    XCTAssertEqual(
      updates.last?.map(\.identifier),
      want.map(\.id)
    )
  }

  /// iCloud's own sync steps (an import
  /// finishing) do the same.
  func testSyncEventReschedules() throws {
    let store = try TestStore()
    _ = store.pushUps()
    try store.context.save()

    let updates = changes(
      in: store,
      posting: NSPersistentCloudKitContainer
        .eventChangedNotification
    )

    XCTAssertEqual(updates.count, 1)
  }

  /// Posts `name` to a watcher on `store`
  /// and returns the reminder updates once
  /// the first arrives.
  private func changes(
    in store: TestStore,
    posting name: Notification.Name
  ) -> [[UNNotificationRequest]] {
    let center = NotificationCenter()
    let recorder = Recorder()
    let done = expectation(
      description: "reminders updated"
    )
    recorder.onUpdate = { done.fulfill() }
    let watcher = SyncWatcher(
      store: store.container,
      notifier: recorder,
      center: center
    ) { day(1, hour: 8) }
    withExtendedLifetime(watcher) {
      center.post(name: name, object: nil)
      wait(for: [done], timeout: 10)
    }
    return recorder.updates
  }
}
