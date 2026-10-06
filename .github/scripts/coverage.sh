#!/usr/bin/env bash
# Coverage gate: every line in the app's
# non-view code (Models/, Support/) must be
# run by the tests. Views are covered by UI
# tests and, later, snapshot tests, so their
# numbers are reported but not gated.
set -euo pipefail

result="$1"
# The JSON report lists every file's
# functions with their line counts.
report=$(
  xcrun xccov view --report --json "$result"
)
# A jq function picking the app target.
pick='def app: .targets[]
  | select(.name == "OneHundo.app");'

files=$(jq -r "$pick"' app | .files[]
  | [.path, .coveredLines,
     .executableLines] | @tsv' \
  <<<"$report")

sum_cov=0
sum_all=0
failed=0
table="| File | Lines | Covered |\n"
table+="|---|---|---|\n"
while IFS=$'\t' read -r path covered total
do
  [ -n "$path" ] || continue
  name="${path#*/OneHundo/}"
  case "$name" in
    Models/*|Support/*) ;;
    *) continue ;;
  esac
  sum_cov=$((sum_cov + covered))
  sum_all=$((sum_all + total))
  table+="| $name | $total | $covered |\n"
  if [ "$covered" -lt "$total" ]; then
    failed=1
    # Name each function with untested
    # lines, and the line it starts on.
    gaps=$(jq -r --arg path "$path" "$pick"'
      app | .files[]
      | select(.path == $path)
      | (.functions // [])[]
      | select(.coveredLines
        < .executableLines)
      | (.executableLines
        - .coveredLines) as $n
      | "\(.name) (line \(.lineNumber)): "
        + "\($n) untested"' \
      <<<"$report")
    untested=$((total - covered))
    file="OneHundo/$name"
    echo "::error file=$file::$name" \
      "has $untested untested lines"
    while IFS= read -r gap; do
      [ -n "$gap" ] && echo "  $name: $gap"
    done <<<"$gaps"
  fi
done <<<"$files"

whole=$(jq -r "$pick"' app
  | (.lineCoverage * 100 | floor) as $pct
  | "\(.coveredLines)/\(.executableLines)"
    + " lines (\($pct)%)"' <<<"$report")

{
  echo "### Coverage"
  echo "- Non-view code (gated at 100%):" \
    "$sum_cov/$sum_all lines"
  echo "- Whole app (report only): $whole"
  echo
  printf "%b" "$table"
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

echo "Non-view coverage: $sum_cov/$sum_all;" \
  "whole app: $whole"
if [ "$failed" -ne 0 ] \
  || [ "$sum_all" -eq 0 ]; then
  echo "::error::Non-view code must be" \
    "100% covered by tests (see uncovered" \
    "lines above)."
  exit 1
fi
