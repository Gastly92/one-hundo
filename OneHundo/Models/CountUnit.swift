import Foundation

enum CountUnit: String, CaseIterable {
  case reps, seconds, minutes

  /// A count with its unit for labels: "6"
  /// for reps, "46 seconds", "1 minute". The
  /// String Catalog holds the plural forms
  /// ("1 second" / "2 seconds").
  func format(_ count: Int) -> String {
    switch self {
    case .reps:
      count.formatted()
    case .seconds:
      String(localized: "\(count) seconds")
    case .minutes:
      String(localized: "\(count) minutes")
    }
  }

  /// The unit's name, shown under the number
  /// when logging, e.g. "seconds".
  var name: String {
    switch self {
    case .reps:
      String(localized: "reps")
    case .seconds:
      String(localized: "seconds")
    case .minutes:
      String(localized: "minutes")
    }
  }

  /// The unit's name as a choice in the
  /// custom challenge form.
  var title: String {
    switch self {
    case .reps:
      String(localized: "Reps")
    case .seconds:
      String(localized: "Seconds")
    case .minutes:
      String(localized: "Minutes")
    }
  }
}
