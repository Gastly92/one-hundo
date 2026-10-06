#!/usr/bin/env bash
# Every screen must be in the screen list, so the accessibility audit and the
# localization check (which loop over ScreenID) cover it. A screen is a top-level
# `struct Name: View` in OneHundo/Views/Screens/; ScreenHost must show it.
set -euo pipefail

host=OneHundo/Views/ScreenHost.swift
missing=0
count=0
for file in OneHundo/Views/Screens/*.swift; do
  for name in $(grep -oE '^struct [A-Za-z0-9_]+: View' "$file" | awk '{print $2}' | tr -d ':'); do
    count=$((count + 1))
    if ! grep -qE "\\b${name}\\b" "$host"; then
      echo "::error file=$file::$name is a screen but isn't in the screen list. Add a" \
        "ScreenID case for it and show it in ScreenHost (see CLAUDE.md)."
      missing=1
    fi
  done
done
echo "Checked $count screens against $host."
exit "$missing"
