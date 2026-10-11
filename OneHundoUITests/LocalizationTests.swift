import XCTest

/// Runs the app in Xcode's bounded
/// pseudo-language, which wraps every
/// translatable string in "[# ... #]".
/// Visible text without the brackets would
/// stay in English after translation, so
/// each screen fails on any such text.
final class LocalizationTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  private static let pseudo = [
    "-NSSurroundLocalizedStrings", "YES",
  ]

  /// System-formatted text: dates (a
  /// completed card's is its detail),
  /// weekday letters, and the system's own
  /// error description.
  private static let systemIDs: Set = [
    "attemptRow", "attemptDate",
    "errorDetails", "monthTitle",
    "weekday", "dayTitle", "cardDetail",
  ]

  /// Calendar days ("day.5"): a date, and
  /// the names of challenges logged then
  /// (the sample Plank's stays as typed).
  private static let dayPrefix = "day."

  /// Text the user typed (the sample custom
  /// challenge's name), which stays as
  /// typed.
  private static let userText: Set = [
    "Plank",
  ]

  /// Every screen in the app (`ScreenID`),
  /// each opened directly with sample data.
  @MainActor
  func testEveryScreen() {
    for screen in ScreenID.allCases {
      let app = App.start(
        screen: screen,
        arguments: Self.pseudo
      )
      let text = app.staticTexts.firstMatch
      guard text.appears(within: 10) else {
        XCTFail("[\(screen)] showed no text")
        continue
      }
      // The whole screen in one read. Asking
      // for each element's label and frame
      // took hundreds of round trips a
      // screen, and one timed out when CI's
      // runner stalled.
      do {
        check(try app.snapshot(), on: screen)
      } catch {
        XCTFail("[\(screen)] \(error)")
      }
      app.terminate()
    }
  }

  private typealias Node =
    any XCUIElementSnapshot

  /// `node` and everything inside it.
  @MainActor
  private func all(_ node: Node) -> [Node] {
    let inside = node.children.flatMap {
      all($0)
    }
    return [node] + inside
  }

  /// Where system text sits, which isn't
  /// the app's to translate: navigation bar
  /// buttons (e.g. Back), inside date
  /// pickers, and the history chart (its
  /// axis labels are system-formatted dates
  /// and numbers).
  @MainActor
  private func systemAreas(
    in nodes: [Node]
  ) -> [CGRect] {
    let bars = nodes.filter {
      $0.elementType == .navigationBar
    }
    .flatMap { all($0) }
    .filter { $0.elementType == .button }
    let pickers = nodes.filter {
      $0.elementType == .datePicker
    }
    .flatMap { all($0).dropFirst() }
    let charts = nodes.filter {
      $0.identifier == "historyChart"
    }
    return (bars + pickers + charts)
      .map(\.frame)
  }

  /// Fails for each visible text or button
  /// label that has letters but no brackets.
  @MainActor
  private func check(
    _ root: Node,
    on screen: ScreenID,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let nodes = all(root)
    let system = systemAreas(in: nodes)
    let kinds: [XCUIElement.ElementType] =
      [.staticText, .button]
    var bracketed = 0
    for node in nodes
    where kinds.contains(node.elementType) {
      let label = node.label
      let id = node.identifier
      guard label.contains(where: \.isLetter)
      else { continue }
      if label.contains("[#") {
        bracketed += 1
        continue
      }
      if Self.systemIDs.contains(id)
        || id.hasPrefix(Self.dayPrefix)
        || Self.userText.contains(label) {
        continue
      }
      let frame = node.frame
      if system.contains(where: {
        $0.contains(frame)
      }) {
        continue
      }
      XCTFail(
        "[\(screen)] Not translatable: "
          + "'\(label)' (id '\(id)')",
        file: file,
        line: line
      )
    }
    // Guards against the pseudo-language not
    // taking effect at all.
    XCTAssertGreaterThan(
      bracketed,
      0,
      "[\(screen)] No bracketed text",
      file: file,
      line: line
    )
  }
}
