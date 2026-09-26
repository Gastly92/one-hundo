"""Writes a 1024x1024 opaque placeholder app icon (orange with a white ring).

Pure stdlib so it runs anywhere; replace AppIcon.png with a real icon later.
"""
import math
import struct
import sys
import zlib

SIZE = 1024
BG = (250, 107, 46)
FG = (255, 255, 255)


def pixel(x, y):
    r = math.hypot(x - SIZE / 2, y - SIZE / 2)
    return FG if 300 <= r <= 380 else BG


def chunk(tag, data):
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def main(path):
    rows = b"".join(b"\x00" + b"".join(bytes(pixel(x, y)) for x in range(SIZE)) for y in range(SIZE))
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(rows, 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "OneHundo/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
