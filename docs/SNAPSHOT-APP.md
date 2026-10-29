# Snapshot app

When CI records new snapshot images, it
pushes them to the PR branch. A push made
with CI's own token (`GITHUB_TOKEN`) starts
no CI run; since June 2026 GitHub instead
holds one behind "Approve and run". So CI
pushes with a token from a small GitHub App
installed on this repo: that push starts CI
like any other. The app's key doesn't
expire; each run gets a one-hour token from
it (`actions/create-github-app-token`).

Without the app's secrets (or on Dependabot
PRs, which can't read them),
`save-snapshots.sh` pushes with CI's own
token and starts the run itself, and
GitHub's held run shows "Approve and run":
it needs no approval.

## Setting it up
1. Open github.com/settings/apps/new.
2. Name: e.g. `one-hundo-snapshots` (names
   are unique across GitHub). Homepage URL:
   the repo's URL.
3. Webhook: untick **Active**.
4. Repository permissions → **Contents**:
   **Read and write**. Leave the rest.
5. Where can it be installed: **Only on
   this account**. Tap **Create GitHub
   App**.
6. On the app's page, note the **App ID**.
   Under **Private keys**, tap **Generate a
   private key** (a `.pem` file downloads).
7. **Install App** → **Install** → **Only
   select repositories** → `one-hundo`.
8. In the repo: Settings → Secrets and
   variables → Actions → New repository
   secret:
   - `SNAPSHOT_APP_ID`: the App ID.
   - `SNAPSHOT_APP_KEY`: all the text of
     the `.pem` file (in Files, rename it to
     end in `.txt` to open it), including
     the `-----BEGIN` and `-----END` lines.
9. Delete the `.pem` file from Files.

If the key is ever lost or leaked, generate
a new one on the app's page, update
`SNAPSHOT_APP_KEY`, and delete the old key.
