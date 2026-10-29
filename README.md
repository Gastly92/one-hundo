# One Hundo

A daily tracker for fitness challenges like
100 push-ups in one go, built entirely from a
phone with Claude Code and GitHub Actions.
[On the App Store](https://apps.apple.com/app/id6818800020).
See [docs/PRODUCT.md](docs/PRODUCT.md) for
what the app does and
[docs/ROADMAP.md](docs/ROADMAP.md) for
what's next.

Built on
[ios-template](https://github.com/gastly92/ios-template),
pinned in `.github/workflows/build.yml`:
its shared CI runs the unit tests in
`OneHundoTests/` and the UI tests in
`OneHundoUITests/` on every PR and push to
`main`, and the `CI / Gate` check shows
whether a PR passed. See CLAUDE.md.

To install on a real iPhone, run the
**TestFlight** workflow (Actions → TestFlight
→ Run workflow). One-time setup:
[docs/TESTFLIGHT.md](docs/TESTFLIGHT.md).

The Xcode project is generated from
`project.yml` by XcodeGen; don't commit a
`.xcodeproj`.
