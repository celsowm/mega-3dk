    include "src/core/config.inc"
    include "src/core/types.inc"

    xdef painter_sort_faces

; Bubble sort visible faces by depth descending (back-to-front).
; For a cube, at most 6 visible faces — bubble sort is fine.
painter_sort_faces:
    movem.l d0-d3/a0-a1,-(sp)

    move.w  visible_face_count,d3
    subq.w  #2,d3
    blt.s   .done                  ; 0 or 1 faces: nothing to sort

.outer:
    lea     visible_faces,a0
    moveq   #0,d2                  ; swapped flag
    move.w  d3,d1                  ; inner count

.inner:
    move.l  VFACE_DEPTH(a0),d0     ; depth of current
    lea     VFACE_SIZE(a0),a1      ; next face
    cmp.l   VFACE_DEPTH(a1),d0
    bge.s   .no_swap               ; current >= next: already correct order

    ; Swap the two VFACE entries (12 bytes = 3 longs)
    move.l  (a0),d0
    move.l  (a1),(a0)
    move.l  d0,(a1)

    move.l  4(a0),d0
    move.l  4(a1),4(a0)
    move.l  d0,4(a1)

    move.l  8(a0),d0
    move.l  8(a1),8(a0)
    move.l  d0,8(a1)

    moveq   #1,d2                  ; mark swapped

.no_swap:
    lea     VFACE_SIZE(a0),a0
    dbra    d1,.inner

    tst.w   d2
    bne.s   .outer                 ; repeat if any swap happened

.done:
    movem.l (sp)+,d0-d3/a0-a1
    rts
    rts
