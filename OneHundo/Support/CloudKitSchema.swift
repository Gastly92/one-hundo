#if CLOUDKIT_SCHEMA
import CoreData
import SwiftData

/// Only in the one-off build that creates
/// iCloud's schema (`docs/CLOUDKIT.md`),
/// built with `CLOUDKIT_SCHEMA` and signed
/// for iCloud's Development environment.
///
/// iCloud makes a field only when a record
/// sends a value for it, and some never
/// have one yet (`completedDate`, 1.0's
/// empty `loggedAt`). This uploads a sample
/// of every field from a throwaway store,
/// then deletes it; the user's data isn't
/// touched (that build doesn't sync it).
enum CloudKitSchema {
  static let container =
    "iCloud.com.gastly92.onehundo"

  /// Starts the upload in the background.
  static func start() {
    Task.detached(priority: .background) {
      try? upload()
    }
  }

  private static func upload() throws {
    let url = URL.temporaryDirectory
      .appending(path: "schema.store")
    let store = NSPersistentStoreDescription(
      url: url
    )
    store.cloudKitContainerOptions =
      NSPersistentCloudKitContainerOptions(
        containerIdentifier: container
      )
    store.shouldAddStoreAsynchronously =
      false
    guard let model = NSManagedObjectModel
      .makeManagedObjectModel(
        for: [Challenge.self, Attempt.self]
      )
    else { return }
    let kit = NSPersistentCloudKitContainer(
      name: "Schema",
      managedObjectModel: model
    )
    kit.persistentStoreDescriptions = [store]
    kit.loadPersistentStores { _, _ in
      // initializeCloudKitSchema reports
      // a store that didn't load.
    }
    try kit.initializeCloudKitSchema()
  }
}
#endif
