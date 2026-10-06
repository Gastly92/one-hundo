import SwiftData
import XCTest
@testable import OneHundo

/// Targets, progress, card text, and stats.
final class ChallengeTests: ChallengeTestCase {
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

    func testUnitFormatting() {
        XCTAssertEqual(ChallengeUnit.reps.format(1), "1")
        XCTAssertEqual(ChallengeUnit.seconds.format(1), "1 second")
        XCTAssertEqual(ChallengeUnit.seconds.format(45), "45 seconds")
        XCTAssertEqual(ChallengeUnit.minutes.format(1), "1 minute")
        XCTAssertEqual(ChallengeUnit.minutes.format(3), "3 minutes")
    }

    func testMissingAttemptsListCountsAsNone() {
        let challenge = makePushUps()
        challenge.attempts = nil
        XCTAssertTrue(challenge.allAttempts.isEmpty)
        XCTAssertEqual(challenge.currentCount, 5)
        XCTAssertEqual(challenge.daysLogged(calendar: calendar), 0)
    }

    func testUnknownStoredUnitFallsBackToReps() {
        let challenge = makePushUps()
        challenge.unitRaw = "laps"
        XCTAssertEqual(challenge.unit, .reps)
    }
}
