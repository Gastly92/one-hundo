import SwiftUI

/// How the challenge list lays out its
/// tiles.
enum GridLayout {
  /// Two tiles per row, or one at
  /// accessibility text sizes, where two
  /// would break words mid-word.
  static func columns(
    for size: DynamicTypeSize
  ) -> Int {
    size.isAccessibilitySize ? 1 : 2
  }

  /// Splits `items` into rows of
  /// `columns` (the last may be shorter).
  static func rows<Item>(
    _ items: [Item], columns: Int
  ) -> [[Item]] {
    let starts = stride(
      from: 0, to: items.count, by: columns
    )
    return starts.map { start in
      let end = min(
        start + columns, items.count
      )
      return Array(items[start..<end])
    }
  }
}
