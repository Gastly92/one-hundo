import BaseSnapshots
@testable import OneHundo
import SwiftData
import SwiftUI
import XCTest

/// A picture of every screen (`ScreenID`) in
/// each look (see `Looks`), on a fixed day.
@MainActor
final class SnapshotTests: XCTestCase {
  /// The fixed "now": noon, Jan 15 2026,
  /// UTC, so dates on screen never change.
  private static let now = Date(
    timeIntervalSince1970: 1_768_478_400
  )

  /// Every screen's store, kept for the
  /// whole run: SwiftUI keeps a drawn
  /// screen's @Query listening for saves,
  /// and one whose store was freed crashes
  /// on the next save (`StoreTests`).
  private static var stores: [ModelContainer]
    = []

  func testEveryScreen() throws {
    for screen in ScreenID.allCases {
      let view = try page(screen)
      let name = screen.rawValue
      Looks.check(view, named: name)
    }
  }

  /// The screen as `ScreenHost` shows it,
  /// with the sample challenges where it
  /// needs them, on the fixed day.
  private func page(
    _ screen: ScreenID
  ) throws -> some View {
    let store = try AppStore.open(
      inMemory: true
    )
    Self.stores.append(store)
    let seeded = AppLaunch.seededScreens
    if seeded.contains(screen) {
      let variant = AppLaunch.sample(
        for: screen
      )
      SampleData.insert(
        into: store.mainContext,
        now: Self.now,
        variant: variant
      )
    }
    // No animations (the goal's confetti
    // falls on appear), so every picture
    // shows where they end.
    return ScreenHost(screen: screen)
      .modelContainer(store)
      .fixedNow(Self.now)
      .transaction { $0.animation = nil }
  }
}
