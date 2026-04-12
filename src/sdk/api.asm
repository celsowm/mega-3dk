    include "src/core/config.inc"
    include "src/core/memory_map.inc"
    include "src/scene/scene.inc"

    xdef m3dk_init
    xdef m3dk_frame_begin
    xdef m3dk_frame_end
    xdef m3dk_present_frame
    xdef m3dk_clear_frame
    xdef m3dk_transform_scene
    xdef m3dk_render_scene
    xdef m3dk_draw_wireframe
    xdef m3dk_draw_visible_wireframe
    xdef m3dk_draw_solid
    xdef m3dk_set_active_mesh
    xdef m3dk_get_active_mesh
    xdef m3dk_set_scene_rotation
    xdef m3dk_set_camera
    xdef m3dk_get_pad_cur
    xdef m3dk_get_pad_press
    xdef m3dk_get_pad_ext_cur
    xdef m3dk_get_pad_ext_press

; Public SDK entry points.
; Calling convention for pointer args:
;   - arguments are passed on the stack like a standard 68k C ABI
;   - functions that return values place them in d0
;   - the assembly examples in sdk/examples show direct calls

m3dk_init:
    jsr     vdp_init
    jsr     pad_init
    move.l  #PROJ_DISTANCE,camera_proj_distance
    move.l  #CAMERA_Z_BIAS,camera_z_bias
    rts

m3dk_frame_begin:
    jsr     wait_vblank
    jsr     pad_read
    jsr     profiler_reset
    rts

m3dk_frame_end:
    jsr     present_frame
    rts

m3dk_present_frame:
    jsr     present_frame
    rts

m3dk_clear_frame:
    jsr     clear_color_buffer
    rts

m3dk_transform_scene:
    jsr     transform_mesh_vertices
    rts

m3dk_draw_wireframe:
    jsr     draw_scene_wire
    rts

m3dk_draw_visible_wireframe:
    jsr     draw_scene_visible_wire
    rts

m3dk_draw_solid:
    jsr     draw_scene_solid
    rts

m3dk_render_scene:
    ifeq RENDER_PIPELINE_MODE
    jsr     draw_scene_wire
    endc
    ifeq RENDER_PIPELINE_MODE-1
    jsr     draw_scene_visible_wire
    endc
    ifeq RENDER_PIPELINE_MODE-2
    jsr     draw_scene_solid
    endc
    rts

m3dk_set_active_mesh:
    move.l  4(sp),scene_active_mesh
    rts

m3dk_get_active_mesh:
    move.l  scene_active_mesh,d0
    rts

m3dk_set_scene_rotation:
    movea.l 4(sp),a0
    move.w  (a0),scene_rot_x
    move.w  2(a0),scene_rot_y
    move.w  4(a0),scene_rot_z
    rts

m3dk_set_camera:
    movea.l 4(sp),a0
    move.l  (a0),camera_proj_distance
    move.l  4(a0),camera_z_bias
    rts

m3dk_get_pad_cur:
    move.w  pad_cur,d0
    rts

m3dk_get_pad_press:
    move.w  pad_press,d0
    rts

m3dk_get_pad_ext_cur:
    move.w  pad_ext_cur,d0
    rts

m3dk_get_pad_ext_press:
    move.w  pad_ext_press,d0
    rts
