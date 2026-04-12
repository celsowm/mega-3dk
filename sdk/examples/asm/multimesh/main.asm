    include "m3dk.inc"
    include "../../../../src/core/memory_map.inc"

    xdef main_init
    xdef main_frame

example_rotation_x equ WRAM_BASE+$7000
example_rotation_y equ WRAM_BASE+$7002
example_rotation_z equ WRAM_BASE+$7004
example_mesh_index equ WRAM_BASE+$7006
example_rotation    equ example_rotation_x

main_init:
    jsr     m3dk_init
    clr.w   example_rotation_x
    clr.w   example_rotation_y
    clr.w   example_rotation_z
    clr.w   example_mesh_index

    lea     example_camera,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_camera
    addq.l  #4,sp

    moveq   #0,d0
    bsr     multimesh_select_by_index

    lea     example_rotation,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_scene_rotation
    addq.l  #4,sp
    rts

main_frame:
    jsr     m3dk_frame_begin

    jsr     m3dk_get_pad_press
    move.w  d0,d1
    btst    #4,d1
    beq.s   .no_b
    moveq   #0,d0
    bsr     multimesh_select_by_index
.no_b:
    btst    #5,d1
    beq.s   .no_c
    moveq   #1,d0
    bsr     multimesh_select_by_index
.no_c:
    btst    #6,d1
    beq.s   .no_a
    moveq   #2,d0
    bsr     multimesh_select_by_index
.no_a:
    btst    #7,d1
    beq.s   .no_start
    moveq   #3,d0
    bsr     multimesh_select_by_index
.no_start:

    addi.w  #16,example_rotation_y
    lea     example_rotation,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_scene_rotation
    addq.l  #4,sp

    jsr     m3dk_clear_frame
    jsr     m3dk_transform_scene
    jsr     m3dk_render_scene
    jsr     m3dk_frame_end
    rts

multimesh_select_by_index:
    move.w  d0,example_mesh_index
    lsl.w   #2,d0
    lea     example_mesh_table,a1
    move.l  0(a1,d0.w),a0
    move.l  a0,-(sp)
    jsr     m3dk_set_active_mesh
    addq.l  #4,sp
    rts

example_mesh_table:
    dc.l mesh_cube
    dc.l mesh_pyramid
    dc.l mesh_prism
    dc.l mesh_dodeca

example_camera:
    dc.l 4194304
    dc.l 327680
