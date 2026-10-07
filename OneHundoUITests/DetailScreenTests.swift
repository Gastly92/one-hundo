import XCTest

final class DetailScreenTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  @MainActor
  func testLogThenReplaceSameDay() {
    let app = App.start(seeded: true)

    // Push-ups started 3 days ago at 8,
    // logged 10 yesterday: "Try 11 today".
    let pushUps = app.card("pushups")
    XCTAssertTrue(
      pushUps.appears(within: 10)
    )
    pushUps.tap()

    let log = app.button("logAttemptButton")
    let best = app.text("personalBestValue")
    let days = app.text("daysLoggedValue")
    let today = app.text("todayText")
    XCTAssertTrue(log.appears())
    XCTAssertEqual(
      today.label, "Try 11 today"
    )
    XCTAssertEqual(best.label, "10")
    XCTAssertEqual(days.label, "2")
    XCTAssertEqual(log.label, "Log attempt")

    // Log 13: prefilled with today's target
    // of 11, then + twice.
    log.tap()
    logCount(app, from: 11, to: 13)

    let title = app.text("logOutcomeTitle")
    XCTAssertTrue(title.appears())
    XCTAssertEqual(title.label, "Nice work!")
    let badge = app.text("newBestBadge")
    XCTAssertTrue(badge.exists)
    let done = app.button("logDoneButton")
    done.tap()

    XCTAssertTrue(
      app.text("Done: 13").appears()
    )
    XCTAssertEqual(best.label, "13")
    XCTAssertEqual(days.label, "3")
    XCTAssertEqual(log.label, "Edit today")

    // Logging again the same day replaces
    // today's count.
    log.tap()
    logCount(app, from: 13, to: 14)
    XCTAssertTrue(done.appears())
    done.tap()

    XCTAssertTrue(
      app.text("Done: 14").appears()
    )
    XCTAssertEqual(days.label, "3")

    // Back on the list, the card shows
    // today's count.
    let back = app.navigationBars.buttons
      .element(boundBy: 0)
    back.tap()
    XCTAssertTrue(pushUps.appears())
    let card = pushUps.label
    XCTAssertTrue(card.contains("14 / 100"))
    XCTAssertTrue(card.contains("Done: 14"))
  }

  @MainActor
  func testHistoryRowEditsAttempt() {
    let app = App.start(seeded: true)

    // Push-ups has attempts of 8 (start) and
    // 10 (yesterday).
    let pushUps = app.card("pushups")
    XCTAssertTrue(
      pushUps.appears(within: 10)
    )
    pushUps.tap()

    let row = app.button("attemptRow")
      .firstMatch
    XCTAssertTrue(row.appears())
    row.tap()

    let sheet = app.bar("Edit attempt")
    XCTAssertTrue(sheet.appears())
    let field = app.field("logCount.field")
    XCTAssertEqual(field.textValue, "10")
    app.button("Cancel").tap()
    let log = app.button("logAttemptButton")
    XCTAssertTrue(log.appears())
  }

  @MainActor
  func testHistoryMenuEditsAndDeletes() {
    let app = App.start(seeded: true)
    let pushUps = app.card("pushups")
    XCTAssertTrue(
      pushUps.appears(within: 10)
    )
    pushUps.tap()
    let row = app.button("attemptRow")
      .firstMatch
    XCTAssertTrue(row.appears())

    // Edit from the row's menu.
    pick("Edit", on: row, app)
    let sheet = app.bar("Edit attempt")
    XCTAssertTrue(sheet.appears())
    app.button("Cancel").tap()
    XCTAssertTrue(sheet.disappears())

    // Delete both attempts (8 and 10).
    pick("Delete", on: row, app)
    pick("Delete", on: row, app)
    let empty = app.text("No attempts yet")
    XCTAssertTrue(empty.appears())
  }

  /// Long-presses `row`, then taps `label`
  /// in its menu.
  @MainActor
  private func pick(
    _ label: String,
    on row: XCUIElement,
    _ app: XCUIApplication
  ) {
    let item = app.menuItem(label, on: row)
    item.tap()
    // Wait for the menu to close, so the
    // next pick doesn't find this one.
    _ = item.disappears()
  }

  /// In the open Log attempt sheet: checks
  /// the count starts at `start`, taps + up
  /// to `end`, and saves.
  @MainActor
  private func logCount(
    _ app: XCUIApplication,
    from start: Int,
    to end: Int
  ) {
    let field = app.field("logCount.field")
    XCTAssertTrue(field.appears())
    XCTAssertEqual(
      field.textValue, "\(start)"
    )
    let plus = app.button("logCount.plus")
    for _ in start..<end { plus.tap() }
    XCTAssertEqual(field.textValue, "\(end)")
    app.button("logSaveButton").tap()
  }
}
