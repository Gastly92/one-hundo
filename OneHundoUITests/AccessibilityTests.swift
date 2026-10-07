import XCTest

/// Which audit checks to run.
private typealias Checks =
  XCUIAccessibilityAuditType

/// Runs Xcode's accessibility audit
/// (contrast, Dynamic Type, labels, hit
/// areas, clipped text) on each main screen,
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
  /// fit, and buttons stay big enough. (It
  /// can't scale further, so Dynamic Type
  /// isn't checked.)
  @MainActor
  func testLargestText() {
    let size = [
      "-UIPreferredContentSizeCategoryName",
      "UICTContentSizeCategory"
        + "AccessibilityXXXL",
    ]
    auditScreens(
      look: "largest",
      .all.subtracting(.dynamicType),
      arguments: size
    )
  }

  /// Every screen in the app (`ScreenID`),
  /// each opened directly with sample data.
  @MainActor
  private func auditScreens(
    look: String,
    _ types: Checks = .all,
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

  /// Drags up half a screen near the leading
  /// edge, clear of pickers. False if
  /// nothing moved. (One snapshot of the
  /// screen is far quicker than asking for
  /// each element's frame.)
  @MainActor
  private func scrollDown(
    _ app: XCUIApplication
  ) -> Bool {
    let before = Self.layout(of: app)
    let window = app.windows.firstMatch
    let start = window.coordinate(
      withNormalizedOffset: CGVector(
        dx: 0.04, dy: 0.75
      )
    )
    let end = window.coordinate(
      withNormalizedOffset: CGVector(
        dx: 0.04, dy: 0.25
      )
    )
    start.press(
      forDuration: 0.05, thenDragTo: end
    )
    return Self.layout(of: app) != before
  }

  /// Every element and its frame, without
  /// the memory addresses that change on
  /// each snapshot.
  @MainActor
  private static func layout(
    of app: XCUIApplication
  ) -> String {
    let tree = app.debugDescription
    return tree.replacingOccurrences(
      of: "0x[0-9a-fA-F]+",
      with: "",
      options: .regularExpression
    )
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
    let window = app.windows.firstMatch.frame
    try app.performAccessibilityAudit(
      for: types
    ) {
      if Self.isExpected(
        $0, bars: bars, window: window
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
    window: CGRect
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
    // Text cut off at the screen's edge:
    // the audit measures it against what's
    // past the edge. It's audited in full
    // on the next page.
    return !window.contains(element.frame)
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
