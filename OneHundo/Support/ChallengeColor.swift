import SwiftUI

extension Color {
  /// A palette color: its stored name, the
  /// color, and its name for VoiceOver.
  struct Swatch {
    let name: String
    let color: Color
    let label: LocalizedStringResource

    init(
      _ name: String,
      _ color: Color,
      _ label: LocalizedStringResource
    ) {
      self.name = name
      self.color = color
      self.label = label
    }
  }

  /// The palette challenges pick from, by
  /// stored name (`Challenge.colorName`).
  static let palette = [
    Swatch("orange", .orange, "Orange"),
    Swatch("red", .red, "Red"),
    Swatch("pink", .pink, "Pink"),
    Swatch("purple", .purple, "Purple"),
    Swatch("indigo", .indigo, "Indigo"),
    Swatch("blue", .blue, "Blue"),
    Swatch("teal", .teal, "Teal"),
    Swatch("mint", .mint, "Mint"),
    Swatch("green", .green, "Green"),
    Swatch("yellow", .yellow, "Yellow"),
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
