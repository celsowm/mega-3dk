# Full Resolution Study: 160×112 → 320×224

## Current State (v4.7)

| Resource | Size | Notes |
|---|---|---|
| `color_buffer` | 8,960 B | 160×112 / 2 (4bpp packed) |
| `present_tile_buffer` | 8,960 B | 20×14 tiles × 32 bytes |
| `present_name_table` | 560 B | 20×14 × 2 |
| misc (vars, vertices, faces, etc.) | ~2.5 KB | |
| **Total WRAM** | **~21 KB** | fits in 64 KB |

### Present pipeline (per frame)

1. Render 3D scene into linear `color_buffer` in WRAM
2. Pack `color_buffer` → `present_tile_buffer` (VDP 8×8 tile format) in WRAM
3. Build `present_name_table` in WRAM
4. Upload both buffers to VRAM via CPU word-by-word loop

---

## The Problem at 320×224

| Resource | Size | Notes |
|---|---|---|
| `color_buffer` | 35,840 B | 320×224 / 2 |
| `present_tile_buffer` | 35,840 B | 40×28 tiles × 32 bytes |
| `present_name_table` | 2,240 B | 40×28 × 2 |
| misc | ~2.5 KB | |
| **Total WRAM** | **~76 KB** | **exceeds 64 KB** |

The intermediate `present_tile_buffer` alone doubles the framebuffer cost. Both buffers together consume ~70 KB, blowing past the Mega Drive's 64 KB WRAM limit.

---

## Proposed Solution: Strip-Streaming with DMA

### Memory layout

| Resource | Size | Notes |
|---|---|---|
| `color_buffer` | 35,840 B | 320×224 / 2 (linear 4bpp) |
| `strip_buffer` | 1,280 B | 40 tiles × 32 bytes (one tile row) |
| misc | ~2.5 KB | |
| **Total WRAM** | **~40 KB** | fits in 64 KB |

### Key changes

#### 1. Eliminate `present_tile_buffer`

No full-frame tile-format copy in WRAM. Instead, convert and upload one 8-line strip at a time using a 1,280-byte scratch buffer.

#### 2. Eliminate `present_name_table` buffer

The name table is static for a full-screen framebuffer — it maps tiles 1..1120 in sequential order. Build it once at init by writing directly to VRAM. No per-frame rebuild, no WRAM buffer needed.

#### 3. Present in 28 strips

Per frame:

```
for ty = 0..27:
    pack 8 scanlines from color_buffer → strip_buffer (1,280 bytes)
    DMA strip_buffer → VRAM at tile offset (TILE_BASE + ty * 40) * 32
```

Each strip covers one tile row: 40 tiles wide × 8 pixels tall × 4bpp = 1,280 bytes. This is contiguous in VRAM when tile indices are assigned in screen order.

#### 4. Add DMA transfer helper

Replace `vdp_upload_words_cpu` (CPU word loop) with a proper `vdp_dma_to_vram` routine. CPU upload is already the bottleneck at 160×112; at 320×224 it's not viable.

#### 5. VDP plane size

Current `PRESENT_PLANE_W = 32` doesn't support 40 visible columns in H40 mode. Change VDP plane size to **64×32** so that all 40 tile columns are addressable.

---

## Bandwidth Reality

### VRAM transfer budget (NTSC H40)

| Window | Bandwidth |
|---|---|
| VBlank only | ~7,524 bytes |
| VBlank + active display | ~11,556 bytes |

### Full-frame upload cost

- 320×224 4bpp = **35,840 bytes/frame**
- That's **~4.8× the VBlank budget**
- And **~3.1× the total per-frame budget**

### Achievable framerates

| Strategy | Bytes/frame | Estimated FPS |
|---|---|---|
| Upload during VBlank only | 7,524 B | ~12 fps |
| Upload during VBlank + active | 11,556 B | ~19 fps |
| Dirty-tile tracking (50% dirty) | ~5,800 B | ~30+ fps |

**True 60 fps at full 320×224 unique-tile framebuffer is not physically achievable on the Mega Drive**, regardless of upload method (CPU or DMA).

---

## Implementation Plan

### Phase 1: Memory restructure

1. Update `config.inc`: `RENDER_W=320`, `RENDER_H=224`, centers, tile counts
2. Update `memory_map.inc`: recalculate all buffer addresses after the larger `color_buffer`
3. Update `viewport.inc`: `VIEW_W=320`, `VIEW_H=224`
4. Update `tools/gen_lut.py`: 224 rows, stride 160

### Phase 2: Direct VRAM name table init

1. Add `present_init_plane` routine that writes tile indices 1..1120 directly to VRAM at Plane A address
2. Call once during boot, not per frame
3. Set VDP plane size to 64×32
4. Remove `present_build_linear_name_table` from per-frame path

### Phase 3: DMA helper

1. Implement `vdp_dma_to_vram(src, dst, len)` in `vdp.asm`
2. Handle 68k→VRAM DMA register setup (regs 19-23)
3. Set auto-increment to 2

### Phase 4: Strip-streaming present

1. Allocate 1,280-byte `strip_buffer` in WRAM
2. Rewrite `present_pack_full_frame_4bpp_to_tiles` → `present_frame_strips`:
   - Loop over 28 tile rows
   - Pack 8 scanlines into `strip_buffer`
   - DMA `strip_buffer` to correct VRAM offset
3. Remove old `present_tile_buffer` and `present_name_table` from memory map

### Phase 5: Validation

1. Verify VRAM layout: tile data, plane table, SAT, and scroll table don't overlap
2. Test on BlastEm and BizHawk
3. Measure actual framerate

---

## Future Optimization: Dirty-Tile Tracking

If framerate is insufficient, the next architectural step:

- Store a **dirty bitfield** (1120 bits = 140 bytes) in WRAM
- Mark tiles dirty when the rasterizer writes to them
- During present, only pack and DMA dirty tiles
- For a rotating cube occupying ~30% of screen, this could reduce upload to ~10 KB/frame → viable at 60 fps

This requires the rasterizer to set dirty bits when writing to `color_buffer`, which is a small change in `plot_pixel` and `draw_span_fast`.
