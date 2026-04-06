#!/usr/bin/env python3
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
out = ROOT / 'assets' / 'generated' / 'mesh_cube.inc'
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text('; placeholder generated mesh include\n', encoding='utf-8')
print('generated mesh include placeholder')
