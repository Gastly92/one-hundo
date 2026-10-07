/// Cleans what's typed into a number field:
/// digits only, clamped to a range.
enum NumberText {
  /// The text to show and the number it
  /// holds (nil when there are no digits).
  static func clean(
    _ text: String,
    in range: ClosedRange<Int>
  ) -> (text: String, value: Int?) {
    let digits = text.filter(\.isNumber)
    guard let number = Int(digits) else {
      return (digits, nil)
    }
    let value = clamp(number, to: range)
    return (String(value), value)
  }

  /// `number` moved into `range`.
  static func clamp(
    _ number: Int,
    to range: ClosedRange<Int>
  ) -> Int {
    min(
      max(number, range.lowerBound),
      range.upperBound
    )
  }
}
