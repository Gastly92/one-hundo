import SwiftUI

extension Color {
    /// The palette challenges pick from, by stored name (`Challenge.colorName`).
    static let challengePalette: [(name: String, color: Color)] = [
        ("orange", .orange), ("red", .red), ("pink", .pink), ("purple", .purple),
        ("indigo", .indigo), ("blue", .blue), ("teal", .teal), ("mint", .mint),
        ("green", .green), ("yellow", .yellow),
    ]

    init(challengeColorName name: String) {
        self = Color.challengePalette.first { $0.name == name }?.color ?? .orange
    }
}
