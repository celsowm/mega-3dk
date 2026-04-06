    include "src/core/config.inc"
    include "src/core/memory_map.inc"
    include "src/core/types.inc"

    xdef main_init
    xdef main_frame
    xdef color_buffer
    xdef cam_vertices
    xdef proj_vertices
    xdef visible_faces
    xdef tri_tmp_vertices
    xdef tri_setup_state
    xdef present_tile_buffer
    xdef present_name_table

main_init:
    bsr vdp_init
    bsr pad_init
    bsr scene_bench_init
    bsr profiler_reset
    rts

main_frame:
    bsr wait_vblank
    bsr pad_read
    bsr scene_bench_update
    bsr clear_color_buffer
    bsr transform_mesh_vertices
    bsr draw_scene_wire
    bsr present_frame
    bsr debug_overlay_draw
    rts

    section bss
color_buffer:
    ds.b (RENDER_W*RENDER_H)/2
cam_vertices:
    ds.b MAX_VERTICES*VERT3_SIZE
proj_vertices:
    ds.b MAX_VERTICES*VERT2_SIZE
visible_faces:
    ds.b MAX_VISIBLE_FACES*VFACE_SIZE
tri_tmp_vertices:
    ds.b 3*VERT2_SIZE
tri_setup_state:
    ds.b 64
present_tile_buffer:
    ds.b PRESENT_TILE_BYTES
present_name_table:
    ds.b PRESENT_NAME_BYTES
