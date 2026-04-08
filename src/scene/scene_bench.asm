    include "src/core/config.inc"

    xdef scene_bench_init
    xdef scene_bench_update
    xdef scene_active_mesh
    xdef scene_rot_x
    xdef scene_rot_y
    xdef scene_rot_z

scene_bench_init:
    lea mesh_cube,a0
    move.l a0,scene_active_mesh
    move.w #DEBUG_START_ROT_X,scene_rot_x
    move.w #DEBUG_START_ROT_Y,scene_rot_y
    move.w #DEBUG_START_ROT_Z,scene_rot_z
    rts

scene_bench_update:
    ifne DEBUG_FREEZE_SCENE
    rts
    endc

    ; Manual rotation control on D-pad.
    move.w pad_cur,d0
    btst #2,d0
    beq.s .no_left
    subi.w #24,scene_rot_y
.no_left:
    btst #3,d0
    beq.s .no_right
    addi.w #24,scene_rot_y
.no_right:
    btst #0,d0
    beq.s .no_up
    subi.w #24,scene_rot_x
.no_up:
    btst #1,d0
    beq.s .no_down
    addi.w #24,scene_rot_x
.no_down:
    rts
