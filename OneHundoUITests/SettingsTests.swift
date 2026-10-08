import XCTest

final class SettingsTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  @MainActor
  func testChangeGoal() {
    let app = App.start(seeded: true)
    // Push-ups: 10 of 100.
    let pushUps = app.card("pushups")
    XCTAssertTrue(
      pushUps.appears(within: 10)
    )
    pushUps.tap()
    let gear = app.button("Settings")
    XCTAssertTrue(gear.appears())

    // Cancel keeps the old goal.
    gear.tap()
    let sheet = app.bar("Settings")
    XCTAssertTrue(sheet.appears())
    app.button("goalChoice.150").tap()
    app.button("Cancel").tap()
    XCTAssertTrue(sheet.disappears())

    // Save keeps the new one.
    gear.tap()
    let goal = app.field("goal.field")
    XCTAssertTrue(goal.appears())
    XCTAssertEqual(goal.textValue, "100")
    app.button("goalChoice.150").tap()
    let note = app.text("goalNote")
    XCTAssertEqual(note.label, """
      At this pace you'd hit 150 in about \
      140 days.
      """)
    app.button("settingsSave").tap()
    XCTAssertTrue(sheet.disappears())

    let back = app.navigationBars.buttons
      .element(boundBy: 0)
    back.tap()
    XCTAssertTrue(pushUps.appears())
    let card = pushUps.label
    XCTAssertTrue(
      card.contains("10 / 150"), card
    )
  }

  @MainActor
  func testDeleteChallenge() {
    let app = App.start(seeded: true)
    let pullUps = app.card("pullups")
    XCTAssertTrue(
      pullUps.appears(within: 10)
    )
    pullUps.tap()
    app.button("Settings").tap()

    let row = app.button("deleteChallenge")
    XCTAssertTrue(row.appears())
    row.tap()
    let warning = app.text("""
      This deletes the challenge and all \
      its attempts. You can't undo this.
      """)
    XCTAssertTrue(warning.appears())
    // The dialog's button, not the form's.
    let mine = NSPredicate(
      format: "label == %@ AND "
        + "identifier != %@",
      "Delete challenge",
      "deleteChallenge"
    )
    app.buttons.matching(mine).firstMatch
      .tap()

    // Back on the list, without Pull-ups.
    let pushUps = app.card("pushups")
    XCTAssertTrue(pushUps.appears())
    XCTAssertFalse(pullUps.exists)
  }
}
