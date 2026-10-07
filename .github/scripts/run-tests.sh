#!/usr/bin/env bash
# Builds for testing, then runs the tests,
# timing each. One simulator: the 3-core
# runner can't run two (tried in #21: the
# second timed out, the first slowed 4x).
# A failed test prints its step-by-step
# record (taps, waits, what it found).
set -euo pipefail

# The first available iPhone simulator.
devices=$(
  xcrun simctl list devices available -j
)
pick='[.devices | to_entries[]
  | select(.key | contains("iOS"))
  | .value[]
  | select(.name | startswith("iPhone"))
  ][0].udid // empty'
device=$(jq -r "$pick" <<<"$devices")
if [ -z "$device" ]; then
  echo "::error::No iPhone simulator found"
  exit 1
fi
echo "Testing on simulator $device"

mkdir -p build

# Snapshot tests record any missing images
# (all of them when the PR has the
# `record-snapshots` label), and save the
# images of a failed comparison.
mode=missing
if grep -q '"record-snapshots"' \
  <<<"${LABELS:-}"; then
  mode=all
fi
echo "Snapshot record mode: $mode"
export \
  TEST_RUNNER_SNAPSHOT_TESTING_RECORD="$mode"
diffs="$PWD/build/snapshot-diffs"
export \
  TEST_RUNNER_SNAPSHOT_ARTIFACTS="$diffs"
common=(
  -project OneHundo.xcodeproj
  -scheme OneHundo
  -destination "id=$device"
  -derivedDataPath build/test
  -enableCodeCoverage YES
  -enableThreadSanitizer YES
  CODE_SIGNING_ALLOWED=NO
)
status=0
start=$SECONDS
xcodebuild build-for-testing "${common[@]}" \
  > build/build.log 2>&1 || status=$?
built=$SECONDS
if [ "$status" -ne 0 ]; then
  grep -E 'error:' build/build.log \
    || tail -n 60 build/build.log
  exit "$status"
fi

xcodebuild test-without-building \
  "${common[@]}" \
  -resultBundlePath build/test.xcresult \
  > build/test.log 2>&1 || status=$?
tested=$SECONDS

# Each test's result, errors and races.
shown='Test Case .*(passed|failed)'
shown+='|error:|ThreadSanitizer|\*\* TEST'
grep -E "($shown)" build/test.log || true

{
  echo "### Test timings"
  echo "| Phase | Seconds |"
  echo "|---|---|"
  echo "| Build for testing |" \
    "$((built - start)) |"
  echo "| Run tests | $((tested - built)) |"
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

if [ "$status" -ne 0 ]; then
  awk '
    /Test Case .* started/ { buf = "" }
    { buf = buf "\n" $0 }
    /Test Case .* failed/ {
      print "::group::" $0
      print buf
      print "::endgroup::"
    }' build/test.log
  tail -n 60 build/test.log
fi
exit "$status"
