import XCTest
@testable import OneHundo

/// Text built in code (not in views), which
/// goes through the String Catalog.
@MainActor
final class DisplayTextTests: ModelTestCase {
  func testBuiltInsUseCatalogName() {
    let pushUps = makePushUps()
    // A name stored in another language still
    // shows in the user's language.
    pushUps.name = "Liegestütze"
    XCTAssertEqual(
      pushUps.displayName, "Push-ups"
    )
  }

  func testCustomUsesOwnName() {
    let plank = Challenge(
      name: "Plank",
      colorName: "teal",
      startingCount: 30
    )
    XCTAssertEqual(plank.displayName, "Plank")
  }

  func testUnitNames() {
    let names = CountUnit.allCases.map(\.name)
    XCTAssertEqual(
      names, ["reps", "seconds", "minutes"]
    )
  }

  func testBuiltInTestQuestions() {
    for builtIn in BuiltIn.all {
      let what = builtIn.name.lowercased()
      XCTAssertEqual(builtIn.testQuestion, """
        How many \(what) can you do in one go?
        """)
    }
  }
}
