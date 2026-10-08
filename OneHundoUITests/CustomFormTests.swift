import XCTest

final class CustomFormTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  @MainActor
  func testCreatePlankInSeconds() {
    let app = App.start()
    let first = app.button("welcomeStart")
    XCTAssertTrue(first.appears(within: 10))
    first.tap()
    let custom =
      app.button("customChallenge")
    XCTAssertTrue(custom.appears())
    custom.tap()

    // Start stays off until there's a name.
    let start = app.button("customStart")
    XCTAssertTrue(start.appears())
    XCTAssertFalse(start.isEnabled)

    // Top of the form first: tapping a
    // shape or color scrolls down, and rows
    // scrolled away can't be found.
    app.button("Seconds").tap()
    // Test yourself: 1 + 4 = 5 seconds.
    let plus = app.button("testCount.plus")
    for _ in 0..<4 { plus.tap() }
    let count = app.field("testCount.field")
    XCTAssertEqual(count.textValue, "5")
    XCTAssertTrue(app.text("seconds").exists)

    let name = app.field("customName")
    name.tap()
    name.typeText("Plank")
    app.button("shape.hexagon").tap()
    app.button("color.blue").tap()
    XCTAssertTrue(start.isEnabled)
    start.tap()

    let card = app.card("custom")
    XCTAssertTrue(card.appears(within: 10))
    let label = card.label
    let texts = [
      "Plank", "Done: 5 seconds", "5 / 100",
    ]
    for text in texts {
      XCTAssertTrue(
        label.contains(text), label
      )
    }
  }
}
