# iCloud sync

Since 1.1 (1.1.0 on TestFlight, 1.1.1
the first App Store release with it),
challenges and attempts sync
through the user's own private iCloud
database (CloudKit), so they appear on
their other devices and come back after a
reinstall. What users see:
`docs/PRODUCT.md` (Data). Setting up the
CloudKit schema: `docs/CLOUDKIT.md`.

## How it works
- **Store**: `AppStore.open` uses
  `cloudKitDatabase: .automatic` for the
  on-disk store: the private database of
  the container the app is signed with
  (`iCloud.com.gastly92.onehundo`).
  In-memory stores (UI tests) use
  `.none`. No entitlement (CI's unsigned
  builds), no iCloud account, iCloud off
  for the app, or a full iCloud: it works
  on the phone alone. `.automatic` is
  SwiftData's default, so a signed build
  syncs unless told not to.
- **Entitlements**:
  `OneHundo/OneHundo.entitlements`
  (CloudKit container, push) and the
  `remote-notification` background mode
  (`OneHundo/Info.plist`), so changes
  arrive on their own.
- **Watching for changes**: `SyncWatcher`
  (`Support/`), kept by `AppLaunch` for
  the app's life, listens for
  `NSPersistentStoreRemoteChange` and
  CloudKit's `eventChangedNotification`.
  Each one merges duplicates and
  reschedules reminders, in the
  background too (`RootView` only
  reschedules while the app is in
  front). Its handler is `@Sendable`:
  Core Data posts from background
  threads, and a main-actor handler
  crashed the app under Swift 6.
- **Fresh install** (1.1.1,
  `RestoreCheck`, `CloudCheck`): with an
  empty store at launch, the app asks
  iCloud whether this account has the
  app's zone (the account must be
  available, then it looks the zone up).
  Meanwhile `LaunchCover` keeps the
  launch screen's picture over the app.
  "No" (or an error, offline, signed
  out): the welcome screen. "Yes": the
  picture stays until CloudKit's first
  import ends (an `eventChangedNotification`
  import event with an end date). Limits:
  3 s for the answer, 4 s for a returning
  user's data; past those, the welcome
  screen, with a "Still checking
  iCloud…" note when the answer was yes
  (gone after 30 s). Challenges that
  arrive replace any of it.
- **Testing the check**: CloudKit
  crashes builds without the
  entitlement, so only builds with
  `OneHundoCloudKit` = YES in Info.plist
  ask (`ONEHUNDO_CLOUDKIT`, `NO` in
  `project.yml`, `YES` in the TestFlight
  archive). Tests pass fake accounts
  through two small protocols that
  `CKContainer` and `CKDatabase` already
  meet (`CloudContainer`, `CloudZones`),
  so no app line needs real iCloud.
- **Duplicates** (`Models/Duplicates.swift`,
  also run when the store opens): the
  same challenge twice (same `id`)
  becomes one copy with all the days; two
  attempts on one day become one, with
  the later log's count (`loggedAt`, or
  `date` for 1.0 data); same moment: the
  higher count. A challenge's copies keep
  one copy's settings (no edit times).
- **Why `copyID`**: every device merges
  on its own, maybe at the same moment.
  Two devices keeping different copies
  would each delete the other's, losing
  both. So each record has a `copyID`
  that never changes, and every device
  keeps the lowest. Copies with no tag,
  or sharing one, are left alone.
- **Schema** (`Models/SchemaV2.swift`):
  `SchemaV2` adds `copyID` (challenges
  and attempts) and `loggedAt`
  (attempts). The V1 → V2 migration tags
  1.0 data on each device before it can
  sync, so copies from two devices never
  share a tag; `loggedAt` stays empty for
  1.0 data. Both fields are optional:
  CloudKit only lets the schema grow.
- **Reminders**: settings sync with the
  challenge, so they're the same on every
  device; each device schedules its own
  notifications.

## Decisions
- iCloud is on by default; users turn it
  off in iOS Settings (your name →
  iCloud). No switch in the app.
- Reminder settings sync (not per
  device).
- A fresh install shows no message while
  it waits, just the launch picture (the
  icon's gradient with the ring in light
  mode, the dark icon on black in dark).
  Most apps don't mention syncing for a
  second or two; iCloud only comes up in
  the slow case's note. No buttons to
  choose from. Offline counts as a new
  user. The launch screen shows on every
  cold start, like Spotify's: kept on
  purpose.
- App Privacy stays "Data Not
  Collected": the private database isn't
  visible to the developer.

## Signing (TestFlight)
CI builds unsigned. The TestFlight
workflow archives unsigned, signs the
entitlements in ad hoc, and export
re-signs with them (it keeps what it
finds in the app). The archive sets
`ONEHUNDO_CLOUDKIT=YES`, turning on the
fresh-install check. Every run checks the
entitlements
(`.github/scripts/entitlements.sh`);
with `upload` off it builds, signs and
checks the exported app without
uploading. Export sets iCloud and push to
Production for TestFlight.

## The CloudKit schema
TestFlight and App Store builds use
CloudKit's Production environment, which
only takes record types and fields first
made in Development and deployed. With no
Mac, a one-off ad hoc build makes them
(`schema-build.yml`, `docs/CLOUDKIT.md`).
Deployed to Production on 2026-11-08:
`CD_Challenge` (29 fields) and
`CD_Attempt` (16). A new schema version
that adds a field needs this again.

## Checking sync by hand
In the CloudKit Console
(icloud.developer.apple.com) →
container → **Prod** → Menu → **Act As
iCloud Account…** (the phone's Apple ID)
→ **Records** → **Private Database**,
zone `com.apple.coredata.cloudkit.zone`,
then **Fetch Changes** (not Query
Records: it fails with "Field
'recordName' is not marked queryable").
It lists the `CD_Challenge` and
`CD_Attempt` records. The zone existing
means the app has synced at least once.

## Learned along the way
- TestFlight builds always use
  Production: export overrides an app's
  Development setting (Apple confirms it
  on its forums). Ad hoc ("Release
  Testing") exports can use Development.
- An ad hoc build can't install over the
  TestFlight app without deleting it (and
  its data), so the schema build is a
  separate app,
  `com.gastly92.onehundo.schema`, with
  the same container.
- iOS opens ad hoc apps only with
  Developer Mode on.
- The launch screen centres its picture
  at its own size (never stretched), so
  the light one is a 440×956 pt picture
  that smaller phones crop, and
  `LaunchCover` draws it the same way.
  iOS keeps an old launch screen until
  the app is reinstalled.
- iPhones don't show their UDID; the
  device ID page (`tools/udid`) gets it
  through a profile service.
- Data on a phone uploads only once the
  schema is in Production and the app
  runs (after the deploy, open the app).
- Cloudflare's preview builds ignore
  watch paths, so they're off; CI
  previews the Worker instead
  (`worker-preview.yml`).

## Hand checks
- Done (owner's phone, TestFlight build
  28): 1.0 data opened with sync on; a
  new log saved and came back after
  reopening; the data reached iCloud (1
  challenge, 4 attempts, linked);
  deleting and reinstalling the app
  brought it all back within seconds,
  and reminders asked for permission
  again.
- Done (build 30, 1.1.1): installed
  over 1.1.0 with the data kept; deleting
  and reinstalling showed the launch
  picture, then the challenges, with no
  welcome screen in between; dark mode
  checked.
- Pending: two phones (an iPhone 12 on
  the same Apple ID): first download,
  changes both ways, and the same day
  logged on both while one is offline
  (one entry, the later one).
- Not done: duplicates from a restored
  backup (unit tested).

## History
- #98: entitlements, signing in
  TestFlight, the entitlements check.
- #99: duplicates merge, `SchemaV2`
  (`copyID`, `loggedAt`).
- #100: sync on (1.1.0), `SyncWatcher`.
- #101–#103: the CloudKit schema without
  a Mac (device ID page, ad hoc schema
  build, separate app ID).
- #104: release docs (privacy page, App
  Store text) and this file.
- #105: Worker previews from CI.
- #106: the fresh-install check and the
  launch picture (1.1.1).
