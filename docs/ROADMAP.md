# Roadmap

Features after 1.0, not yet scheduled.
Each is its own PR series: when one
starts, break it into small PRs here and
check them off as they land; once it
ships, update `docs/PRODUCT.md` and remove
it from this list. Versions: minor for a
new feature (1.1.0), patch for fixes.

- **iCloud sync** (CloudKit), so
  challenges come back after a reinstall
  and appear on a new phone or iPad. The
  models are already CloudKit-ready
  (PR 1).
  - PRs (in progress):
    - [x] PR 1: signing. iCloud
      (CloudKit) and push entitlements,
      the remote-notification background
      mode, and the TestFlight workflow
      signs them in (it archived with
      `CODE_SIGNING_ALLOWED=NO`, which
      left them out). Its `upload` input
      off builds and checks the signed
      app with `codesign` without
      uploading. Owner first: the
      container and App ID steps in
      `docs/TESTFLIGHT.md` (step 9).
      Sync stays off.
    - [x] PR 2: merge duplicates
      (`Models/Duplicates.swift`, unit
      tested), run when the store opens.
      Harmless without sync. Devices
      merge on their own, maybe at once,
      so all must keep the same copy (two
      keeping different ones would delete
      both). `SchemaV2` adds a `copyID`
      to each record for that: the lowest
      is kept. Migrating tags 1.0 data,
      on each device before it syncs, so
      copies never share one. It also
      adds `loggedAt` to attempts, so a
      day's later log or edit wins (1.0
      data falls back to `date`).
    - [x] PR 3: sync on (1.1.0).
      `AppStore.open` sets `.automatic`
      (in-memory stores `.none`; it was
      the default already, so a signed
      build would have synced without
      this). `SyncWatcher` merges and
      reschedules reminders after each
      change iCloud brings, in the
      background too. Decided: reminder
      settings sync, and there's no
      switch in the app (iOS Settings).
      Test by hand on two devices through
      TestFlight, starting from a phone
      with 1.0 data (the V1 → V2
      migration with CloudKit on is only
      checked there).
    - [x] PR 4: the CloudKit schema,
      part 1. No Mac to make it, and
      TestFlight always signs for
      Production (tried), so a one-off ad
      hoc build will. This PR: the plan
      (`docs/CLOUDKIT.md`) and
      `tools/udid`, a Cloudflare Worker
      that shows the iPhone's device ID
      to register it.
    - [x] PR 5: the schema, part 2. An ad
      hoc build for Development that runs
      `initializeCloudKitSchema` (built
      with `CLOUDKIT_SCHEMA`;
      `schema-build.yml`), and the
      Worker's `/install` page serving it
      from the `schema-build` release. The
      owner deploys the schema.
      Schema deployed to Production
      (2026-11-08). Also needed: a
      separate app ID for the schema app
      (#103) and Developer Mode.
    - [ ] PR 6: release. Privacy page,
      listing text and App Privacy note
      (`docs/APPSTORE.md`). Hand checks:
      1.0 data opens with sync on, and a
      log saves (owner's phone, build
      28); two devices sync (pending).
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
    unit tests for the rules. A same-day
    pair keeps the later-logged count; a
    challenge's copies keep one copy's
    settings (no edit times to compare).
  - Reminders are scheduled per device:
    reschedule them when synced
    challenges change.
  - Existing users: on the first launch
    with sync, the data already on the
    phone should upload by itself (no
    migration). Check it on a phone with
    real 1.0 data before release.
  - There's no prompt: iCloud is on for
    the app by default, and turned off
    in iOS Settings. No switch in the app
    (decided).
  - A device still on the old version
    doesn't sync until it updates; a
    full iCloud pauses sync. Both keep
    working on the phone alone.
  - Testing: CI can't sync between
    devices. Test by hand through
    TestFlight on two devices, including
    the duplicates case (a phone with
    data, plus a device restored from
    its backup).
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
  sale since 2026-10-23. Last in line:
  start it by early 2027 to make April.
  - Runner: `macos-26` tops out at Xcode
    26.6, so CI and TestFlight move to
    GitHub's `xcode-27` image (macOS 27,
    Xcode 27.1, iOS 27.1 simulator with
    an iPhone Duo). Free for this repo.
  - Tried in Oct 2026 (PR #89, closed;
    branch `xcode-27-runner` has all of
    it). The image was two weeks old and
    flaky, so it waits. What it found:
    - The pinned actionlint didn't know
      the `xcode-27` label and needed a
      config entry
      (`.github/actionlint.yaml`) with
      no way to remove it later. Check
      for an actionlint release that
      knows it first.
    - `run-tests.sh` picks the first
      iPhone simulator; skip the Duo so
      snapshots keep a phone's window.
    - Periphery on Xcode 27 called
      `FormTips`' `$showsTips` binding
      unused; letting `DisclosureGroup`
      keep its own state fixed it.
    - Every snapshot changes on iOS 27
      (`record-snapshots` label).
    - `AppStoreTests`' first poster
      (`ImageRenderer`) came out all
      black in about half the runs: it
      builds its shaders on first use
      and timed out. Drawing the first
      screenshot once and throwing it
      away fixed it.
    - `NotificationTests` twice found no
      permission prompt (the app was
      uncovered; cause unknown, then 6
      clean runs). The branch logs iOS's
      answer and prints iOS's
      notification lines after the main
      shard, to catch it.
    - One-off stalls: a timeout deleting
      attempts, an app launch that hung.
  - PR 1 (next patch version): the
    runner, the fixes above, re-recorded
    snapshots. Run CI several times
    before merging to judge the runner.
  - PR 2: Duo-sized snapshots and App
    Store screenshots (`AppStoreTests`),
    and the upload steps in
    `docs/APPSTORE.md`. Its snapshots
    are where the portrait lock and wide
    layouts on the inner screen get
    checked (no Mac to look by hand).
