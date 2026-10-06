import SwiftUI

extension Color {
  typealias Swatch =
    (name: String, color: Color)

  /// The palette challenges pick from, by
  /// stored name (`Challenge.colorName`).
  static let palette: [Swatch] = [
    ("orange", .orange), ("red", .red),
    ("pink", .pink), ("purple", .purple),
    ("indigo", .indigo), ("blue", .blue),
    ("teal", .teal), ("mint", .mint),
    ("green", .green), ("yellow", .yellow),
  ]

  /// The palette color with this name, or
  /// orange.
  init(paletteName name: String) {
    let match = Self.palette.first {
      $0.name == name
    }
    self = match?.color ?? .orange
  }
}

extension Challenge {
  var color: Color {
    Color(paletteName: colorName)
  }
}

extension BuiltIn {
  var color: Color {
    Color(paletteName: colorName)
  }
}
