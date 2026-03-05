#!/usr/bin/env python3
"""
generate-wallpaper.py — Creates the edpearOS Tokyo Night wallpaper PNG.
Pure Python stdlib — no PIL/Pillow/ImageMagick needed.

Usage: python3 generate-wallpaper.py <output.png> [width] [height]
"""
import sys, struct, zlib, math

W = int(sys.argv[2]) if len(sys.argv) > 2 else 1920
H = int(sys.argv[3]) if len(sys.argv) > 3 else 1080
OUT = sys.argv[1] if len(sys.argv) > 1 else "default.png"

# Tokyo Night color palette
BG      = (26,  27,  38)   # #1a1b26  — background
SURFACE = (36,  40,  59)   # #24283b  — surface
ACCENT  = (122, 162, 247)  # #7aa2f7  — blue accent
PURPLE  = (187, 154, 247)  # #bb9af7  — purple

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

def radial(cx, cy, r, x, y):
    d = math.sqrt((x - cx)**2 + (y - cy)**2)
    return max(0.0, 1.0 - d / r)

rows = []
for y in range(H):
    fy = y / H
    row = bytearray()
    row.append(0)  # filter byte: None
    for x in range(W):
        fx = x / W

        # Base: vertical gradient from BG (top) to slightly lighter SURFACE (bottom)
        base = lerp(BG, SURFACE, fy * 0.35)

        # Subtle blue glow in upper-right
        g1 = radial(W * 0.78, H * 0.18, W * 0.38, x, y) * 0.10
        base = lerp(base, ACCENT, g1)

        # Subtle purple glow in lower-left
        g2 = radial(W * 0.18, H * 0.82, W * 0.32, x, y) * 0.08
        base = lerp(base, PURPLE, g2)

        # Subtle bottom highlight (vignette inverse - brightest near bottom center)
        bc = radial(W * 0.5, H * 1.1, W * 0.55, x, y) * 0.04
        base = lerp(base, SURFACE, bc)

        row += bytes(base)
    rows.append(bytes(row))

# Compress with zlib
raw = b"".join(rows)
compressed = zlib.compress(raw, 9)

def chunk(name, data):
    c = name + data
    return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xFFFFFFFF)

sig    = b"\x89PNG\r\n\x1a\n"
ihdr   = chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
idat   = chunk(b"IDAT", compressed)
iend   = chunk(b"IEND", b"")

with open(OUT, "wb") as f:
    f.write(sig + ihdr + idat + iend)

print(f"[edpearOS] Wallpaper written: {OUT} ({W}x{H})")
