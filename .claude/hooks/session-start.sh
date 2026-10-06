#!/bin/bash
# Claude Code cloud sessions: install the
# workflow and script checkers CI runs, so
# they can run before pushing, and report
# pinned packages with newer releases.
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

# Printed output reaches Claude at session
# start, so a newer pinned package gets
# noticed (CI only shows it as a notice).
cd "$root"
.github/scripts/check-updates.sh \
  | sed 's/^::notice:://' || true
