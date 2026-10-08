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

    // Shape and color first: Seconds adds
    // a row, pushing them lower.
    app.button("shape.hexagon").tap()
    app.button("color.blue").tap()
    app.button("Seconds").tap()
    // Test yourself: 1 + 4 = 5 seconds.
    let plus = app.button("testCount.plus")
    for _ in 0..<4 { plus.tap() }
    let count = app.field("testCount.field")
    XCTAssertEqual(count.textValue, "5")
    XCTAssertTrue(app.text("seconds").exists)

    // Last, as the keyboard covers the form.
    let name = app.field("customName")
    name.tap()
    name.typeText("Plank")
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
