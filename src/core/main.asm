    include "src/core/config.inc"

    xdef main_init
    xdef main_frame

main_init:
    jsr m3dk_init
    jsr scene_demo_init
    rts

main_frame:
    jsr m3dk_frame_begin
    ifeq DEBUG_VIEW_MODE - 2
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
    ifeq DEBUG_PIPELINE_STAGE - 1
    jsr m3dk_clear_frame
    jsr debug_overlay_draw
    jsr m3dk_frame_end
    rts
    endc
    ifeq DEBUG_PIPELINE_STAGE - 2
    jsr scene_demo_update
    jsr m3dk_clear_frame
    jsr m3dk_transform_scene
    jsr m3dk_draw_wireframe
    jsr debug_overlay_draw
    jsr m3dk_frame_end
    rts
    endc
    ifeq DEBUG_PIPELINE_STAGE - 3
    jsr scene_demo_update
    jsr m3dk_clear_frame
    jsr m3dk_transform_scene
    jsr m3dk_draw_visible_wireframe
    jsr debug_overlay_draw
    jsr m3dk_frame_end
    rts
    endc
    ifeq DEBUG_PIPELINE_STAGE - 4
    jsr scene_demo_update
    jsr m3dk_clear_frame
    jsr m3dk_transform_scene
    jsr m3dk_draw_solid
    jsr debug_overlay_draw
    jsr m3dk_frame_end
    rts
    endc

    ; Normal path (stage disabled)
    jsr scene_demo_update
    jsr m3dk_clear_frame
    jsr m3dk_transform_scene
    jsr m3dk_render_scene
    jsr debug_overlay_draw
    jsr m3dk_frame_end
    rts
