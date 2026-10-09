import SwiftUI

/// The shapes to pick a challenge's marker,
/// drawn in its color; the picked one has a
/// ring.
struct MarkerPicker: View {
  @Binding var marker: Marker
  /// The challenge's color.
  let color: Color

  private static let columns = [
    GridItem(
      .adaptive(minimum: 44), spacing: 12
    ),
  ]

  var body: some View {
    LazyVGrid(
      columns: Self.columns, spacing: 12
    ) {
      ForEach(Marker.allCases, id: \.self) {
        choice($0)
      }
    }
    .padding(.vertical, 4)
    .sensoryFeedback(
      .selection, trigger: marker
    )
  }

  private func choice(
    _ shape: Marker
  ) -> some View {
    let picked = marker == shape
    return Button {
      marker = shape
    } label: {
      Image(systemName: shape.symbol)
        .font(.title2)
        .foregroundStyle(color)
        .frame(width: 44, height: 44)
        .overlay {
          if picked {
            Circle().strokeBorder(
              .primary, lineWidth: 3
            )
          }
        }
    }
    .buttonStyle(.plain)
    .accessibilityLabel(shape.label)
    .accessibilityAddTraits(
      picked ? .isSelected : []
    )
    .testID("shape.\(shape.rawValue)")
  }
}
