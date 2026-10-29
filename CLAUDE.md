# CLAUDE.md

One Hundo: a SwiftUI iOS fitness-challenge
tracker (e.g. 100 push-ups a day), on the
App Store since 1.0.0. The owner develops
entirely from an iPhone via Claude Code;
there is no Mac. What the app does:
`docs/PRODUCT.md`. Features after 1.0:
`docs/ROADMAP.md`. Keep both updated as
features land. How 1.0 was built (a
finished record): `docs/HISTORY.md`.

## The template
- Built on
  [ios-template](https://github.com/gastly92/ios-template),
  pinned in the `uses:` lines of
  `.github/workflows/build.yml`,
  `testflight.yml` and `pages.yml` (the
  version lives only there; Dependabot
  bumps all three in one PR). The
  template's RULES.md applies here; the
  session start hook fetches the template
  into `.template/` and prints it. Only
  what's specific to One Hundo is below.
- Shared CI, scripts, SwiftLint rules and
  the Base package (`Base`,
  `BaseTesting`, `BaseSnapshots`) come
  from the template. To change them,
  change the template and pin the new
  version here.
- New code goes in One Hundo by default,
  even if it could be shared. Suggest a
  template change only for a bug in the
  shared code, or tooling every app would
  want, and ask the owner first: it's a
  template PR and tag before this repo
  can use it.

## This app
- Bundle ID `com.gastly92.onehundo`, shown
  as "One Hundo". App Store:
  https://apps.apple.com/app/id6818800020.
- Screens that need challenges are listed
  in `AppLaunch.seededScreens`, and
  `AppLaunch.sample(for:)` picks a variant
  of the sample data (`SampleData`) for
  other states. UI tests seed the whole
  app with `App.start(seeded: true)`
  (`-seedData`).
- `LocalizationTests` lets through
  system-formatted dates and weekdays (by
  identifier), calendar days (`day.`),
  the history chart's axes and the sample
  custom challenge's name ("Plank"). Add
  new system text there.
- `testLongPressLogsToday` taps first on
  purpose, so `menuItem`'s stall path
  runs every time.
- App UI test helpers: `app.card(_:)` (a
  challenge card) and `app.editSheet` (a
  history row read as a tap), in
  `OneHundoUITests/TestApp.swift`.
- Reminders: `ReminderSync` schedules one
  notification per day ahead
  (`Reminder.request`), through the
  `Notifier` `AppLaunch` passes in.
- Stored data: the 1.0 models are in
  `SchemaV1` (`Models/Schema.swift`),
  frozen from the 1.0 release on, used
  through the `Challenge` and `Attempt`
  aliases. Never edit it; follow the
  steps in that file to change a stored
  model. Users' data must never be lost.
- Privacy: the manifest declares no
  tracking, no collected data and no
  required-reason APIs (nothing uses
  `UserDefaults` yet); `PrivacyInfoTests`
  checks it. Update it, `site/privacy.html`
  and the test together.
- `site/` is published to
  https://gastly92.github.io/one-hundo/.
- App Store screenshots: `AppStoreTests`
  (seven shots, `Showcase` data, the
  icon's colors). The listing's text is in
  `docs/APPSTORE.md`. Update both when a
  pictured screen or a listed feature
  changes.
- The icon (a ring with "100") and the
  product page header are drawn by One
  Hundo's own `.github/scripts/app-icon.sh`
  and `app-header.sh`, not the template's.
- Accessibility: there's no automated
  audit (Xcode's stalled at random on
  CI's simulators). Check VoiceOver and
  the largest text size on the phone when
  screens change.

## Shipping
- TestFlight setup is done; how it was
  configured: `docs/TESTFLIGHT.md`. After
  a feature PR merges, ship when the
  owner asks (see RULES.md). Each upload
  tags its commit, e.g. `v1.0.1-build12`.
- Version: 1.0.0 was the first App Store
  release. Patch for bug fixes, minor for
  new features, bumped in the same PR.
