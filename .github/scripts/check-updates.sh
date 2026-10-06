#!/usr/bin/env bash
# Opens a GitHub issue when a Swift package
# pinned in project.yml has a newer release.
# Dependabot can't see these: XcodeGen keeps
# them in project.yml, not a Package.swift.
# Needs GH_TOKEN (issues: write).
set -euo pipefail

# Pairs of url and exactVersion lines.
pins=$(grep -A1 '^    url: ' project.yml \
  | grep -E 'url:|exactVersion:' \
  | awk '{print $2}' | paste - -)

while read -r url pinned; do
  [ -n "$url" ] || continue
  name=$(basename "$url")
  latest=$(
    git ls-remote --tags --refs "$url" \
      | sed 's#.*refs/tags/##' \
      | grep -E '^v?[0-9]+(\.[0-9]+)*$' \
      | sort -V | tail -n 1
  )
  latest=${latest#v}
  echo "$name: pinned $pinned, latest $latest"
  [ "$latest" != "$pinned" ] || continue

  title="Update $name to $latest"
  open=$(gh issue list --state open \
    --search "\"$title\" in:title" \
    --json number --jq length)
  if [ "$open" != "0" ]; then
    echo "Issue already open."
    continue
  fi
  body="$name $latest is out (pinned:"
  body+=" $pinned). Bump exactVersion in"
  body+=" project.yml, then re-record"
  body+=" snapshots if they change."
  gh issue create --title "$title" \
    --body "$body"
done <<<"$pins"
