"""Generates FarmMap's UI frame textures: plain rounded rectangles.

No drawing and no image model is involved. Each pixel's opacity is computed
from geometry alone - how much of the pixel lies inside a rectangle with
rounded corners, the same shape CSS draws with `border-radius`. Run it again
and you get the same files, byte for byte.

The textures are WHITE. The game tints them with SetVertexColor, so a single
file serves every colour theme. They are cut in nine by the game (nine-slice):
the four corners keep their size, the edges and the centre stretch, and one
small texture frames a window of any size without distorting its corners.

Written with AI assistance, like the rest of FarmMap's code.

Usage:  python tools/make_frame_textures.py
Output: Textures/ui/*.tga   (32-bit, uncompressed - the TGA flavour WoW reads)
Only the Python standard library is needed.
"""

import os
import struct

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "Textures", "ui")

# Sub-pixel samples per axis. 4 x 4 = 16 samples per pixel is plenty for a
# smooth edge on shapes this small.
SAMPLES = 4

# name, texture size (power of two, WoW requires it), corner radius,
# border thickness (0 = filled shape), all in pixels.
SHAPES = [
    ("frame-fill",   32, 8, 0),   # panel and window backgrounds
    ("frame-border", 32, 8, 1),   # their 1 px outline
    ("tag-fill",     16, 3, 0),   # the small "New" / "Fixes" labels
    ("tag-border",   16, 3, 1),
]


def inside_rounded_rect(x, y, size, radius):
    """True when point (x, y) lies inside a size x size square whose corners
    are rounded with the given radius."""
    if x < 0 or y < 0 or x > size or y > size:
        return False
    # Distance into the nearest corner box, if the point is in one.
    cx = radius - x if x < radius else (x - (size - radius) if x > size - radius else 0)
    cy = radius - y if y < radius else (y - (size - radius) if y > size - radius else 0)
    if cx > 0 and cy > 0:
        return cx * cx + cy * cy <= radius * radius
    return True


def coverage(px, py, size, radius, thickness):
    """Share of pixel (px, py) covered by the shape, from 0.0 to 1.0."""
    hits = 0
    for sy in range(SAMPLES):
        for sx in range(SAMPLES):
            x = px + (sx + 0.5) / SAMPLES
            y = py + (sy + 0.5) / SAMPLES
            if not inside_rounded_rect(x, y, size, radius):
                continue
            if thickness > 0:
                # Outline only: drop what is also inside the same shape,
                # shrunk by the thickness on every side.
                inner = size - 2 * thickness
                inner_radius = max(radius - thickness, 0)
                if inside_rounded_rect(x - thickness, y - thickness, inner, inner_radius):
                    continue
            hits += 1
    return hits / (SAMPLES * SAMPLES)


def write_tga(path, size, alphas):
    """Uncompressed 32-bit TGA, top-left origin, white pixels with the given
    alpha values (0-255, row by row from the top)."""
    header = struct.pack(
        "<BBBHHBHHHHBB",
        0,      # no image ID
        0,      # no colour map
        2,      # uncompressed true-colour
        0, 0, 0,                # colour map spec (unused)
        0, 0,                   # x / y origin
        size, size,             # width, height
        32,                     # bits per pixel
        0x28,                   # 8 alpha bits, top-left origin
    )
    with open(path, "wb") as f:
        f.write(header)
        for a in alphas:
            f.write(bytes((255, 255, 255, a)))   # B, G, R, A


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, size, radius, thickness in SHAPES:
        alphas = []
        for py in range(size):
            for px in range(size):
                alphas.append(round(coverage(px, py, size, radius, thickness) * 255))
        path = os.path.join(OUT_DIR, name + ".tga")
        write_tga(path, size, alphas)
        print("wrote", os.path.normpath(path))


if __name__ == "__main__":
    main()
