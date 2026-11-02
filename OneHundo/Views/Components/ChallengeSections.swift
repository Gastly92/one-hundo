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
        prompt: Text("e.g. Squats")
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

/// A custom challenge's icon: its color,
/// then its shape drawn in that color, with
/// the result next to the header.
struct IconSection: View {
  /// The shapes row's ID, to scroll to.
  static let shapes = "iconShapes"

  @Binding var draft: ChallengeDraft

  private var color: Color {
    Color(paletteName: draft.colorName)
  }

  var body: some View {
    Section {
      ColorSwatches(
        colorName: $draft.colorName
      )
      MarkerPicker(
        marker: $draft.marker,
        color: color
      )
      .id(Self.shapes)
    } header: {
      header
    } footer: {
      Text("""
        Marks this challenge in your list \
        and calendar.
        """)
    }
  }

  /// "Icon", then the picked icon. The
  /// pickers above say what's picked, so
  /// VoiceOver skips the preview.
  private var header: some View {
    HStack {
      SectionTitle("Icon")
      Image(systemName: draft.marker.symbol)
        .font(.headline)
        .foregroundStyle(color)
        .accessibilityHidden(true)
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
        // Only with the reminder on: "this
        // time" means the time above.
        Text("""
          On days you haven't logged yet, a \
          notification reminds you at this \
          time.
          """)
          .font(.footnote)
      }
    } header: {
      SectionTitle("Daily reminder")
    }
  }
}
