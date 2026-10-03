# What One Hundo is

One Hundo is a daily tracker for fitness challenges, where the goal is to do a
lot of one exercise in a single set. The classic example: 100 push-ups in one go.

You start from whatever you can do today, and the app moves you toward your goal
one small step a day.

## How a challenge works

1. **Start a challenge.** Pick one, e.g. Push-ups.
2. **Test yourself.** The app asks how many you can do in one go today.
   Say that's 5. This is your starting point.
3. **Set a goal.** Defaults to 100; you can change it.
4. **Train daily.** Each day the app suggests a target: your last result plus
   the daily increment (default 1). Did 5 yesterday? Try for 6 today.
5. **Log your attempt.** Enter how many you actually did. That becomes the new
   baseline for tomorrow's target.
6. **Track progress.** The challenge shows how far you are from start to goal,
   e.g. "6 / 100", with a progress bar and your history.

## Daily reminders

The app can send a phone notification each day to remind you to try your
challenges, e.g. "Push-ups: try for 6 today." You choose the time, and can turn
reminders off per challenge.

## Challenges

**Built-in challenges** come ready to start, for example:

- Push-ups
- Sit-ups
- Pull-ups

Each built-in challenge has tips, and images where helpful, explaining good form
and common mistakes.

**Custom challenges** let you track anything else. You name it, pick a unit
(reps, seconds, or minutes), icon, and color, give it a starting count and a goal,
and it works like the built-in ones (no form tips).

## Screens

The app has two tabs at the bottom: **Challenges** and **Calendar**.

### Challenge list (Challenges tab)

- A grid of challenge cards, 2 columns, scrolling down as far as you have cards.
- A **+** button in the top bar opens Add challenge.
- First launch, with no challenges yet: a friendly empty state with a big
  "Start your first challenge" button that also opens Add challenge.

### Challenge card

- Icon and name, e.g. a push-up icon and "Push-ups".
- Today's target, large: "Try 6 today", or "Done: 6" with a checkmark once
  logged today.
- Progress toward the goal: "6 / 100" with a thin progress bar.
- Tapping the card opens the challenge screen.

### Add challenge (sheet)

The first step of starting a challenge. A list of choices:

- Each built-in challenge, with icon, name, and a one-line description.
  Built-ins you've already started are shown greyed out with "In progress".
- **Custom challenge** at the bottom, which opens the custom challenge form.

Picking a built-in goes to the enroll flow.

### Enroll flow

A short step-by-step flow (a few pages in the same sheet, with Back/Next):

1. **Intro**: the challenge name, its form tips, and an image where available,
   so you warm up with good form before testing yourself.
2. **Test yourself**: "How many push-ups can you do in one go?" A number entry
   with − / + buttons and a number pad. This is your starting count.
3. **Goal and pace**:
   - Goal: number entry, defaulting to 100 (must be above the starting count).
   - Daily increase: picker, defaulting to 1 (choices like 1, 2, 3, 5, 10).
   - A preview line: "At this pace you'd hit 100 in about 95 days."
4. **Reminder**: a toggle (on by default) and a time picker (default 6:00 PM).
   Turning it on asks for notification permission the first time.
5. **Start** button: saves the challenge with today's test as its first
   attempt, and returns to the list with the new card.

### Custom challenge form

Opened from Add challenge. One scrolling form:

- **Name** (required), e.g. "Plank" or "Burpees".
- **Unit**: picker of reps, seconds, or minutes (default reps). The unit is used
  in labels, e.g. "Try 46 seconds today". Higher is always better.
- **Icon**: a grid of a few dozen fitness-style symbols to pick from.
- **Color**: a row of color swatches for the card.
- Then the same fields as the enroll flow: starting count, goal (default 100),
  daily increase (default 1), and reminder.
- **Start** button, enabled once the name is filled in.

### Challenge screen

Opened from a card or from the calendar.

- **Header**: icon, name, and a large progress ring showing current / goal.
- **Today**: today's target and a big **Log attempt** button. If already logged
  today, it shows your count and the button becomes **Edit today**.
- **History**: a line chart of your counts over time, and a list of attempts
  (date and count), newest first. Swipe an attempt to edit or delete it.
- **Form tips** (built-ins only): the tips and images, collapsible.
- **Settings** (the gear in the top bar): edit goal, daily increase, reminder,
  and for custom challenges name, unit, icon, and color. A red **Delete
  challenge** button at the bottom, with a confirmation.

### Log attempt (sheet)

- "How many did you do?" with the number entry, prefilled with today's target.
- Date: today by default; can be changed to log a past day.
- **Save**. One attempt per challenge per day: logging the same day again
  replaces that day's count.
- Hitting or beating the target shows a small celebration; falling short shows
  an encouraging message and tomorrow's target.

### Goal reached

When an attempt reaches the goal: a full-screen celebration, then two choices:
**Set a new goal** (back to Goal and pace) or **Done** (the card moves to a
"Completed" section at the bottom of the list, showing the date you finished).

### Calendar (Calendar tab)

- A month calendar you can swipe between months; days with logged attempts
  show a dot (one per challenge, in the challenge's color, up to 3).
- Tap a day to open the day view: each challenge you logged that day with its
  count, and whether you hit that day's target.
- Tap a challenge in the day view to open its challenge screen.

## Rules

- **Missed days are fine.** The target stays the same until you log again.
- **Fell short?** The next target is what you actually did plus the increment.
  Did 4 when the target was 6? Try for 5 next time.

## Data

- Stored on the phone only, with no account or server.
- Saved with SwiftData in the app's normal storage, which iCloud Backup
  includes automatically. Restoring a phone from backup brings your challenges
  back. Don't put user data in `Caches` or `tmp`, or mark it excluded from
  backup, since iCloud Backup skips those.
- This is backup, not sync: data doesn't move live between devices.

## Later (not planned yet)

- **Apple Health integration**: e.g. save workouts to the Health app.
- **Ads or other monetization**, in some light form.
- **iCloud sync** (CloudKit) so data shows up on a new phone or iPad without a
  full restore. Needs the iCloud entitlement and extra signing setup.
