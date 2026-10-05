#!/usr/bin/env bash
# Coverage gate: every line in the app's non-view code (Models/, Support/) must be
# run by the tests. Views are covered by UI tests and, later, snapshot tests, so
# their numbers are reported but not gated.
set -euo pipefail

result="$1"
report=$(xcrun xccov view --report --json "$result")
files=$(jq -r '.targets[] | select(.name == "OneHundo.app") | .files[]
  | [.path, .coveredLines, .executableLines] | @tsv' <<<"$report")

gated_covered=0
gated_total=0
failed=0
table="| File | Lines | Covered |\n|---|---|---|\n"
while IFS=$'\t' read -r path covered total; do
  [ -n "$path" ] || continue
  name="${path#*/OneHundo/}"
  case "$name" in
    Models/*|Support/*) ;;
    *) continue ;;
  esac
  gated_covered=$((gated_covered + covered))
  gated_total=$((gated_total + total))
  table+="| $name | $total | $covered |\n"
  if [ "$covered" -lt "$total" ]; then
    failed=1
    uncovered=$(xcrun xccov view --archive --file "$path" "$result" \
      | awk -F: '$2 ~ /^ *0( |$)/ { gsub(/ /, "", $1); printf "%s ", $1 }')
    echo "::error file=OneHundo/$name::$((total - covered)) uncovered lines: $uncovered"
  fi
done <<<"$files"

app=$(jq -r '.targets[] | select(.name == "OneHundo.app")
  | "\(.coveredLines)/\(.executableLines) lines (\(.lineCoverage * 100 | floor)%)"' <<<"$report")

{
  echo "### Coverage"
  echo "- Non-view code (gated at 100%): $gated_covered/$gated_total lines"
  echo "- Whole app (report only): $app"
  echo
  printf "%b" "$table"
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

echo "Non-view coverage: $gated_covered/$gated_total; whole app: $app"
if [ "$failed" -ne 0 ] || [ "$gated_total" -eq 0 ]; then
  echo "::error::Non-view code must be 100% covered by tests (see uncovered lines above)."
  exit 1
fi
