    include "src/core/config.inc"
    include "src/core/types.inc"
    include "src/core/memory_map.inc"
    include "src/render/renderer.inc"

    xdef tri_fill_fast

; Debug-oriented triangle filler:
; robust scanline fill using horizontal draw_line spans.
; This prioritizes correctness and visual stability over speed.
tri_fill_fast:
    lea     tri_tmp_vertices,a1

    ; y_total = y2 - y0
    move.w  18(a1),d4
    sub.w   2(a1),d4
    bgt.s   .y_ok
    bne.w   .done

    ; Flat triangle after projection: draw the collapsed span instead of
    ; dropping the primitive entirely. This avoids visible holes on tiny faces.
    move.w  (a1),d0
    move.w  8(a1),d1
    cmp.w   d1,d0
    ble.s   .flat_min_ok
    exg     d0,d1
.flat_min_ok:
    move.w  16(a1),d2
    cmp.w   d2,d1
    ble.s   .flat_max_ok
    move.w  d2,d1
    cmp.w   d1,d0
    ble.s   .flat_max_ok
    move.w  d0,d1
.flat_max_ok:
    move.w  2(a1),d1
    move.w  tri_setup_state+TS_COLOR,d4
    andi.w  #$000F,d4
    bne.s   .flat_color_ok
    moveq   #1,d4
.flat_color_ok:
    bsr     draw_span_fast
    bra.w   .done

.y_ok:

    move.w  tri_setup_state+TS_COLOR,d6
    andi.w  #$000F,d6
    beq.s   .color_ok
    bra.s   .color_ready
.color_ok:
    moveq   #1,d6
.color_ready:
    move.w  tri_setup_state+TS_FLAGS,d7

    ; dx_long = step(v0->v2) in 16.8
    move.w  16(a1),d0
    sub.w   (a1),d0
    move.w  18(a1),d1
    sub.w   2(a1),d1
    bsr     .calc_step
    move.l  d0,d2                  ; dx_long

    ; x_long = x0<<8, x_short = x0<<8, y = y0
    move.w  (a1),d0
    ext.l   d0
    asl.l   #8,d0
    move.l  d0,d1
    move.w  2(a1),d5

    ; top half: v0 -> v1
    move.w  10(a1),d4
    sub.w   2(a1),d4
    ble.s   .skip_top

    movem.l d0-d1,-(sp)
    move.w  8(a1),d0
    sub.w   (a1),d0
    move.w  d4,d1
    bsr     .calc_step
    move.l  d0,d3                  ; dx_short(top)
    movem.l (sp)+,d0-d1

.top_loop:
    bsr     .draw_span
    add.l   d2,d0
    add.l   d3,d1
    addq.w  #1,d5
    subq.w  #1,d4
    bgt.s   .top_loop

.skip_top:
    ; bottom half: v1 -> v2
    move.w  18(a1),d4
    sub.w   10(a1),d4
    ble.s   .done

    move.w  8(a1),d1
    ext.l   d1
    asl.l   #8,d1

    movem.l d0-d1,-(sp)
    move.w  16(a1),d0
    sub.w   8(a1),d0
    move.w  d4,d1
    bsr     .calc_step
    move.l  d0,d3                  ; dx_short(bottom)
    movem.l (sp)+,d0-d1

.bot_loop:
    bsr     .draw_span
    add.l   d2,d0
    add.l   d3,d1
    addq.w  #1,d5
    subq.w  #1,d4
    bgt.s   .bot_loop

.done:
    rts

; In: d0=dx (word), d1=dy (word). Out: d0=step (16.8, long)
.calc_step:
    tst.w   d1
    beq.s   .cs_zero
    ext.l   d0
    asl.l   #8,d0
    divs.w  d1,d0
    ext.l   d0
    rts
.cs_zero:
    moveq   #0,d0
    rts

; In: d0=x_long(16.8), d1=x_short(16.8), d5=y, d6=color nibble
.draw_span:
    cmpi.w  #0,d5
    blt.s   .ds_done
    cmpi.w  #RENDER_H,d5
    bge.s   .ds_done

    movem.l d0-d4/d7,-(sp)

    ; Order edges dynamically per scanline.
    ; This is more robust than relying on a precomputed handedness flag,
    ; especially for flat-top/flat-bottom cases and near-degenerate spans.
    move.l  d0,d2
    move.l  d1,d3
    cmp.l   d3,d2
    ble.s   .edge_ordered
    exg     d2,d3
.edge_ordered:
    ; Use floor/floor inclusive edges for stability while bring-up continues.
    asr.l   #8,d2
    asr.l   #8,d3

    cmpi.w  #0,d2
    bge.s   .x0_ok
    moveq   #0,d2
.x0_ok:
    cmpi.w  #RENDER_W-1,d3
    ble.s   .x1_ok
    move.w  #RENDER_W-1,d3
.x1_ok:
    cmp.w   d3,d2
    ble.s   .span_ok
    move.w  d2,d3
.span_ok:

    move.w  d2,d0
    move.w  d5,d1
    move.w  d3,d2
    move.w  d6,d4
    bsr     draw_span_fast

.pop_done:
    movem.l (sp)+,d0-d4/d7
.ds_done:
    rts
