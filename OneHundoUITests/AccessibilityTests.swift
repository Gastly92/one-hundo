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
    for _ in 0..<Self.maxPages {
      try audit(app, types, on: name)
      if !scrollDown(app) {
        return
      }
    }
    XCTFail("[\(name)] kept scrolling")
  }

  /// Drags up half a screen, quickly and in
  /// the page margin, so no card or row
  /// gets pressed (a slow drag opened a
  /// card's menu). False if no text moved.
  @MainActor
  private func scrollDown(
    _ app: XCUIApplication
  ) -> Bool {
    let before = Self.settledFrames(in: app)
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
    return Self.settledFrames(in: app)
      != before
  }

  /// Text frames once the screen stops
  /// moving (a drag can leave it bouncing).
  @MainActor
  private static func settledFrames(
    in app: XCUIApplication
  ) -> [CGRect] {
    var last = textFrames(in: app)
    for _ in 0..<10 {
      Thread.sleep(forTimeInterval: 0.3)
      let next = textFrames(in: app)
      if next == last {
        return next
      }
      last = next
    }
    return last
  }

  /// Where each text is, read from one
  /// snapshot of the screen (asking each
  /// element separately is far slower).
  @MainActor
  private static func textFrames(
    in app: XCUIApplication
  ) -> [CGRect] {
    let root = try? app.snapshot()
    return root.map(frames) ?? []
  }

  @MainActor
  private static func frames(
    _ node: any XCUIElementSnapshot
  ) -> [CGRect] {
    let own = node.elementType == .staticText
      ? [node.frame] : []
    return own + node.children.flatMap {
      frames($0)
    }
  }

  /// Audits the current screen, failing once
  /// per issue with enough detail to find
  /// it.
  @MainActor
  private func audit(
    _ app: XCUIApplication,
    _ types: Checks,
    on screen: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) throws {
    do {
      try runAudit(
        app,
        types,
        screen,
        file: file,
        line: line
      )
    } catch {
      // "Audit failed to complete in time":
      // retry once; a second timeout fails.
      guard (error as NSError).code == -56
      else { throw error }
      try runAudit(
        app,
        types,
        screen,
        file: file,
        line: line
      )
    }
  }

  @MainActor
  private func runAudit(
    _ app: XCUIApplication,
    _ types: Checks,
    _ screen: String,
    file: StaticString,
    line: UInt
  ) throws {
    // The navigation bar (title, Close,
    // Cancel, Save) is iOS's own: it doesn't
    // scale with text size, and its glass
    // can read as low contrast
    // mid-animation.
    let bars = app.navigationBars
      .descendants(matching: .any)
      .allElementsBoundByIndex.map(\.frame)
    let visible = Self.visibleArea(of: app)
    try app.performAccessibilityAudit(
      for: types
    ) {
      if Self.isExpected(
        $0, bars: bars, visible: visible
      ) {
        return true
      }
      let found = Self.describe($0)
      XCTFail(
        "[\(screen)] \(found)",
        file: file,
        line: line
      )
      return true
    }
  }

  /// Issues that come from iOS itself, not
  /// the app.
  @MainActor
  private static func isExpected(
    _ issue: XCUIAccessibilityAuditIssue,
    bars: [CGRect],
    visible: CGRect
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
    // element comes from a system control
    // (the time picker draws its own);
    // anything in our views has an element.
    guard let element = issue.element else {
      return text.contains(
        "Potentially inaccessible text"
      )
    }
    if bars.contains(element.frame) {
      return true
    }
    // Text cut off at the screen's edge or
    // under the navigation bar: the audit
    // measures it against what's past the
    // edge. It's audited in full on another
    // page.
    return !visible.contains(element.frame)
  }

  /// The window below the navigation bar:
  /// text scrolled under the bar's glass
  /// is partly hidden.
  @MainActor
  private static func visibleArea(
    of app: XCUIApplication
  ) -> CGRect {
    let window = app.windows.firstMatch.frame
    let bar = app.navigationBars.firstMatch
    guard bar.exists else {
      return window
    }
    let top = bar.frame.maxY
    return CGRect(
      x: window.minX,
      y: top,
      width: window.width,
      height: window.maxY - top
    )
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
