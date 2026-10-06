import XCTest
@testable import OneHundo

final class ProgressionTests: XCTestCase {
    func testTargetAfterNormalDay() {
        XCTAssertEqual(target(5, step: 1), 6)
        XCTAssertEqual(target(10, step: 5), 15)
    }

    func testTargetAfterShortDay() {
        // Target was 6 but only 4 were done: next target is
        // 4 + 1.
        XCTAssertEqual(target(4, step: 1), 5)
    }

    func testTargetIsCappedAtGoal() {
        XCTAssertEqual(target(98, step: 5), 100)
        XCTAssertEqual(target(100, step: 1), 100)
        XCTAssertEqual(target(120, step: 1), 100)
    }

    func testDaysToGoal() {
        XCTAssertEqual(days(from: 5, step: 1), 95)
        XCTAssertEqual(days(from: 5, step: 2), 48)
        XCTAssertEqual(days(from: 10, step: 10), 9)
        XCTAssertEqual(days(from: 100, step: 1), 0)
        XCTAssertEqual(days(from: 150, step: 1), 0)
    }

    func testPaceText() {
        XCTAssertEqual(
            pace(from: 5),
            "At this pace you'd hit 100 in about 95 days."
        )
        XCTAssertEqual(
            pace(from: 99),
            "At this pace you'd hit 100 in about 1 day."
        )
        XCTAssertEqual(
            pace(from: 100),
            "Your goal needs to be above 100."
        )
    }

    func testProgress() {
        XCTAssertEqual(
            Progression.progress(current: 6, goal: 100),
            0.06,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            Progression.progress(current: 150, goal: 100), 1
        )
        XCTAssertEqual(
            Progression.progress(current: 5, goal: 0), 0
        )
    }

    // Shorthands with a goal of 100.

    private func target(_ baseline: Int, step: Int) -> Int {
        Progression.target(
            baseline: baseline, step: step, goal: 100
        )
    }

    private func days(from count: Int, step: Int) -> Int {
        Progression.daysToGoal(
            from: count, goal: 100, step: step
        )
    }

    private func pace(from count: Int) -> String {
        Progression.paceText(
            from: count, goal: 100, step: 1
        )
    }
}
