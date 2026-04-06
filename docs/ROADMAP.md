# mega-3dk Roadmap

**Goal:** The most optimized, well-documented pure-assembly 3D SDK for the Sega Mega Drive, with best-in-class Big-O complexity at every pipeline stage.

---

## Current State (v4.8)

✅ Wireframe cube rendering with 2-axis rotation  
✅ 160×112 4bpp software framebuffer  
✅ Bresenham line drawing with clipping  
✅ CPU-based tile packing and VRAM upload  
✅ Controller input  
✅ Sin/cos/reciprocal LUT system  
✅ Centered display on screen  
✅ Working Makefile (build + run)  

---

## Phase 1 — Solid Foundation (v4.9–v5.1)

### v4.9 — Proper Fixed-Point Math
**Current:** `fixed_mul_16_16` uses `(a>>8)*(b>>8)` via `muls.w` — loses precision for small values and overflows for large ones.

**Target:**
```
; True 16.16 × 16.16 multiply using two muls.w + shifts
; Result = (a.hi * b.hi) << 16 + a.hi * b.lo + a.lo * b.hi + (a.lo * b.lo) >> 16
; Big-O: O(1) — 4 multiplies, ~40 cycles vs current ~20 cycles
```
- [ ] Implement accurate `fixed_mul_16_16` (4-part multiply)
- [ ] Add `fixed_div` using Newton-Raphson iteration from recip LUT
- [ ] Add `fixed_sqrt` via LUT + 1 Newton step (needed for normals later)
- [ ] Benchmark both multiply variants, keep fast version as `fixed_mul_fast`

### v5.0 — General Transform Pipeline
**Current:** Cube-specific transform using `tst`/`neg` (only works for ±1.0 vertices).

**Target:** True matrix-vector multiply for arbitrary meshes.
- [ ] Implement 3×3 rotation matrix build from Euler angles (all 3 axes)
- [ ] `mat3_mul_vec3`: 9 multiplies + 6 adds per vertex — **O(V)** with small constant
- [ ] Store matrix in WRAM, compute once per frame — amortized **O(1)**
- [ ] Separate camera transform from model transform (model-view)
- [ ] Add translation support (world position for objects)

### v5.1 — Backface Culling
**Current:** All 12 edges drawn regardless of visibility.

**Target:** Cull back-facing triangles before any edge/fill work.
```
; Cross product of two edge vectors → normal Z component
; If normal_z <= 0, face is back-facing → skip
; Big-O: O(F) — 2 subtracts + 1 multiply per face
; Saves ~50% of rendering work on convex objects
```
- [ ] Compute screen-space cross product per face
- [ ] Build `visible_faces` array (already allocated in WRAM)
- [ ] Wire renderer reads from `visible_faces` instead of raw edges
- [ ] Ensure edge list is derived from visible faces (no duplicate edges)

---

## Phase 2 — Filled Polygons (v5.2–v5.5)

### v5.2 — Flat-Shaded Triangle Rasterizer
**Target:** Scanline-based triangle fill — the core of any filled 3D engine.
```
; For each triangle:
;   1. Sort vertices by Y               — O(1) (3 vertices)
;   2. Walk left/right edges with DDA    — O(H) per triangle
;   3. Fill each scanline                — O(W) per scanline
; Total per triangle: O(H × W_avg)
; Total per frame:    O(F × H_avg × W_avg) = O(pixels filled)
```
- [ ] `tri_sort_y`: Sort 3 vertices by screen Y (already stubbed)
- [ ] `tri_setup`: Compute edge slopes as fixed-point DDA
- [ ] `tri_fill`: Horizontal span fill using `move.l` for 4-pixel bursts
- [ ] Per-face color from mesh data (palette index 0–15)

### v5.3 — Painter's Algorithm (Z-Sorting)
**Target:** Draw back-to-front for correct occlusion without a Z-buffer.
```
; Sort visible_faces by average Z (centroid depth)
; Big-O: O(F log F) — insertion sort is O(F²) but F < 256, so practical
; Insertion sort preferred: ~20 instructions per compare, cache-friendly
```
- [ ] Compute face centroid Z from `cam_vertices`
- [ ] Insertion sort on `visible_faces` by depth (far to near)
- [ ] Draw filled triangles in sorted order

### v5.4 — Flat Shading with Lighting
**Target:** Compute per-face brightness from a directional light.
```
; dot(face_normal, light_dir) → intensity
; Big-O: O(F) — 3 multiplies + 2 adds per face
; Map intensity to palette ramp (4–8 shades per color)
```
- [ ] Compute face normal from cross product (reuse from culling)
- [ ] Normalize via `fixed_sqrt` + reciprocal
- [ ] Dot product with light direction vector
- [ ] Quantize to palette shade index
- [ ] Design multi-shade palette (8 colors × 2 shades = 16 entries)

### v5.5 — Near-Plane Clipping
**Target:** Clip triangles that cross the camera plane to prevent wrap-around.
```
; Sutherland-Hodgman clip against z_near plane
; Big-O: O(F) — each triangle clips to at most 2 output triangles
; Essential for close-up objects and camera movement
```
- [ ] Clip in camera space before projection
- [ ] Handle 1-vertex-behind and 2-vertex-behind cases
- [ ] Output clipped triangles to temporary buffer

---

## Phase 3 — Performance (v5.6–v6.0)

### v5.6 — DMA Transfer for VRAM Upload
**Current:** CPU loop writing word-by-word to VDP — **O(B)** with ~18 cycles/word.

**Target:** DMA transfer — **O(1)** CPU time (VDP handles the transfer).
```
; Setup: write 5 VDP registers (source, length, destination, command)
; The 68000 is halted during DMA but it's ~2× faster than CPU copy
; Frees CPU to do work during non-DMA time
; Tiles: 8960 bytes → 4480 words → ~4480 × 5 = 22,400 VDP cycles via DMA
;   vs ~4480 × 18 = 80,640 CPU cycles via CPU loop
```
- [ ] Implement `vdp_dma_vram` (68K→VRAM)
- [ ] Replace `present_upload_minimal_cpu` with DMA path
- [ ] Queue DMA during VBlank for tear-free updates
- [ ] Keep CPU upload as fallback for debugging

### v5.7 — Dirty-Tile Optimization
**Current:** Pack and upload all 280 tiles every frame — **O(W×H)**.

**Target:** Track which tiles changed and only re-pack/upload those.
```
; Maintain a dirty bitmap (280 bits = 35 bytes)
; After clear + render, mark tiles containing drawn pixels
; Only pack and DMA dirty tiles
; Best case (small object): O(T_dirty) << O(T_total)
; Worst case (full screen): O(T_total) — no worse than current
```
- [ ] Bitmap of dirty tiles (1 bit per tile)
- [ ] `plot_pixel` marks tile dirty
- [ ] `present_pack` only processes dirty tiles
- [ ] DMA uploads use scatter-gather (multiple small DMAs or sorted upload)

### v5.8 — Fast Framebuffer Clear
**Current:** `move.l #0,(a0)+` in a loop — **O(W×H/4)**.

**Target:** Unrolled clear using `movem.l` — 14 registers × 4 bytes = 56 bytes per instruction.
```
; movem.l d0-d6/a1-a6,-(a0)  ; 52 bytes per instruction
; 8960 bytes / 52 ≈ 173 iterations
; ~6 cycles per longword vs ~12 for move.l loop → 2× speedup
; Combined with dirty-tile: only clear dirty regions
```
- [ ] Unrolled clear with `movem.l` (13 zero registers)
- [ ] Optional: only clear dirty tile regions
- [ ] Benchmark vs current clear

### v5.9 — Optimized Triangle Fill
**Target:** Maximum throughput for the innermost rendering loop.
```
; Techniques:
; 1. Self-modifying code: patch span start/end addresses at runtime
;    Eliminates per-pixel bounds check — saves ~4 cycles/pixel
;
; 2. Unrolled spans: for common widths (8, 16, 32 pixels),
;    jump into pre-built movem.l chains
;    8 pixels: 2 move.l = 2 instructions vs 8 iterations
;
; 3. Word-aligned fill: handle odd start/end pixels separately,
;    then fill aligned middle with move.l or movem.l
;
; Big-O stays O(pixels) but constant factor drops 3-5×
```
- [ ] Word-aligned fast span fill
- [ ] Jump table for common span widths
- [ ] Optional self-modifying code path (advanced)

### v6.0 — Double Buffering
**Target:** Eliminate tearing by rendering to an off-screen buffer while displaying the previous frame.
```
; Two tile buffers: front (displaying) and back (rendering)
; Swap pointers at VBlank
; Cost: 2× tile buffer memory (8960 × 2 = 17920 bytes)
; WRAM budget: 64KB total, ~25KB used → fits easily
```
- [ ] Allocate two tile buffers in WRAM
- [ ] Render to back buffer while front buffer displays
- [ ] Pointer swap in VBlank handler
- [ ] VBlank interrupt handler (replace polling)

---

## Phase 4 — Advanced Features (v6.1–v7.0)

### v6.1 — Multiple Meshes & Scene Graph
- [ ] Array of mesh instances with individual transforms (position, rotation, scale)
- [ ] Per-mesh model matrix, shared view matrix
- [ ] Simple draw list sorted by depth
- [ ] **O(M × V_avg)** transform, **O(M × F_avg)** rendering

### v6.2 — Mesh LOD (Level of Detail)
```
; For each mesh, store 2-3 LOD versions
; Select based on distance: far → low-poly, near → high-poly
; Big-O: O(1) LOD select, reduces V and F for distant objects
```
- [ ] LOD mesh format (array of mesh pointers per object)
- [ ] Distance-based LOD selection
- [ ] Smooth LOD transitions (optional hysteresis)

### v6.3 — Gouraud Shading (Vertex Colors)
```
; Interpolate color across triangle scanlines
; Per-vertex lighting → per-pixel color interpolation
; Big-O: O(pixels) — 1 add per pixel for color interpolation
; Requires palette ramp of 16 shades
```
- [ ] Per-vertex color/intensity computation
- [ ] Scanline color interpolation via DDA
- [ ] Extended palette design (16 shades)

### v6.4 — Texture Mapping (Affine)
```
; Interpolate U, V texture coordinates across scanlines
; Look up texel from texture in ROM
; Big-O: O(pixels) — 2 adds + 1 lookup per pixel
; No perspective correction (affine) — acceptable for Mega Drive
```
- [ ] UV coordinate storage in mesh format
- [ ] Affine texture interpolation
- [ ] 16×16 or 32×32 textures stored as 4bpp in ROM
- [ ] Texture atlas support

### v6.5 — Z80 Co-Processing
```
; Offload non-critical work to the Z80 (3.58 MHz, 8KB RAM):
; - Sound playback (FM/PSG)
; - Sorting (bubble sort on face depths)
; - Name table generation
; Frees 68000 cycles for transform + rasterization
```
- [ ] Z80 initialization and communication protocol
- [ ] Z80 sound driver (basic FM playback)
- [ ] Evaluate Z80-assisted sorting (may not be worth the bus contention)

### v7.0 — SDK Release
- [ ] Clean public API: `m3dk_init`, `m3dk_load_mesh`, `m3dk_set_camera`, `m3dk_render`
- [ ] Comprehensive documentation with examples
- [ ] Mesh converter tool (OBJ/PLY → mega-3dk binary format)
- [ ] Example scenes: spinning cube, multi-mesh scene, textured level
- [ ] Performance profiler overlay (FPS, cycles per stage)
- [ ] ROM size optimizer (strip unused code paths)

---

## Big-O Summary by Pipeline Stage

| Stage | Current | Target | Technique |
|-------|---------|--------|-----------|
| Clear | O(W×H) | O(T_dirty) | Dirty-tile tracking + movem.l unroll |
| Transform | O(V) | O(V) | Matrix multiply (constant factor improvement) |
| Backface Cull | — | O(F) | Screen-space cross product |
| Z-Sort | — | O(F²) | Insertion sort (F < 256) |
| Rasterize | O(E×L) wire | O(pixels) fill | DDA scanline + word-aligned fill |
| Tile Pack | O(W×H) | O(T_dirty) | Dirty-tile sparse pack |
| Upload | O(B) CPU | O(1) CPU | DMA transfer |
| Name Table | O(T) | O(1) | Build once, never rebuild |

### Theoretical Frame Budget (NTSC)
```
68000 @ 7.67 MHz = 127,833 cycles/frame @ 60fps

Current wireframe path (estimated):
  Clear:     ~22,000 cy   (8960 bytes / 4 × 10 cy)
  Transform:  ~5,000 cy   (8 vertices × ~600 cy)
  Wire draw: ~15,000 cy   (12 edges × ~100 px avg × 12 cy/px)
  Pack:      ~45,000 cy   (8960 bytes × 5 cy)
  Upload:    ~40,000 cy   (4480+448 words × ~18 cy)
  Total:    ~127,000 cy   ← barely fits in one frame!

Target filled-polygon path:
  Clear:      ~3,000 cy   (movem.l unrolled, dirty only)
  Transform:  ~8,000 cy   (32 vertices × 250 cy with real matrix mul)
  Cull+Sort:  ~3,000 cy   (20 faces × 150 cy)
  Rasterize: ~50,000 cy   (fill ~5000 pixels × 10 cy)
  Pack:      ~10,000 cy   (dirty tiles only, ~30% of screen)
  DMA:           ~50 cy   (setup only, VDP does the rest)
  Total:     ~74,000 cy   ← 58% of frame budget, room for 60fps!
```

---

## Optimization Principles

1. **Never touch a pixel you don't need to.** Dirty-tile tracking, backface culling, and frustum culling all serve this goal.

2. **DMA everything.** Every CPU cycle spent copying data to VRAM is a cycle not spent on math. Let the VDP hardware do bulk transfers.

3. **Amortize setup, optimize inner loops.** Matrix build is once per frame. LUT lookups are O(1). The triangle fill inner loop runs thousands of times — optimize it to the cycle level.

4. **Use the 68000's strengths.** `movem.l` for bulk moves, `swap` for 16.16 math, `muls`/`mulu` for single-cycle-start multiplies, address registers for zero-cost pointer arithmetic.

5. **Pre-compute everything possible.** Sin/cos/reciprocal LUTs, pre-sorted face lists, pre-built name tables, pre-computed normals.

6. **Measure before optimizing.** The profiler overlay should show cycle counts per pipeline stage so you know where time is actually spent.

---

## Stretch Goals

- **Subdivision surfaces** — Adaptive mesh refinement for curved surfaces
- **Particle system** — Sprite-based particles using hardware sprites (up to 80)
- **BSP trees** — For complex static scenes (indoor environments)
- **Portal rendering** — For room-based scenes with doorways
- **Mode 7-style floor** — HScroll line-by-line for ground plane effect (hybrid 2D/3D)
- **Stereo 3D** — Alternate-frame rendering for shutter glasses (Sega Master System 3D glasses compatible)
