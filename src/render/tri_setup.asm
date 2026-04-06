    include "src/core/config.inc"
    include "src/core/types.inc"
    include "src/core/memory_map.inc"
    include "src/render/renderer.inc"

    xdef tri_setup

    xref tri_sort_vertices_by_y
    xref tri_tmp_vertices
    xref tri_setup_state
    xref tri_fill_fast
    xref draw_line

tri_setup:
    move.w  d6,tri_setup_state+TS_COLOR
    bsr     tri_sort_vertices_by_y

    lea     tri_tmp_vertices,a0
    move.w  d0,(a0)
    move.w  d1,2(a0)
    move.w  d2,8(a0)
    move.w  d3,10(a0)
    move.w  d4,16(a0)
    move.w  d5,18(a0)

    move.w  d0,debug_last_tri_v0x
    move.w  d1,debug_last_tri_v0y
    move.w  d2,debug_last_tri_v1x
    move.w  d3,debug_last_tri_v1y
    move.w  d4,debug_last_tri_v2x
    move.w  d5,debug_last_tri_v2y
    move.w  tri_setup_state+TS_COLOR,debug_last_tri_color

    ; Determine whether the middle vertex lies left or right of the long edge (V0->V2).
    ; Long edge vector A = V2 - V0
    ; Mid point vector B = V1 - V0
    ; Cross = Ax*By - Ay*Bx
    move.w  16(a0),d7
    sub.w   (a0),d7                ; dx20 (Ax)
    move.w  10(a0),d6
    sub.w   2(a0),d6               ; dy01 (By)
    muls.w  d6,d7                  ; Ax*By

    move.w  18(a0),d6
    sub.w   2(a0),d6               ; dy20 (Ay)
    move.w  8(a0),d5
    sub.w   (a0),d5                ; dx01 (Bx)
    muls.w  d6,d5                  ; Ay*Bx
    sub.l   d5,d7                  ; cross = Ax*By - Ay*Bx

    ; Contract with tri_fill_fast:
    ; flag=0 => short edge on RIGHT  (long edge provides x_left)
    ; flag=1 => short edge on LEFT   (short edge provides x_left)
    moveq   #0,d6
    tst.l   d7
    blt.s   .flags_ok              ; Cross < 0: Short edge on right, flag=0
    moveq   #1,d6                  ; Cross >= 0: Short edge on left, flag=1
.flags_ok:
    move.w  d6,tri_setup_state+TS_FLAGS
    move.w  d6,debug_last_tri_flags

    move.w  tri_setup_state+TS_COLOR,d7
    andi.w  #$000F,d7
    move.w  d7,d6
    lsl.w   #4,d6
    or.b    d6,d7
    bra     tri_fill_fast

.done:
    rts
