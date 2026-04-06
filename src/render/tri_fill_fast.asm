    include "src/core/config.inc"
    include "src/core/types.inc"

    xdef tri_fill_fast

    xref color_buffer
    xref tri_tmp_vertices
    xref tri_setup_state

TFF_FLAGS   equ 0
TFF_COLOR   equ 2

tri_fill_fast:
    ; Single real scanline from the sorted triangle.
    ; This verifies triangle setup and span writing without restoring
    ; the full edge-walker yet.
    lea     tri_tmp_vertices,a1

    move.w  (a1),d0                ; x0
    move.w  2(a1),d1               ; y0
    move.w  8(a1),d2               ; x1 (middle vertex)
    move.w  10(a1),d3              ; y1
    move.w  16(a1),d4              ; x2
    move.w  18(a1),d5              ; y2

    move.w  d3,d6                  ; scanline = y_mid
    cmpi.w  #0,d6
    blt.w   .done
    cmpi.w  #RENDER_H-1,d6
    bgt.w   .done

    ; Intersect the long edge v0->v2 with the scanline y_mid.
    ; x_long = x0 + (x2-x0) * (y_mid-y0) / (y2-y0)
    move.w  d4,d7
    sub.w   d0,d7                  ; dx = x2 - x0
    move.w  d6,d4
    sub.w   d1,d4                  ; dy = y_mid - y0
    muls.w  d4,d7
    move.w  d5,d4
    sub.w   d1,d4                  ; denom = y2 - y0
    beq.w   .done
    divs.w  d4,d7
    add.w   d0,d7                  ; d7 = x_long

    ; x_mid is vertex 1; choose left/right based on the setup flag.
    tst.w   tri_setup_state+TFF_FLAGS
    bne.s   .short_left
    move.w  d7,d0                  ; left = long edge
    move.w  d2,d1                  ; right = mid vertex
    bra.s   .span_ready
.short_left:
    move.w  d2,d0                  ; left = mid vertex
    move.w  d7,d1                  ; right = long edge

.span_ready:
    cmp.w   d1,d0
    ble.s   .x_ok
    exg     d0,d1
.x_ok:
    cmpi.w  #0,d0
    bge.s   .x0_ok
    moveq   #0,d0
.x0_ok:
    cmpi.w  #RENDER_W-1,d1
    ble.s   .x1_ok
    move.w  #RENDER_W-1,d1
.x1_ok:
    cmp.w   d1,d0
    bgt.w   .done

    move.w  d6,d4
    mulu.w  #(RENDER_W/2),d4
    lea     color_buffer,a0
    adda.w  d4,a0

    move.w  d0,d5
    lsr.w   #1,d5
    lea     0(a0,d5.w),a1
    move.w  d1,d6
    lsr.w   #1,d6

    move.w  tri_setup_state+TFF_COLOR,d7
    andi.w  #$000F,d7
    move.w  d7,d4
    lsl.w   #4,d4
    or.b    d4,d7

    cmp.w   d6,d5
    beq.w   .same_byte

    btst    #0,d0
    beq.s   .first_full
    move.b  (a1),d2
    andi.b  #$F0,d2
    move.b  d7,d3
    andi.b  #$0F,d3
    or.b    d3,d2
    move.b  d2,(a1)+
    bra.s   .middle_bytes

.first_full:
    move.b  d7,(a1)+

.middle_bytes:
    move.w  d6,d2
    sub.w   d5,d2
    subq.w  #2,d2
    blt.s   .last_byte
.mid_loop:
    move.b  d7,(a1)+
    dbra    d2,.mid_loop

.last_byte:
    btst    #0,d1
    beq.s   .last_high
    move.b  d7,(a1)
    bra.s   .done

.last_high:
    move.b  (a1),d2
    andi.b  #$0F,d2
    move.b  d7,d3
    andi.b  #$F0,d3
    or.b    d3,d2
    move.b  d2,(a1)
    bra.s   .done

.same_byte:
    btst    #0,d0
    beq.s   .same_even
    move.b  (a1),d2
    andi.b  #$F0,d2
    move.b  d7,d3
    andi.b  #$0F,d3
    or.b    d3,d2
    move.b  d2,(a1)
    bra.s   .done

.same_even:
    btst    #0,d1
    beq.s   .same_high
    move.b  d7,(a1)
    bra.s   .done

.same_high:
    move.b  (a1),d2
    andi.b  #$0F,d2
    move.b  d7,d3
    andi.b  #$F0,d3
    or.b    d3,d2
    move.b  d2,(a1)

.done:
    rts
