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
    jsr vdp_init
    jsr pad_init
    jsr scene_bench_init
    jsr profiler_reset
    rts

main_frame:
    jsr wait_vblank
    jsr pad_read
    jsr scene_bench_update
    jsr clear_color_buffer
    jsr transform_mesh_vertices
    jsr draw_scene_wire
    jsr present_frame
    jsr debug_overlay_draw
    rts
