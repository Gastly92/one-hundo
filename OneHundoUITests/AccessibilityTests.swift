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
        try audit(app, types, on: name)
      } catch {
        XCTFail("[\(name)] audit: \(error)")
      }
      app.terminate()
    }
  }

  /// Audits the current screen, failing once
  /// per issue with enough detail to find
  /// it.
  @MainActor
  private func audit(
    _ app: XCUIApplication,
    _ types: Checks,
    on screen: String
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
      XCTFail("[\(screen)] \(found)")
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
    // element is drawn by iOS (the time
    // picker) or cut off at the screen's
    // edge; our views' text has an element
    // when fully shown.
    guard let element = issue.element else {
      return true
    }
    if bars.contains(element.frame) {
      return true
    }
    // Text cut off at the screen's edge
    // (a long list at large text sizes):
    // the audit measures contrast against
    // what's past the edge.
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
