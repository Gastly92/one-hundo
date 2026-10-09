import SwiftUI

/// The palette as round swatches to pick a
/// challenge's color; the picked one has a
/// ring.
struct ColorSwatches: View {
  @Binding var colorName: String

  private static let columns = [
    GridItem(
      .adaptive(minimum: 44), spacing: 12
    ),
  ]

  var body: some View {
    LazyVGrid(
      columns: Self.columns, spacing: 12
    ) {
      ForEach(Color.palette, id: \.name) {
        swatch($0)
      }
    }
    .padding(.vertical, 4)
    .sensoryFeedback(
      .selection, trigger: colorName
    )
  }

  private func swatch(
    _ swatch: Color.Swatch
  ) -> some View {
    let picked = colorName == swatch.name
    return Button {
      colorName = swatch.name
    } label: {
      Circle()
        .fill(swatch.color)
        .padding(5)
        .overlay {
          if picked {
            Circle().strokeBorder(
              .primary, lineWidth: 3
            )
          }
        }
        .frame(width: 44, height: 44)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(Text(swatch.label))
    .accessibilityAddTraits(
      picked ? .isSelected : []
    )
    .testID("color.\(swatch.name)")
  }
}
