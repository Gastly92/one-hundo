import XCTest

/// Which audit checks to run.
private typealias Checks =
  XCUIAccessibilityAuditType

/// Runs Xcode's accessibility audit
/// (contrast, labels, hit areas, clipped
/// text) on each main screen,
/// in light mode, dark mode and the largest
/// text size. Each issue fails the test with
/// the screen and element.
final class AccessibilityTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  /// A stop for screens that keep moving
  /// when swiped.
  private static let maxPages = 12

  /// Every check, in light mode.
  @MainActor
  func testLight() {
    auditScreens(look: "light")
  }

  /// Dark mode changes colors, so only
  /// contrast is checked again. The app is
  /// put in dark mode itself: switching the
  /// simulator's setting right before launch
  /// made launches time out.
  @MainActor
  func testDark() {
    auditScreens(
      look: "dark",
      .contrast,
      arguments: ["-darkMode"]
    )
  }

  /// The largest text size: text must still
  /// fit, and buttons stay big enough.
  @MainActor
  func testLargestText() {
    let size = [
      "-UIPreferredContentSizeCategoryName",
      "UICTContentSizeCategory"
        + "AccessibilityXXXL",
    ]
    auditScreens(
      look: "largest", arguments: size
    )
  }

  /// Every screen in the app (`ScreenID`),
  /// each opened directly with sample data.
  ///
  /// The audit's Dynamic Type check is left
  /// out: it enlarges the text, and text
  /// pushed off screen by that fails, so it
  /// can't check anything low on a screen.
  /// The `fixed_font_size` lint rule covers
  /// it instead (a fixed size is what stops
  /// text scaling), and the large text
  /// snapshots show every screen scaled.
  @MainActor
  private func auditScreens(
    look: String,
    _ types: Checks = .all.subtracting(
      .dynamicType
    ),
    arguments: [String] = []
  ) {
    for screen in ScreenID.allCases {
      let app = App.start(
        screen: screen, arguments: arguments
      )
      let name = "\(screen) \(look)"
      let text = app.staticTexts.firstMatch
      guard text.appears(within: 10) else {
        XCTFail("[\(name)] showed no text")
        continue
      }
      do {
        try auditPages(app, types, on: name)
      } catch {
        XCTFail("[\(name)] audit: \(error)")
      }
      app.terminate()
    }
  }

  /// The audit only sees what's on screen,
  /// so each screen is audited, scrolled
  /// down, and audited again until nothing
  /// moves.
  @MainActor
  private func auditPages(
    _ app: XCUIApplication,
    _ types: Checks,
    on name: String
  ) throws {
    var bottom: CGFloat?
    for _ in 0..<Self.maxPages {
      try audit(
        app, types, on: name, bottom: bottom
      )
      let before = Self.settled(app)
      drag(app)
      let after = Self.settled(app)
      if after.texts == before.texts {
        return
      }
      bottom = Self.fixedTop(before, after)
    }
    XCTFail("[\(name)] kept scrolling")
  }

  /// Drags up half a screen, quickly and in
  /// the page margin, so no card or row
  /// gets pressed (a slow drag opened a
  /// card's menu).
  @MainActor
  private func drag(_ app: XCUIApplication) {
    let window = app.windows.firstMatch
    let start = window.coordinate(
      withNormalizedOffset: CGVector(
        dx: 0.02, dy: 0.75
      )
    )
    let end = window.coordinate(
      withNormalizedOffset: CGVector(
        dx: 0.02, dy: 0.25
      )
    )
    start.press(
      forDuration: 0.01,
      thenDragTo: end,
      withVelocity: .fast,
      thenHoldForDuration: 0.2
    )
  }

  /// The screen once it stops moving (a
  /// drag can leave it bouncing).
  @MainActor
  private static func settled(
    _ app: XCUIApplication
  ) -> Screen {
    var last = Screen(app)
    for _ in 0..<10 {
      Thread.sleep(forTimeInterval: 0.3)
      let next = Screen(app)
      if next == last {
        return next
      }
      last = next
    }
    return last
  }

  /// The top of whatever stays put at the
  /// bottom while the page scrolls (e.g. a
  /// Next button): text under it is hidden.
  /// The screen's bottom if nothing does.
  @MainActor
  private static func fixedTop(
    _ before: Screen, _ after: Screen
  ) -> CGFloat {
    let fixed = before.items
      .intersection(after.items)
      .filter { $0.top > after.middle }
    let top = fixed.map(\.top).min()
    return CGFloat(top ?? after.end)
  }

  /// Audits the current screen, failing once
  /// per issue with enough detail to find
  /// it. `bottom` is set on scrolled pages.
  @MainActor
  private func audit(
    _ app: XCUIApplication,
    _ types: Checks,
    on screen: String,
    bottom: CGFloat?
  ) throws {
    let page = Page(app, bottom: bottom)
    do {
      try runAudit(app, types, screen, page)
    } catch {
      // "Audit failed to complete in time":
      // retry once; a second timeout fails.
      guard (error as NSError).code == -56
      else { throw error }
      try runAudit(app, types, screen, page)
    }
  }

  @MainActor
  private func runAudit(
    _ app: XCUIApplication,
    _ types: Checks,
    _ screen: String,
    _ page: Page
  ) throws {
    try app.performAccessibilityAudit(
      for: types
    ) {
      if page.isExpected($0) {
        return true
      }
      let found = Self.describe($0)
      XCTFail("[\(screen)] \(found)")
      return true
    }
  }

  /// The issue and its element, to find it
  /// on screen.
  @MainActor
  private static func describe(
    _ issue: XCUIAccessibilityAuditIssue
  ) -> String {
    let text = issue.compactDescription
    let detail = issue.detailedDescription
    let head = "\(text): \(detail)"
    guard let found = issue.element,
      found.exists
    else { return "\(head) | no element" }
    let type = found.elementType.rawValue
    return "\(head) | \(type) "
      + "label='\(found.label)' "
      + "id='\(found.identifier)' "
      + "frame=\(found.frame)"
  }
}

/// The elements on screen, from one
/// snapshot (asking each element separately
/// is far slower). Frames are rounded to
/// whole points: snapshots differ by tiny
/// fractions.
private struct Screen: Equatable {
  struct Item: Hashable {
    let name: String
    let isText: Bool
    let top: Int
  }

  let items: Set<Item>
  let middle: Int
  let end: Int

  var texts: Set<Item> {
    items.filter(\.isText)
  }

  @MainActor
  init(_ app: XCUIApplication) {
    let root = try? app.snapshot()
    items = Set(root.map(Self.collect) ?? [])
    middle = Int(app.frame.midY)
    end = Int(app.frame.maxY)
  }

  @MainActor
  private static func collect(
    _ node: any XCUIElementSnapshot
  ) -> [Item] {
    let box = node.frame
    let type = node.elementType
    let name = [
      "\(type.rawValue)",
      node.identifier,
      node.label,
      "\(Int(box.minX)) \(Int(box.width))",
      "\(Int(box.height))",
    ].joined(separator: "|")
    let own = Item(
      name: name,
      isText: type == .staticText,
      top: Int(box.minY.rounded())
    )
    return [own] + node.children.flatMap {
      collect($0)
    }
  }
}

/// What the audit can fairly check on one
/// page.
private struct Page {
  /// The navigation bar (title, Close,
  /// Cancel, Save) is iOS's own: it doesn't
  /// scale with text size, and its glass
  /// can read as low contrast
  /// mid-animation.
  let bars: [CGRect]
  /// Below the navigation bar and above
  /// anything fixed at the bottom.
  let visible: CGRect
  let isScrolled: Bool

  @MainActor
  init(
    _ app: XCUIApplication,
    bottom: CGFloat?
  ) {
    bars = app.navigationBars
      .descendants(matching: .any)
      .allElementsBoundByIndex.map(\.frame)
    let window = app.windows.firstMatch.frame
    let bar = app.navigationBars.firstMatch
    let top = bar.exists
      ? bar.frame.maxY : window.minY
    let end = bottom ?? window.maxY
    visible = CGRect(
      x: window.minX,
      y: top,
      width: window.width,
      height: end - top
    )
    isScrolled = bottom != nil
  }

  /// Issues that come from iOS itself, or
  /// from text this page only partly shows.
  @MainActor
  func isExpected(
    _ issue: XCUIAccessibilityAuditIssue
  ) -> Bool {
    let text = issue.compactDescription
    // "Nearly passed" contrast passes at
    // larger text sizes; iOS's own secondary
    // text color gets it. Real contrast
    // failures still fail.
    if text.contains("nearly passed") {
      return true
    }
    // Text the audit can't tie to any
    // element comes from iOS: a system
    // control (the time picker draws its
    // own) or, once scrolled, the blur at
    // the screen's edges. Anything in our
    // views has an element, and the first
    // page is checked strictly.
    guard let element = issue.element else {
      return isScrolled || text.contains(
        "Potentially inaccessible text"
      )
    }
    if bars.contains(element.frame) {
      return true
    }
    // Text cut off at the screen's edge,
    // under the navigation bar or under
    // something fixed at the bottom: it's
    // audited in full on another page.
    return !visible.contains(element.frame)
  }
}
