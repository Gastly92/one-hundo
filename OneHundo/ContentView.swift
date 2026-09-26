import SwiftUI

struct ContentView: View {
    @State private var challenge = Challenge(name: "Push-ups", goal: 100)

    var body: some View {
        VStack(spacing: 24) {
            Text(challenge.name)
                .font(.largeTitle.bold())

            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 16)
                Circle()
                    .trim(from: 0, to: challenge.progress)
                    .stroke(.tint, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: challenge.progress)
                VStack {
                    Text("\(challenge.completed)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    Text("of \(challenge.goal)")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 220, height: 220)

            HStack(spacing: 12) {
                ForEach([1, 5, 10], id: \.self) { reps in
                    Button("+\(reps)") { challenge.log(reps) }
                        .buttonStyle(.borderedProminent)
                        .font(.title2)
                }
            }

            Button("Reset", role: .destructive) { challenge.completed = 0 }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
