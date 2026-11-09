import CoreData
@testable import OneHundo
import XCTest

/// Stands in for iCloud's import events,
/// which tests can't make; `RestoreCheck`
/// reads them through key-value coding.
private final class FakeEvent: NSObject {
  @objc let type: Int
  @objc let endDate: Date?

  init(type: Int, ended: Bool) {
    self.type = type
    endDate = ended ? Date() : nil
  }
}

/// A fresh install checking iCloud for
/// challenges (`RestorePhase`,
/// `RestoreCheck`).
@MainActor
final class RestoreTests: XCTestCase {
  private static let importType =
    NSPersistentCloudKitContainer
      .EventType.import.rawValue
  private static let exportType =
    NSPersistentCloudKitContainer
      .EventType.export.rawValue

  func testPhaseSteps() {
    XCTAssertEqual(
      RestorePhase.checking.waited(), .slow
    )
    XCTAssertEqual(
      RestorePhase.offline.waited(), .offline
    )
    XCTAssertEqual(
      RestorePhase.slow.gaveUp(), .done
    )
    XCTAssertEqual(
      RestorePhase.offline.gaveUp(), .offline
    )
    XCTAssertEqual(
      RestorePhase.slow.imported(), .done
    )
  }

  func testConnection() {
    XCTAssertEqual(
      RestorePhase.checking.online(false),
      .offline
    )
    XCTAssertEqual(
      RestorePhase.slow.online(false),
      .offline
    )
    XCTAssertEqual(
      RestorePhase.offline.online(true),
      .slow
    )
    XCTAssertEqual(
      RestorePhase.checking.online(true),
      .checking
    )
    XCTAssertEqual(
      RestorePhase.done.online(false), .done
    )
  }

  /// Not active (data on the phone, or UI
  /// tests): the welcome screen as usual.
  func testInactiveIsDone() {
    let check = RestoreCheck(active: false)
    XCTAssertEqual(check.phase, .done)
  }

  /// Only a finished import ends the check.
  func testImportEndsIt() async {
    let center = NotificationCenter()
    let check = RestoreCheck(
      active: true,
      center: center,
      wait: .seconds(60)
    )
    XCTAssertEqual(check.phase, .checking)
    post(nil, to: center)
    post(
      FakeEvent(
        type: Self.exportType, ended: true
      ),
      to: center
    )
    post(
      FakeEvent(
        type: Self.importType, ended: false
      ),
      to: center
    )
    await Task.yield()
    XCTAssertEqual(check.phase, .checking)
    post(
      FakeEvent(
        type: Self.importType, ended: true
      ),
      to: center
    )
    await until(check, is: .done)
  }

  /// No answer: the welcome screen with a
  /// note, then without.
  func testWaitsEnd() async {
    let check = RestoreCheck(
      active: true,
      center: NotificationCenter(),
      wait: .milliseconds(20),
      giveUp: .milliseconds(200)
    )
    await until(check, is: .slow)
    await until(check, is: .done)
  }

  /// Offline, then back: the note gets a
  /// wait of its own.
  func testOfflineThenBack() async {
    let check = RestoreCheck(
      active: true,
      center: NotificationCenter(),
      wait: .seconds(60),
      giveUp: .milliseconds(20)
    )
    check.connection(false)
    XCTAssertEqual(check.phase, .offline)
    check.connection(true)
    XCTAssertEqual(check.phase, .slow)
    await until(check, is: .done)
  }

  private func post(
    _ event: NSObject?,
    to center: NotificationCenter
  ) {
    let key = NSPersistentCloudKitContainer
      .eventNotificationUserInfoKey
    center.post(
      name: NSPersistentCloudKitContainer
        .eventChangedNotification,
      object: nil,
      userInfo: event.map { [key: $0] }
    )
  }

  /// Waits (up to 5 s) for `check` to reach
  /// `phase`.
  private func until(
    _ check: RestoreCheck,
    is phase: RestorePhase
  ) async {
    var tries = 0
    while check.phase != phase, tries < 500 {
      tries += 1
      try? await Task.sleep(
        for: .milliseconds(10)
      )
    }
    XCTAssertEqual(check.phase, phase)
  }
}
