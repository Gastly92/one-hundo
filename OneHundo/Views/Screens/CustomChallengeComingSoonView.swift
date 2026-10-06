import SwiftUI

/// Stand-in for the custom challenge form (plan step 5).
struct CustomChallengeComingSoonView: View {
    var body: some View {
        ContentUnavailableView(
            "Custom challenges",
            systemImage: "square.and.pencil",
            description: Text("Coming soon: track anything, like planks.")
        )
    }
}
