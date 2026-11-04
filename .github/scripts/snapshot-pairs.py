"""Before and after pictures of the snapshot
images the last commit changed, for
snapshot-review.yml.

Writes to <out>: pairs/NN-<image>.png, each
pair side by side (before on the left),
most changed first, and list.md, every
changed image with the share of its pixels
that visibly changed.

Usage: snapshot-pairs.py <out>
"""

import subprocess
import sys
from io import BytesIO
from pathlib import Path

from PIL import Image, ImageChops

ROOT = "OneHundoTests/__Snapshots__/"
# Pairs drawn; the rest are only listed.
SHOWN = 20
# A pair's height at most, in pixels.
HEIGHT = 1400
# A channel this far off counts as changed
# (below it: noise between runners).
NOISE = 16
GAP = 24


def git(*args: str) -> bytes:
    return subprocess.run(
        ["git", *args],
        check=True,
        capture_output=True,
    ).stdout


def changed() -> list[str]:
    out = git(
        "diff", "--name-only",
        "HEAD~1", "HEAD", "--", ROOT,
    ).decode()
    return [
        path for path in out.split()
        if path.endswith(".png")
    ]


def before(path: str) -> Image.Image | None:
    """The image before the commit, if any
    (None for a new screen)."""
    try:
        data = git("show", f"HEAD~1:{path}")
    except subprocess.CalledProcessError:
        return None
    return Image.open(BytesIO(data)).convert(
        "RGB"
    )


def share(
    old: Image.Image | None,
    new: Image.Image,
) -> float:
    """The share of pixels that changed: all
    of them for a new or resized image."""
    if old is None or old.size != new.size:
        return 1.0
    diff = ImageChops.difference(old, new)
    hist = diff.convert("L").histogram()
    total = new.width * new.height
    return sum(hist[NOISE:]) / total


def fit(image: Image.Image) -> Image.Image:
    if image.height <= HEIGHT:
        return image
    width = image.width * HEIGHT // image.height
    return image.resize((width, HEIGHT))


def pair(
    old: Image.Image | None,
    new: Image.Image,
) -> Image.Image:
    right = fit(new)
    left = fit(old) if old else None
    width = right.width
    if left:
        width += left.width + GAP
    height = max(
        right.height,
        left.height if left else 0,
    )
    out = Image.new(
        "RGB", (width, height), "white"
    )
    if left:
        out.paste(left, (0, 0))
        out.paste(right, (left.width + GAP, 0))
    else:
        out.paste(right, (0, 0))
    return out


def main() -> None:
    out = Path(sys.argv[1])
    (out / "pairs").mkdir(parents=True)
    rows = []
    for path in changed():
        new = Image.open(path).convert("RGB")
        old = before(path)
        rows.append(
            (share(old, new), path, old, new)
        )
    rows.sort(key=lambda row: -row[0])
    lines = [
        "| Image | Changed | Pair |",
        "|---|---|---|",
    ]
    for n, row in enumerate(rows, 1):
        part, path, old, new = row
        name = Path(path).stem
        shown = ""
        if n <= SHOWN:
            shown = f"pairs/{n:02}-{name}.png"
            pair(old, new).save(out / shown)
        note = " (new)" if old is None else ""
        lines.append(
            f"| `{name}`{note} "
            f"| {part:.2%} | {shown} |"
        )
    total = len(rows)
    head = (
        f"{total} snapshot images changed; "
        f"the {min(total, SHOWN)} most "
        "changed are drawn in pairs/.\n\n"
    )
    (out / "list.md").write_text(
        head + "\n".join(lines) + "\n"
    )


if __name__ == "__main__":
    main()
