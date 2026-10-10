# App Store listing

What to fill in on App Store Connect for
the first release (plan step 9d). Text to
paste is in the boxes below; each box is
one field. Keep it true to what the app
does, and update it as features change.

## Screenshots

Six iPhone screenshots, 1320 × 2868 (the
6.9-inch size; App Store Connect scales
them down for smaller iPhones). They're
drawn by `AppStoreTests` from a month of
sample training (`Showcase`), in light
mode, and saved in
`OneHundoTests/__Snapshots__/AppStoreTests/`.
CI records them like the other snapshots,
so they follow the app's look; re-record
with the `record-snapshots` label.

1. `1-list`: the challenge list.
2. `2-challenge`: Push-ups' screen.
3. `3-log`: logging an attempt.
4. `4-calendar`: the month's calendar.
5. `5-plan`: setting a goal and pace.
6. `6-goal`: goal reached.

## Text

Name (30 characters at most):

```
One Hundo
```

Subtitle (30):

```
One more rep, every day
```

Promotional text (170; can change any
time without a new version):

```
Pick a challenge, test yourself, and do a little more each day. One Hundo sets today's target and shows how close you are to 100.
```

Description:

```
Can you do 100 push-ups in one go? One Hundo gets you there one small step at a time.

Start a challenge and test yourself: how many can you do today? That's your starting point. Each day the app suggests a target, a little more than last time. Log what you did, and tomorrow's target builds on it.

• Push-ups, sit-ups and pull-ups, each with tips on good form
• Custom challenges for anything else, in reps, seconds or minutes
• Today's target on every card, and a progress ring toward your goal
• A chart of your progress and a history of every attempt
• A calendar of the days you trained
• A daily reminder at the time you choose, skipped once you've logged
• Reach your goal, then set a new one

No account, no ads, no tracking. Your challenges stay on your iPhone.
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
