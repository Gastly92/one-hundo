@testable import OneHundo
import SwiftData
import SwiftUI
import TestSupport
import XCTest

/// A picture of every screen (`ScreenID`) in
/// light mode, dark mode and large text,
/// compared with the committed images in
/// `__Snapshots__/`. A screen that looks
/// different fails until its images are
/// recorded again (see CLAUDE.md).
///
/// Pictures are drawn in the app's window:
/// iOS 26's glass bars only show their real
/// colors there (offscreen, small titles
/// came out white on white).
@MainActor
final class SnapshotTests: XCTestCase {
  /// The fixed "now": noon, Jan 15 2026,
  /// UTC, so dates on screen never change.
  private static let now = Date(
    timeIntervalSince1970: 1_768_478_400
  )

  /// An iPhone 13-sized screen.
  private static let phone =
    SwiftUISnapshotLayout.device(
      config: .iPhone13
    )

  /// Each look's name and traits. 2x scale
  /// keeps the images small but readable.
  private static let looks = [
    ("light", traits(.light)),
    ("dark", traits(.dark)),
    ("large", traits(.light, large: true)),
  ]

  /// sRGB color: in the app's window images
  /// are otherwise wide color (Display P3),
  /// which compares unreliably once saved.
  /// The text size is always set: left
  /// unset, sizes scaled with text (like
  /// @ScaledMetric) drift from the standard
  /// size.
  private static func traits(
    _ style: UIUserInterfaceStyle,
    large: Bool = false
  ) -> UITraitCollection {
    UITraitCollection {
      $0.userInterfaceStyle = style
      $0.displayScale = 2
      $0.displayGamut = .SRGB
      $0.preferredContentSizeCategory = large
        ? .accessibilityExtraLarge : .large
    }
  }

  func testEveryScreen() throws {
    for screen in ScreenID.allCases {
      let view = try page(screen)
      for (look, traits) in Self.looks {
        assertSnapshot(
          of: view,
          as: .image(
            drawHierarchyInKeyWindow: true,
            precision: 0.99,
            perceptualPrecision: 0.98,
            layout: Self.phone,
            traits: traits
          ),
          named: "\(screen.rawValue)-\(look)"
        )
      }
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
      .environment(\.now, Self.now)
      .transaction { $0.animation = nil }
  }
}
