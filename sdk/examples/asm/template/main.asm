    include "m3dk.inc"
    include "../../../../src/core/memory_map.inc"

    xdef main_init
    xdef main_frame

template_rotation_x equ WRAM_BASE+$7100
template_rotation_y equ WRAM_BASE+$7102
template_rotation_z equ WRAM_BASE+$7104
template_rotation    equ template_rotation_x

main_init:
    jsr     m3dk_init
    clr.w   template_rotation_x
    clr.w   template_rotation_y
    clr.w   template_rotation_z

    lea     template_camera,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_camera
    addq.l  #4,sp

    lea     template_mesh,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_active_mesh
    addq.l  #4,sp

    lea     template_rotation,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_scene_rotation
    addq.l  #4,sp
    rts

main_frame:
    jsr     m3dk_frame_begin

    addi.w  #20,template_rotation_y
    lea     template_rotation,a0
    move.l  a0,-(sp)
    jsr     m3dk_set_scene_rotation
    addq.l  #4,sp

    jsr     m3dk_clear_frame
    jsr     m3dk_transform_scene
    jsr     m3dk_render_scene
    jsr     m3dk_frame_end
    rts

template_vertices:
    dc.l -65536,-65536,-65536
    dc.l  65536,-65536,-65536
    dc.l  65536, 65536,-65536
    dc.l -65536, 65536,-65536
    dc.l -65536,-65536, 65536
    dc.l  65536,-65536, 65536
    dc.l  65536, 65536, 65536
    dc.l -65536, 65536, 65536

template_faces:
    dc.w 0,1,2,2
    dc.w 0,2,3,2
    dc.w 4,6,5,3
    dc.w 4,7,6,3
    dc.w 0,5,1,4
    dc.w 0,4,5,4
    dc.w 3,2,6,5
    dc.w 3,6,7,5
    dc.w 1,5,6,6
    dc.w 1,6,2,6
    dc.w 0,3,7,7
    dc.w 0,7,4,7

template_edges:
    dc.w 0,1
    dc.w 1,2
    dc.w 2,3
    dc.w 3,0
    dc.w 4,5
    dc.w 5,6
    dc.w 6,7
    dc.w 7,4
    dc.w 0,4
    dc.w 1,5
    dc.w 2,6
    dc.w 3,7

template_mesh:
    dc.l template_vertices
    dc.l template_faces
    dc.w 8
    dc.w 12
    dc.l template_edges
    dc.w 12

template_camera:
    dc.l 4194304
    dc.l 327680
