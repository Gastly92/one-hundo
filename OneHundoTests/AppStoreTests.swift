import BaseSnapshots
@testable import OneHundo
import SwiftData
import SwiftUI
import XCTest

/// The App Store screenshots
/// (`AppStoreShots`): seven screens (one in
/// dark mode) with a month of sample
/// training (`Showcase`). The images in
/// `__Snapshots__/AppStoreTests/` are the
/// ones to upload (docs/APPSTORE.md).
@MainActor
final class AppStoreTests: XCTestCase {
  /// Noon, Jan 28 2026, UTC: late in the
  /// month, so the calendar is full.
  private static let now = Date(
    timeIntervalSince1970: 1_769_601_600
  )

  /// Kept for the whole run (see
  /// `SnapshotTests.stores`).
  private static var stores: [ModelContainer]
    = []

  /// The icon's gradient (#8B2CF5 into
  /// #00B4F0), violet at the top so white
  /// text on it is easy to read.
  private static let colors = [
    Color(
      red: 0.545, green: 0.173, blue: 0.961
    ),
    Color(red: 0, green: 0.706, blue: 0.941),
  ]

  /// The screenshots, in the listing's
  /// order. Search results show the first
  /// three, so they're the strongest.
  func testScreenshots() throws {
    try AppStoreShots.check(
      [
        shot(
          "1-list",
          .tabs,
          "Get to 100,\none day at a time"
        ),
        shot(
          "2-challenge",
          .challengeDetail,
          "See how far you've come"
        ),
        shot(
          "3-calendar",
          .calendar,
          "Every day you trained"
        ),
        shot(
          "4-plan",
          .enrollGoal,
          "Set your goal and pace"
        ),
        shot(
          "5-log",
          .logAttempt,
          "Beat yesterday by one"
        ),
        shot(
          "6-goal",
          .goalReached,
          "Reach 100, then aim higher"
        ),
        shot(
          "7-dark",
          .challengeDetail,
          "Light or dark, your choice",
          dark: true
        ),
      ],
      colors: Self.colors
    )
  }

  /// One screenshot: `screen` under
  /// `caption`, saved as `name`.
  private func shot(
    _ name: String,
    _ screen: ScreenID,
    _ caption: String,
    dark: Bool = false
  ) throws -> Shot {
    Shot(
      name: name,
      caption: caption,
      view: try page(screen),
      dark: dark
    )
  }

  /// The screen as `ScreenHost` shows it,
  /// with the showcase data, on the fixed
  /// day.
  private func page(
    _ screen: ScreenID
  ) throws -> some View {
    let store = try AppStore.open(
      inMemory: true
    )
    Self.stores.append(store)
    Showcase.insert(
      into: store.mainContext,
      now: Self.now
    )
    return ScreenHost(screen: screen)
      .modelContainer(store)
      .fixedNow(Self.now)
      .transaction { $0.animation = nil }
  }
}
