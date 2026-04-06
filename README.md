# mega-3dk v4.7

68000 3D engine base for Mega Drive, organized to grow from **wireframe** to **flat-shaded triangles**.

## Focus of this v4.7
- Reduce obscure points in the bring-up
- Correct the misalignment between `tile base` and tile upload
- Bring up a default palette right in `vdp_init`
- Make the path `framebuffer -> tiles -> name table -> VRAM` more auditable

## Important fixes in this version
- `PRESENT_TILE_BASE` is now **0**, aligned with tile upload
- `vdp_init` now calls `vdp_init_default_palette`

- Separate support for writing to **CRAM** has been added
- `present_upload_minimal_cpu` now documents and uses the tile base coherently
- `STACK_TOP` has been defined in `config.inc`, eliminating a boot loophole

## Actual state
This v4.7 is still a **serious technical bring-up**, not a confirmed demo in the emulator. But the critical section is now shorter and has fewer obvious inconsistencies.

## What's already more concrete
- Internal buffer 160x112 in 4bpp
- `plot_pixel(x,y,color)` in high/low nibble
- Entire Bresenham in `draw_line`
- Cube described by edges
- `cube-first` transformation
- Packing of the framebuffer in 8x8 tiles
- Linear name table 20x14
- Minimum upload to VRAM per CPU
- Default palette in CRAM at init

## What's still missing to call it a ready demo
- Validate the first frame in the emulator
- Check the exact VDP command if a black screen or incorrect layout appears
- Actual reading of the 3-button controller
- Review the `present` for DMA after the first frame is validated

## Next milestones
- v4.8: First visual frame validated
- v4.9: Backface culling + visible faces
- v5.0: Flat-shaded triangles