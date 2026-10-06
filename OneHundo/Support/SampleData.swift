import Foundation
import SwiftData

/// Challenges for UI tests (launched with -uiTesting
/// -seedSampleData).
enum SampleData {
    @MainActor
    static func insert(
        into context: ModelContext,
        now: Date = Date(),
        calendar cal: Calendar = .current
    ) {
        // `days` days before `now`. 24-hour steps: always
        // an earlier calendar day for sample data.
        func ago(_ days: Int) -> Date {
            now.addingTimeInterval(-Double(days) * 86_400)
        }

        // Logged yesterday: "Try 11 today", "10 / 100".
        let pushUps = make(.pushUps, start: 8, on: ago(3))
        context.insert(pushUps)
        pushUps.logAttempt(count: 8, on: ago(3), in: cal)
        pushUps.logAttempt(count: 10, on: ago(1), in: cal)

        // Logged today: "Done: 20", "20 / 100".
        let sitUps = make(.sitUps, start: 15, on: ago(2))
        context.insert(sitUps)
        sitUps.logAttempt(count: 15, on: ago(2), in: cal)
        sitUps.logAttempt(count: 20, on: now, in: cal)

        // Started today with a test of 3: "Done: 3"
        // (tomorrow "Try 4"), "3 / 100".
        let pullUps = make(.pullUps, start: 3, on: now)
        context.insert(pullUps)
        pullUps.logAttempt(count: 3, on: now, in: cal)

        try? context.save()
    }

    private static func make(
        _ builtIn: BuiltInChallenge,
        start: Int,
        on created: Date
    ) -> Challenge {
        Challenge(
            kind: builtIn.id,
            name: builtIn.name,
            colorName: builtIn.colorName,
            startingCount: start,
            createdDate: created
        )
    }
}
