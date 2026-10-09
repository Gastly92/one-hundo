@testable import OneHundo
import SwiftData
import XCTest

/// The custom challenge form and settings.
@MainActor
final class ChallengeDraftTests: XCTestCase {
  func testStartNeedsNameAndGoal() {
    var draft = ChallengeDraft()
    XCTAssertFalse(draft.canStart)
    draft.name = "  "
    XCTAssertFalse(draft.canStart)
    draft.name = "Plank"
    XCTAssertTrue(draft.canStart)
    // The goal must be above today's test.
    draft.startingCount = 100
    XCTAssertFalse(draft.canStart)
  }

  func testSaveNeedsName() {
    var draft = ChallengeDraft()
    draft.name = " "
    XCTAssertFalse(draft.canSave)
    draft.name = "Plank"
    XCTAssertTrue(draft.canSave)
  }

  func testQuickGoalsAboveTest() {
    var draft = ChallengeDraft()
    XCTAssertEqual(
      draft.quickGoals, [50, 100, 150, 200]
    )
    draft.startingCount = 60
    XCTAssertEqual(
      draft.quickGoals, [100, 150, 200]
    )
  }

  func testReminderTime() {
    var draft = ChallengeDraft()
    XCTAssertEqual(draft.minutes, 1080)
    draft.time = ReminderTime.date(
      minutes: 90
    )
    XCTAssertEqual(draft.minutes, 90)
    XCTAssertEqual(
      ReminderTime.minutes(of: draft.time),
      90
    )
  }

  func testPaceText() {
    var draft = ChallengeDraft()
    draft.startingCount = 5
    XCTAssertEqual(draft.paceText, """
      At this pace you'd hit 100 in about \
      95 days.
      """)
  }

  func testGoalText() {
    var draft = ChallengeDraft()
    draft.unit = .seconds
    XCTAssertEqual(
      draft.goalText(current: 40), """
        At this pace you'd hit 100 in \
        about 60 days.
        """
    )
    // At or below the current count: the
    // goal counts as reached.
    draft.goal = 40
    XCTAssertEqual(
      draft.goalText(current: 40), """
        You're at 40 seconds, so this goal \
        counts as reached.
        """
    )
  }

  func testStartMakesCustom() throws {
    let store = try TestStore()
    var draft = ChallengeDraft()
    draft.name = " Plank "
    draft.unit = .seconds
    draft.colorName = "teal"
    draft.marker = .hexagon
    draft.startingCount = 30
    draft.goal = 120
    draft.increase = 5
    draft.remind = false
    draft.minutes = 420
    let plank = draft.start(
      into: store.context,
      on: day(1),
      in: utc
    )
    XCTAssertTrue(plank.isCustom)
    XCTAssertEqual(plank.name, "Plank")
    XCTAssertEqual(plank.unit, .seconds)
    XCTAssertEqual(plank.colorName, "teal")
    XCTAssertEqual(plank.marker, .hexagon)
    XCTAssertEqual(plank.goal, 120)
    XCTAssertEqual(plank.dailyIncrease, 5)
    XCTAssertFalse(plank.reminderEnabled)
    XCTAssertEqual(
      plank.reminderMinutes, 420
    )
    // The test is the first day's attempt.
    XCTAssertEqual(
      plank.todayText(day: 1),
      "Done: 30 seconds"
    )
    XCTAssertEqual(
      plank.todayText(day: 2),
      "Try 35 seconds today"
    )
    let count = try store.context.fetchCount(
      FetchDescriptor<Challenge>()
    )
    XCTAssertEqual(count, 1)
  }

  func testDraftFromChallenge() throws {
    let store = try TestStore()
    let pushUps = store.pushUps(
      start: 8, goal: 150, increase: 2
    )
    pushUps.reminderMinutes = 420
    let draft = ChallengeDraft(pushUps)
    XCTAssertEqual(draft.name, "Push-ups")
    XCTAssertEqual(draft.unit, .reps)
    XCTAssertEqual(draft.colorName, "violet")
    XCTAssertEqual(draft.marker, .circle)
    XCTAssertEqual(draft.startingCount, 8)
    XCTAssertEqual(draft.goal, 150)
    XCTAssertEqual(draft.increase, 2)
    XCTAssertTrue(draft.remind)
    XCTAssertEqual(draft.minutes, 420)
  }

  func testApplyToCustom() {
    let plank = Challenge(
      name: "Plank",
      colorName: "teal",
      startingCount: 30
    )
    var draft = ChallengeDraft(plank)
    draft.name = "Side plank "
    draft.unit = .minutes
    draft.colorName = "red"
    draft.marker = .triangle
    draft.goal = 100
    draft.increase = 3
    draft.remind = false
    draft.minutes = 60
    draft.apply(to: plank)
    XCTAssertEqual(plank.name, "Side plank")
    XCTAssertEqual(plank.unit, .minutes)
    XCTAssertEqual(plank.colorName, "red")
    XCTAssertEqual(plank.marker, .triangle)
    XCTAssertEqual(plank.goal, 100)
    XCTAssertEqual(plank.dailyIncrease, 3)
    XCTAssertFalse(plank.reminderEnabled)
    XCTAssertEqual(plank.reminderMinutes, 60)
    // Lowered to the current count: reached.
    XCTAssertFalse(plank.isGoalReached)
    XCTAssertFalse(plank.isCompleted)
    draft.goal = 30
    draft.apply(to: plank)
    XCTAssertTrue(plank.isGoalReached)
    XCTAssertTrue(plank.isCompleted)
  }

  func testApplyKeepsBuiltInLook() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    var draft = ChallengeDraft(pushUps)
    draft.name = "Press-ups"
    draft.unit = .seconds
    draft.colorName = "red"
    draft.marker = .star
    draft.goal = 150
    draft.apply(to: pushUps)
    XCTAssertEqual(pushUps.name, "Push-ups")
    XCTAssertEqual(pushUps.unit, .reps)
    XCTAssertEqual(
      pushUps.colorName, "violet"
    )
    XCTAssertEqual(pushUps.marker, .circle)
    XCTAssertEqual(pushUps.goal, 150)
  }
}
