import SwiftUI

/// A custom challenge's name and unit, in
/// the custom challenge form and its
/// settings.
struct CustomSections: View {
  @Binding var draft: ChallengeDraft

  var body: some View {
    Section {
      TextField(
        "Name",
        text: $draft.name,
        prompt: Text("e.g. Plank")
      )
      .textInputAutocapitalization(.words)
      .testID("customName")
    } header: {
      SectionTitle("Name")
    }
    Section {
      Picker(
        "Unit", selection: $draft.unit
      ) {
        ForEach(
          CountUnit.allCases, id: \.self
        ) { Text($0.title).tag($0) }
      }
      .pickerStyle(.segmented)
    } header: {
      SectionTitle("Unit")
    }
  }
}

/// A custom challenge's shape and color,
/// which tell it apart from the others.
struct LookSections: View {
  @Binding var draft: ChallengeDraft

  var body: some View {
    Section {
      MarkerPicker(
        marker: $draft.marker,
        color: Color(
          paletteName: draft.colorName
        )
      )
    } header: {
      SectionTitle("Shape")
    }
    Section {
      ColorSwatches(
        colorName: $draft.colorName
      )
    } header: {
      SectionTitle("Color")
    }
  }
}

/// Goal, daily step and reminder, in the
/// custom challenge form and settings.
struct PlanSections: View {
  @Binding var draft: ChallengeDraft
  /// The quick goal buttons.
  let goals: [Int]
  /// Under the goal: the pace, or what's
  /// wrong with the goal.
  let note: String

  var body: some View {
    Section {
      NumberEntry(
        value: $draft.goal,
        id: "goal",
        range: 1...9999
      )
      // One tap per button, not the whole
      // row.
      .buttonStyle(.borderless)
      GoalChips(
        goals: goals, goal: $draft.goal
      )
      Text(note)
        .font(.subheadline)
        .testID("goalNote")
    } header: {
      SectionTitle("Goal")
    }
    Section {
      Stepper(
        value: $draft.increase, in: 1...10
      ) {
        let step = draft.increase
        Text("\(step) more each day")
      }
      .testID("dailyIncreaseStepper")
    } header: {
      SectionTitle("Daily step")
    }
    reminder
  }

  private var reminder: some View {
    Section {
      Toggle(
        "Remind me each day",
        isOn: $draft.remind
      )
      if draft.remind {
        DatePicker(
          "Time",
          selection: $draft.time,
          displayedComponents: .hourAndMinute
        )
        // Times are moments on a fixed day
        // in GMT (see `ReminderTime`).
        .environment(\.timeZone, .gmt)
      }
      Text("""
        Your reminder time is saved now; \
        notifications arrive in a later \
        update.
        """)
        .font(.footnote)
    } header: {
      SectionTitle("Daily reminder")
    }
  }
}
