#!/usr/bin/env bash
# Coverage gate: every line in the app's
# non-view code (Models/, Support/) must be
# run by the tests, and views (run by UI and
# snapshot tests) must stay at VIEW_MIN% or
# more. Raise VIEW_MIN as views gain tests;
# never lower it.
set -euo pipefail

result="$1"
VIEW_MIN=97
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
low_views=0
view_cov=0
view_all=0
views="| View file | Lines | Covered |\n"
views+="|---|---|---|\n"
failed=0
table="| File | Lines | Covered |\n"
table+="|---|---|---|\n"
while IFS=$'\t' read -r path covered total
do
  [ -n "$path" ] || continue
  name="${path#*/OneHundo/}"
  case "$name" in
    Models/*|Support/*) ;;
    *)
      view_cov=$((view_cov + covered))
      view_all=$((view_all + total))
      if [ "$covered" -lt "$total" ]; then
        views+="| $name | $total |"
        views+=" $covered |\n"
      fi
      continue
      ;;
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

view_pct=0
if [ "$view_all" -gt 0 ]; then
  view_pct=$((view_cov * 100 / view_all))
fi

{
  echo "### Coverage"
  echo "- Non-view code (gated at 100%):" \
    "$sum_cov/$sum_all lines"
  echo "- Views (gated at $VIEW_MIN%):" \
    "$view_cov/$view_all lines" \
    "($view_pct%)"
  echo "- Whole app: $whole"
  echo
  printf "%b" "$table"
  echo
  echo "View files with untested lines:"
  echo
  printf "%b" "$views"
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

echo "Non-view coverage: $sum_cov/$sum_all;" \
  "views: $view_cov/$view_all" \
  "($view_pct%); whole app: $whole"
if [ "$view_pct" -lt "$VIEW_MIN" ]; then
  echo "::error::View coverage is" \
    "$view_pct%, below $VIEW_MIN%. Test the" \
    "new screens or branches (see the CI" \
    "summary for which files)."
  low_views=1
fi
if [ "$failed" -ne 0 ] \
  || [ "$sum_all" -eq 0 ]; then
  echo "::error::Non-view code must be" \
    "100% covered by tests (see uncovered" \
    "lines above)."
  exit 1
fi
[ "$low_views" -eq 0 ] || exit 1
