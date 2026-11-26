# Roadmap

Features after 1.0, not yet scheduled.
Each is its own PR series: when one
starts, break it into small PRs here and
check them off as they land; once it
ships, update `docs/PRODUCT.md` and remove
it from this list. Versions: minor for a
new feature (1.1.0), patch for fixes.

- **iPhone Duo (foldable) support**: apps
  fill its inner screen only when built
  with Xcode 27.1 or later (older builds,
  like 1.0.0, show with black borders),
  and from April 2027 App Store
  submissions need Duo screenshots. On
  sale since 2026-10-23. Last in line:
  start it by early 2027 to make April.
  - PR 1 (1.1.3): CI and TestFlight on
    GitHub's `xcode-27` image (macOS 27,
    Xcode 27, iOS 27), as the template
    did (ios-template#20). It also: lets
    `FormTips` keep its own open state
    (Periphery on Xcode 27), warms up
    the first App Store poster (it came
    out black), tests `PhoneNotifier`
    with a stand-in notification center
    instead of the iOS 27 prompt (XCTest
    can't see it), tracks the
    `actionlint.yaml` label
    (`runner-labels.sh`), and re-records
    every snapshot.
  - PR 2: Duo-sized snapshots and App
    Store screenshots (`AppStoreTests`),
    and the upload steps in
    `docs/APPSTORE.md`. Its snapshots
    are where the portrait lock and wide
    layouts on the inner screen get
    checked (no Mac to look by hand).
