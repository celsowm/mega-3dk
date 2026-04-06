    include "src/core/config.inc"
    include "src/core/types.inc"

    xdef tri_setup

    xref tri_sort_vertices_by_y
    xref tri_tmp_vertices
    xref tri_setup_state
    xref tri_fill_fast
    xref draw_line

TS_FLAGS    equ 0
TS_COLOR    equ 2

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

    ; Determine whether the middle vertex lies left or right of the long edge.
    move.w  d2,d7
    sub.w   d0,d7                  ; dx01
    move.w  d5,d6
    sub.w   d1,d6                  ; dy20
    muls.w  d6,d7                  ; term1

    move.w  d3,d6
    sub.w   d1,d6                  ; dy01
    move.w  d4,d5
    sub.w   d0,d5                  ; dx20
    muls.w  d6,d5                  ; term2
    sub.l   d5,d7                  ; cross

    moveq   #0,d6
    tst.l   d7
    blt.s   .flags_ok
    moveq   #1,d6                  ; short edge is on the left
.flags_ok:
    move.w  d6,tri_setup_state+TS_FLAGS

    move.w  tri_setup_state+TS_COLOR,d7
    andi.w  #$000F,d7
    move.w  d7,d6
    lsl.w   #4,d6
    or.b    d6,d7
    bra     tri_fill_fast

.done:
    rts
