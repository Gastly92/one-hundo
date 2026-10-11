#!/usr/bin/env bash
# Draws the App Store product page header
# (docs/appstore/header.png, 5244 x 2950):
# the light app icon's glowing white ring
# and "100", then "One Hundo" and the
# subtitle, on the icon's gradient. All of
# it sits in the middle, inside the widest
# crop (3840 x 1646's shape), as Apple's
# asset guidance asks. Needs ImageMagick 6
# and Inter Display (both in the cloud
# session). Run from the repo root after
# changing the design or the subtitle.
set -euo pipefail

fonts=/usr/share/fonts/opentype/inter
bold="$fonts/InterDisplay-Bold.otf"
medium="$fonts/InterDisplay-Medium.otf"
out=docs/appstore/header.png
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

w=5244
h=2950
mid=$((w / 2))
# The ring: centre height, radius (to the
# middle of its stroke) and width, in the
# same shape as the icon's (336 and 64 of
# 1024).
y=1130
radius=420
width=80
circle="circle $mid,$y $mid,$((y - radius))"

convert -size "${w}x$h" \
  -define gradient:angle=135 \
  gradient:'#00B4F0-#8B2CF5' "$tmp/bg.png"
convert -size "${w}x$h" xc:black \
  -fill none -stroke white \
  -strokewidth "$width" -draw "$circle" \
  "$tmp/mask.png"
# The glow: white, with the blurred ring as
# its opacity.
convert -size "${w}x$h" xc:white \
  \( "$tmp/mask.png" -blur 0x44 \
  -evaluate multiply 0.75 \) \
  -alpha off -compose CopyOpacity \
  -composite "$tmp/glow.png"
convert -size "${w}x$h" xc:none \
  -fill none -stroke white \
  -strokewidth "$width" -draw "$circle" \
  "$tmp/ring.png"

# Text is placed from the centre, so +0+N
# is N below the middle.
convert "$tmp/bg.png" \
  "$tmp/glow.png" -composite \
  "$tmp/ring.png" -composite \
  -gravity center -fill white \
  -font "$bold" -pointsize 290 \
  -annotate "+0+$((y - h / 2 + 8))" 100 \
  -pointsize 300 \
  -annotate +0+355 'One Hundo' \
  -font "$medium" -pointsize 150 \
  -fill 'rgba(255,255,255,0.88)' \
  -annotate +0+640 \
  'Get to 100, one day at a time' \
  -alpha off -depth 8 "$out"

echo "Wrote $out."
