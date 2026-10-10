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

  /// One screenshot: its file name, caption
  /// and screen.
  private struct Shot {
    let name: String
    let caption: String
    let screen: ScreenID
  }

  /// A drawn screen and its caption.
  private struct Page {
    let caption: String
    let view: AnyView
  }

  /// The screenshots, in the listing's
  /// order.
  private static let shots = [
    Shot(
      name: "1-list",
      caption:
        "Get to 100, one day at a time",
      screen: .tabs
    ),
    Shot(
      name: "2-challenge",
      caption: "See how far you've come",
      screen: .challengeDetail
    ),
    Shot(
      name: "3-log",
      caption: "Log what you did today",
      screen: .logAttempt
    ),
    Shot(
      name: "4-calendar",
      caption: "Every day you trained",
      screen: .calendar
    ),
    Shot(
      name: "5-plan",
      caption: "Set your goal and pace",
      screen: .enrollGoal
    ),
    Shot(
      name: "6-goal",
      caption: "Reach 100, then aim higher",
      screen: .goalReached
    ),
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
  /// with its safe area, for the screen.
  private static let phone = layout(
    UIEdgeInsets(
      top: 62,
      left: 0,
      bottom: 34,
      right: 0
    )
  )

  /// The same size with no safe area, for
  /// the poster around it.
  private static let full = layout(.zero)

  private static func layout(
    _ safeArea: UIEdgeInsets
  ) -> SwiftUISnapshotLayout {
    .device(
      config: ViewImageConfig(
        safeArea: safeArea,
        size: CGSize(
          width: 440,
          height: 956
        ),
        traits: traits
      )
    )
  }

  private typealias Strategy =
    Snapshotting<AnyView, UIImage>

  private static func image(
    on layout: SwiftUISnapshotLayout
  ) -> Strategy {
    .image(
      drawHierarchyInKeyWindow: true,
      precision: 0.99,
      perceptualPrecision: 0.98,
      layout: layout,
      traits: traits
    )
  }

  /// Draws the screen, then the `Poster`
  /// around it, saved without an alpha
  /// channel (App Store Connect turns
  /// those down).
  private static var poster:
    Snapshotting<Page, UIImage> {
    let screen = image(on: phone)
    let around = image(on: full)
    return Snapshotting(
      pathExtension: "png",
      diffing: around.diffing
    ) { page in
      Async { done in
        screen.snapshot(page.view).run {
          let view = Poster(
            caption: page.caption,
            screen: $0
          )
          around.snapshot(AnyView(view))
            .map(opaque)
            .run(done)
        }
      }
    }
  }

  func testScreenshots() throws {
    for shot in Self.shots {
      let view = try page(shot.screen)
      assertSnapshot(
        of: Page(
          caption: shot.caption,
          view: AnyView(view)
        ),
        as: Self.poster,
        named: shot.name
      )
      try check(shot.name)
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
