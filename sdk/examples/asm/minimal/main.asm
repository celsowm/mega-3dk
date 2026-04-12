    include "m3dk.inc"
    include "../../../../src/core/memory_map.inc"

    xdef main_init
    xdef main_frame

example_rotation_x equ WRAM_BASE+$7000
example_rotation_y equ WRAM_BASE+$7002
example_rotation_z equ WRAM_BASE+$7004
example_rotation    equ example_rotation_x

main_init:
    jsr     m3dk_init
    clr.w   example_rotation_x
    clr.w   example_rotation_y
    clr.w   example_rotation_z

    lea     example_camera,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_camera
    addq.l  #4,sp

    lea     mesh_cube,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_active_mesh
    addq.l  #4,sp

    lea     example_rotation,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_scene_rotation
    addq.l  #4,sp
    rts

main_frame:
    jsr     m3dk_frame_begin

    addi.w  #24,example_rotation_y
    lea     example_rotation,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_scene_rotation
    addq.l  #4,sp

    jsr     m3dk_clear_frame
    jsr     m3dk_transform_scene
    jsr     m3dk_render_scene
    jsr     m3dk_frame_end
    rts

example_camera:
    dc.l 4194304
    dc.l 327680
