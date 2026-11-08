# Roadmap

Features after 1.0, not yet scheduled.
Each is its own PR series: when one
starts, break it into small PRs here and
check them off as they land; once it
ships, update `docs/PRODUCT.md` and remove
it from this list. Versions: minor for a
new feature (1.1.0), patch for fixes.

- **Restore screen on first launch**
  (candidate, after 1.1.0's iCloud sync,
  `docs/ICLOUD.md`): a reinstall shows the
  welcome screen for a second or two
  until the data arrives, and a returning
  user could start a duplicate challenge
  in that moment. If it comes up in use:
  - Returning user (iCloud on, the app's
    zone exists): "Restoring your
    challenges from iCloud…" until the
    first import finishes; after ~5 s,
    the welcome screen with a small
    "Still restoring…" note, replaced
    once the data arrives.
  - Offline: the welcome screen with a
    note that synced challenges appear
    once connected (Network framework).
  - New user or iCloud off: welcome
    screen at once, no note. No buttons
    to choose from in any case.
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
