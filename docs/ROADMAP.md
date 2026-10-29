# Roadmap

Features after 1.0, not yet scheduled.
Each is its own PR series: when one
starts, break it into small PRs here and
check them off as they land; once it
ships, update `docs/PRODUCT.md` and remove
it from this list. Versions: minor for a
new feature (1.1.0), patch for fixes.

- **Signing for capabilities** (needed
  first by Health and iCloud): add a
  `.entitlements` file through
  `project.yml`, and turn the capability
  on for the App ID in the developer
  portal (owner, by hand). The TestFlight
  workflow archives with
  `CODE_SIGNING_ALLOWED=NO`, which leaves
  entitlements out; sign the archive (or
  make export add them) and check the
  uploaded app with
  `codesign -d --entitlements`. CI's
  simulator builds can stay unsigned.
- **Apple Health**: save each logged day
  to the Health app, opt in from Settings.
  - Health has no type for push-ups or
    squats: save a strength workout
    (`HKWorkout`), with the count and
    challenge in its metadata. Timed
    challenges (plank) give it a real
    duration; rep counts need a chosen
    one, since attempts store no time.
  - Write only: needs
    `NSHealthUpdateUsageDescription`
    (`NSHealthShareUsageDescription` only
    if it ever reads) and the HealthKit
    entitlement. Ask for access when the
    user turns it on, not at launch.
  - Editing or deleting an attempt should
    change or delete its workout, so the
    attempt keeps the workout's ID: a new
    stored field, so a new schema version
    and migration (`Schema.swift`), kept
    CloudKit-safe (optional, no unique).
  - Health calls go behind a small
    protocol that tests fake, like the
    notifications.
  - App Review: Health use must be
    visible in the app, and the privacy
    page must say what's written. Health
    data must never be stored in iCloud
    (fine while it's write only).
  - App Privacy answers likely unchanged
    (nothing reaches the developer);
    recheck.
- **iCloud sync** (CloudKit), so
  challenges come back after a reinstall
  and appear on a new phone or iPad. The
  models are already CloudKit-ready
  (PR 1).
  - Needs the iCloud entitlement with a
    CloudKit container
    (`iCloud.com.gastly92.onehundo`), and
    background modes "Remote
    notifications" so changes arrive on
    their own.
  - `AppStore.open` sets
    `cloudKitDatabase: .automatic`; tests
    and UI tests keep it `.none`. With no
    iCloud account (or iCloud off for the
    app) it must keep working on the
    phone alone.
  - Before release, deploy the CloudKit
    schema from Development to
    Production in the CloudKit Console
    (owner, by hand), or sync silently
    fails in App Store builds.
  - Once in Production the CloudKit
    schema can only grow: new optional
    fields, never renamed or removed
    ones. Every later schema version
    must follow that too.
  - Merge duplicates: "one attempt per
    day" is only enforced in code, so two
    devices (or a reinstall syncing back)
    can bring the same day twice, or the
    same challenge twice (same `id`).
    Merge on launch and after sync, with
    unit tests for the rules.
  - Reminders are scheduled per device:
    reschedule them when synced
    challenges change.
  - Release: privacy page (data saved in
    the user's iCloud, removed in iOS
    Settings), recheck App Privacy (the
    private database isn't visible to the
    developer), version 1.1.0.
- **iPhone Duo (foldable) support**: apps
  fill its inner screen only when built
  with Xcode 27.1 or later (older builds,
  like 1.0.0, show with black borders),
  and from April 2027 App Store
  submissions need Duo screenshots. On
  sale since 2026-10-23.
  - Runner: `macos-26` tops out at Xcode
    26.6 (Xcode 27 needs macOS 27), so
    switch `runs-on` to GitHub's
    `xcode-27` image instead (macOS 27,
    generally available 2026-10-15,
    Xcode 27.1 default, iOS 27.1
    simulator with an iPhone Duo; checked
    2026-10-29). Not yet confirmed free
    for public repos like `macos-26`
    (`xcode-27-xlarge` is paid): the
    first CI run shows it. Its tools
    differ, so check XcodeGen, SwiftLint
    and Periphery still install.
  - PR 1 (next patch version): CI and
    the TestFlight workflow on
    `xcode-27`, simulator
    names in `run-tests.sh` if they
    changed, `CLAUDE.md`'s runner note,
    re-record snapshots
    (`record-snapshots` label), check
    the portrait lock and wide layouts on
    the Duo simulator's inner screen.
  - PR 2: Duo-sized snapshots and App
    Store screenshots (`AppStoreTests`),
    and the upload steps in
    `docs/APPSTORE.md`.
- **"Lower is better" challenges**, e.g.
  a faster mile time (shown as mm:ss) or
  less screen time. Targets step down,
  hitting one means at or below it, and
  new goals, progress, the chart and the
  celebration all read the other way.
- **Ads or monetization**.
