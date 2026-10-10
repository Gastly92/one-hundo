import Foundation

/// What a challenge's card in the list
/// shows besides its name and today's text.
extension Challenge {
  /// Progress label, e.g. "6 / 100".
  var progressText: String {
    "\(currentCount) / \(goal)"
  }

  /// Under a card's progress bar: the
  /// progress, or once completed the day it
  /// was reached (e.g. "Oct 8, 2026"), which
  /// tells a restarted challenge's runs
  /// apart.
  var cardDetail: String {
    guard let completedDate else {
      return progressText
    }
    return completedDate.formatted(
      .dateTime.month().day().year()
    )
  }

  /// Whether a card shows the "logged
  /// today" checkmark: not once completed,
  /// where "Reached 100" already says it.
  func showsDoneMark(
    on day: Date = Date(),
    in cal: Calendar = .current
  ) -> Bool {
    !isCompleted
      && attempt(on: day, in: cal) != nil
  }
}
