# AI Agent Guide — mega-3dk

Lessons learned and architectural notes for AI agents working on this Mega Drive 3D engine.

---

## Build System

### Makefile
The Makefile performs real assembly and emulator launch. Key targets:

| Target | Description |
|--------|-------------|
| `make build` | Run asset generators + assemble ROM with vasm |
| `make run` | Launch BlastEm emulator with the ROM |
| `make screenshot` | Launch BlastEm and auto-send `P` for a screenshot |
| `make dev` | Build + run in one step |
| `make clean` | Remove build artifacts |
| `make bootstrap` | Download/compile vasm toolchain |
| `make emulator` | Download BlastEm |
| `make info` | Print paths for vasm, ROM, BlastEm |

### Toolchain
- **Assembler:** `toolchain/vasm/vasmm68k_mot.exe` (Motorola syntax, flat binary output)
- **Emulator:** `emulator/blastem-win64-0.6.3-pre/blastem.exe`
- **Asset generators:** `tools/gen_lut.py` (sin/recip LUTs), `tools/pack_mesh.py` (mesh data)
- **Screenshot helper:** `scripts/screenshot-windows.ps1` launches BlastEm, waits 2 seconds, focuses the window, and sends `P`

### Include paths
vasm needs `-I` flags for every source subdirectory. The assembler uses a single-file include model (`boot.asm` includes everything), not separate object linking. All `xref`/`xdef` warnings are harmless in this mode.

### Windows note
`make` is installed via `winget install GnuWin32.Make` at `C:\Program Files (x86)\GnuWin32\bin\make.exe`. It may not be on PATH by default.

---

## Architecture Overview

```
boot.asm          Entry point, includes all other files
  ├── vectors.asm   68000 vector table (SSP + reset vector)
  ├── header.asm    Mega Drive ROM header at $100
  └── main.asm      Init + per-frame dispatch
```

### Per-frame pipeline (`main_frame`)
1. `wait_vblank` — poll VDP status register for VBlank
2. `pad_read` — read controller input
3. `scene_bench_update` — update rotation angles from input/auto-rotate
4. `clear_color_buffer` — zero the 160×112 4bpp framebuffer
5. `transform_mesh_vertices` — 3D transform + perspective projection
6. `draw_scene_wire` — Bresenham line drawing for all edges
7. `present_frame` — pack framebuffer into VDP tiles + upload via CPU

---

## Memory Map (Work RAM $FF0000–$FFFFFF)

Key buffers defined in `src/core/memory_map.inc`:

| Symbol | Offset | Size | Description |
|--------|--------|------|-------------|
| `pad_*` | $0000 | 8B | Controller state (prev, cur, press, release) |
| `scene_rot_*` | $0010 | 6B | Rotation angles (X, Y, Z) as words |
| `color_buffer` | $0040 | 8960B | 160×112 4bpp packed framebuffer |
| `cam_vertices` | $2340 | | Camera-space vertices (VERT3: 12 bytes each) |
| `proj_vertices` | $2940 | | Screen-space vertices (VERT2: 8 bytes each) |
| `present_tile_buffer` | $3998 | 8960B | Packed VDP tiles (20×14 × 32 bytes) |
| `present_name_table` | $5EC8 | 1792B | VDP plane A name table (32×28 words) |
| `STACK_TOP` | $FFFC | | Stack grows downward from here |

---

## Common Pitfalls

### 1. Register clobbering in indexed access
When reading multiple struct fields with `(a1,d0.w)` indexing, **read the field that does NOT go into the index register last**. Otherwise the index is destroyed.

```asm
; WRONG — d0 is overwritten by X, then used as index for Y
move.w  VERT2_X(a1,d0.w),d0
move.w  VERT2_Y(a1,d0.w),d1    ; BUG: d0 is now X, not offset

; CORRECT — read Y first (into d1), then X last (into d0, destroying offset)
move.w  VERT2_Y(a1,d0.w),d1
move.w  VERT2_X(a1,d0.w),d0
```

### 2. Preserve intermediate values across subroutine calls
`fixed_mul_16_16` destroys d0 and d1. `lut_sin`/`lut_cos`/`lut_recip` destroy d0 and a0. Save any value you need later in a callee-safe register (d2–d7, a2–a6) before calling these.

Example: save `x1` in `d5` instead of recomputing it after calling `fixed_mul` and `lut_recip`.

### 3. VDP name table layout must match plane width
The VDP plane is **32 tiles wide** (with `$9000` plane size register). The name table is a 2D array in VRAM with 32-word rows, NOT a flat linear array.

```
; WRONG — flat array wraps tiles into wrong rows
tile 0  1  2 ... 19 | 20 21 ... 31    ← row 0 plus start of row 1!

; CORRECT — pad each row to 32 entries
tile 0  1 ... 19  0  0 ... 0          ← row 0 (20 tiles + 12 zeros)
tile 20 21 ... 39 0  0 ... 0          ← row 1
```

### 4. Center the render area on screen
H40 mode displays 40×28 tiles (320×224 pixels). A 20×14 tile render area must be offset:
- Horizontal: `(40 − 20) / 2 = 10` tiles
- Vertical: `(28 − 14) / 2 = 7` tiles

Write tile references at the correct offset in the name table, and **clear the entire plane** to avoid stale data appearing as wrapping artifacts.

### 5. Fixed-point multiply precision
`fixed_mul_16_16` uses an approximate method: `(a >> 8) * (b >> 8)` via `muls.w`. This works for moderate values but loses precision for very small numbers. The shift-8 approach means:
- Values must fit in signed 16-bit after `>> 8` (i.e., magnitude < ~8,388,608 in 16.16)
- Very small values (< 256 in raw fixed-point, i.e., < 0.004) round to zero

### 6. Projection scale matters
With `PROJ_DISTANCE = F` and `CAMERA_Z_BIAS = Z`, a unit cube (±1.0 vertices) projects to roughly `±F/Z` pixels from center. If this is too small (e.g., F=3, Z=5 → ±0.6px), the cube is invisible. Current working value: **F = 64.0 (4194304 in 16.16)**.

### 7. Exception vectors
All 62 exception vectors in `vectors.asm` are zero (`ds.l 62,0`). Any exception (bus error, address error, illegal instruction) will jump to address 0 and freeze. If you see a freeze at a weird address, the CPU likely took an exception. Consider adding a panic handler.

---

## Data Formats

### Vertex3 (camera space) — 12 bytes
```
Offset 0: X (long, 16.16 fixed-point)
Offset 4: Y (long, 16.16 fixed-point)
Offset 8: Z (long, 16.16 fixed-point)
```

### Vertex2 (screen space) — 8 bytes
```
Offset 0: X (word, integer pixels)
Offset 2: Y (word, integer pixels)
Offset 4: Z (long, 16.16 depth for sorting)
```

### Edge — 4 bytes
```
Offset 0: vertex index 0 (word)
Offset 2: vertex index 1 (word)
```

### Mesh descriptor
```
Offset 0: pointer to vertex array (long)
Offset 4: pointer to face array (long)
Offset 8: vertex count (word)
Offset 10: face count (word)
```

### Color buffer
- 160×112 pixels at 4 bits per pixel (2 pixels per byte)
- High nibble = left pixel, low nibble = right pixel
- Row stride = `RENDER_W / 2 = 80` bytes
- Total = 8960 bytes
- Format matches Genesis VDP tile pixel packing

---

## VDP Configuration

| Register | Value | Meaning |
|----------|-------|---------|
| Mode 1 | $8004 | Normal mode |
| Mode 2 | $8174 | Display on, VBlank IRQ off, V28 (224px) |
| Mode 4 | $8C81 | H40 mode (320px wide) |
| Plane A | $8230 | Name table at VRAM $C000 |
| Plane B | $8407 | Name table at VRAM $E000 |
| Plane size | $9000 | 32×32 tiles |
| Auto-inc | $8F02 | VRAM pointer auto-increment by 2 |

### VDP VRAM layout
- `$0000`: Tile pattern data (frame tiles uploaded here)
- `$C000`: Plane A name table
- `$E000`: Plane B name table
- `$F800`: Sprite attribute table

---

## Transform Pipeline Details

The current transform is **cube-specific** — it assumes vertices are exactly ±1.0 and uses `tst`/`neg` instead of full multiplies for the rotation matrix terms. This works only for unit-cube meshes.

Rotation order: **Y then X** (no Z rotation yet, `tr_sz`/`tr_cz` are computed but unused).

```
1. Y rotation:  x1 = cy*sign(vx) + sy*sign(vz)
                z1 = -sy*sign(vx) + cy*sign(vz)

2. X rotation:  y2 = cx*sign(vy) - z1*sx     (uses fixed_mul for z1*sx)
                z2 = sx*sign(vy) + z1*cx + CAMERA_Z_BIAS

3. Projection:  scale = PROJ_DISTANCE * recip(z2_int)
                screen_x = x1 * scale + CENTER_X
                screen_y = -(y2 * scale) + CENTER_Y
```

To support arbitrary meshes, replace the sign-based multiplication with proper `fixed_mul(vertex_component, trig_value)` calls.

---

## File Quick Reference

| File | Purpose |
|------|---------|
| `src/boot/boot.asm` | Entry point, include order |
| `src/core/config.inc` | All tuning constants |
| `src/core/memory_map.inc` | RAM buffer addresses |
| `src/core/types.inc` | Struct offsets (VERT2, VERT3, EDGE, FACE) |
| `src/hw/vdp.asm` | VDP init, VBlank wait, VRAM/CRAM upload |
| `src/hw/vdp.inc` | VDP register values and VRAM addresses |
| `src/render/transform.asm` | 3D transform + projection |
| `src/render/wire.asm` | Bresenham line drawing + edge loop |
| `src/render/clear.asm` | Framebuffer clear |
| `src/render/present.asm` | Tile packing + name table + VRAM upload |
| `src/math/fixed.asm` | Fixed-point multiply, int↔fixed conversion |
| `src/math/lut.asm` | Sin/cos/reciprocal LUT lookups |
| `src/scene/mesh_cube.asm` | Cube vertex/edge/face data |
| `src/scene/scene_bench.asm` | Scene update (auto-rotate + input) |
| `tools/gen_lut.py` | Generates sin + reciprocal LUT includes |
| `tools/pack_mesh.py` | Generates mesh data includes |
