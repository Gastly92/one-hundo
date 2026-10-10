#!/usr/bin/env bash
# Draws the app icon: a ring with "100"
# inside, in the three versions iOS shows:
# light (a white ring on light blue to
# purple), dark (that gradient as a neon
# ring on black) and tinted (gray, which
# iOS colors). Needs ImageMagick 6 and the
# Inter Display Bold font (both in the
# cloud session). Run from the repo root
# after changing the design; it overwrites
# the PNGs.
set -euo pipefail

font="${ICON_FONT:-/usr/share/fonts/opentype/inter/InterDisplay-Bold.otf}"
out=OneHundo/Assets.xcassets/AppIcon.appiconset
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

size=1024
mid=512
# The ring's radius (to the middle of its
# stroke) and width.
radius=336
width=64
top=$((mid - radius))
circle="circle $mid,$mid $mid,$top"

# A ring in a gradient of $1 (two colors,
# e.g. "#000-#fff"), saved as $2.
ring() {
  convert -size "${size}x$size" \
    -define gradient:angle=135 \
    gradient:"$1" "$tmp/grad.png"
  convert -size "${size}x$size" xc:black \
    -fill none -stroke white \
    -strokewidth "$width" -draw "$circle" \
    "$tmp/mask.png"
  convert "$tmp/grad.png" "$tmp/mask.png" \
    -alpha off -compose CopyOpacity \
    -composite "$2"
}

# Writes "100" over image $1 in color $2,
# flattened (the App Store wants no
# transparency) to $3.
label() {
  convert "$1" -font "$font" \
    -pointsize 230 -fill "$2" \
    -gravity center -annotate +0+6 100 \
    -alpha off -depth 8 "$3"
}

# Dark: the ring glows on black, with a
# bright core line like a neon tube.
ring '#19E3FF-#A23BFF' "$tmp/neon.png"
convert -size "${size}x$size" xc:none \
  -fill none \
  -stroke 'rgba(255,255,255,0.5)' \
  -strokewidth 12 -draw "$circle" \
  -blur 0x4 "$tmp/core.png"
convert "$tmp/neon.png" -channel A \
  -blur 0x28 -evaluate multiply 0.9 \
  +channel "$tmp/halo.png"
convert "$tmp/neon.png" -channel A \
  -blur 0x70 -evaluate multiply 0.6 \
  +channel "$tmp/haze.png"
convert -size "${size}x$size" \
  xc:'#05050A' \
  "$tmp/haze.png" -composite \
  "$tmp/halo.png" -composite \
  "$tmp/neon.png" -composite \
  "$tmp/core.png" -composite \
  "$tmp/dark.png"
label "$tmp/dark.png" white \
  "$out/AppIcon-Dark.png"

# Light: inverted. A white ring glowing on
# deeper colors (white reads better on
# them than on the dark icon's neon).
convert -size "${size}x$size" \
  -define gradient:angle=135 \
  gradient:'#00B4F0-#8B2CF5' "$tmp/deep.png"
convert -size "${size}x$size" \
  xc:'rgba(255,255,255,0)' -fill none \
  -stroke white -strokewidth "$width" \
  -draw "$circle" "$tmp/white.png"
# The glow: white, with the blurred ring
# as its opacity.
convert -size "${size}x$size" xc:white \
  \( "$tmp/mask.png" -blur 0x34 \
  -evaluate multiply 0.75 \) \
  -alpha off -compose CopyOpacity \
  -composite "$tmp/glow.png"
convert "$tmp/deep.png" \
  "$tmp/glow.png" -composite \
  "$tmp/white.png" -composite \
  "$tmp/light.png"
label "$tmp/light.png" white \
  "$out/AppIcon.png"

# Tinted: white on black; iOS colors it.
convert -size "${size}x$size" xc:black \
  "$tmp/mask.png" -compose Screen \
  -composite "$tmp/tint.png"
label "$tmp/tint.png" white \
  "$tmp/tinted.png"
convert "$tmp/tinted.png" -colorspace Gray \
  -depth 8 "$out/AppIcon-Tinted.png"

echo "Wrote the icons to $out."
