import Foundation
import SwiftData

/// Challenges for UI tests (launched with -uiTesting -seedSampleData).
enum SampleData {
    @MainActor
    static func insert(
        into context: ModelContext,
        now: Date = Date(),
        calendar: Calendar = .current
    ) {
        func daysAgo(_ days: Int) -> Date {
            // 24-hour steps: always an earlier calendar day for sample data.
            now.addingTimeInterval(-Double(days) * 24 * 60 * 60)
        }

        // Logged yesterday: "Try 11 today", "10 / 100".
        let pushUps = make(.pushUps, start: 8, created: daysAgo(3))
        context.insert(pushUps)
        pushUps.logAttempt(count: 8, on: daysAgo(3), calendar: calendar)
        pushUps.logAttempt(count: 10, on: daysAgo(1), calendar: calendar)

        // Logged today: "Done: 20", "20 / 100".
        let sitUps = make(.sitUps, start: 15, created: daysAgo(2))
        context.insert(sitUps)
        sitUps.logAttempt(count: 15, on: daysAgo(2), calendar: calendar)
        sitUps.logAttempt(count: 20, on: now, calendar: calendar)

        // Started today with a test of 3: "Done: 3" (tomorrow "Try 4"), "3 / 100".
        let pullUps = make(.pullUps, start: 3, created: now)
        context.insert(pullUps)
        pullUps.logAttempt(count: 3, on: now, calendar: calendar)

        try? context.save()
    }

    private static func make(_ builtIn: BuiltInChallenge, start: Int, created: Date) -> Challenge {
        Challenge(
            kind: builtIn.id,
            name: builtIn.name,
            colorName: builtIn.colorName,
            startingCount: start,
            createdDate: created
        )
    }
}
