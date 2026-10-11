# App Store listing

What to fill in on App Store Connect for
the first release (plan step 9d). Text to
paste is in the boxes below; each box is
one field. Keep it true to what the app
does, and update it as features change.

## Screenshots

Seven iPhone screenshots, in the two
sizes App Store Connect takes (its
[screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications)):

- Medium, 1206 × 2622 (`…-medium.png`):
  "iPhone with Dynamic Island (medium
  display)", e.g. 17 Pro. Required.
- Large, 1320 × 2868: "iPhone with
  Dynamic Island (large display)", e.g.
  17 Pro Max and Air.

The medium ones are the large ones scaled
down (the shapes differ by 0.07%). Each is a
caption on the icon's violet-to-blue
gradient over the screen in a phone frame
(black bezel, grey rim), with a tidy 9:41
status bar (`Poster`).
They're drawn by `AppStoreTests` from a
month of sample training (`Showcase`), in
light mode (the last in dark), and saved
in
`OneHundoTests/__Snapshots__/AppStoreTests/`.
CI records them like the other snapshots,
so they follow the app's look; re-record
with the `record-snapshots` label.

1. `1-list`: the challenge list. "Get to
   100, one day at a time"
2. `2-challenge`: Push-ups' screen. "See
   how far you've come"
3. `3-calendar`: the month. "Every day you
   trained"
4. `4-plan`: a new challenge's plan. "Set
   your goal and pace"
5. `5-log`: logging an attempt. "Beat
   yesterday by one"
6. `6-goal`: goal reached. "Reach 100,
   then aim higher"
7. `7-dark`: Push-ups' screen in dark
   mode. "Light or dark, your choice"

Search results show only the first three
(the app's page shows all, two or three
at a time), so the strongest go first.
Captions are in `AppStoreTests.shots`. Each
is a short phrase that adds to the picture
rather than describing it (Apple's
[asset guidance](https://developer.apple.com/app-store/asset-best-practices/)).

## Header

`docs/appstore/header.png` (5244 × 2950),
the product page header on iOS 27 and
later: the light icon's ring, "One Hundo"
and the subtitle on the icon's gradient,
all in the centre so no device crops it.
Drawn by `.github/scripts/app-header.sh`;
run it again if the subtitle changes.
There's no search results image: without
one, search shows the first three
screenshots.

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

Save the pictures first:

1. In Safari, open the repo on GitHub and
   go to
   `OneHundoTests/__Snapshots__/AppStoreTests`.
2. Tap a picture, then the download
   button (or "Raw"), long-press the
   image and tap "Save to Photos". Do all
   fourteen (seven of each size), in
   order (1 to 7).
3. Do the same for
   `docs/appstore/header.png`.

Then the version page (Apps → One Hundo →
iOS App Version, "Prepare for
Submission"). Tap Save now and then.

1. Under "Header and Search Results",
   on the Header tab, tap Upload and pick
   the header. Leave the Search Results
   tab empty.
2. Screenshots: tap "Header and Search
   Results >" (or find "Previews and
   Screenshots"). Upload the seven
   `-medium` files, in order, to "iPhone
   with Dynamic Island (medium display)"
   (or 6.3"), and the other seven to the
   large display (or 6.9").
3. Promotional Text, Description,
   Keywords: paste from the boxes above
   (each box on GitHub has a copy
   button).
4. Support URL as above; leave Marketing
   URL empty.
5. Version: 1.0.0, the same as the app's
   (it must match exactly).
6. Copyright: `2026` and your name.
7. Leave Routing App Coverage, App Clip,
   iMessage App and Game Center empty.
8. Build: once the 1.0.0 build is in
   TestFlight, tap + and pick it.
9. App Review Information: untick
   "Sign-in required" (the app has no
   accounts), add your contact details
   (only Apple sees them), and paste the
   notes below.
10. Release: "Manually release this
    version", so you choose the day once
    Apple approves.
11. Save. "Add for Review" comes last,
    with the build attached.

The other fields (category, age rating,
price, App Privacy and the privacy policy
URL) are under Distribution at the top,
on the App Information, Pricing and
Availability, and App Privacy pages.

Notes for App Review:

```
No account or sign-in. Tap "Start your first challenge", pick Push-ups, enter how many you can do, set a goal and tap Start. Tap the card to see its screen and log an attempt; long-press a card for a quick menu. Daily reminders are optional local notifications. The app collects no data.
```
