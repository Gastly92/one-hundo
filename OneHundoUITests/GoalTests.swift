import XCTest

/// Reaching a goal: the celebration, a new
/// goal right away, or Done and later
/// Continue from the Completed section.
final class GoalTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  @MainActor
  func testReachGoalAndKeepGoing() {
    let app = App.start(seeded: true)
    // Push-ups: logged 10 yesterday, goal
    // 100.
    let pushUps = app.card("pushups")
    XCTAssertTrue(
      pushUps.appears(within: 10)
    )
    pushUps.tap()
    let log = app.button("logAttemptButton")
    let today = app.text("todayText")
    XCTAssertTrue(log.appears())

    // 100 today: a new goal right away,
    // suggested at 150.
    log.tap()
    enter("100", app)
    let title = app.text("logOutcomeTitle")
    XCTAssertTrue(title.appears())
    XCTAssertEqual(
      title.label, "Goal reached!"
    )
    app.button("setNewGoal").tap()
    let goal = app.field("newGoal.field")
    XCTAssertTrue(goal.appears())
    XCTAssertEqual(goal.textValue, "150")
    app.button("keepGoing").tap()
    XCTAssertTrue(log.appears())
    XCTAssertEqual(today.label, "Done: 100")

    // 150 the same day: Done sets it aside.
    log.tap()
    enter("150", app)
    let done = app.button("logDoneButton")
    XCTAssertTrue(done.appears())
    done.tap()
    let more = app.button("continueButton")
    XCTAssertTrue(more.appears())
    XCTAssertEqual(
      today.label, "Reached 150"
    )

    // On the list, under Completed.
    let back = app.navigationBars.buttons
      .element(boundBy: 0)
    back.tap()
    XCTAssertTrue(
      app.text("Completed").appears()
    )
    XCTAssertTrue(
      pushUps.label.contains("Reached 150")
    )

    // Continue: 150 leads to 230.
    pushUps.tap()
    XCTAssertTrue(more.appears())
    more.tap()
    XCTAssertTrue(goal.appears())
    XCTAssertEqual(goal.textValue, "230")
    app.button("keepGoing").tap()
    XCTAssertTrue(log.appears())
    XCTAssertEqual(today.label, "Done: 150")
  }

  /// In the open Log attempt sheet: types
  /// `count` in place of the number, and
  /// saves.
  @MainActor
  private func enter(
    _ count: String,
    _ app: XCUIApplication
  ) {
    let field = app.field("logCount.field")
    XCTAssertTrue(field.appears())
    // Right of the centered number, so the
    // cursor lands after it.
    let end = CGVector(dx: 0.95, dy: 0.5)
    field
      .coordinate(withNormalizedOffset: end)
      .tap()
    let delete = XCUIKeyboardKey.delete
      .rawValue
    field.typeText(
      String(repeating: delete, count: 4)
        + count
    )
    XCTAssertEqual(field.textValue, count)
    app.button("logSaveButton").tap()
  }
}
