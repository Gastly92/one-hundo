import XCTest

final class ChallengeListTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  @MainActor
  func testEmptyStateOnFirstLaunch() {
    let app = App.start()
    let title = app.text("welcomeTitle")
    XCTAssertTrue(title.appears(within: 10))
    XCTAssertEqual(
      title.label, "Get to 100 in one go."
    )

    let start = app.button("welcomeStart")
    XCTAssertTrue(start.exists)
    start.tap()
    let sheet = app.bar("Add challenge")
    XCTAssertTrue(sheet.appears())
    app.button("Close").tap()
    XCTAssertTrue(start.appears())
  }

  @MainActor
  func testSeededChallengesShowAsCards() {
    let app = App.start(seeded: true)
    let pushUps = app.text("Push-ups")
    XCTAssertTrue(pushUps.appears(within: 10))
    let title = app.text("welcomeTitle")
    XCTAssertFalse(title.exists)

    for label in [
      // Logged yesterday: target is
      // yesterday's 10 + 1.
      "Try 11 today", "10 / 100",
      // Logged today.
      "Sit-ups", "Done: 20", "20 / 100",
      // Started today with a test of 3: the
      // test is today's attempt.
      "Pull-ups", "Done: 3",
    ] {
      XCTAssertTrue(
        app.text(label).exists, label
      )
    }
  }

  @MainActor
  func testAddTileOpensAddChallenge() {
    let app = App.start(seeded: true)
    let tile = app.button("addTile")
    XCTAssertTrue(tile.appears(within: 10))
    // The title bar stays plain: no buttons.
    let bar = app.bar("Challenges")
    XCTAssertEqual(bar.buttons.count, 0)
    tile.tap()
    let sheet = app.bar("Add challenge")
    XCTAssertTrue(sheet.appears())
  }

  @MainActor
  func testCalendarTabShowsPlaceholder() {
    let app = App.start()
    let tabs = app.tabBars.buttons
    tabs["Calendar"].tap()
    let soon = app.text("""
      Coming soon: your attempts, day by day.
      """)
    XCTAssertTrue(soon.appears())
    tabs["Challenges"].tap()
    let title = app.text("welcomeTitle")
    XCTAssertTrue(title.appears())
  }

  @MainActor
  func testLongPressDeletesChallenge() {
    let app = App.start(seeded: true)
    let pullUps = app.text("Pull-ups")
    XCTAssertTrue(pullUps.appears(within: 10))

    // The first press can land while the list
    // is still settling: press up to three
    // times until the menu opens.
    let item = app.button("Delete challenge")
    for _ in 0..<3 where !item.exists {
      pullUps.press(forDuration: 1.5)
      _ = item.appears(within: 3)
    }
    XCTAssertTrue(item.exists)
    let edit = app.button("Edit today")
    XCTAssertTrue(edit.exists)
    item.tap()

    // The confirmation's button has the same
    // label as the menu item, which is gone
    // by now.
    let warning = app.text("""
      This deletes the challenge and all its \
      attempts. You can't undo this.
      """)
    XCTAssertTrue(warning.appears())
    let sure = app.button("Delete challenge")
      .firstMatch
    sure.tap()

    XCTAssertTrue(pullUps.disappears())
    XCTAssertTrue(app.text("Push-ups").exists)
  }

  @MainActor
  func testTabTitlesLineUp() {
    let app = App.start()
    let first = title("Challenges", app)
    XCTAssertTrue(first.appears(within: 10))
    let before = first.frame

    app.tabBars.buttons["Calendar"].tap()
    let second = title("Calendar", app)
    XCTAssertTrue(second.appears())
    let after = second.frame
    XCTAssertEqual(
      after.minY, before.minY, accuracy: 1
    )
    XCTAssertEqual(
      after.minX, before.minX, accuracy: 1
    )
  }

  /// A tab's large title.
  @MainActor
  private func title(
    _ tab: String, _ app: XCUIApplication
  ) -> XCUIElement {
    app.bar(tab).staticTexts[tab].firstMatch
  }
}
