import XCTest
@testable import OneHundo

/// Text built in code (not in views), which goes through the String Catalog.
@MainActor
final class DisplayTextTests: ChallengeTestCase {
    func testBuiltInsShowTheirCatalogName() {
        let challenge = makePushUps()
        // A name stored in another language still shows in the user's language.
        challenge.name = "Liegestütze"
        XCTAssertEqual(challenge.displayName, "Push-ups")
    }

    func testCustomChallengesShowTheirOwnName() {
        let plank = Challenge(
            name: "Plank", colorName: "teal", startingCount: 30
        )
        XCTAssertEqual(plank.displayName, "Plank")
    }

    func testUnitNames() {
        XCTAssertEqual(
            ChallengeUnit.allCases.map(\.name), ["reps", "seconds", "minutes"]
        )
    }

    func testBuiltInTestQuestions() {
        XCTAssertEqual(
            BuiltInChallenge.all.map(\.testQuestion),
            [
                "How many push-ups can you do in one go?",
                "How many sit-ups can you do in one go?",
                "How many pull-ups can you do in one go?",
            ]
        )
    }
}
