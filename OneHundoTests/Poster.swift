import SwiftUI

/// An App Store screenshot
/// (`AppStoreTests`): `caption` on the
/// icon's violet-to-blue gradient, over
/// `screen` in a phone frame with a 9:41
/// status bar.
struct Poster: View {
  let caption: String
  /// The screen as drawn on a 440 × 956
  /// point phone.
  let screen: UIImage
  /// Dark mode: a white status bar and home
  /// bar.
  let dark: Bool

  /// The phone's size on the poster.
  private static let scale = 0.76

  /// The icon's gradient (#8B2CF5 into
  /// #00B4F0), violet at the top so white
  /// text on it is easy to read.
  private static let gradient =
    LinearGradient(
      colors: [
        Color(
          red: 0.545,
          green: 0.173,
          blue: 0.961
        ),
        Color(
          red: 0,
          green: 0.706,
          blue: 0.941
        ),
      ],
      startPoint: .top,
      endPoint: .bottom
    )

  var body: some View {
    VStack(spacing: 0) {
      Text(caption)
        .font(.largeTitle.bold())
        .foregroundStyle(.white)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
        .frame(maxHeight: .infinity)
      phone
        .scaleEffect(Self.scale)
        .frame(
          width: 468 * Self.scale,
          height: 984 * Self.scale
        )
    }
    .padding(.bottom, 40)
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity
    )
    .background(Self.gradient)
    .ignoresSafeArea()
  }

  /// The status and home bars' color.
  private var ink: Color {
    dark ? .white : .black
  }

  /// The screen at full size, with a status
  /// bar, home bar and black bezel, and a
  /// grey rim like the phone's metal edge
  /// (so it shows around a dark screen).
  private var phone: some View {
    Image(uiImage: screen)
      .resizable()
      .accessibilityLabel(caption)
      .frame(width: 440, height: 956)
      .overlay(alignment: .top) {
        StatusBar(ink: ink)
      }
      .overlay(alignment: .bottom) {
        Capsule()
          .fill(ink)
          .frame(width: 150, height: 5)
          .padding(.bottom, 8)
      }
      .clipShape(.rect(cornerRadius: 56))
      .padding(14)
      .background(
        .black,
        in: .rect(cornerRadius: 70)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 70)
          .strokeBorder(
            Color(white: 0.5),
            lineWidth: 4
          )
      }
  }
}

/// A tidy status bar, as in Apple's own
/// pictures: 9:41, full signal and battery,
/// either side of the Dynamic Island.
private struct StatusBar: View {
  let ink: Color

  private static let icons = [
    "cellularbars",
    "wifi",
    "battery.100percent",
  ]

  var body: some View {
    HStack(spacing: 0) {
      Text(verbatim: "9:41")
        .frame(maxWidth: .infinity)
      Capsule()
        .fill(.black)
        .frame(width: 126, height: 37)
      HStack(spacing: 6) {
        ForEach(Self.icons, id: \.self) {
          Image(systemName: $0)
            .accessibilityHidden(true)
        }
      }
      .frame(maxWidth: .infinity)
    }
    .font(.body.weight(.semibold))
    .foregroundStyle(ink)
    .padding(.top, 11)
  }
}
