@testable import OneHundo
import SwiftData
import SwiftUI
import TestSupport
import XCTest

/// The App Store screenshots: six screens in
/// light mode on a 6.9-inch iPhone (1320 ×
/// 2868 pixels), with a month of sample
/// training (`Showcase`). Recorded and
/// compared like `SnapshotTests`; the images
/// in `__Snapshots__/AppStoreTests/` are the
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

  /// Each picture's name and screen, in the
  /// listing's order.
  private static let shots: [
    (String, ScreenID)
  ] = [
    ("1-list", .tabs),
    ("2-challenge", .challengeDetail),
    ("3-log", .logAttempt),
    ("4-calendar", .calendar),
    ("5-plan", .enrollGoal),
    ("6-goal", .goalReached),
  ]

  /// Light mode, standard text, 3x, sRGB.
  private static let traits =
    UITraitCollection {
      $0.userInterfaceStyle = .light
      $0.displayScale = 3
      $0.displayGamut = .SRGB
      $0.preferredContentSizeCategory =
        .large
    }

  /// An iPhone Pro Max: 440 × 956 points,
  /// with its safe area.
  private static let layout =
    SwiftUISnapshotLayout.device(
      config: ViewImageConfig(
        safeArea: UIEdgeInsets(
          top: 62,
          left: 0,
          bottom: 34,
          right: 0
        ),
        size: CGSize(
          width: 440,
          height: 956
        ),
        traits: traits
      )
    )

  private typealias Shot =
    Snapshotting<AnyView, UIImage>

  /// A picture without an alpha channel,
  /// which App Store Connect turns down.
  private static var flat: Shot {
    let image = Shot.image(
      drawHierarchyInKeyWindow: true,
      precision: 0.99,
      perceptualPrecision: 0.98,
      layout: layout,
      traits: traits
    )
    return Shot(
      pathExtension: "png",
      diffing: image.diffing
    ) { view in
      image.snapshot(view).map(opaque)
    }
  }

  func testScreenshots() throws {
    for (name, screen) in Self.shots {
      let view = try page(screen)
      assertSnapshot(
        of: AnyView(view),
        as: Self.flat,
        named: name
      )
      try check(name)
    }
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
      .environment(\.now, Self.now)
      .transaction { $0.animation = nil }
  }

  /// The saved image is what App Store
  /// Connect takes: 1320 × 2868, 8-bit RGB
  /// (read from the PNG's header).
  private func check(_ name: String) throws {
    let file = URL(filePath: #filePath)
      .deletingLastPathComponent()
      .appending(path: "__Snapshots__")
      .appending(path: "AppStoreTests")
      .appending(
        path: "testScreenshots.\(name).png"
      )
    let data = try Data(contentsOf: file)
    let head = [UInt8](data.prefix(26))
    guard head.count == 26 else {
      XCTFail("\(name): not a PNG")
      return
    }
    func number(at start: Int) -> Int {
      head[start..<start + 4].reduce(0) {
        $0 << 8 | Int($1)
      }
    }
    let width = number(at: 16)
    let height = number(at: 20)
    XCTAssertEqual(width, 1320, name)
    XCTAssertEqual(height, 2868, name)
    // 8 bits a channel; color type 2 is RGB
    // (6 would be RGB with alpha).
    XCTAssertEqual(head[24], 8, name)
    XCTAssertEqual(head[25], 2, name)
  }

  /// `image` drawn again with no alpha
  /// channel (and so saved without one).
  nonisolated private static func opaque(
    _ image: UIImage
  ) -> UIImage {
    guard let source = image.cgImage,
      let space = source.colorSpace,
      let context = CGContext(
        data: nil,
        width: source.width,
        height: source.height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: space,
        bitmapInfo: CGImageAlphaInfo
          .noneSkipLast.rawValue
      )
    else { return image }
    let rect = CGRect(
      x: 0,
      y: 0,
      width: source.width,
      height: source.height
    )
    context.draw(source, in: rect)
    guard let drawn = context.makeImage()
    else { return image }
    return UIImage(
      cgImage: drawn,
      scale: image.scale,
      orientation: .up
    )
  }
}
