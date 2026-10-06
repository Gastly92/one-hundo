import XCTest
@testable import OneHundo

/// Logging an attempt: the outcome (target hit, new best, next target), its
/// wording, and the Log attempt sheet's button title and replacement note.
final class RecordAttemptTests: ChallengeTestCase {
    func testRecordAttemptHittingTargetIsNewBest() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        let outcome = challenge.recordAttempt(
            count: 6, on: day(2), calendar: calendar
        )
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
        let outcome = challenge.recordAttempt(
            count: 4, on: day(3), calendar: calendar
        )
        XCTAssertEqual(outcome.target, 7)
        XCTAssertFalse(outcome.hitTarget)
        XCTAssertFalse(outcome.isNewBest)
        XCTAssertEqual(outcome.nextTarget, 5)
        XCTAssertEqual(outcome.title, "Good effort!")
        XCTAssertEqual(
            outcome.message,
            "You did 4, and every one counts. Next time, try for 5."
        )
    }

    func testMatchingBestIsNotNewBest() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 8, on: day(2), calendar: calendar)
        XCTAssertFalse(record(challenge, count: 8, day: 3).isNewBest)
        XCTAssertTrue(record(challenge, count: 9, day: 4).isNewBest)
    }

    func testReplacingSameDayComparesWithOtherDaysOnly() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        challenge.recordAttempt(
            count: 7, on: day(2, hour: 9), calendar: calendar
        )
        // Re-logging day 2 with 6: still above the earlier best of 5, and
        // replaces the 7.
        let outcome = challenge.recordAttempt(
            count: 6, on: day(2, hour: 18), calendar: calendar
        )
        XCTAssertTrue(outcome.isNewBest)
        XCTAssertEqual(outcome.target, 6)
        XCTAssertEqual(challenge.attempts?.count, 2)
        XCTAssertEqual(challenge.personalBest, 6)
    }

    func testBeatingStartingTestOnStartDayIsNewBest() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1, hour: 8), calendar: calendar)
        let outcome = challenge.recordAttempt(
            count: 6, on: day(1, hour: 18), calendar: calendar
        )
        XCTAssertTrue(outcome.isNewBest)
        XCTAssertEqual(challenge.attempts?.count, 1)
    }

    func testRecordAttemptReachingGoal() {
        let challenge = makePushUps(start: 98, increase: 5)
        let outcome = challenge.recordAttempt(
            count: 100, on: day(2), calendar: calendar
        )
        XCTAssertTrue(outcome.reachedGoal)
        XCTAssertEqual(outcome.title, "Goal reached!")
        XCTAssertEqual(outcome.message, "You hit your goal of 100.")
        XCTAssertEqual(outcome.nextTarget, 100)
    }

    func testOutcomeMessageUsesUnit() {
        let challenge = makePushUps(start: 45)
        challenge.unit = .seconds
        let outcome = challenge.recordAttempt(
            count: 46, on: day(2), calendar: calendar
        )
        XCTAssertEqual(
            outcome.message,
            "You did 46 seconds. Next time, try for 47 seconds."
        )
    }

    func testLogButtonTitle() {
        let challenge = makePushUps()
        challenge.logAttempt(count: 5, on: day(1), calendar: calendar)
        // The starting test counts as that day's attempt.
        XCTAssertEqual(
            challenge.logButtonTitle(on: day(1), calendar: calendar),
            "Edit today"
        )
        challenge.logAttempt(count: 6, on: day(2), calendar: calendar)
        XCTAssertEqual(
            challenge.logButtonTitle(on: day(2), calendar: calendar),
            "Edit today"
        )
        XCTAssertEqual(
            challenge.logButtonTitle(on: day(3), calendar: calendar),
            "Log attempt"
        )
    }

    func testReplacementNote() {
        let challenge = makePushUps(start: 30)
        challenge.unit = .seconds
        XCTAssertNil(challenge.replacementNote(on: day(2), calendar: calendar))
        challenge.logAttempt(count: 31, on: day(2), calendar: calendar)
        XCTAssertEqual(
            challenge.replacementNote(on: day(2, hour: 20), calendar: calendar),
            "This replaces the 31 seconds you logged that day."
        )
    }

    func testOutcomeSymbols() {
        let challenge = makePushUps(start: 98, increase: 1)
        XCTAssertEqual(
            record(challenge, count: 90, day: 2).symbol,
            "arrow.up.forward.circle.fill"
        )
        XCTAssertEqual(
            record(challenge, count: 91, day: 3).symbol, "hands.clap.fill"
        )
        XCTAssertEqual(
            record(challenge, count: 100, day: 4).symbol, "trophy.fill"
        )
    }

    private func record(
        _ challenge: Challenge, count: Int, day number: Int
    ) -> LogOutcome {
        challenge.recordAttempt(
            count: count, on: day(number), calendar: calendar
        )
    }
}
