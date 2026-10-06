import SwiftUI

/// Quick goal buttons (e.g. 50, 100, 150,
/// 200); the selected one is filled. One row,
/// or two rows at the largest text sizes so
/// "100" fits in its button.
struct GoalChips: View {
  let goals: [Int]
  @Binding var goal: Int

  @Environment(\.dynamicTypeSize)
  private var textSize

  var body: some View {
    LazyVGrid(columns: columns, spacing: 8) {
      ForEach(goals, id: \.self) {
        chip($0)
      }
    }
  }

  private var columns: [GridItem] {
    let count = textSize.isAccessibilitySize
      ? 2 : 4
    let column = GridItem(spacing: 8)
    return Array(
      repeating: column, count: count
    )
  }

  private func chip(
    _ choice: Int
  ) -> some View {
    let picked = goal == choice
    let ink = picked ? Color.white : .primary
    let fill = picked
      ? Color.accentColor
      : Color(.tertiarySystemFill)
    return Button {
      goal = choice
    } label: {
      Text("\(choice)")
        .font(.body.weight(.semibold))
        .frame(
          maxWidth: .infinity, minHeight: 44
        )
        .foregroundStyle(ink)
        .background(fill, in: Capsule())
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(
      picked ? .isSelected : []
    )
    .testID("goalChoice.\(choice)")
  }
}
