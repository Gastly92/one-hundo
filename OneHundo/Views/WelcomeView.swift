import SwiftUI

/// The first screen, before any challenge exists: what the app does in three steps,
/// and one button to start.
struct WelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Get to 100 in one go.")
                        .font(.title.bold())
                        .accessibilityIdentifier("welcomeTitle")
                    Text("100 push-ups, sit-ups, or anything else, one small step a day.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 22) {
                    step(
                        number: 1,
                        icon: "stopwatch",
                        title: "Test yourself",
                        detail: "Do as many as you can in one go. Say that's 5."
                    )
                    step(
                        number: 2,
                        icon: "arrow.up.right",
                        title: "Do one more each day",
                        detail: "Tomorrow, try 6. The app keeps track of your target."
                    )
                    step(
                        number: 3,
                        icon: "trophy",
                        title: "Reach 100",
                        detail: """
                            Small steps add up. Missed a day? \
                            No problem, pick up where you left off.
                            """
                    )
                }

                Button(action: onStart) {
                    Text("Start your first challenge")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("startFirstChallengeButton")
            }
            .padding()
            .padding(.top, 8)
        }
    }

    private func step(
        number: Int,
        icon: String,
        title: LocalizedStringKey,
        detail: LocalizedStringKey
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 48, height: 48)
                .background(Color.accentColor.opacity(0.15), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(number). \(Text(title))")
                    .font(.headline)
                Text(detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
