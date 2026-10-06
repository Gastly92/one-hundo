import SwiftUI

/// A big number with − / + buttons; tap the number to type
/// it on the number pad. Shared by the enroll flow, the
/// custom challenge form, and logging attempts.
struct NumberEntry: View {
    @Binding var value: Int
    var range: ClosedRange<Int> = 0...9999
    /// Prefix for accessibility identifiers: `<id>.field`,
    /// `<id>.increment`, `<id>.decrement`.
    var id: String = "number"

    @State private var text = ""
    // The number scales fully with the user's text size
    // setting. The − / + buttons grow less, so a
    // three-digit number and both buttons still fit across
    // the screen.
    @ScaledMetric(relativeTo: .largeTitle)
    private var numberSize: CGFloat = 56
    @ScaledMetric(relativeTo: .body)
    private var buttonBase: CGFloat = 44
    private var buttonSize: CGFloat { min(buttonBase, 56) }

    var body: some View {
        HStack(spacing: 8) {
            stepButton("minus", "Decrease", by: -1)
                .accessibilityIdentifier("\(id).decrement")
            field
            stepButton("plus", "Increase", by: 1)
                .accessibilityIdentifier("\(id).increment")
        }
        .frame(maxWidth: .infinity)
        .onAppear { text = String(value) }
        .onChange(of: text) { _, newText in
            textChanged(to: newText)
        }
        .onChange(of: value) { _, newValue in
            if Int(text) != newValue {
                text = String(newValue)
            }
        }
    }

    private var field: some View {
        TextField("0", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.system(
                size: numberSize,
                weight: .bold,
                design: .rounded
            ))
            .monospacedDigit()
            .frame(minWidth: 100)
            .accessibilityIdentifier("\(id).field")
    }

    /// Keeps only digits, clamps to `range`, and updates
    /// `value`.
    private func textChanged(to newText: String) {
        let digits = newText.filter(\.isNumber)
        guard let number = Int(digits) else {
            if digits != newText { text = digits }
            return
        }
        let clamped = clamp(number)
        if String(clamped) != newText {
            text = String(clamped)
        }
        if clamped != value { value = clamped }
    }

    private func stepButton(
        _ sign: String,
        _ label: LocalizedStringKey,
        by delta: Int
    ) -> some View {
        Button {
            value = clamp(value + delta)
        } label: {
            Image(systemName: "\(sign).circle.fill")
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
