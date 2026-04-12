# mega-3dk Roadmap

`mega-3dk` is evolving from an internal 3D engine base into a usable Mega Drive SDK.
This roadmap focuses on what developers need in order to build games with it.

## Current State

What already works:

- public SDK surface in assembly and C
- assembly starter examples
- C wrapper source and C templates
- singleton scene model
- wireframe, visible-wireframe, and solid render paths
- CPU framebuffer packing and VRAM upload
- controller input polling
- SDK release packaging

What is still provisional:

- the public API is intentionally small
- the C wrapper is source-level convenience, not a fully toolchain-integrated library yet
- the mesh format is simple and not yet a full asset pipeline
- performance work still depends on CPU-side upload and full-frame packing

## Near-Term Goals

### Stabilize the public SDK surface

Goal: make the current API the primary way to use the engine.

- keep `m3dk_init`, `m3dk_frame_begin`, `m3dk_frame_end`, `m3dk_render_scene`, and the input helpers stable
- keep the singleton model predictable
- document calling conventions and data formats clearly
- keep examples synchronized with the actual API

### Improve starter experience

Goal: let a developer start from the SDK package and reach a working ROM quickly.

- keep the assembly template self-contained
- keep the C template self-contained
- add one or two more focused examples when they solve a real onboarding problem
- keep `make sdk-package` producing everything needed to inspect or copy the SDK

### Make asset usage clearer

Goal: reduce friction when importing user-authored meshes.

- document the mesh descriptor format more completely
- improve the mesh conversion toolchain
- define a simple versioning story for SDK snapshots and generated assets

## Next Major Milestones

### v4.9 - Better Math and Camera Control

- improve fixed-point math accuracy where it matters
- separate camera values from rendering constants more clearly
- keep the fast path available where precision is not critical

### v5.0 - General Mesh Transform Pipeline

- support arbitrary meshes instead of template-specific assumptions
- keep transform cost linear in vertex count
- separate model and camera transforms in the public mental model

### v5.1 - Backface Culling

- skip invisible faces before raster work
- reduce wasted work on convex and mostly convex meshes
- keep the visible-face list compatible with the current scene model

### v5.2 - Flat-Shaded Triangles

- make filled triangles the default path
- keep wireframe as a debug and style option
- use palette indices in a way that is easy for game authors to reason about

### v5.3 - Depth Ordering

- sort visible faces before drawing
- preserve a simple no-Z-buffer approach
- keep the implementation small enough for 68000 constraints

### v5.4 - Lighting and Visual Polishing

- add per-face lighting
- introduce palette ramps for shading
- keep the API simple enough for new users

## Performance Roadmap

The current engine is still CPU-heavy. The most important performance work is:

- DMA-based VRAM upload
- dirty-tile tracking
- faster framebuffer clear
- faster span fill
- double buffering for smoother output

These changes matter because they move the project closer to something a game can use continuously, not just a bring-up demo.

## API Growth Roadmap

The SDK will likely grow in this order:

1. mesh loading and asset conversion
2. richer scene control
3. more explicit camera control
4. optional multiple instances or scene graph support
5. higher-level helpers for common gameplay loops

The goal is to grow the API carefully instead of exposing internals too early.

## Success Criteria

The project is moving in the right direction if:

- a developer can start from the SDK package without reading internal source first
- assembly and C examples stay small and understandable
- the public API stays stable enough for real game code
- the release package is copyable and self-contained
- each new milestone improves usability, not only rendering capability

## Stretch Goals

- texture mapping
- sprite/system integration
- audio and Z80 co-processing support
- scene graph helpers
- room/portal-style rendering
- tooling for more mesh formats
