import SwiftUI

/// Confetti that falls once when a goal is
/// reached. The pieces are placed by their
/// index, not at random, so screenshots
/// always match.
struct Confetti: View {
  @State private var falling = false

  private static let pieces = 24
  private static let colors: [Color] = [
    .orange, .pink, .blue, .green,
    .yellow, .purple, .teal, .red,
  ]

  var body: some View {
    GeometryReader { area in
      ForEach(0..<Self.pieces, id: \.self) {
        piece($0, in: area.size)
      }
    }
    .allowsHitTesting(false)
    .accessibilityHidden(true)
    .onAppear {
      withAnimation(.easeIn(duration: 2.5)) {
        falling = true
      }
    }
  }

  private func piece(
    _ index: Int, in size: CGSize
  ) -> some View {
    let count = Self.colors.count
    let across = Double((index * 37) % 100)
      / 100
    let start = Double((index * 53) % 40)
      / 100
    // Past the bottom edge, out of sight.
    let fall = falling ? size.height + 40 : 0
    return RoundedRectangle(cornerRadius: 2)
      .fill(Self.colors[index % count])
      .frame(width: 8, height: 14)
      .rotationEffect(
        .degrees(Double(index * 29))
      )
      .position(
        x: size.width * across,
        y: size.height * start * 0.5 + fall
      )
  }
}
