# iOS updates for the snapshots

The snapshots are drawn on one iOS, saved
in `OneHundoTests/__Snapshots__/iOS.txt`
(see CLAUDE.md). When GitHub's runners get
a newer iOS, CI moves to it in a PR you
review, never on its own.

## What happens
1. A run on `main` finds a newer iOS on the
   runner (`run-tests.sh`, in the build
   job). The `iOS update` job
   (`ios-update.sh`) opens a PR from
   `snapshots/ios-<version>` that sets
   `iOS.txt`, adds the `record-snapshots`
   label and assigns you, so GitHub emails
   you. One PR per iOS version, ever.
2. CI draws every image again on the new
   iOS and commits them to the PR.
   If GitHub is still rolling out the
   runner image with that iOS, a run can
   land on an older runner: recording then
   fails with "isn't on this runner yet".
   Re-run the failed jobs a day or two
   later.
3. `snapshot-review.yml` pairs each changed
   image with its old version, most
   changed first, and Claude comments on
   the PR: what iOS changed, and anything
   that looks like a bug in the app.
4. You look at the images and merge (every
   PR then draws on the new iOS) or close
   the PR to stay on the current one.

## Setup (once)
- **Snapshot app:** it needs **Pull
  requests: Read and write** to open the
  PR (docs/SNAPSHOT-APP.md). Without it,
  the `iOS update` job's "Open the PR"
  step fails (without failing the run),
  and the build log only warns.
- **Claude:** add one repo secret (Settings
  → Secrets and variables → Actions → New
  repository secret):
  - `ANTHROPIC_API_KEY`: a key from
    console.anthropic.com (API Keys),
    billed per use to that account. Works
    from a phone's browser.
  - or `CLAUDE_CODE_OAUTH_TOKEN`: from
    `claude setup-token`, billed to a
    Claude subscription.

  Either can be replaced later to bill
  another account. Without a secret, the
  comment only lists the changed images.
