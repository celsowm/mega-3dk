#!/usr/bin/env python3
from math import sin, pi
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "generated"
OUT.mkdir(parents=True, exist_ok=True)

COUNT = 1024
FIX = 1 << 16

with open(OUT / "sin_lut.inc", "w", encoding="utf-8") as f:
    f.write("sin_lut:\n")
    for i in range(COUNT):
        v = int(round(sin((i / COUNT) * 2 * pi) * FIX))
        f.write(f"    dc.l {v}\n")

with open(OUT / "recip_lut.inc", "w", encoding="utf-8") as f:
    f.write("recip_lut:\n")
    f.write(f"    dc.l {FIX}\n")
    for i in range(1, COUNT):
        v = int(round(FIX / i))
        f.write(f"    dc.l {v}\n")

with open(OUT / "y_offset_lut.inc", "w", encoding="utf-8") as f:
    f.write("y_offset_lut:\n")
    for y in range(112): # RENDER_H
        v = y * 80       # RENDER_W / 2
        f.write(f"    dc.w {v}\n")
