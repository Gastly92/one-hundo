#!/usr/bin/env bash
# CI's tests, in two steps on separate
# runners:
#   run-tests.sh boot
#     starts the simulator early, so it
#     boots while the build downloads;
#   run-tests.sh build
#     builds the app and tests once;
#   run-tests.sh test <shard>
#     runs one shard of the tests on that
#     build (light, dark, largest, main).
# The shards run in parallel, each on its own
# runner with one simulator (the 3-core
# runner can't run two: tried in #21, the
# second timed out). A failed test prints its
# step-by-step record (taps, waits, what it
# found).
set -euo pipefail

mode="${1:?boot, build or test}"

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
echo "Using simulator $device"

if [ "$mode" = boot ]; then
  # Returns while the simulator boots;
  # xcodebuild waits for it later.
  xcrun simctl boot "$device"
  exit 0
fi

mkdir -p build
common=(
  -project OneHundo.xcodeproj
  -scheme OneHundo
  -destination "id=$device"
  -derivedDataPath build/test
  -enableCodeCoverage YES
  CODE_SIGNING_ALLOWED=NO
)
summary="${GITHUB_STEP_SUMMARY:-/dev/stdout}"
status=0
start=$SECONDS

if [ "$mode" = build ]; then
  xcodebuild build-for-testing \
    "${common[@]}" \
    > build/build.log 2>&1 || status=$?
  if [ "$status" -ne 0 ]; then
    grep -E 'error:' build/build.log \
      || tail -n 60 build/build.log
    exit "$status"
  fi
  echo "Build for testing:" \
    "$((SECONDS - start)) s" >> "$summary"
  exit 0
fi

# Which tests each shard runs: the slow
# accessibility looks get one each (dark,
# the quickest, also takes localization),
# and main takes the rest.
shard="${2:?shard: light, dark, ...}"
ui=OneHundoUITests
a11y="$ui/AccessibilityTests"
case "$shard" in
  light) only=(
    "-only-testing:$a11y/testLight"
  ) ;;
  dark) only=(
    "-only-testing:$a11y/testDark"
    "-only-testing:$ui/LocalizationTests"
  ) ;;
  largest) only=(
    "-only-testing:$a11y/testLargestText"
  ) ;;
  main) only=(
    -only-testing:OneHundoTests
    "-only-testing:$ui"
    "-skip-testing:$a11y"
    "-skip-testing:$ui/LocalizationTests"
  ) ;;
  *)
    echo "::error::Unknown shard $shard"
    exit 1 ;;
esac

# Snapshot tests record any missing images
# (all of them when the PR has the
# `record-snapshots` label), and save the
# images of a failed comparison.
record=missing
if grep -q '"record-snapshots"' \
  <<<"${LABELS:-}"; then
  record=all
fi
echo "Snapshot record mode: $record"
export \
  TEST_RUNNER_SNAPSHOT_TESTING_RECORD="$record"
diffs="$PWD/build/snapshot-diffs"
export \
  TEST_RUNNER_SNAPSHOT_ARTIFACTS="$diffs"

xcodebuild test-without-building \
  "${common[@]}" "${only[@]}" \
  -resultBundlePath build/test.xcresult \
  > build/test.log 2>&1 || status=$?

# Each test's result and errors.
shown='Test Case .*(passed|failed)'
shown+='|error:|\*\* TEST'
grep -E "($shown)" build/test.log || true

echo "Tests ($shard):" \
  "$((SECONDS - start)) s" >> "$summary"

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
