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

    ; Button-to-mesh switching via table.
    move.w pad_press,d1
    move.w pad_ext_press,d2
    lea mesh_button_table,a1
.mesh_loop:
    move.w (a1)+,d3
    bmi.s .mesh_done
    move.w (a1)+,d4
    move.l (a1)+,a0
    tst.b  d3
    bne.s .chk_ext
    btst   d4,d1
    bra.s  .chk_set
.chk_ext:
    btst   d4,d2
.chk_set:
    beq.s  .mesh_loop
    move.l a0,scene_active_mesh
    bra.s  .mesh_loop
.mesh_done:

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

; Table: dc.w source (0=pad_press, 1=pad_ext_press), bit_number, dc.l mesh_ptr
; Terminated by dc.w -1
mesh_button_table:
    dc.w 0,6
    dc.l mesh_cube
    dc.w 0,4
    dc.l mesh_pyramid
    dc.w 0,5
    dc.l mesh_prism
    dc.w 1,0
    dc.l mesh_dodeca
    dc.w 1,1
    dc.l mesh_frustum
    dc.w 1,2
    dc.l mesh_star
    dc.w -1
