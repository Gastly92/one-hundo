@testable import OneHundo
import XCTest

final class ProgressionTests: XCTestCase {
  func testTargetAfterNormalDay() {
    XCTAssertEqual(target(5, step: 1), 6)
    XCTAssertEqual(target(10, step: 5), 15)
  }

  func testTargetAfterShortDay() {
    // Target was 6 but only 4 were done: next
    // target is 4 + 1.
    XCTAssertEqual(target(4, step: 1), 5)
  }

  func testTargetIsCappedAtGoal() {
    XCTAssertEqual(target(98, step: 5), 100)
    XCTAssertEqual(target(100, step: 1), 100)
    XCTAssertEqual(target(120, step: 1), 100)
  }

  func testGoalAfterTest() {
    // Still ahead of today's test: kept.
    let kept = Progression.goal(100, after: 5)
    XCTAssertEqual(kept, 100)
    // Reached or passed: raised past it.
    let same = Progression.goal(
      100, after: 100
    )
    XCTAssertEqual(same, 110)
    let past = Progression.goal(
      100, after: 150
    )
    XCTAssertEqual(past, 160)
  }

  func testDaysToGoal() {
    XCTAssertEqual(days(5, step: 1), 95)
    XCTAssertEqual(days(5, step: 2), 48)
    XCTAssertEqual(days(10, step: 10), 9)
    XCTAssertEqual(days(100, step: 1), 0)
    XCTAssertEqual(days(150, step: 1), 0)
  }

  func testPaceText() {
    XCTAssertEqual(pace(5), """
      At this pace you'd hit 100 in about \
      95 days.
      """)
    XCTAssertEqual(pace(99), """
      At this pace you'd hit 100 in about \
      1 day.
      """)
    XCTAssertEqual(
      pace(100),
      "Your goal needs to be above 100."
    )
  }

  func testProgress() {
    XCTAssertEqual(
      progress(6), 0.06, accuracy: 0.0001
    )
    XCTAssertEqual(progress(150), 1)
    XCTAssertEqual(progress(5, goal: 0), 0)
  }

  // Shorthands, with a goal of 100.

  private func target(
    _ baseline: Int, step: Int
  ) -> Int {
    Progression.target(
      baseline: baseline,
      step: step,
      goal: 100
    )
  }

  private func days(
    _ count: Int, step: Int
  ) -> Int {
    Progression.daysToGoal(
      from: count, goal: 100, step: step
    )
  }

  private func pace(_ count: Int) -> String {
    Progression.paceText(
      from: count, goal: 100, step: 1
    )
  }

  private func progress(
    _ current: Int, goal: Int = 100
  ) -> Double {
    Progression.progress(
      current: current, goal: goal
    )
  }
}
