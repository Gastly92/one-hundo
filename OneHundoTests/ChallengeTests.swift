import XCTest
@testable import OneHundo

final class ChallengeTests: XCTestCase {
    func testLoggingRepsUpdatesProgress() {
        var challenge = Challenge(name: "Push-ups", goal: 100)
        challenge.log(25)
        XCTAssertEqual(challenge.completed, 25)
        XCTAssertEqual(challenge.remaining, 75)
        XCTAssertEqual(challenge.progress, 0.25, accuracy: 0.0001)
        XCTAssertFalse(challenge.isComplete)
    }

    func testIgnoresNonPositiveReps() {
        var challenge = Challenge(name: "Push-ups", goal: 100)
        challenge.log(0)
        challenge.log(-5)
        XCTAssertEqual(challenge.completed, 0)
    }

    func testCompletionCapsProgress() {
        var challenge = Challenge(name: "Push-ups", goal: 100)
        challenge.log(120)
        XCTAssertTrue(challenge.isComplete)
        XCTAssertEqual(challenge.remaining, 0)
        XCTAssertEqual(challenge.progress, 1)
    }
}
