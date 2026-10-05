import SwiftData
import XCTest
@testable import OneHundo

@MainActor
final class ChallengeTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext { container.mainContext }

    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    override func setUp() async throws {
        container = try ModelContainer(
            for: Challenge.self, Attempt.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    override func tearDown() async throws {
        container = nil
    }

    /// Noon on the given day of January 2026, UTC.
    private func day(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 1, day: day, hour: hour))!
    }

    private func makePushUps(start: Int = 5, goal: Int = 100, increase: Int = 1) -> Challenge {
        let challenge = Challenge(
            kind: BuiltInChallenge.pushUps.id,
            name: "Push-ups",
            icon: BuiltInChallenge.pushUps.icon,
            colorName: BuiltInChallenge.pushUps.colorName,
            startingCount: start,
            goal: goal,
            dailyIncrease: increase,
            createdDate: day(1)
        )
        context.insert(challenge)
        return challenge
    }

    func testTargetWithNoAttemptsUsesStartingCount() {
        let challenge = makePushUps()
        XCTAssertEqual(challenge.target(on: day(1), calendar: calendar), 6)
        XCTAssertEqual(challenge.currentCount, 5)
    }

    func testTargetAfterNormalDay() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.logAttempt(count: 6, on: day(2), calendar: calendar)
        XCTAssertEqual(challenge.target(on: day(3), calendar: calendar), 7)
    }

    func testTargetAfterShortDay() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        XCTAssertEqual(challenge.target(on: day(2), calendar: calendar), 6)
        challenge.logAttempt(count: 4, on: day(2), calendar: calendar)
        XCTAssertEqual(challenge.target(on: day(3), calendar: calendar), 5)
    }

    func testMissedDaysDoNotChangeTarget() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 6, on: day(2), calendar: calendar)
        XCTAssertEqual(challenge.target(on: day(3), calendar: calendar), 7)
        XCTAssertEqual(challenge.target(on: day(10), calendar: calendar), 7)
    }

    func testLoggingTodayKeepsTodaysTarget() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.logAttempt(count: 6, on: day(2, hour: 8), calendar: calendar)
        XCTAssertEqual(challenge.target(on: day(2, hour: 20), calendar: calendar), 6)
        XCTAssertEqual(challenge.target(on: day(3), calendar: calendar), 7)
    }

    func testTargetIsCappedAtGoal() {
        let challenge = makePushUps(start: 95, increase: 10)
        XCTAssertEqual(challenge.target(on: day(1), calendar: calendar), 100)
    }

    func testLoggingSameDayReplacesAttempt() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 6, on: day(2, hour: 9), calendar: calendar)
        challenge.logAttempt(count: 8, on: day(2, hour: 18), calendar: calendar)
        XCTAssertEqual(challenge.attempts?.count, 1)
        XCTAssertEqual(challenge.attempt(on: day(2), calendar: calendar)?.count, 8)
        XCTAssertEqual(challenge.currentCount, 8)
    }

    func testProgressAndDaysToGoal() {
        let challenge = makePushUps()
        XCTAssertEqual(challenge.daysToGoal, 95)
        challenge.logAttempt(count: 20, on: day(2), calendar: calendar)
        XCTAssertEqual(challenge.progress, 0.2, accuracy: 0.0001)
        XCTAssertEqual(challenge.daysToGoal, 80)
        XCTAssertFalse(challenge.isGoalReached)
        challenge.logAttempt(count: 100, on: day(3), calendar: calendar)
        XCTAssertTrue(challenge.isGoalReached)
    }

    func testAttemptsAreSavedAndSortedNewestFirst() throws {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.logAttempt(count: 6, on: day(2), calendar: calendar)
        try context.save()
        let saved = try context.fetch(FetchDescriptor<Attempt>())
        XCTAssertEqual(saved.count, 2)
        XCTAssertEqual(challenge.sortedAttempts.map(\.count), [6, 5])
    }

    func testCardTextTryAndDone() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        XCTAssertEqual(challenge.todayText(on: day(2), calendar: calendar), "Try 6 today")
        challenge.logAttempt(count: 6, on: day(2), calendar: calendar)
        XCTAssertEqual(challenge.todayText(on: day(2), calendar: calendar), "Done: 6")
        XCTAssertEqual(challenge.progressText, "6 / 100")
    }

    func testStartingTestAloneIsNotDoneOnStartDay() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        XCTAssertNil(challenge.loggedAttempt(on: day(1), calendar: calendar))
        XCTAssertEqual(challenge.todayText(on: day(1), calendar: calendar), "Try 6 today")

        // Logging again on the start day replaces the test and counts as done.
        challenge.logAttempt(count: 6, on: day(1, hour: 18), calendar: calendar)
        XCTAssertEqual(challenge.todayText(on: day(1), calendar: calendar), "Done: 6")
        XCTAssertEqual(challenge.target(on: day(2), calendar: calendar), 7)
    }

    func testCardTextUsesUnit() {
        let challenge = makePushUps(start: 45)
        challenge.unit = .seconds
        XCTAssertEqual(challenge.todayText(on: day(2), calendar: calendar), "Try 46 seconds today")
        XCTAssertEqual(ChallengeUnit.minutes.format(1), "1 minute")
        XCTAssertEqual(ChallengeUnit.reps.format(12), "12")
    }

    func testBuiltInLookupAndUnit() {
        let challenge = makePushUps()
        XCTAssertEqual(challenge.builtIn?.name, "Push-ups")
        XCTAssertFalse(challenge.isCustom)
        XCTAssertEqual(challenge.unit, .reps)
        challenge.unit = .seconds
        XCTAssertEqual(challenge.unitRaw, "seconds")
        XCTAssertEqual(BuiltInChallenge.all.map(\.id), ["pushups", "situps", "pullups"])
    }

    func testPersonalBestIncludesStartingTest() {
        let challenge = makePushUps()
        XCTAssertEqual(challenge.personalBest, 5)
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.logAttempt(count: 9, on: day(2), calendar: calendar)
        challenge.logAttempt(count: 7, on: day(3), calendar: calendar)
        XCTAssertEqual(challenge.personalBest, 9)
    }

    func testDaysLoggedCountsDistinctDays() {
        let challenge = makePushUps()
        XCTAssertEqual(challenge.daysLogged(calendar: calendar), 0)
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.logAttempt(count: 6, on: day(2, hour: 8), calendar: calendar)
        challenge.logAttempt(count: 7, on: day(2, hour: 20), calendar: calendar)
        challenge.logAttempt(count: 7, on: day(5), calendar: calendar)
        XCTAssertEqual(challenge.daysLogged(calendar: calendar), 3)
    }

    func testRecordAttemptHittingTargetIsNewBest() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        let outcome = challenge.recordAttempt(count: 6, on: day(2), calendar: calendar)
        XCTAssertEqual(outcome.target, 6)
        XCTAssertTrue(outcome.hitTarget)
        XCTAssertTrue(outcome.isNewBest)
        XCTAssertEqual(outcome.nextTarget, 7)
        XCTAssertEqual(outcome.title, "Nice work!")
        XCTAssertEqual(outcome.message, "You did 6. Next time, try for 7.")
    }

    func testRecordAttemptFallingShort() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.logAttempt(count: 6, on: day(2), calendar: calendar)
        let outcome = challenge.recordAttempt(count: 4, on: day(3), calendar: calendar)
        XCTAssertEqual(outcome.target, 7)
        XCTAssertFalse(outcome.hitTarget)
        XCTAssertFalse(outcome.isNewBest)
        XCTAssertEqual(outcome.nextTarget, 5)
        XCTAssertEqual(outcome.title, "Good effort!")
        XCTAssertEqual(outcome.message, "You did 4, and every one counts. Next time, try for 5.")
    }

    func testMatchingBestIsNotNewBest() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 8, on: day(2), calendar: calendar)
        XCTAssertFalse(challenge.recordAttempt(count: 8, on: day(3), calendar: calendar).isNewBest)
        XCTAssertTrue(challenge.recordAttempt(count: 9, on: day(4), calendar: calendar).isNewBest)
    }

    func testReplacingSameDayComparesWithOtherDaysOnly() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.recordAttempt(count: 7, on: day(2, hour: 9), calendar: calendar)
        // Re-logging day 2 with 6: still above the earlier best of 5, and replaces the 7.
        let outcome = challenge.recordAttempt(count: 6, on: day(2, hour: 18), calendar: calendar)
        XCTAssertTrue(outcome.isNewBest)
        XCTAssertEqual(outcome.target, 6)
        XCTAssertEqual(challenge.attempts?.count, 2)
        XCTAssertEqual(challenge.personalBest, 6)
    }

    func testBeatingStartingTestOnStartDayIsNewBest() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1, hour: 8), calendar: calendar)
        let outcome = challenge.recordAttempt(count: 6, on: day(1, hour: 18), calendar: calendar)
        XCTAssertTrue(outcome.isNewBest)
        XCTAssertEqual(challenge.attempts?.count, 1)
    }

    func testRecordAttemptReachingGoal() {
        let challenge = makePushUps(start: 98, increase: 5)
        let outcome = challenge.recordAttempt(count: 100, on: day(2), calendar: calendar)
        XCTAssertTrue(outcome.reachedGoal)
        XCTAssertEqual(outcome.title, "Goal reached!")
        XCTAssertEqual(outcome.message, "You hit your goal of 100.")
        XCTAssertEqual(outcome.nextTarget, 100)
    }

    func testOutcomeMessageUsesUnit() {
        let challenge = makePushUps(start: 45)
        challenge.unit = .seconds
        let outcome = challenge.recordAttempt(count: 46, on: day(2), calendar: calendar)
        XCTAssertEqual(outcome.message, "You did 46 seconds. Next time, try for 47 seconds.")
    }
}
