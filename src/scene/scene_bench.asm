    xdef scene_bench_init
    xdef scene_bench_update
    xdef scene_active_mesh
    xdef scene_rot_x
    xdef scene_rot_y
    xdef scene_rot_z

    xref mesh_cube
    xref pad_cur

PAD_UP      equ $0001
PAD_DOWN    equ $0002
PAD_LEFT    equ $0004
PAD_RIGHT   equ $0008
PAD_B       equ $0010
PAD_C       equ $0020
PAD_A       equ $0040
PAD_START   equ $0080

scene_bench_init:
    lea mesh_cube,a0
    move.l a0,scene_active_mesh
    clr.w scene_rot_x
    clr.w scene_rot_y
    clr.w scene_rot_z
    rts

scene_bench_update:
    ; rotação automática leve
    addq.w #2,scene_rot_y
    addq.w #1,scene_rot_x

    ; input já integrado à API, mesmo antes da leitura real do pad.
    move.w pad_cur,d0
    btst #2,d0
    beq.s .no_left
    subq.w #2,scene_rot_y
.no_left:
    btst #3,d0
    beq.s .no_right
    addq.w #2,scene_rot_y
.no_right:
    btst #0,d0
    beq.s .no_up
    subq.w #2,scene_rot_x
.no_up:
    btst #1,d0
    beq.s .no_down
    addq.w #2,scene_rot_x
.no_down:
    rts

    section bss
scene_active_mesh:
    ds.l 1
scene_rot_x:
    ds.w 1
scene_rot_y:
    ds.w 1
scene_rot_z:
    ds.w 1
