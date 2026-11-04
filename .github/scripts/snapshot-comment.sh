#!/usr/bin/env bash
# The comment snapshot-review.yml posts on
# an iOS update PR: Claude's review (or why
# there is none) and the changed images. A
# Claude secret that stopped working (key
# revoked or out of credit, token expired)
# shows as a warning here, on the PR the
# owner is emailed about.
# Usage: snapshot-comment.sh <dir>, with
# HAS_CLAUDE, RAN (the review step's
# outcome), RUN (this run's URL), BRANCH
# and GH_TOKEN.
set -euo pipefail

out=$1
docs=docs/IOS-UPDATES.md
{
  if [ -f "$out/review.md" ]; then
    echo "## Claude's review"
    echo
    cat "$out/review.md"
  elif [ "$HAS_CLAUDE" != true ]; then
    echo "No Claude review: no Claude" \
      "secret is set ($docs)."
  else
    echo "> [!WARNING]"
    echo "> **Claude's review failed**" \
      "($RAN). The Claude secret may be" \
      "revoked, out of credit or expired:" \
      "see [the run]($RUN). Fix the" \
      "secret ($docs), then run the" \
      "Snapshot review workflow on this" \
      "branch again."
    echo "::warning::Claude's review" \
      "failed; see the PR comment." >&2
  fi
  echo
  echo "## Changed images"
  echo
  cat "$out/list.md"
} > "$out/comment.md"
gh pr comment "$BRANCH" \
  --body-file "$out/comment.md"
