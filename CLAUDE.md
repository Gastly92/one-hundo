# CLAUDE.md

iOS app (SwiftUI, iOS 17+) developed without a Mac. The dev container is Linux,
so **nothing Swift/Xcode can be built or run locally**. All builds and tests run
in GitHub Actions (`.github/workflows/ios-build.yml`, `macos-26` runner).

## Workflow
- Make the change, push to the working branch, and open/update the PR; CI is the compiler.
- Check CI results with the GitHub MCP tools (`actions_list`, `get_job_logs`) and fix failures before calling the work done.
- Re-read Swift changes carefully before pushing; each CI round trip takes several minutes.

## Conventions
- The Xcode project is generated from `project.yml` by XcodeGen. Never add a `.xcodeproj`;
  add new source files under `OneHundo/` (sources are picked up by folder) and change
  build settings in `project.yml`.
- Keep logic in plain Swift types (like `Challenge`) that are unit-tested in `OneHundoTests/`;
  keep views thin.
- Bump `CURRENT_PROJECT_VERSION` in `project.yml` only if the release workflow doesn't do it automatically.
