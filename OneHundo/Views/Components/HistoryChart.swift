import Charts
import SwiftUI

/// A challenge's counts over time, oldest
/// first, as a line in its color.
struct HistoryChart: View {
  let challenge: Challenge

  @ScaledMetric(relativeTo: .body)
  private var height: CGFloat = 180

  init(_ challenge: Challenge) {
    self.challenge = challenge
  }

  var body: some View {
    Chart(challenge.oldestFirst) { attempt in
      let day = PlottableValue.value(
        "Day", attempt.date, unit: .day
      )
      let count = PlottableValue.value(
        "Count", attempt.count
      )
      LineMark(x: day, y: count)
      PointMark(x: day, y: count)
    }
    .foregroundStyle(challenge.color)
    .frame(height: min(height, 320))
    .testID("historyChart")
  }
}
