import Foundation
import SwiftData

/// What the app does at launch: read the
/// launch arguments, open the data store,
/// and seed sample data for UI tests. Kept
/// out of the `App` so it can be unit tested
/// with a fake store.
@MainActor
struct AppLaunch {
  let isUITesting: Bool
  /// The opened store, or the error that
  /// stopped it from opening.
  let store:
    Result<ModelContainer, any Error>
  /// A single screen to show instead of the
  /// app (`-showScreen <id>`, UI tests
  /// only).
  let screen: ScreenID?
  /// Where reminders go. UI tests get none
  /// (no permission prompt), unless they
  /// launch with -notifications.
  let notifier: any Notifier

  /// Screens shown with the sample
  /// challenges; the rest show an empty app.
  static let seededScreens: Set<ScreenID> = [
    .challengeList, .challengeDetail,
    .calendar, .calendarDay,
    .logAttempt, .editAttempt, .logTimed,
    .logResult, .goalReached, .newGoal,
    .challengeSettings, .customSettings,
    .completedList, .completedDetail,
    .noHistory, .logMissed, .logReplace,
    .newGoalLow,
  ]

  /// How the sample data differs for
  /// `screen`.
  static func sample(
    for screen: ScreenID?
  ) -> SampleData.Variant {
    switch screen {
    case .completedList, .completedDetail:
      .completed
    case .noHistory:
      .noHistory
    default:
      .standard
    }
  }

  /// Opens the store, in memory or on disk.
  typealias Opener = (_ inMemory: Bool)
    throws -> ModelContainer

  init(
    arguments args: [String],
    open: Opener = AppStore.open(inMemory:)
  ) {
    // UI tests launch with -uiTesting: an
    // in-memory store, so every run starts
    // clean.
    isUITesting = args.contains("-uiTesting")
    let inMemory = isUITesting
    let real = !isUITesting
      || args.contains("-notifications")
    if real {
      notifier = PhoneNotifier()
    } else {
      notifier = SilentNotifier()
    }
    let shown = isUITesting
      ? Self.screen(in: args) : nil
    screen = shown
    if shown == .storeError {
      // The store-error screen opens through
      // the real failure path (a full disk).
      store = .failure(
        CocoaError(.fileWriteOutOfSpace)
      )
    } else {
      store = Result { try open(inMemory) }
    }
    let seeded = Self.seededScreens
    let needsData = seeded.contains {
      $0 == shown
    }
    let seedFlag = args.contains(
      "-seedSampleData"
    )
    guard isUITesting, seedFlag || needsData,
      case .success(let container) = store
    else { return }
    let context = container.mainContext
    SampleData.insert(
      into: context,
      variant: Self.sample(for: shown)
    )
  }

  /// The screen named after `-showScreen`,
  /// if any and if it exists.
  private static func screen(
    in args: [String]
  ) -> ScreenID? {
    let key = "-showScreen"
    guard let pos = args.firstIndex(of: key),
      pos + 1 < args.count
    else { return nil }
    return ScreenID(rawValue: args[pos + 1])
  }
}
