# What One Hundo is

One Hundo is a daily tracker for fitness
challenges, where the goal is to do a lot of
one exercise in a single set. The classic
example: 100 push-ups in one go.

You start from whatever you can do today, and
the app moves you toward your goal one small
step a day.

## How a challenge works

1. **Start a challenge.** Pick one, e.g.
   Push-ups.
2. **Test yourself.** The app asks how many
   you can do in one go today. Say that's 5.
   This is your starting point.
3. **Set a goal.** Defaults to 100; you can
   change it.
4. **Train daily.** Each day the app suggests
   a target: your last result plus the daily
   increment (default 1). Did 5 yesterday?
   Try for 6 today.
5. **Log your attempt.** Enter how many you
   actually did. That becomes the new
   baseline for tomorrow's target.
6. **Track progress.** The challenge shows
   how far you are from start to goal, e.g.
   "6 / 100", with a progress bar and your
   history.

## Daily reminders

The app can send a phone notification each
day to remind you to try your challenges,
e.g. "Push-ups: try for 6 today." You choose
the time, and can turn reminders off per
challenge. Once you've logged a day, that
day's reminder doesn't come, even if you
logged it on another device. Reminder
settings sync like the rest, so they're
the same on every device.

## Challenges

**Built-in challenges** come ready to start,
for example:

- Push-ups
- Sit-ups
- Pull-ups

Each built-in challenge has tips, and images
where helpful, explaining good form and
common mistakes.

**Custom challenges** let you track anything
else. You name it, pick a unit (reps,
seconds, or minutes) and a color, give it a
starting count and a goal, and it works like
the built-in ones (no form tips).

## Look

- App icon: a ring with "100" inside. In
  dark mode it's a neon ring (light blue
  into purple) glowing on black; in light
  mode it's inverted, a glowing white ring
  on that blue-to-purple gradient. A gray
  tinted version is colored by iOS.
- Accent (buttons, today in the calendar):
  a neon violet, deeper in light mode so
  white text on it stays readable.
- Each challenge keeps its own color.

## Screens

The app has two tabs at the bottom:
**Challenges** and **Calendar**.

### Challenge list (Challenges tab)

- A grid of challenge cards, 2 columns,
  scrolling down as far as you have cards.
- An **Add challenge** tile, the last card in
  the grid, opens Add challenge. The title
  bar stays plain.
- First launch, with no challenges yet: a
  welcome that explains the idea in three
  steps (test yourself, do one more each day,
  reach 100) and a big "Start your first
  challenge" button that opens Add challenge.

### Challenge card

- The challenge's shape, then its name,
  e.g. "● Push-ups". Challenges are told
  apart by name and shape, never by color
  alone (color-blind friendly); color is an
  extra cue. Built-ins have fixed shapes:
  Push-ups a circle, Sit-ups a square,
  Pull-ups a triangle.
- Today's target, large: "Try 6 today", or
  "Done: 6" with a checkmark once logged
  today. On the day you start, your test
  counts: "Done: 5" until tomorrow.
- Progress toward the goal: "6 / 100" with a
  thin progress bar.
- Tapping the card opens the challenge
  screen.
- Long-pressing the card opens a menu: **Log
  attempt** (or **Edit today**) and **Delete
  challenge**, with a confirmation.

### Add challenge (sheet)

The first step of starting a challenge. A
list of choices:

- Each built-in challenge, with its name and
  a one-line description. Built-ins you're
  currently doing are shown greyed out with
  "In progress", so there is only one active
  challenge per built-in. Once it's
  completed, the built-in is available to
  start again (as a fresh challenge). Custom
  challenges have no such limit.
- **Custom challenge** at the bottom, which
  opens the custom challenge form.

Picking a built-in goes to the enroll flow.

### Enroll flow

A short step-by-step flow (a few pages in the
same sheet, with Back/Next):

1. **Intro**: the challenge name and its
   form tips (open; images to come), so you
   warm up with good form before testing
   yourself.
2. **Test yourself**: "How many push-ups can
   you do in one go?" A number entry with − /
   + buttons and a number pad. This is your
   starting count.
3. **Set your plan** (goal and pace):
   - Goal: number entry, defaulting to 100
     (must be above the starting count), with
     quick buttons for 50, 100, 150, and 200.
   - Daily step: "1 more each day", with − /
     + (1 to 10).
   - A preview: "5 Today → 6 Tomorrow → 100
     Goal" and "At this pace you'd hit 100 in
     about 95 days."
4. **Reminder**: a toggle (on by default) and
   a time picker (default 6:00 PM). Starting
   a challenge with a reminder on asks for
   notification permission the first time.
5. **Start** button: saves the challenge with
   today's test as its first attempt, and
   returns to the list with the new card.

### Custom challenge form

Opened from Add challenge. One scrolling
form:

- **Name** (required), e.g. "Plank" or
  "Burpees".
- **Unit**: picker of reps, seconds, or
  minutes (default reps). The unit is used in
  labels, e.g. "Try 46 seconds today". Higher
  is always better.
- **Test yourself**: the starting count
  (today's test, default 1).
- Then the same fields as the enroll flow:
  goal (default 100, with quick buttons),
  daily step (default 1), and reminder.
- **Icon**, last as it's optional: color
  swatches (violet, the app's accent, by
  default), then shapes drawn in that color
  (circle, square, triangle, diamond, star
  or hexagon; star by default). The picked
  icon shows next to the header, and a note
  says it marks the challenge in the list
  and calendar.
- **Start** button at the bottom, enabled
  once the name is filled in and the goal is
  above the starting count. Like the enroll
  flow, the test is the first attempt.

### Challenge screen

Opened from a card or from the calendar.

- **Header**: name and a large progress ring
  showing current / goal. Below it, small
  stats: personal best and days logged.
- **Today**: today's target and a big **Log
  attempt** button. If already logged today,
  it shows your count and the button becomes
  **Edit today**.
- **History**: a list of attempts (date and
  count), newest first. Tap an attempt to
  edit it; swipe left or long-press to delete
  it.
- **Progress**: a line chart of your counts
  over time, below the history.
- **Form tips** (built-ins only): "Good
  form", closed until tapped (images to
  come).
- **Settings** (the gear in the top bar, a
  sheet with Cancel and Save): edit goal,
  daily increase, reminder, and for custom
  challenges name, unit and icon (last,
  as in the form).
  Under
  the goal, the pace ("At this pace you'd
  hit 150 in about 140 days"). A red
  **Delete challenge** button at the
  bottom, with a confirmation.
  - The goal can be raised or lowered at any
    time. Lowering it to at or below your
    current count counts as reaching it: you
    get the goal-reached celebration.

### Log attempt (sheet)

- "How many did you do?" with the number
  entry, prefilled with today's target.
- Date: today by default; can be changed to
  log a past day.
- **Save**. One attempt per challenge per
  day: logging the same day again replaces
  that day's count.
- Editing an attempt (swipe in History, or
  **Edit today**) opens the same sheet with
  its count; the date stays fixed.
- Hitting or beating the target shows a small
  celebration; falling short shows an
  encouraging message. Both show the next
  target ("Next time, try for 7").
- Beating your highest count ever for this
  challenge (including your starting test)
  adds a "New personal best!" badge to the
  celebration.

### Goal reached

When an attempt reaches the goal (or the goal
is lowered to your current count): a
full-screen celebration with confetti and a
success haptic, then two choices:

- **Set a new goal**: back to Goal and pace,
  defaulting to a higher goal (e.g. 150 after
  100). The challenge keeps going from your
  current count.
- **Done**: the card moves to a "Completed"
  section at the bottom of the list, saying
  e.g. "Reached 100" and the day it was
  reached (no "logged today" checkmark), so
  a restarted built-in's runs are told
  apart and both kept. Its challenge screen
  stays viewable (history, chart) and has a
  **Set a new goal** button (Cancel leaves
  it completed), which moves it back to the
  active list.

### Calendar (Calendar tab)

- A month calendar you can swipe between
  months (or use the arrows), up to the
  current month; days with logged attempts
  show a marker (one per challenge: its
  icon, up to 3). A month
  with nothing logged says so, and what
  the markers mean. Away from the current
  month, Today jumps back to it.
- Tap a marked day to open the day view:
  each challenge you logged that day with
  its count, and whether you hit that
  day's target ("Hit the target of 6." /
  "The target was 7."). A challenge's
  first day shows "Started this challenge".
- Tap a challenge in the day view to open its
  challenge screen.

## Rules

- **Missed days are fine.** The target stays
  the same until you log again. There are no
  streaks to break; the challenge screen
  shows "days logged" instead.
- **Fell short?** The next target is what you
  actually did plus the increment. Did 4 when
  the target was 6? Try for 5 next time.

## Data

- Stored on the phone, and synced through
  your own iCloud (from 1.1), so challenges
  appear on your other devices and come
  back after a reinstall. No account or
  server of ours: it's iCloud's private
  database, which only you can see.
- iCloud is on for the app by default; turn
  it off in iOS Settings (your name →
  iCloud). There's no switch in the app.
  Without iCloud (signed out, off, or
  full) the app works on the phone alone.
- The same challenge or day arriving twice
  (two devices, a restored backup) is
  merged: one copy of each challenge with
  all its days, and one attempt a day, the
  last logged.
- First launch with no challenges on the
  phone: the app asks iCloud whether this
  account has used One Hundo, keeping the
  launch screen's logo up meanwhile (at
  most 3 s). A new user, or no answer
  (offline, signed out): the welcome
  screen, no message. A returning user (a
  reinstall, a new device): an iCloud
  icon and "Checking iCloud for your
  challenges…" until iCloud's first
  import finishes, so they aren't invited
  to start over. After 4 s, the welcome
  screen with a quiet note that it's
  still checking (up to 30 s); a "yes"
  that comes after the logo's 3 s adds
  the note too.
- The launch screen shows the app icon.
  Challenges that arrive replace it.
  (1.1.1)
- Saved with SwiftData in the app's normal
  storage, which iCloud Backup includes
  automatically. Restoring a phone from
  backup brings your challenges back. Don't
  put user data in `Caches` or `tmp`, or mark
  it excluded from backup, since iCloud
  Backup skips those.
- No analytics or tracking in the app: it
  collects nothing. Crash reports and usage
  numbers come from Apple (App Store
  Connect), only from people who share
  analytics with developers in iOS
  Settings.

## Later

Planned features after 1.0 are in
`docs/ROADMAP.md`.
