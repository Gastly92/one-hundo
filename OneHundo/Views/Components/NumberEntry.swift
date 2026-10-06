import SwiftUI

/// A big number with − / + buttons; tap the number to type it on the number
/// pad. Shared by the enroll flow, the custom challenge form, and logging
/// attempts.
struct NumberEntry: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...9999
    /// Prefix for accessibility identifiers: `<id>.field`, `<id>.increment`,
    /// `<id>.decrement`.
    var identifier: String = "number"

    @State private var text = ""
    // The number scales fully with the user's text size setting. The − / +
    // buttons grow less, so a three-digit number and both buttons still fit
    // across the screen.
    @ScaledMetric(relativeTo: .largeTitle) private var numberSize: CGFloat = 56
    @ScaledMetric(relativeTo: .body) private var scaledButtonSize: CGFloat = 44
    private var buttonSize: CGFloat { min(scaledButtonSize, 56) }

    var body: some View {
        HStack(spacing: 8) {
            stepButton(
                systemImage: "minus.circle.fill", label: "Decrease", delta: -1
            )
                .accessibilityIdentifier("\(identifier).decrement")

            TextField("0", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(
                    .system(size: numberSize, weight: .bold, design: .rounded)
                )
                .monospacedDigit()
                .frame(minWidth: 100)
                .accessibilityIdentifier("\(identifier).field")

            stepButton(
                systemImage: "plus.circle.fill", label: "Increase", delta: 1
            )
                .accessibilityIdentifier("\(identifier).increment")
        }
        .frame(maxWidth: .infinity)
        .onAppear { text = String(value) }
        .onChange(of: text) { _, newText in
            let digits = newText.filter(\.isNumber)
            guard let number = Int(digits) else {
                if digits != newText { text = digits }
                return
            }
            let clamped = clamp(number)
            if String(clamped) != newText { text = String(clamped) }
            if clamped != value { value = clamped }
        }
        .onChange(of: value) { _, newValue in
            if Int(text) != newValue { text = String(newValue) }
        }
    }

    private func stepButton(
        systemImage: String,
        label: LocalizedStringKey,
        delta: Int
    ) -> some View {
        Button {
            value = clamp(value + delta)
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: buttonSize))
                .symbolRenderingMode(.hierarchical)
        }
        .accessibilityLabel(label)
        .disabled(!range.contains(value + delta))
    }

    private func clamp(_ number: Int) -> Int {
        min(max(number, range.lowerBound), range.upperBound)
    }
}
