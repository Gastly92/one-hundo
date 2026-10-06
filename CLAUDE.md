# CLAUDE.md

One Hundo: a SwiftUI iOS fitness-challenge tracker (e.g. 100 push-ups a day).
The owner develops entirely from an iPhone via Claude Code; there is no Mac.
Product vision and planned features: `docs/PRODUCT.md`. Build order: `docs/PLAN.md`.
Keep both updated as features land.

## Working with the owner
- Keep it simple: few steps, few questions. Pick sensible defaults and say what you chose.
- Explain anything they must do by hand as short numbered steps for iPhone Safari.
  App Store Connect's mobile layout can hide buttons; "Request Desktop Website" or Safari's
  Find on page helps.

## Building
- This container is Linux: nothing Swift/Xcode builds locally. CI is the compiler.
- `.github/workflows/ios-build.yml` runs on every PR and push to `main` (macOS runner,
  `macos-26`). It generates the project, runs tests on a simulator, and builds.
  Docs-only PRs skip the macOS job. The `CI Gate` job is the single pass/fail check for a PR;
  keep its name stable, and add new code paths to the `changes` filter.
- Tests: `OneHundoTests/` (unit tests for logic in `OneHundo/Models/`) and `OneHundoUITests/`
  (XCTest UI tests that launch the app and check the screen). Both run in the scheme's test action.
- `AccessibilityTests` runs Xcode's accessibility audit on each main screen. Add new screens to it.
  Use system colors and text styles (or `@ScaledMetric` for big custom sizes) so text scales
  and both light and dark mode work.
- SwiftLint runs in CI with `--strict` (warnings fail); lines max 100 chars (diffs are read on
  a phone). Config: `.swiftlint.yml`. It can't be
  downloaded in this container, so read the `SwiftLint` job log on failure.
- Compiler warnings are errors, and the app target uses strict concurrency checking.
- Coverage gate (`.github/scripts/coverage.sh`): every line in `OneHundo/Models/` and
  `OneHundo/Support/` must run in tests (unit and UI tests count). Keep decisions out
  of views: put them in those folders and unit test them. Pass in outside pieces
  (store, clock, notifications) so tests can fake them. Views are reported, not gated.
- Tests run with Thread Sanitizer: a data race stops the app and fails the test. UI tests
  launch the app with `XCUIApplication.launchForTesting(seeded:)`, which sets this up.
- Periphery (CI step after tests) fails on unused code. Delete it rather than ignore it;
  for a real false positive, add a `// periphery:ignore` comment saying why.
  Homebrew marks it deprecated (archived upstream, disabled 2027-08); if it stops
  installing or supporting the current Xcode, remove the CI step.
- Stored data: before 1.0, `@Model`s change freely with no migrations. SwiftData adapts
  to simple changes itself; for bigger ones the owner deletes and reinstalls the app
  (say so in the PR). Plan step 9 adds versioned schemas (schema V1 = the 1.0 release);
  from then on every model change needs a migration and a test that old data opens.
- `OneHundo/PrivacyInfo.xcprivacy` is the App Store privacy manifest. Update it when
  adding tracking, collecting data, or using APIs Apple requires a reason for
  (e.g. `UserDefaults`/`@AppStorage`: reason `CA92.1`).
- Dependabot opens weekly PRs for GitHub Actions versions; merge them if CI is green.
- After pushing, check CI with the GitHub MCP tools (`actions_list`, `get_job_logs`) and fix
  failures before calling the work done. Re-read Swift changes carefully first, since each
  CI round trip takes a few minutes.
- The Xcode project is generated from `project.yml` by XcodeGen. Never add a `.xcodeproj`;
  put new source files under `OneHundo/` (picked up automatically) and build settings in
  `project.yml`. Info.plist is generated from `INFOPLIST_KEY_*` settings there. Add
  permission strings (e.g. `INFOPLIST_KEY_NSHealthShareUsageDescription`) the same way.

## Shipping to the phone (TestFlight)
- `.github/workflows/testflight.yml` (manual, `workflow_dispatch`) archives, cloud-signs with
  an App Store Connect API key, and uploads to TestFlight. Setup is done; see
  `docs/TESTFLIGHT.md` for how it was configured.
- After a feature PR merges, trigger it with `actions_run_trigger` (`run_workflow`,
  `workflow_id: testflight.yml`, `ref: main`) when the owner asks to ship or test on their phone.
  Verify the log ends with "Upload succeeded". The build shows in TestFlight about 5–15 min later.
- Version scheme (`MARKETING_VERSION` in `project.yml`; Apple allows only three numbers):
  - Before 1.0: `0.<plan step>.0` when a plan step's PR lands (step 4 → 0.4.0), and bump the
    patch for fixes between steps (0.4.1). Make the bump in the same PR as the change.
  - 1.0.0 is the first App Store release (end of plan step 9). After that: patch for bug
    fixes, minor for new features.
  - Build number = workflow run number (automatic), shown in TestFlight as e.g. 0.4.0 (5).
- Secrets (`APPLE_TEAM_ID`, `ASC_ISSUER_ID`, `ASC_KEY_ID`, `ASC_KEY_P8`) live in GitHub
  repo secrets. Never print, log, or ask for them.
- Bundle ID `com.gastly92.onehundo`, iOS 17+, iPhone only, portrait.
  `ITSAppUsesNonExemptEncryption` is NO; keep it that way unless adding real encryption.
- Adding capabilities that need entitlements (HealthKit, push, iCloud, App Groups) needs
  extra signing setup: add a `.entitlements` file via `project.yml`, and the capability may
  need enabling on the App ID in the developer portal. Expect to adjust the TestFlight workflow,
  which currently archives with `CODE_SIGNING_ALLOWED=NO`.
