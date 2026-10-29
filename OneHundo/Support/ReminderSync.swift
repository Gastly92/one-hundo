import Base
import Foundation
import UserNotifications

extension Reminder {
  /// The notification, shown once at
  /// `date`'s time on its day.
  func request(
    in cal: Calendar = .current
  ) -> UNNotificationRequest {
    let content =
      UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    let parts = cal.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: date
    )
    let trigger =
      UNCalendarNotificationTrigger(
        dateMatching: parts, repeats: false
      )
    return UNNotificationRequest(
      identifier: id,
      content: content,
      trigger: trigger
    )
  }
}

/// Keeps the phone's pending reminders in
/// step with the challenges.
enum ReminderSync {
  /// Schedules `reminders` in place of the
  /// old ones, asking for permission first
  /// if there are any. Does nothing if
  /// cancelled meanwhile (a newer update
  /// started while the prompt was up).
  @MainActor
  static func update(
    _ reminders: [Reminder],
    with notifier: any Notifier
  ) async {
    if !reminders.isEmpty {
      await notifier.ask()
    }
    guard !Task.isCancelled else {
      return
    }
    notifier.replace(
      with: reminders.map { $0.request() }
    )
  }
}
