# CLAUDE.md

SwiftUI iOS app developed without a Mac. This container is Linux, so nothing
Swift/Xcode builds locally; GitHub Actions (`.github/workflows/ios-build.yml`) is the compiler.

- Push, then check CI with the GitHub MCP tools (`actions_list`, `get_job_logs`) and fix failures.
- The Xcode project is generated from `project.yml` by XcodeGen. Never add a `.xcodeproj`;
  put new source files under `OneHundo/` and build settings in `project.yml`.
