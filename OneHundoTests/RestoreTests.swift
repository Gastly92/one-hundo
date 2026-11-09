import CloudKit
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

/// A private database that has the app's
/// zone or not.
private struct FakeZones: CloudZones {
  let exists: Bool

  func recordZone(
    for zoneID: CKRecordZone.ID
  ) throws -> CKRecordZone {
    guard exists else {
      throw CKError(.zoneNotFound)
    }
    return CKRecordZone(zoneID: zoneID)
  }
}

/// An iCloud account: its status (nil:
/// iCloud can't be asked, e.g. offline) and
/// whether the app has synced to it.
private struct FakeCloud: CloudContainer {
  let status: CKAccountStatus?
  let privateCloudDatabase: FakeZones

  init(
    _ status: CKAccountStatus?,
    synced: Bool = false
  ) {
    self.status = status
    privateCloudDatabase = FakeZones(
      exists: synced
    )
  }

  func accountStatus() throws
    -> CKAccountStatus {
    guard let status else {
      throw CKError(.networkUnavailable)
    }
    return status
  }
}

/// A fresh install checking iCloud for
/// challenges (`RestorePhase`, `CloudCheck`,
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
    let deciding = RestorePhase.deciding
    XCTAssertEqual(
      deciding.decided(true), .checking
    )
    XCTAssertEqual(
      deciding.decided(false), .done
    )
    XCTAssertEqual(
      RestorePhase.done.decided(true), .done
    )
    XCTAssertEqual(deciding.waited(), .done)
    XCTAssertEqual(
      RestorePhase.checking.waited(), .slow
    )
    XCTAssertEqual(
      RestorePhase.slow.waited(), .slow
    )
    XCTAssertEqual(
      RestorePhase.slow.gaveUp(), .done
    )
    XCTAssertEqual(
      RestorePhase.checking.gaveUp(),
      .checking
    )
    XCTAssertEqual(
      RestorePhase.slow.imported(), .done
    )
  }

  /// Only builds signed for iCloud ask it.
  func testSignedBuildsOnly() {
    let key = CloudCheck.signedKey
    XCTAssertTrue(
      CloudCheck.isSigned([key: "YES"])
    )
    XCTAssertFalse(
      CloudCheck.isSigned([key: "NO"])
    )
    XCTAssertFalse(CloudCheck.isSigned(nil))
    XCTAssertNil(
      CloudCheck.container(signed: false)
    )
  }

  /// Signed in, with the app's zone: a
  /// returning user. Anything else: no.
  func testWhoHasSynced() async {
    let returning = FakeCloud(
      .available, synced: true
    )
    let new = FakeCloud(.available)
    let signedOut = FakeCloud(
      .noAccount, synced: true
    )
    let offline = FakeCloud(nil)
    let clouds = [
      returning, new, signedOut, offline,
    ]
    var answers: [Bool] = []
    for cloud in clouds {
      answers.append(
        await CloudCheck.hasSynced(cloud)
      )
    }
    XCTAssertEqual(
      answers, [true, false, false, false]
    )
  }

  /// Not active (data on the phone, UI
  /// tests, or a build that can't reach
  /// iCloud): the welcome screen as usual.
  func testInactiveIsDone() {
    let inactive = RestoreCheck(
      active: false,
      cloud: FakeCloud(.available)
    )
    XCTAssertEqual(inactive.phase, .done)
    let noCloud = RestoreCheck(
      active: true, cloud: nil
    )
    XCTAssertEqual(noCloud.phase, .done)
  }

  /// A new user: blank, then the welcome
  /// screen, no message.
  func testNewUserSeesNoMessage() async {
    let check = RestoreCheck(
      active: true,
      cloud: FakeCloud(.available),
      center: NotificationCenter(),
      wait: .seconds(60)
    )
    XCTAssertEqual(check.phase, .deciding)
    await until(check, is: .done)
  }

  /// A returning user: "Checking…" until
  /// a finished import (nothing else) ends
  /// it.
  func testReturningUntilImport() async {
    let center = NotificationCenter()
    let check = RestoreCheck(
      active: true,
      cloud: FakeCloud(
        .available, synced: true
      ),
      center: center,
      wait: .seconds(60)
    )
    await until(check, is: .checking)
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

  /// No import: the welcome screen with a
  /// note, then without.
  func testWaitsEnd() async {
    let check = RestoreCheck(
      active: true,
      cloud: FakeCloud(
        .available, synced: true
      ),
      center: NotificationCenter(),
      wait: .milliseconds(100),
      giveUp: .milliseconds(200)
    )
    await until(check, is: .slow)
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
