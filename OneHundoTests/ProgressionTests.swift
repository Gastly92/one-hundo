import XCTest
@testable import OneHundo

final class ProgressionTests: XCTestCase {
    func testTargetAfterNormalDay() {
        XCTAssertEqual(Progression.target(baseline: 5, dailyIncrease: 1, goal: 100), 6)
        XCTAssertEqual(Progression.target(baseline: 10, dailyIncrease: 5, goal: 100), 15)
    }

    func testTargetAfterShortDay() {
        // Target was 6 but only 4 were done: next target is 4 + 1.
        XCTAssertEqual(Progression.target(baseline: 4, dailyIncrease: 1, goal: 100), 5)
    }

    func testTargetIsCappedAtGoal() {
        XCTAssertEqual(Progression.target(baseline: 98, dailyIncrease: 5, goal: 100), 100)
        XCTAssertEqual(Progression.target(baseline: 100, dailyIncrease: 1, goal: 100), 100)
        XCTAssertEqual(Progression.target(baseline: 120, dailyIncrease: 1, goal: 100), 100)
    }

    func testDaysToGoal() {
        XCTAssertEqual(Progression.daysToGoal(from: 5, goal: 100, dailyIncrease: 1), 95)
        XCTAssertEqual(Progression.daysToGoal(from: 5, goal: 100, dailyIncrease: 2), 48)
        XCTAssertEqual(Progression.daysToGoal(from: 10, goal: 100, dailyIncrease: 10), 9)
        XCTAssertEqual(Progression.daysToGoal(from: 100, goal: 100, dailyIncrease: 1), 0)
        XCTAssertEqual(Progression.daysToGoal(from: 150, goal: 100, dailyIncrease: 1), 0)
    }

    func testPaceText() {
        XCTAssertEqual(
            Progression.paceText(from: 5, goal: 100, dailyIncrease: 1),
            "At this pace you'd hit 100 in about 95 days."
        )
        XCTAssertEqual(
            Progression.paceText(from: 99, goal: 100, dailyIncrease: 1),
            "At this pace you'd hit 100 in about 1 day."
        )
        XCTAssertEqual(
            Progression.paceText(from: 100, goal: 100, dailyIncrease: 1),
            "Your goal needs to be above 100."
        )
    }

    func testProgress() {
        XCTAssertEqual(Progression.progress(current: 6, goal: 100), 0.06, accuracy: 0.0001)
        XCTAssertEqual(Progression.progress(current: 150, goal: 100), 1)
        XCTAssertEqual(Progression.progress(current: 5, goal: 0), 0)
    }
}
