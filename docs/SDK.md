# mega-3dk SDK

`mega-3dk` exposes a small public SDK for Mega Drive game code.
The goal is to let developers build games on top of a stable, simple surface instead of depending on the internal engine layout.

## What is public

- [sdk/include/m3dk.inc](../sdk/include/m3dk.inc) - assembly declarations and public constants
- [sdk/include/m3dk.h](../sdk/include/m3dk.h) - C header for the wrapper layer
- [sdk/src/m3dk.c](../sdk/src/m3dk.c) - C convenience wrapper built on top of the assembly API
- [sdk/examples/asm/minimal](../sdk/examples/asm/minimal) - minimal assembly example
- [sdk/examples/asm/multimesh](../sdk/examples/asm/multimesh) - mesh-switching assembly example
- [sdk/examples/asm/template](../sdk/examples/asm/template) - self-contained game template in assembly
- [sdk/examples/c/minimal_game.c](../sdk/examples/c/minimal_game.c) - minimal C usage example
- [sdk/examples/c/template_game.c](../sdk/examples/c/template_game.c) - self-contained C template

## Build targets

- `make build` - build the main ROM
- `make sdk-example-minimal` - build the minimal SDK example ROM
- `make sdk-example-multimesh` - build the mesh-switching SDK example ROM
- `make sdk-example-template` - build the starter template ROM
- `make sdk-package` - build and collect the release package

## Public API

The SDK currently exposes a singleton engine model with these entry points:

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

The C wrapper adds convenience helpers:

- `m3dk_use_mesh`
- `m3dk_set_rotation_xyz`
- `m3dk_set_camera_values`
- `m3dk_frame`

## Typical frame flow

1. `m3dk_init`
2. set the camera
3. set the active mesh
4. set the initial rotation
5. `m3dk_frame_begin`
6. `m3dk_clear_frame`
7. `m3dk_transform_scene`
8. `m3dk_render_scene`
9. `m3dk_frame_end`

This is the recommended pattern for both assembly and C consumers.

## Calling convention

- no-argument functions take no parameters
- pointer parameters are passed on the stack
- return values, when present, come back in `d0`

The main pointer-based calls are:

- `m3dk_set_active_mesh(const M3DKMesh *mesh)`
- `m3dk_set_scene_rotation(const M3DKRotation *rotation)`
- `m3dk_set_camera(const M3DKCamera *camera)`

## Mesh format

`M3DKMesh` mirrors the internal mesh descriptor used by the engine:

- `vertices`: pointer to 16.16 fixed-point `x/y/z` triplets
- `faces`: pointer to triangle records with 3 vertex indices and a palette index
- `vertex_count`: number of vertices
- `face_count`: number of faces
- `edges`: pointer to edge pairs
- `edge_count`: number of edges

The current engine targets simple convex and near-convex meshes.
That keeps wireframe and flat-shaded rendering predictable while the API stabilizes.

## Units and conventions

- rotation uses the engine's LUT index space, `0..1023` for a full turn
- vertex and camera values use 16.16 fixed-point
- palette indices are 4-bit values in the range `0..15`

## Example starter path

If you want the fastest path to a working game:

1. copy `sdk/examples/asm/template`
2. replace the template mesh with your own data
3. adjust rotation and camera values
4. build with `make sdk-example-template`

For C users, start from `sdk/examples/c/template_game.c`.

## Package contents

`make sdk-package` creates a release folder with:

- public headers
- C wrapper source
- assembly and C examples
- demo ROMs
- this documentation

## Notes

- The SDK is usable now, but the engine is still evolving.
- The public API is intentionally small.
- A long-term stable ABI has not been committed yet.
