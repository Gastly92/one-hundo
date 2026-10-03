import Testing
@testable import OneHundo

struct DailyProgressTests {
    @Test func startsEmpty() {
        let progress = DailyProgress()
        #expect(progress.goal == 100)
        #expect(progress.reps == 0)
        #expect(progress.remaining == 100)
        #expect(!progress.isComplete)
        #expect(progress.fraction == 0)
    }

    @Test func loggingSetsAddsUp() {
        var progress = DailyProgress()
        progress.log(25)
        progress.log(30)
        #expect(progress.reps == 55)
        #expect(progress.remaining == 45)
        #expect(progress.fraction == 0.55)
    }

    @Test func ignoresNonPositiveCounts() {
        var progress = DailyProgress()
        progress.log(0)
        progress.log(-10)
        #expect(progress.reps == 0)
    }

    @Test func completesAtGoalAndCapsFraction() {
        var progress = DailyProgress(goal: 100)
        progress.log(120)
        #expect(progress.isComplete)
        #expect(progress.remaining == 0)
        #expect(progress.fraction == 1)
    }
}
