@testable import OneHundo
import UserNotifications
import XCTest

/// Records what reminder updates do.
@MainActor
private final class FakeNotifier: Notifier {
  var asked = 0
  var pending: [UNNotificationRequest] = []

  func ask() { asked += 1 }

  func replace(
    with requests: [UNNotificationRequest]
  ) {
    pending = requests
  }
}

/// Daily reminders: which days, what they
/// say, and how they're scheduled.
@MainActor
final class ReminderTests: XCTestCase {
  private static let sample = Reminder(
    id: "a",
    title: "A",
    body: "B",
    date: day(2)
  )

  /// Reminders from `now` for 3 days, UTC.
  private func plan(
    _ challenge: Challenge,
    from now: Date
  ) -> [Reminder] {
    challenge.reminders(
      days: 3, from: now, in: utc
    )
  }

  func testEachDayWithItsTarget() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.log(5, day: 1)
    // Day 1 is logged, so it's skipped.
    let list = plan(
      pushUps, from: day(1, hour: 9)
    )
    XCTAssertEqual(
      list.map(\.date),
      [day(2, hour: 18), day(3, hour: 18)]
    )
    // Missed days don't change the target.
    let six = "Try for 6 today."
    XCTAssertEqual(
      list.map(\.body), [six, six]
    )
    XCTAssertEqual(list[0].title, "Push-ups")
    XCTAssertNotEqual(list[0].id, list[1].id)
  }

  func testTodayUntilLoggedOrPast() throws {
    let store = try TestStore()
    let pushUps = store.pushUps()
    pushUps.log(5, day: 1)
    // Before 18:00, today's reminder is on.
    let morning = plan(
      pushUps, from: day(2, hour: 9)
    )
    XCTAssertEqual(
      morning.first?.date, day(2, hour: 18)
    )
    // After 18:00 it's gone.
    let night = plan(
      pushUps, from: day(2, hour: 19)
    )
    XCTAssertEqual(
      night.first?.date, day(3, hour: 18)
    )
    // Logging today skips it too, and the
    // next days build on today's count.
    pushUps.log(7, day: 2)
    let logged = plan(
      pushUps, from: day(2, hour: 9)
    )
    XCTAssertEqual(
      logged.first?.date, day(3, hour: 18)
    )
    XCTAssertEqual(
      logged.first?.body, "Try for 8 today."
    )
  }

  func testTimeAndUnit() throws {
    let store = try TestStore()
    let plank = store.pushUps(
      start: 40, increase: 5
    )
    plank.unit = .seconds
    // 7:30.
    plank.reminderMinutes = 450
    let list = plan(
      plank, from: day(1, hour: 6)
    )
    XCTAssertEqual(
      list.first?.date,
      day(1, hour: 7) + 30 * 60
    )
    XCTAssertEqual(
      list.first?.body,
      "Try for 45 seconds today."
    )
  }

  func testOffOrCompletedSendsNone() throws {
    let store = try TestStore()
    let off = store.pushUps()
    off.reminderEnabled = false
    let done = store.pushUps()
    done.completedDate = day(1)
    XCTAssertFalse(off.remindsDaily)
    XCTAssertFalse(done.remindsDaily)
    let list = ReminderPlan.reminders(
      for: [off, done],
      now: day(1),
      in: utc
    )
    XCTAssertEqual(list, [])
  }

  func testPlanKeepsSoonest64() throws {
    let store = try TestStore()
    // 5 challenges at 10:00 to 10:04.
    let all = (0..<5).map { index in
      let challenge = store.pushUps()
      challenge.reminderMinutes = 600 + index
      return challenge
    }
    let list = ReminderPlan.reminders(
      for: all, now: day(1), in: utc
    )
    XCTAssertEqual(list.count, 64)
    let dates = list.map(\.date)
    XCTAssertEqual(dates, dates.sorted())
    // Today's are past (it's noon), so 13
    // days each, 65 in all: the last one
    // (day 14 at 10:04) is dropped.
    XCTAssertEqual(
      dates.first, day(2, hour: 10)
    )
    XCTAssertEqual(
      dates.last, day(14, hour: 10) + 180
    )
  }

  func testRequest() throws {
    let reminder = Reminder(
      id: "abc.1",
      title: "Push-ups",
      body: "Try for 6 today.",
      date: day(2, hour: 18)
    )
    let request = reminder.request(in: utc)
    XCTAssertEqual(
      request.identifier, "abc.1"
    )
    XCTAssertEqual(
      request.content.title, "Push-ups"
    )
    XCTAssertEqual(
      request.content.body,
      "Try for 6 today."
    )
    let trigger = try XCTUnwrap(
      request.trigger
        as? UNCalendarNotificationTrigger
    )
    XCTAssertFalse(trigger.repeats)
    let parts = trigger.dateComponents
    XCTAssertEqual(parts.year, 2026)
    XCTAssertEqual(parts.month, 1)
    XCTAssertEqual(parts.day, 2)
    XCTAssertEqual(parts.hour, 18)
    XCTAssertEqual(parts.minute, 0)
  }

  func testAsksOnlyWithReminders() async {
    let fake = FakeNotifier()
    let reminder = Self.sample
    await ReminderSync.update(
      [], with: fake
    )
    XCTAssertEqual(fake.asked, 0)
    XCTAssertEqual(fake.pending, [])

    await ReminderSync.update(
      [reminder], with: fake
    )
    XCTAssertEqual(fake.asked, 1)
    XCTAssertEqual(
      fake.pending.map(\.identifier), ["a"]
    )
  }

  func testCancelledUpdateKeepsOld() async {
    let fake = FakeNotifier()
    let reminder = Self.sample
    // Cancelled before it runs: a newer
    // update took over.
    let task = Task {
      await ReminderSync.update(
        [reminder], with: fake
      )
    }
    task.cancel()
    await task.value
    XCTAssertEqual(fake.pending, [])
  }
}
