import XCTest

final class EnrollFlowTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  @MainActor
  func testStartPushUpsShowsCard() {
    let app = App.start()

    let first = app.button("welcomeStart")
    XCTAssertTrue(first.appears(within: 10))
    first.tap()

    let pick = app.button("builtIn.pushups")
    XCTAssertTrue(pick.appears())
    pick.tap()

    // Intro.
    let next = app.button("enrollNext")
    XCTAssertTrue(next.appears())
    next.tap()

    // Test yourself: 1 + 4 = 5.
    let plus = app.button("testCount.plus")
    XCTAssertTrue(plus.appears())
    for _ in 0..<4 { plus.tap() }
    let count = app.field("testCount.field")
    XCTAssertEqual(count.textValue, "5")
    next.tap()

    // Goal and pace: defaults to 100 at +1 a
    // day; the quick goal buttons change it.
    let pace100 = app.text("""
      At this pace you'd hit 100 in about \
      95 days.
      """)
    XCTAssertTrue(pace100.appears())
    app.button("goalChoice.150").tap()
    let pace150 = app.text("""
      At this pace you'd hit 150 in about \
      145 days.
      """)
    XCTAssertTrue(pace150.appears())
    app.button("goalChoice.100").tap()
    let goal = app.field("goal.field")
    XCTAssertEqual(goal.textValue, "100")
    next.tap()

    // Reminder: keep the defaults and start.
    let start = app.button("enrollStart")
    XCTAssertTrue(start.appears())
    start.tap()

    let card = app.card("pushups")
    XCTAssertTrue(card.appears(within: 10))
    // The test is today's attempt; tomorrow's
    // target is 6.
    let label = card.label
    XCTAssertTrue(label.contains("Done: 5"))
    XCTAssertTrue(label.contains("5 / 100"))

    // Push-ups is now in progress, so it
    // can't be started twice.
    app.button("addTile").tap()
    let again = app.button("builtIn.pushups")
    XCTAssertTrue(again.appears())
    XCTAssertFalse(again.isEnabled)
    let sitUps = app.button("builtIn.situps")
    XCTAssertTrue(sitUps.isEnabled)
  }
}
