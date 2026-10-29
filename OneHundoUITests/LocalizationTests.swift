import BaseTesting
import XCTest

/// Every screen's visible text is
/// translatable (see `LocalizationCheck`).
final class LocalizationTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = true
  }

  /// Every screen in the app (`ScreenID`),
  /// each opened directly with sample data.
  @MainActor
  func testEveryScreen() {
    let check = LocalizationCheck(
      // System-formatted text: dates (a
      // completed card's is its detail),
      // weekday letters, and the system's
      // own error description.
      systemIDs: [
        "attemptRow", "attemptDate",
        "errorDetails", "monthTitle",
        "weekday", "dayTitle", "cardDetail",
      ],
      // Calendar days ("day.5"): a date, and
      // the names of challenges logged then
      // (the sample Plank's stays as typed).
      idPrefixes: ["day."],
      // Text the user typed (the sample
      // custom challenge's name).
      userText: ["Plank"],
      // The history chart: its axis labels
      // are system-formatted dates and
      // numbers.
      systemAreaIDs: ["historyChart"]
    )
    check.run(ScreenID.allCases)
  }
}
