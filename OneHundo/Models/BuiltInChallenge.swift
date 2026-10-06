import Foundation

/// A ready-made challenge. Static data in code, not stored; a started one is a
/// `Challenge` whose `kind` is this id.
struct BuiltInChallenge: Identifiable, Hashable {
    let id: String
    let name: String
    /// One-line description for the Add challenge list.
    let summary: String
    /// SF Symbol name.
    let icon: String
    let colorName: String
    let tips: [String]

    static let all: [BuiltInChallenge] = [pushUps, sitUps, pullUps]

    static func with(id: String) -> BuiltInChallenge? {
        all.first { $0.id == id }
    }

    static let pushUps = BuiltInChallenge(
        id: "pushups",
        name: "Push-ups",
        summary: "The classic: chest, shoulders, and arms.",
        icon: "figure.strengthtraining.functional",
        colorName: "orange",
        tips: [
            "Hands just wider than your shoulders.",
            "Keep your body in a straight line from head to heels.",
            "Lower until your chest nearly touches the floor.",
        ]
    )

    static let sitUps = BuiltInChallenge(
        id: "situps",
        name: "Sit-ups",
        summary: "Core strength, one rep at a time.",
        icon: "figure.core.training",
        colorName: "blue",
        tips: [
            "Bend your knees and keep your feet flat.",
            "Cross your arms over your chest; don't pull on your neck.",
            "Come up with control, not momentum.",
        ]
    )

    static let pullUps = BuiltInChallenge(
        id: "pullups",
        name: "Pull-ups",
        summary: "Back and arms. Even one is a great start.",
        icon: "figure.climbing",
        colorName: "green",
        tips: [
            "Start from a full hang with straight arms.",
            "Pull until your chin is over the bar.",
            "Lower slowly; no swinging or kipping.",
        ]
    )
}
