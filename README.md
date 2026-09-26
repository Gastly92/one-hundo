# One Hundo

A fitness challenge tracker for iOS (think 100 push-ups a day), built entirely
from a phone with Claude Code and GitHub Actions. No Mac required.

## How it works

```
edit code (Claude Code on phone) → open PR → GitHub Actions (macOS runner) builds & tests → install on phone
```

- `project.yml` defines the Xcode project for [XcodeGen](https://github.com/yonaskolb/XcodeGen).
  The `.xcodeproj` is generated in CI and never committed, so every change is
  plain text that's easy to edit and review.
- `OneHundo/` holds the SwiftUI app source; `OneHundoTests/` holds the unit tests.
- `.github/workflows/ios-build.yml` runs on every PR and push to `main`:
  1. generates the project
  2. runs unit tests on an iPhone simulator
  3. uploads two artifacts: a **simulator build** (`OneHundo-simulator`) and an
     **unsigned device IPA** (`OneHundo-unsigned-ipa`)

## Getting the app onto your phone

| Route | Cost | What you need |
|---|---|---|
| **TestFlight** (recommended, coming in the next PR) | Apple Developer Program, $99/yr | An App Store Connect API key stored as repo secrets. Builds install through the TestFlight app. |
| Sideload the unsigned IPA | Free | [SideStore](https://sidestore.io) / AltStore re-signs the IPA with your Apple ID. Free-account apps expire every 7 days, and first-time setup needs a computer once. |
| Simulator build in the browser | Free tier | Upload `OneHundo-simulator.zip` to [Appetize.io](https://appetize.io) and run it in mobile Safari. |

## Project layout

```
project.yml                 XcodeGen spec (targets, bundle ID, versions)
OneHundo/                   App source + asset catalog
OneHundoTests/              XCTest unit tests
scripts/                    Helper scripts
.github/workflows/          CI
```
