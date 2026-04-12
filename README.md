# mega-3dk

`mega-3dk` is a Sega Mega Drive 3D SDK and engine base written in 68000 assembly.
It is organized so other developers can build games on top of a small public API instead of reading the internal engine first.

## What it gives you

- a public assembly interface for game code
- a thin C wrapper layer on top of the same API
- starter examples in assembly and C
- a reproducible build and package flow
- a path from wireframe rendering toward flat-shaded 3D

## Current scope

The project currently focuses on a singleton engine model with:

- 160x112 4bpp software framebuffer
- controller input polling
- mesh selection
- scene rotation
- wireframe, visible-wireframe, and solid render paths
- CPU tile packing and VRAM upload
- public SDK packaging

The engine is still evolving. The SDK is usable, but the renderer and asset pipeline are not yet a full long-term stable release.

## Public SDK

Public headers and source live under `sdk/`:

- [sdk/include/m3dk.inc](sdk/include/m3dk.inc) - assembly-facing public declarations
- [sdk/include/m3dk.h](sdk/include/m3dk.h) - C-facing public header
- [sdk/src/m3dk.c](sdk/src/m3dk.c) - C convenience wrapper

Examples:

- [sdk/examples/asm/minimal](sdk/examples/asm/minimal) - minimal assembly game
- [sdk/examples/asm/multimesh](sdk/examples/asm/multimesh) - mesh switching sample
- [sdk/examples/asm/template](sdk/examples/asm/template) - starter game template
- [sdk/examples/c/minimal_game.c](sdk/examples/c/minimal_game.c) - minimal C usage example
- [sdk/examples/c/template_game.c](sdk/examples/c/template_game.c) - C starter template

## Quick Start

Build the main ROM:

```bash
make build
```

Build the SDK examples:

```bash
make sdk-example-minimal
make sdk-example-multimesh
make sdk-example-template
```

Build the distributable SDK package:

```bash
make sdk-package
```

The package is written under:

```text
build/sdk-release/mega-3dk-sdk-v4.7
```

## Public API

The main entry points exposed by the SDK are:

- `m3dk_init`
- `m3dk_frame_begin`
- `m3dk_frame_end`
- `m3dk_present_frame`
- `m3dk_clear_frame`
- `m3dk_transform_scene`
- `m3dk_render_scene`
- `m3dk_draw_wireframe`
- `m3dk_draw_visible_wireframe`
- `m3dk_draw_solid`
- `m3dk_set_active_mesh`
- `m3dk_get_active_mesh`
- `m3dk_set_scene_rotation`
- `m3dk_set_camera`
- `m3dk_get_pad_cur`
- `m3dk_get_pad_press`
- `m3dk_get_pad_ext_cur`
- `m3dk_get_pad_ext_press`

The C wrapper also provides convenience helpers:

- `m3dk_use_mesh`
- `m3dk_set_rotation_xyz`
- `m3dk_set_camera_values`
- `m3dk_frame`

## Usage model

The intended frame flow is:

1. `m3dk_init`
2. set camera
3. set mesh
4. set rotation
5. `m3dk_frame_begin`
6. clear
7. transform
8. render
9. `m3dk_frame_end`

This keeps game code small and makes the engine easier to embed into a real project.

## Mesh format

The SDK uses a simple mesh descriptor:

- vertices are 16.16 fixed-point `x/y/z` triplets
- faces store 3 vertex indices plus a palette index
- edges store 2 vertex indices
- counts are explicit and fixed-size

This is enough for the current wireframe and flat-shaded pipeline.

## Repository layout

- [src/](src) - internal engine code
- [sdk/](sdk) - public SDK headers, wrapper, and examples
- [docs/](docs) - SDK docs, roadmap, and technical notes
- [tools/](tools) - asset generators
- [scripts/](scripts) - build and packaging helpers
- [assets/](assets) - generated and source assets

## Build targets

- `make build` - build the main ROM
- `make sdk-example-minimal` - build the minimal SDK example
- `make sdk-example-multimesh` - build the multi-mesh example
- `make sdk-example-template` - build the starter template
- `make sdk-package` - build and package the SDK release
- `make run` - launch the main ROM in the configured emulator

## Status

What works now:

- public SDK surface
- assembly examples
- C wrapper source
- package generation
- wireframe and solid render paths

What still needs work:

- a real external C cross-build workflow
- a more complete public scene API
- better asset tooling beyond the current simple mesh format
- performance upgrades such as DMA and dirty-tile tracking

## Documentation

- [docs/SDK.md](docs/SDK.md)
- [docs/ROADMAP.md](docs/ROADMAP.md)
- [docs/AI_GUIDE.md](docs/AI_GUIDE.md)

## License

No explicit license file is present yet. Add one before distributing externally.
