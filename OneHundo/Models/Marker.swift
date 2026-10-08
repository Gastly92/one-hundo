import Foundation

/// The shape that marks a challenge on its
/// card (and later in the calendar), so
/// challenges are told apart without relying
/// on color. Color stays as an extra cue.
enum Marker: String, CaseIterable {
  case circle, square, triangle
  case diamond, star, hexagon

  /// The SF Symbol drawn for it.
  var symbol: String {
    "\(rawValue).fill"
  }

  /// Its name for VoiceOver.
  var label: String {
    switch self {
    case .circle:
      String(localized: "Circle")
    case .square:
      String(localized: "Square")
    case .triangle:
      String(localized: "Triangle")
    case .diamond:
      String(localized: "Diamond")
    case .star:
      String(localized: "Star")
    case .hexagon:
      String(localized: "Hexagon")
    }
  }
}
