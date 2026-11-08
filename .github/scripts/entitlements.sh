#!/bin/bash
# Fails if the signed app at $1 lacks the
# iCloud (CloudKit) or push entitlements, so
# a TestFlight build never ships without
# them (CI builds unsigned and can't tell).
set -euo pipefail

app="$1"
list=$(mktemp)
codesign -d --entitlements - --xml "$app" \
  > "$list"
plutil -p "$list"
container=iCloud.com.gastly92.onehundo
for key in aps-environment "$container" \
  CloudKit; do
  grep -q "$key" "$list" || {
    echo "::error::$app lacks $key"
    exit 1
  }
done
echo "$app has iCloud and push."
