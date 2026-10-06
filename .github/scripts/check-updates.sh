#!/usr/bin/env bash
# Notes in the CI summary when a Swift
# package pinned in project.yml has a newer
# release. Dependabot can't see these:
# XcodeGen keeps them in project.yml, not a
# Package.swift. Never fails the build.
set -euo pipefail

# Pairs of url and exactVersion lines.
pins=$(grep -A1 '^    url: ' project.yml \
  | grep -E 'url:|exactVersion:' \
  | awk '{print $2}' | paste - -)

while read -r url pinned; do
  [ -n "$url" ] || continue
  name=$(basename "$url")
  latest=$(
    { git ls-remote --tags --refs "$url" \
      || true; } | sed 's#.*refs/tags/##' \
      | grep -E '^v?[0-9]+(\.[0-9]+)*$' \
      | sort -V | tail -n 1 || true
  )
  latest=${latest#v}
  if [ -z "$latest" ]; then
    echo "$name: couldn't list releases."
    continue
  fi
  echo "$name: pinned $pinned, latest $latest"
  [ "$latest" != "$pinned" ] || continue
  echo "::notice::$name $latest is out" \
    "(pinned $pinned). Bump exactVersion" \
    "in project.yml when convenient."
done <<<"$pins"
