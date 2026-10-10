# App Store listing

What to fill in on App Store Connect for
the first release (plan step 9d). Text to
paste is in the boxes below; each box is
one field. Keep it true to what the app
does, and update it as features change.

## Screenshots

Six iPhone screenshots, 1320 × 2868 (the
6.9-inch size; App Store Connect scales
them down for smaller iPhones). Each is a
caption on the icon's violet-to-blue
gradient over the screen in a phone frame,
with a tidy 9:41 status bar (`Poster`).
They're drawn by `AppStoreTests` from a
month of sample training (`Showcase`), in
light mode, and saved in
`OneHundoTests/__Snapshots__/AppStoreTests/`.
CI records them like the other snapshots,
so they follow the app's look; re-record
with the `record-snapshots` label.

1. `1-list`: the challenge list. "Get to
   100, one day at a time"
2. `2-challenge`: Push-ups' screen. "See
   how far you've come"
3. `3-log`: logging an attempt. "Log what
   you did today"
4. `4-calendar`: the month. "Every day you
   trained"
5. `5-plan`: a new challenge's plan. "Set
   your goal and pace"
6. `6-goal`: goal reached. "Reach 100,
   then aim higher"

Captions are in `AppStoreTests.shots`.

## Text

Name (30 characters at most):

```
One Hundo
```

Subtitle (30):

```
Get to 100, one day at a time
```

Promotional text (170; can change any
time without a new version):

```
How many push-ups can you do in a row? Start there, do one more each day, and watch yourself get to 100.
```

Description:

```
Can you do 100 push-ups in a row? Not yet? One Hundo gets you there, one small step a day.

Pick a challenge and test yourself: how many can you do today without stopping? That's where you start. Each day the app gives you a target, just one more than last time. Do it, tap to log it, and tomorrow's target builds on it. Start at 10 and you'll reach 100 in about three months. Miss a day? Pick up where you left off.

• Push-ups, sit-ups and pull-ups, with tips on good form
• Make your own challenge for anything else, like squats or holding a plank, counted as a number, in seconds or in minutes
• Today's target on every challenge, and a ring that fills up as you get closer to your goal
• A chart of your progress and a list of every day you logged
• A calendar showing the days you trained
• A daily reminder at the time you choose, which skips the days you've already logged
• Reach your goal, then set a bigger one

No account, no ads, no tracking. Your progress stays on your iPhone.
```

Keywords (100, commas, no spaces after
them):

```
push ups,pushups,sit ups,pull ups,plank,workout,fitness,training,reps,calisthenics,exercise,habit
```

## Other fields

- Category: Health & Fitness.
- Support URL:
  https://gastly92.github.io/one-hundo/
- Privacy policy URL:
  https://gastly92.github.io/one-hundo/privacy.html
- Copyright: `2026` and your name.
- Age rating: answer "None" or "No" to
  every question (4+).
- App Privacy: "Data Not Collected" (see
  `site/privacy.html`; Apple's own crash
  reports don't count).
- Price: Free.

## Adding them from an iPhone

1. In Safari, open the repo on GitHub and
   go to
   `OneHundoTests/__Snapshots__/AppStoreTests`.
2. Tap a picture, then the download
   button (or "Raw"), long-press the
   image and tap "Save to Photos". Do all
   six, in order.
3. Open appstoreconnect.apple.com, tap
   the aA button and "Request Desktop
   Website".
4. Apps → One Hundo → the iOS version
   being prepared (e.g. 1.0) → "Previews
   and Screenshots" → the 6.9" iPhone
   tab.
5. Tap "Choose File" → Photo Library, pick
   the six, and drag them into order if
   needed.
6. Paste the text above into its fields,
   fill in the other fields, and tap
   Save.
