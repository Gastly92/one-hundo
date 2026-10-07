#!/bin/bash
# Runs SwiftLint the way CI's SwiftLint job
# does, with the same pinned image, so lint
# errors show up before pushing. Needs
# Docker; starts the daemon if it isn't
# running (as in Claude Code cloud
# sessions). `--prepare` only starts Docker
# and downloads the image.
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
wf=.github/workflows/ios-build.yml
pattern='ghcr.io/realm/swiftlint:[^ ]*'
image="$(grep -o "$pattern" "$root/$wf")"

if ! docker info >/dev/null 2>&1; then
  (dockerd >/tmp/dockerd.log 2>&1 &)
  for _ in $(seq 1 30); do
    docker info >/dev/null 2>&1 && break
    sleep 1
  done
fi

if [ "${1:-}" = "--prepare" ]; then
  docker pull -q "$image" >/dev/null
  exit 0
fi

docker run --rm -v "$root:/work" -w /work \
  --entrypoint swiftlint "$image" \
  lint --strict --quiet --reporter xcode
