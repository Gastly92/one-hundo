#!/bin/bash
# Claude Code cloud sessions: install the
# workflow and script checkers CI runs, so
# they can run before pushing.
set -euo pipefail

remote="${CLAUDE_CODE_REMOTE:-}"
[ "$remote" = "true" ] || exit 0

root="$CLAUDE_PROJECT_DIR"
venv="$HOME/.cache/onehundo-venv"
if [ ! -x "$venv/bin/pip" ]; then
  python3 -m venv "$venv"
fi
"$venv/bin/pip" install -q \
  --disable-pip-version-check \
  -r "$root/.github/scripts/checkers.txt"
echo "export PATH=\"$venv/bin:\$PATH\"" \
  >> "$CLAUDE_ENV_FILE"

# SwiftLint runs in Docker: start it and
# fetch the image in the background so the
# first lint is quick.
lint="$root/.github/scripts/swiftlint.sh"
(nohup "$lint" --prepare >/dev/null 2>&1 &)
