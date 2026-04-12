    include "src/core/config.inc"
    include "src/hw/pad.inc"

    xdef scene_demo_init
    xdef scene_demo_update
    xdef scene_demo_draw

scene_demo_init:
    lea mesh_torus,a0
    move.l a0,scene_active_mesh
    move.w #DEBUG_START_ROT_X,scene_rot_x
    move.w #DEBUG_START_ROT_Y,scene_rot_y
    move.w #DEBUG_START_ROT_Z,scene_rot_z
    rts

scene_demo_update:
    ifne DEBUG_FREEZE_SCENE
    rts
    endc

    ; Manual rotation control on D-pad.
    move.w pad_cur,d0
    btst #2,d0
    beq.s .no_left
    subi.w #40,scene_rot_y
.no_left:
    btst #3,d0
    beq.s .no_right
    addi.w #40,scene_rot_y
.no_right:
    btst #0,d0
    beq.s .no_up
    subi.w #40,scene_rot_x
.no_up:
    btst #1,d0
    beq.s .no_down
    addi.w #40,scene_rot_x
.no_down:

    ; X/Z adjust camera zoom.
    move.w pad_ext_cur,d1
    btst #0,d1
    beq.s .no_zoom_in
    subi.l #32768,camera_z_bias
    cmp.l  #196608,camera_z_bias
    bge.s  .no_zoom_in
    move.l #196608,camera_z_bias
.no_zoom_in:
    btst #2,d1
    beq.s .no_zoom_out
    addi.l #32768,camera_z_bias
    cmp.l  #655360,camera_z_bias
    ble.s  .no_zoom_out
    move.l #655360,camera_z_bias
.no_zoom_out:
    rts

scene_demo_draw:
    rts
