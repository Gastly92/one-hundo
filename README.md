# One Hundo

An iOS app built entirely from a phone with Claude Code and GitHub Actions.
Right now it just says "Hello One Hundo".

Every PR and push to `main` runs `.github/workflows/ios-build.yml` on a macOS
runner, which uploads:

- `OneHundo-unsigned-ipa`: install on a phone with a sideloading app (e.g. SideStore)
- `OneHundo-simulator`: run in the browser on Appetize.io

To install on a real iPhone, run the **TestFlight** workflow
(Actions → TestFlight → Run workflow). One-time setup: [docs/TESTFLIGHT.md](docs/TESTFLIGHT.md).

The Xcode project is generated from `project.yml` by XcodeGen; don't commit a `.xcodeproj`.
