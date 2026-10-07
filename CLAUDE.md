# CLAUDE.md

One Hundo: a SwiftUI iOS fitness-challenge
tracker (e.g. 100 push-ups a day). The owner
develops entirely from an iPhone via Claude
Code; there is no Mac. Product vision and
planned features: `docs/PRODUCT.md`. Build
order: `docs/PLAN.md`. Keep both updated as
features land.

## Working with the owner
- Keep it simple: few steps, few questions.
  Pick sensible defaults and say what you
  chose.
- Explain anything they must do by hand as
  short numbered steps for iPhone Safari. App
  Store Connect's mobile layout can hide
  buttons; "Request Desktop Website" or
  Safari's Find on page helps.

## Building
- This container is Linux: nothing
  Swift/Xcode builds locally. CI is the
  compiler.
- `.github/workflows/ios-build.yml` runs on
  every PR and push to `main` (macOS runner,
  `macos-26`). It generates the project and
  builds the tests once, then runs them in
  three shards on separate runners in
  parallel (`run-tests.sh`; one simulator
  each, as the runner is too small for two),
  and a `Coverage` job merges the shards'
  results. A Release device build runs in
  its own job alongside. The CI summary shows
  how long building and each shard took.
  When adding a slow test class, check the
  shards stay balanced.
  Docs-only PRs skip the macOS job. The `CI
  Gate` job is the single pass/fail check for
  a PR; keep its name stable, and add new
  code paths to the `changes` filter. Test
  steps live in
  `.github/scripts/run-tests.sh`.
- Tests: `OneHundoTests/` (unit tests for
  logic in `OneHundo/Models/`) and
  `OneHundoUITests/` (XCTest UI tests that
  launch the app and check the screen). Both
  run in the scheme's test action.
- Screens: every full screen is a view in
  `OneHundo/Views/Screens/` (one per file;
  pieces of screens go in
  `Views/Components/`). Each screen and
  screen state has a case in `ScreenID`
  (`Support/`, also compiled into the UI
  tests) and is shown by `ScreenHost`, which
  UI tests open directly with `-showScreen
  <id>`. CI's `Screen list` job fails if a
  screen in `Views/Screens/` isn't in
  `ScreenHost`. Screens that need challenges
  are listed in `AppLaunch.seededScreens`.
- `AccessibilityTests` runs Xcode's
  accessibility audit on every `ScreenID`
  (what fits on screen; no retries). Use
  system colors and text styles (or
  `@ScaledMetric` for big custom sizes) so
  text scales and both light and dark mode
  work. The `fixed_font_size` lint rule
  flags fixed sizes (the audit's own
  Dynamic Type check can't see text low on
  a screen, so it's off).
- All user-facing text must be translatable
  (English only for now):
  - In views, pass literals to `Text`,
    `Label`, `Button`, etc. Helper parameters
    that reach `Text` are
    `LocalizedStringKey`, not `String`. Never
    join text with `+` (one literal, or a
    `"""` literal with `\` line breaks).
  - Text built in `Models/` or `Support/`
    uses `String(localized:)`, as whole
    sentences (no gluing words together). A
    SwiftLint rule flags plain sentences
    there.
  - Words that change with a number ("1 day"
    / "2 days") get plural forms in
    `OneHundo/Localizable.xcstrings`; edit
    its JSON by hand (no Xcode here).
  - CI's `String catalog` job
    (`.github/scripts/check-strings.py`)
    fails on catalog keys no Swift string
    uses any more; delete them with the code.
  - `LocalizationTests` runs every `ScreenID`
    in a pseudo-language that brackets
    translatable text, and fails on
    unbracketed text.
- SwiftLint runs in CI with `--strict`
  (warnings fail). Config: `.swiftlint.yml`.
  Every opt-in rule is on; the few turned
  off each say why there. When two rules
  disagree, keep the one that makes code
  shorter. No `swiftlint:disable` comments
  in code: fix the cause (a flagged line
  usually has a cleaner form), or turn the
  rule off in `.swiftlint.yml` with a
  reason. Run `.github/scripts/swiftlint.sh`
  before pushing Swift changes: CI's
  SwiftLint job runs the same script. It
  lints in Docker with the version pinned
  in `.github/swiftlint/Dockerfile` (the
  session start hook prepares it).
- Lines max 45 chars, so a diff line fits a
  phone in portrait without wrapping. This
  covers docs, YAML and scripts too: CI's
  `Line length` job runs
  `.github/scripts/check-lines.py` (it skips
  URLs, single unbreakable words, Markdown
  tables and code blocks, and files Xcode
  owns). Indent with 2 spaces. To fit:
  - Prefer short, clear names; a long line
    often means a name could be shorter.
  - Pull deeply nested view code into a small
    helper view or property, but only where
    nesting is what pushes lines over (not
    just because).
  - Use the shared helpers: `LeadingStack`,
    `.testID(_:)`, `.fullWidth(_:)`,
    `.wrapsText()`
    (`Views/Components/ViewHelpers.swift`);
    in UI tests `App.start`,
    `app.text/button/field/bar(_:)`,
    `app.menuItem(_:on:)` (one long-press,
    no retries), `element.appears()`.
  - Long text uses a `"""` literal with `\`
    line breaks (one key, still one
    sentence).
  - Otherwise wrap: one argument per line is
    fine.
- Compiler warnings are errors, and every
  target builds in Swift 6 language mode, so
  data races are compile errors.
- Coverage gate
  (`.github/scripts/coverage.sh`): every line
  of the app must run in tests (unit,
  snapshot and UI tests all count); the log
  names each untested function. Keep
  decisions out of views: put them in
  `Models/` or `Support/` and unit test them.
  Pass in outside pieces (store, clock,
  notifications) so tests can fake them.
  Every button and branch in a view needs a
  UI test or snapshot that reaches it; code
  nothing can reach gets deleted. A view
  using Swift's automatic initializer shows
  its private property defaults as untested;
  give it an explicit `init`.
- Tests run with Thread Sanitizer: a data
  race stops the app and fails the test. UI
  tests launch the app with
  `App.start(seeded:)`, which sets this up.
- Snapshot tests (`SnapshotTests`) take a
  picture of every `ScreenID` in light,
  dark and large text, on a fixed day
  (`\.now` environment value; views read
  "today" from it, not `Date()`). Images live
  in `OneHundoTests/__Snapshots__/`. CI
  records missing ones and commits them to
  the PR branch (pull before pushing again).
  A bot push needs approval to merge, so
  look at the images, then push the next
  real change (or the owner approves).
  Deleting images re-records them too.
  After an intended visual change, add the
  `record-snapshots` label to the PR to
  record all of them again; a failed
  comparison uploads `snapshot-diffs`.
  Re-record after Xcode or iOS updates.
- CI's `Workflows & scripts` job runs
  actionlint on `.github/workflows/` and
  ShellCheck on `.github/scripts/` and
  `.claude/hooks/`. Versions are pinned in
  `.github/scripts/checkers.txt`; the cloud
  session start hook
  (`.claude/hooks/session-start.sh`) installs
  them, so run both before pushing workflow
  or script changes.
- Test-only Swift packages are declared in
  `Packages/TestSupport/Package.swift`
  (pinned with `exact:`), which tests
  `import TestSupport` to get. Dependabot
  opens weekly PRs for them; if snapshots
  change, re-record them before merging.
- Wrapped Swift lines go in one level (2
  spaces), never aligned by hand: SwiftLint's
  `indentation_width` rule checks it.
- Periphery (CI step after tests) fails on
  unused code. Delete it rather than ignore
  it; no `periphery:ignore` comments. For a
  real false positive, restructure the code
  or ask the owner.
  Homebrew marks it deprecated (archived
  upstream, disabled 2027-08); if it stops
  installing or supporting the current Xcode,
  remove the CI step.
- Stored data: before 1.0, `@Model`s change
  freely with no migrations. SwiftData adapts
  to simple changes itself; for bigger ones
  the owner deletes and reinstalls the app
  (say so in the PR). Plan step 9 adds
  versioned schemas (schema V1 = the 1.0
  release); from then on every model change
  needs a migration and a test that old data
  opens.
- `OneHundo/PrivacyInfo.xcprivacy` is the App
  Store privacy manifest. Update it when
  adding tracking, collecting data, or using
  APIs Apple requires a reason for (e.g.
  `UserDefaults`/`@AppStorage`: reason
  `CA92.1`).
- Dependabot opens weekly PRs for GitHub
  Actions, SwiftLint and test-only Swift
  package versions. Check CI and summarize
  what changed (release notes); the owner
  reviews and merges them.
- After pushing, check CI with the GitHub MCP
  tools (`actions_list`, `get_job_logs`) and
  fix failures before calling the work done.
  Re-read Swift changes carefully first,
  since each CI round trip takes a few
  minutes.
- The Xcode project is generated from
  `project.yml` by XcodeGen. Never add a
  `.xcodeproj`; put new source files under
  `OneHundo/` (picked up automatically) and
  build settings in `project.yml`. Info.plist
  is generated from `INFOPLIST_KEY_*`
  settings there. Add permission strings
  (e.g.
  `INFOPLIST_KEY_NSHealthShareUsageDescription`)
  the same way.

## Shipping to the phone (TestFlight)
- `.github/workflows/testflight.yml` (manual,
  `workflow_dispatch`) archives, cloud-signs
  with an App Store Connect API key, and
  uploads to TestFlight. Setup is done; see
  `docs/TESTFLIGHT.md` for how it was
  configured.
- After a feature PR merges, trigger it with
  `actions_run_trigger` (`run_workflow`,
  `workflow_id: testflight.yml`, `ref: main`)
  when the owner asks to ship or test on
  their phone. Verify the log shows "Upload
  succeeded". The build shows in TestFlight
  about 5–15 min later. Each upload tags its
  commit, e.g. `v0.4.6-build12`.
- Version scheme (`MARKETING_VERSION` in
  `project.yml`; Apple allows only three
  numbers):
  - Before 1.0: `0.<plan step>.0` when a plan
    step's PR lands (step 4 → 0.4.0), and
    bump the patch for fixes between steps
    (0.4.1). Make the bump in the same PR as
    the change.
  - 1.0.0 is the first App Store release (end
    of plan step 9). After that: patch for
    bug fixes, minor for new features.
  - Build number = workflow run number
    (automatic), shown in TestFlight as e.g.
    0.4.0 (5).
- Secrets (`APPLE_TEAM_ID`, `ASC_ISSUER_ID`,
  `ASC_KEY_ID`, `ASC_KEY_P8`) live in GitHub
  repo secrets. Never print, log, or ask for
  them.
- Bundle ID `com.gastly92.onehundo`, iOS 17+,
  iPhone only, portrait.
  `ITSAppUsesNonExemptEncryption` is NO; keep
  it that way unless adding real encryption.
- Adding capabilities that need entitlements
  (HealthKit, push, iCloud, App Groups) needs
  extra signing setup: add a `.entitlements`
  file via `project.yml`, and the capability
  may need enabling on the App ID in the
  developer portal. Expect to adjust the
  TestFlight workflow, which currently
  archives with `CODE_SIGNING_ALLOWED=NO`.
