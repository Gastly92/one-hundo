import XCTest

/// The notification permission prompt, with
/// the phone's real notification center
/// (`-notifications`). Other UI tests never
/// see it.
final class NotificationTests: XCTestCase {
  override func setUp() {
    continueAfterFailure = false
  }

  @MainActor
  func testAsksWhenRemindersAreOn() {
    // The sample challenges have reminders
    // on, so the app asks right away. CI's
    // simulators are new, so it's always
    // the first time.
    let app = App.start(
      seeded: true,
      arguments: ["-notifications"]
    )
    let springboard = App(
      bundleIdentifier:
        "com.apple.springboard"
    )
    let allow = springboard.buttons["Allow"]
    XCTAssertTrue(allow.appears(within: 10))
    allow.tap()
    XCTAssertTrue(allow.disappears())
    let card = app.card("pushups")
    XCTAssertTrue(card.appears())
  }
}
