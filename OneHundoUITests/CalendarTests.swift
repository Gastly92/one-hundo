import XCTest

final class CalendarTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  /// Today, the sample data has Sit-ups
  /// (target hit) and Pull-ups (started
  /// today).
  @MainActor
  func testDayListsItsChallenges() {
    let app = App.start(seeded: true)
    app.tabBars.buttons["Calendar"].tap()
    let today = Calendar.current.component(
      .day, from: Date()
    )
    let cell = app.button("day.\(today)")
    XCTAssertTrue(cell.appears(within: 10))
    // A marker per challenge, by name.
    XCTAssertTrue(
      cell.label.contains("Sit-ups"),
      cell.label
    )
    cell.tap()

    let sitUps = app.button(
      "dayEntry.situps"
    )
    XCTAssertTrue(sitUps.appears())
    XCTAssertTrue(
      sitUps.label.contains(
        "Hit the target of 16."
      ),
      sitUps.label
    )
    let pullUps = app.button(
      "dayEntry.pullups"
    )
    XCTAssertTrue(
      pullUps.label.contains(
        "Started this challenge"
      ),
      pullUps.label
    )

    // On to the challenge's own screen.
    sitUps.tap()
    let screen = app.bar("Sit-ups")
    XCTAssertTrue(screen.appears())
  }

  @MainActor
  func testChangeMonth() {
    let app = App.start()
    app.tabBars.buttons["Calendar"].tap()
    let title = app.text("monthTitle")
    XCTAssertTrue(title.appears(within: 10))
    let now = title.label
    // Nothing to see after this month.
    let next = app.button("Next month")
    XCTAssertFalse(next.isEnabled)

    // Swipe right for the month before.
    app.scrollViews["calendarGrid"]
      .swipeRight()
    XCTAssertNotEqual(title.label, now)
    next.tap()
    XCTAssertEqual(title.label, now)
    app.button("Previous month").tap()
    XCTAssertNotEqual(title.label, now)

    // Today goes back, then hides.
    let today = app.button("todayButton")
    today.tap()
    XCTAssertEqual(title.label, now)
    XCTAssertTrue(today.disappears())
  }
}
