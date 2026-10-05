import SwiftData
import XCTest
@testable import OneHundo

/// Shared setup for challenge tests: an in-memory store, a UTC calendar, fixed
/// January 2026 dates, and a Push-ups challenge factory.
@MainActor
class ChallengeTestCase: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext { container.mainContext }

    let calendar: Calendar = {
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
    func day(_ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 1, day: day, hour: hour))!
    }

    func makePushUps(start: Int = 5, goal: Int = 100, increase: Int = 1) -> Challenge {
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
}
