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
  /// Violet, the default, is the app's
  /// accent.
  static let palette = [
    Swatch("violet", .accentColor, "Violet"),
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
  /// the app's violet.
  init(paletteName name: String) {
    let match = Self.palette.first {
      $0.name == name
    }
    self = match?.color ?? .accentColor
  }
}

extension Challenge {
  /// A built-in's color is the built-in's
  /// own (settings can't change it), so a
  /// new default reaches challenges already
  /// started; a custom one's is its choice.
  var color: Color {
    Color(
      paletteName: builtIn?.colorName
        ?? colorName
    )
  }
}

extension BuiltIn {
  var color: Color {
    Color(paletteName: colorName)
  }
}
