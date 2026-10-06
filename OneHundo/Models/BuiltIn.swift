import Foundation

/// A ready-made challenge. Static data in
/// code, not stored; a started one is a
/// `Challenge` whose `kind` is this id.
struct BuiltIn: Identifiable, Hashable {
  let id: String
  let name: String
  /// One-line description for the Add
  /// challenge list.
  let summary: String
  /// The "Test yourself" question. A whole
  /// sentence per challenge, since other
  /// languages can't build it from the name.
  let testQuestion: String
  let colorName: String
  let tips: [String]

  static let all = [pushUps, sitUps, pullUps]

  static func with(id: String) -> BuiltIn? {
    all.first { $0.id == id }
  }

  static let pushUps = BuiltIn(
    id: "pushups",
    name: String(localized: "Push-ups"),
    summary: String(localized: """
      The classic: chest, shoulders, and \
      arms.
      """),
    testQuestion: String(localized: """
      How many push-ups can you do in one \
      go?
      """),
    colorName: "orange",
    tips: [
      String(localized: """
        Hands just wider than your \
        shoulders.
        """),
      String(localized: """
        Keep your body in a straight line \
        from head to heels.
        """),
      String(localized: """
        Lower until your chest nearly \
        touches the floor.
        """),
    ]
  )

  static let sitUps = BuiltIn(
    id: "situps",
    name: String(localized: "Sit-ups"),
    summary: String(localized: """
      Core strength, one rep at a time.
      """),
    testQuestion: String(localized: """
      How many sit-ups can you do in one go?
      """),
    colorName: "blue",
    tips: [
      String(localized: """
        Bend your knees and keep your feet \
        flat.
        """),
      String(localized: """
        Cross your arms over your chest; \
        don't pull on your neck.
        """),
      String(localized: """
        Come up with control, not momentum.
        """),
    ]
  )

  static let pullUps = BuiltIn(
    id: "pullups",
    name: String(localized: "Pull-ups"),
    summary: String(localized: """
      Back and arms. Even one is a great \
      start.
      """),
    testQuestion: String(localized: """
      How many pull-ups can you do in one \
      go?
      """),
    colorName: "green",
    tips: [
      String(localized: """
        Start from a full hang with straight \
        arms.
        """),
      String(localized: """
        Pull until your chin is over the \
        bar.
        """),
      String(localized: """
        Lower slowly; no swinging or \
        kipping.
        """),
    ]
  )
}
