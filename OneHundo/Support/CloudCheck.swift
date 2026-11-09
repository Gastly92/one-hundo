import CloudKit
import Foundation

/// What `CloudCheck` needs of an iCloud
/// container: its account and its private
/// database. `CKContainer` has both already
/// (the empty conformance below), so tests
/// pass fakes and no line here needs real
/// iCloud, which CI's unsigned builds can't
/// reach.
protocol CloudContainer: Sendable {
  associatedtype Zones: CloudZones

  var privateCloudDatabase: Zones { get }

  func accountStatus() async throws
    -> CKAccountStatus
}

/// A database's zones, as `CKDatabase` has
/// them.
protocol CloudZones: Sendable {
  func recordZone(
    for zoneID: CKRecordZone.ID
  ) async throws -> CKRecordZone
}

extension CKContainer: CloudContainer {}
extension CKDatabase: CloudZones {}

/// Whether this iCloud account has used One
/// Hundo before, for a fresh install
/// (`RestoreCheck`).
enum CloudCheck {
  /// The zone sync keeps the data in; it
  /// exists once the app has synced.
  static let zone = CKRecordZone.ID(
    zoneName: zoneName,
    ownerName: CKCurrentUserDefaultName
  )
  private static let zoneName =
    "com.apple.coredata.cloudkit.zone"

  /// Builds signed for iCloud set this key
  /// in Info.plist (`ONEHUNDO_CLOUDKIT=YES`
  /// in the TestFlight workflow); CloudKit
  /// crashes builds without the
  /// entitlement.
  static let signedKey = "OneHundoCloudKit"

  /// The app's container, only in builds
  /// signed for iCloud.
  static func container(
    signed: Bool
  ) -> CKContainer? {
    signed ? .default() : nil
  }

  /// Whether `info` (an Info.plist) says the
  /// build is signed for iCloud.
  static func isSigned(
    _ info: [String: Any]?
  ) -> Bool {
    info?[signedKey] as? String == "YES"
  }

  /// Signed in, and the app's zone exists.
  /// Any failure (offline, signed out, no
  /// zone) counts as no.
  static func hasSynced(
    _ cloud: some CloudContainer
  ) async -> Bool {
    let status = try? await cloud
      .accountStatus()
    guard status == .available else {
      return false
    }
    let zones = cloud.privateCloudDatabase
    let found = try? await zones.recordZone(
      for: zone
    )
    return found != nil
  }
}
