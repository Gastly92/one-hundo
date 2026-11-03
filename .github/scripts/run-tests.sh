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
#     build (main, localization).
# The shards run in parallel, each on its own
# runner with one simulator (the 3-core
# runner can't run two: tried in #21, the
# second timed out). A failed test prints its
# step-by-step record (taps, waits, what it
# found).
set -euo pipefail

mode="${1:?boot, build or test}"

# Always this iPhone, on the newest iOS the
# runner has, so snapshots match what most
# phones run. The first iPhone listed was
# any iOS: a runner update could switch it
# silently. SnapshotTests fails when the iOS
# differs from the one the images were drawn
# on (__Snapshots__/iOS.txt).
model="iPhone 17"
pick() {
  local devices query found
  devices=$(
    xcrun simctl list devices available -j
  )
  # Runtimes are keyed like ...iOS-26-5.
  query='[.devices | to_entries[]
    | {v: (.key
        | capture("iOS-(?<v>[0-9-]+)\\b").v
        | split("-") | map(tonumber)),
      d: .value[]}]
    | map(select(.d.name == env.MODEL))
    | max_by(.v)
    | select(. != null)
    | "\(.d.udid) \(.v | map(tostring)
      | join("."))"'
  found=$(MODEL=$model \
    jq -r "$query" <<<"$devices")
  if [ -z "$found" ]; then
    echo "::error::No $model simulator"
    exit 1
  fi
  device=${found% *}
  echo "Using $model on iOS ${found#* }" \
    "($device)"
}
pick

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
# localization check (every screen) on its
# own, and main takes the rest.
shard="${2:?shard: main or localization}"
ui=OneHundoUITests
check="$ui/LocalizationTests"
case "$shard" in
  localization) only=(
    "-only-testing:$check"
  ) ;;
  main) only=(
    -only-testing:OneHundoTests
    "-only-testing:$ui"
    "-skip-testing:$check"
  ) ;;
  *)
    echo "::error::Unknown shard $shard"
    exit 1 ;;
esac

# Snapshot tests record any missing images
# (all of them in the run that adding the
# `record-snapshots` label started:
# RECORD_ALL), and save the images of a
# failed comparison.
record=missing
if [ "${RECORD_ALL:-false}" = true ]; then
  record=all
fi
echo "Snapshot record mode: $record"
export \
  TEST_RUNNER_SNAPSHOT_TESTING_RECORD="$record"
diffs="$PWD/build/snapshot-diffs"
export \
  TEST_RUNNER_SNAPSHOT_ARTIFACTS="$diffs"

# The build's own test plan (.xctestrun), so
# a shard needs no Xcode project.
plan=$(find build/test/Build/Products \
  -name '*.xctestrun' | head -1)
run() {
  rm -rf build/test.xcresult
  status=0
  xcodebuild test-without-building \
    -xctestrun "$plan" \
    -destination "id=$device" \
    -enableCodeCoverage YES \
    "${only[@]}" \
    -resultBundlePath build/test.xcresult \
    > build/test.log 2>&1 || status=$?
}
run

# On CI's simulators the UI test runner
# sometimes fails to start ("Timed out while
# loading Accessibility"), or the simulator
# drops out of the device list ("Unable to
# find a device"), before those tests run.
# Only then, run the shard once more (on a
# freshly picked, booted simulator if it
# dropped out). Any other failure stands.
stuck='failed to initialize for UI testing'
gone='Unable to find a device matching'
started="Test Case '-["
log=build/test.log
if [ "$status" -ne 0 ]; then
  if grep -qF "$stuck" "$log" \
    && ! grep -qF "$started$ui." "$log"; then
    echo "::warning::The UI test runner" \
      "didn't start; running the $shard" \
      "tests once more."
    echo "UI test runner restarted" \
      "($shard)" >> "$summary"
    run
  elif grep -qF "$gone" "$log" \
    && ! grep -qF "$started" "$log"; then
    echo "::warning::The simulator was" \
      "gone; booting one and running the" \
      "$shard tests once more."
    echo "Simulator rebooted ($shard)" \
      >> "$summary"
    pick
    xcrun simctl boot "$device" || true
    run
  fi
fi

# Each test's result and errors, and any
# long-press retried after a stall (see
# `menuItem` in OneHundoUITests).
shown='Test Case .*(passed|failed)'
shown+='|error:|\*\* TEST'
shown+='|Long-press read as a tap'
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
