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
day's reminder doesn't come.

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

- App icon: a neon ring, light blue into
  purple, with "100" inside. It glows on
  black in dark mode, sits on near-white
  in light mode, and has a gray tinted
  version that iOS colors.
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
- **Shape**: circle, square, triangle,
  diamond, star or hexagon (star by
  default), drawn in the chosen color.
- **Color**: color swatches for the card
  (violet, the app's accent, by default).
- Then the same fields as the enroll flow:
  goal (default 100, with quick buttons),
  daily step (default 1), and reminder.
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
  challenges name, unit, shape and color.
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
  show a marker (one per challenge, its
  shape in its color, up to 3). A month
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

- Stored on the phone only, with no account
  or server.
- Saved with SwiftData in the app's normal
  storage, which iCloud Backup includes
  automatically. Restoring a phone from
  backup brings your challenges back. Don't
  put user data in `Caches` or `tmp`, or mark
  it excluded from backup, since iCloud
  Backup skips those.
- This is backup, not sync: data doesn't move
  live between devices.

## Later (not planned yet)

- **Apple Health integration**: e.g. save
  workouts to the Health app.
- **Ads or other monetization**, in some
  light form.
- **iCloud sync** (CloudKit) so data shows up
  on a new phone or iPad without a full
  restore. Needs the iCloud entitlement and
  extra signing setup.
