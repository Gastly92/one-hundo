# CLAUDE.md

One Hundo: a SwiftUI iOS fitness-challenge tracker (e.g. 100 push-ups a day).
The owner develops entirely from an iPhone via Claude Code; there is no Mac.

## Working with the owner
- Keep it simple: few steps, few questions. Pick sensible defaults and say what you chose.
- Explain anything they must do by hand as short numbered steps for iPhone Safari.
  App Store Connect's mobile layout can hide buttons; "Request Desktop Website" or Safari's
  Find on page helps.

## Building
- This container is Linux: nothing Swift/Xcode builds locally. CI is the compiler.
- `.github/workflows/ios-build.yml` runs on every PR and push to `main` (macOS runner,
  `macos-26`). It generates the project and builds; there are no unit tests yet.
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
- Build number = workflow run number (automatic). The version (`MARKETING_VERSION` in
  `project.yml`) only changes when the owner asks for a bump.
- Secrets (`APPLE_TEAM_ID`, `ASC_ISSUER_ID`, `ASC_KEY_ID`, `ASC_KEY_P8`) live in GitHub
  repo secrets. Never print, log, or ask for them.
- Bundle ID `com.gastly92.onehundo`, iOS 17+, iPhone only, portrait.
  `ITSAppUsesNonExemptEncryption` is NO; keep it that way unless adding real encryption.
- Adding capabilities that need entitlements (HealthKit, push, iCloud, App Groups) needs
  extra signing setup: add a `.entitlements` file via `project.yml`, and the capability may
  need enabling on the App ID in the developer portal. Expect to adjust the TestFlight workflow,
  which currently archives with `CODE_SIGNING_ALLOWED=NO`.
