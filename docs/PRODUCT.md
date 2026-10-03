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

**Custom challenges** let you track anything else. You name it, give it a
starting count and a goal, and it works like the built-in ones (no form tips).

## Screens

### Challenge list (home)

- A grid of challenge cards, 2 columns, scrolling down as far as you have cards.
- Each card shows the challenge name, today's target, and progress toward the goal.
- Tap a card to open the challenge: log today's attempt, see history, read tips,
  change the goal or increment.
- A button to add a challenge (built-in or custom).

### Calendar

- A month calendar; days with logged attempts are marked.
- Tap a day to see the challenges you did that day and your counts.
- Tap a challenge from that day to open its full challenge screen.

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
