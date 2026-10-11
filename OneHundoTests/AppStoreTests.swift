@testable import OneHundo
import SwiftData
import SwiftUI
import TestSupport
import XCTest

/// The App Store screenshots: seven
/// screens (one in dark mode) on a 6.9-inch
/// iPhone, saved at the large and medium
/// sizes (`phones`), with a month of sample
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

  /// One screenshot: its file name, caption,
  /// screen and light or dark mode.
  private struct Shot {
    let name: String
    let caption: String
    let screen: ScreenID
    var style = UIUserInterfaceStyle.light
  }

  /// A screenshot and its screen's view.
  private struct Page {
    let shot: Shot
    let view: AnyView
  }

  /// The screenshots, in the listing's
  /// order. Search results show the first
  /// three, so they're the strongest.
  private static let shots = [
    Shot(
      name: "1-list",
      caption:
        "Get to 100,\none day at a time",
      screen: .tabs
    ),
    Shot(
      name: "2-challenge",
      caption: "See how far you've come",
      screen: .challengeDetail
    ),
    Shot(
      name: "3-calendar",
      caption: "Every day you trained",
      screen: .calendar
    ),
    Shot(
      name: "4-plan",
      caption: "Set your goal and pace",
      screen: .enrollGoal
    ),
    Shot(
      name: "5-log",
      caption: "Beat yesterday by one",
      screen: .logAttempt
    ),
    Shot(
      name: "6-goal",
      caption: "Reach 100, then aim higher",
      screen: .goalReached
    ),
    Shot(
      name: "7-dark",
      caption: "Light or dark, your choice",
      screen: .challengeDetail,
      style: .dark
    ),
  ]

  /// `style`, standard text, 3x, sRGB.
  private static func traits(
    _ style: UIUserInterfaceStyle
  ) -> UITraitCollection {
    UITraitCollection {
      $0.userInterfaceStyle = style
      $0.displayScale = 3
      $0.displayGamut = .SRGB
      $0.preferredContentSizeCategory =
        .large
    }
  }

  /// The screen: an iPhone Pro Max, 440 ×
  /// 956 points with its safe area, drawn
  /// in the app's window like the
  /// snapshots.
  private static func screen(
    _ style: UIUserInterfaceStyle
  ) -> Snapshotting<AnyView, UIImage> {
    let look = traits(style)
    return .image(
      drawHierarchyInKeyWindow: true,
      precision: 0.99,
      perceptualPrecision: 0.98,
      layout: .device(
        config: ViewImageConfig(
          safeArea: UIEdgeInsets(
            top: 62,
            left: 0,
            bottom: 34,
            right: 0
          ),
          size: size,
          traits: look
        )
      ),
      traits: look
    )
  }

  private static let size = CGSize(
    width: 440,
    height: 956
  )

  /// An iPhone size App Store Connect takes,
  /// in pixels, and what's added to the
  /// file name.
  private struct Phone {
    let suffix: String
    let pixels: (width: Int, height: Int)
  }

  /// Large (6.9-inch, e.g. 17 Pro Max) and
  /// medium (6.3-inch, e.g. 17 Pro, the one
  /// App Store Connect requires).
  private static let phones = [
    Phone(suffix: "", pixels: (1320, 2868)),
    Phone(
      suffix: "-medium",
      pixels: (1206, 2622)
    ),
  ]

  /// Draws the screen, then the `Poster`
  /// around it, at `phone`'s size (the
  /// medium one scaled down from the large;
  /// their shapes differ by 0.07%), saved
  /// without an alpha channel (App Store
  /// Connect turns those down).
  private static func poster(
    _ phone: Phone
  ) -> Snapshotting<Page, UIImage> {
    Snapshotting(
      pathExtension: "png",
      diffing: screen(.light).diffing
    ) { page in
      let shot = page.shot
      return screen(shot.style)
        .snapshot(page.view)
        .map {
          opaque(
            frame($0, for: shot),
            pixels: phone.pixels
          )
        }
    }
  }

  /// `image` in `shot`'s `Poster`, drawn off
  /// screen by SwiftUI (it's only shapes,
  /// text and the picture, so it comes out
  /// the same every time; a second pass in
  /// the window sometimes caught the screen
  /// before the poster appeared).
  private static func frame(
    _ image: UIImage,
    for shot: Shot
  ) -> UIImage {
    let dark = shot.style == .dark
    let framed = Poster(
      caption: shot.caption,
      screen: image,
      dark: dark
    )
    .frame(
      width: size.width,
      height: size.height
    )
    .environment(\.colorScheme, .light)
    .environment(\.dynamicTypeSize, .large)
    let renderer = ImageRenderer(
      content: framed
    )
    renderer.scale = 3
    renderer.isOpaque = true
    return renderer.uiImage ?? image
  }

  func testScreenshots() throws {
    for shot in Self.shots {
      let view = try page(shot.screen)
      for phone in Self.phones {
        let name = shot.name + phone.suffix
        assertSnapshot(
          of: Page(shot: shot, view: view),
          as: Self.poster(phone),
          named: name
        )
        try check(name, phone.pixels)
      }
    }
  }
  /// The screen as `ScreenHost` shows it,
  /// with the showcase data, on the fixed
  /// day.
  private func page(
    _ screen: ScreenID
  ) throws -> AnyView {
    let store = try AppStore.open(
      inMemory: true
    )
    Self.stores.append(store)
    Showcase.insert(
      into: store.mainContext,
      now: Self.now
    )
    let host = ScreenHost(screen: screen)
      .modelContainer(store)
      .environment(\.now, Self.now)
      .transaction { $0.animation = nil }
    return AnyView(host)
  }

  /// The saved image is what App Store
  /// Connect takes: `pixels`' size, 8-bit
  /// RGB (read from the PNG's header).
  private func check(
    _ name: String,
    _ pixels: (width: Int, height: Int)
  ) throws {
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
    XCTAssertEqual(width, pixels.width, name)
    XCTAssertEqual(
      height,
      pixels.height,
      name
    )
    // 8 bits a channel; color type 2 is RGB
    // (6 would be RGB with alpha).
    XCTAssertEqual(head[24], 8, name)
    XCTAssertEqual(head[25], 2, name)
  }

  /// `image` drawn again at `pixels`' size
  /// with no alpha channel (and so saved
  /// without one).
  nonisolated private static func opaque(
    _ image: UIImage,
    pixels: (width: Int, height: Int)
  ) -> UIImage {
    guard let source = image.cgImage,
      let space = source.colorSpace,
      let context = CGContext(
        data: nil,
        width: pixels.width,
        height: pixels.height,
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
      width: pixels.width,
      height: pixels.height
    )
    context.interpolationQuality = .high
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
