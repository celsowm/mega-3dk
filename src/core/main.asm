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
    xdef debug_last_span_y
    xdef debug_last_span_x0
    xdef debug_last_span_x1
    xdef debug_last_tri_flags
    xdef debug_last_tri_color
    xdef debug_last_tri_v0x
    xdef debug_last_tri_v0y
    xdef debug_last_tri_v1x
    xdef debug_last_tri_v1y
    xdef debug_last_tri_v2x
    xdef debug_last_tri_v2y

main_init:
    jsr vdp_init
    jsr pad_init
    jsr scene_bench_init
    jsr profiler_reset
    rts

main_frame:
    jsr wait_vblank
    jsr pad_read
    jsr profiler_reset
    ifeq DEBUG_VIEW_MODE-2
    jsr present_frame_debug_pattern
    rts
    endc

    ; DEBUG_PIPELINE_STAGE:
    ; -1 normal mode (RENDER_PIPELINE_MODE)
    ;  0 present debug pattern
    ;  1 clear + present
    ;  2 wire
    ;  3 visible-wire
    ;  4 solid
    ifeq DEBUG_PIPELINE_STAGE
    jsr present_frame_debug_pattern
    rts
    endc
    ifeq DEBUG_PIPELINE_STAGE-1
    jsr clear_color_buffer
    jsr debug_overlay_draw
    jsr present_frame
    rts
    endc
    ifeq DEBUG_PIPELINE_STAGE-2
    jsr scene_bench_update
    jsr clear_color_buffer
    jsr transform_mesh_vertices
    jsr draw_scene_wire
    jsr debug_overlay_draw
    jsr present_frame
    rts
    endc
    ifeq DEBUG_PIPELINE_STAGE-3
    jsr scene_bench_update
    jsr clear_color_buffer
    jsr transform_mesh_vertices
    jsr draw_scene_visible_wire
    jsr debug_overlay_draw
    jsr present_frame
    rts
    endc
    ifeq DEBUG_PIPELINE_STAGE-4
    jsr scene_bench_update
    jsr clear_color_buffer
    jsr transform_mesh_vertices
    jsr draw_scene_solid
    jsr debug_overlay_draw
    jsr present_frame
    rts
    endc

    ; Normal path (stage disabled)
    jsr scene_bench_update
    jsr clear_color_buffer
    jsr transform_mesh_vertices
    ifeq RENDER_PIPELINE_MODE
    jsr draw_scene_wire
    endc
    ifeq RENDER_PIPELINE_MODE-1
    jsr draw_scene_visible_wire
    endc
    ifeq RENDER_PIPELINE_MODE-2
    jsr draw_scene_solid
    endc
    jsr debug_overlay_draw
    jsr present_frame
    rts
