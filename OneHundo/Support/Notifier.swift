import Foundation
import UserNotifications

/// Where reminders go: the phone's
/// notification center, or a stand-in in
/// tests.
@MainActor
protocol Notifier: Sendable {
  /// Asks to show notifications. iOS shows
  /// its prompt only the first time.
  func ask() async
  /// Replaces every pending reminder.
  func replace(
    with requests: [UNNotificationRequest]
  )
}

/// The phone's notification center.
struct PhoneNotifier: Notifier {
  func ask() async {
    let hub = UNUserNotificationCenter
      .current()
    _ = try? await hub.requestAuthorization(
      options: [.alert, .sound]
    )
  }

  func replace(
    with requests: [UNNotificationRequest]
  ) {
    let hub = UNUserNotificationCenter
      .current()
    hub
      .removeAllPendingNotificationRequests()
    for request in requests {
      hub.add(request)
    }
  }
}

/// UI tests: no permission prompt, and
/// nothing scheduled.
struct SilentNotifier: Notifier {
  func ask() {
    // Never prompts.
  }

  func replace(
    with _: [UNNotificationRequest]
  ) {
    // Schedules nothing.
  }
}

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
