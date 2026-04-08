    include "src/core/config.inc"

    xdef debug_overlay_draw

; Minimal hex overlay for incremental pipeline debugging.
; Layout at top-left (x=2,y=2):
; [stage][lines(4 hex)][faces(2 hex)][flags][color]
debug_overlay_draw:
    movem.l d0-d7/a0,-(sp)

    moveq   #14,d4
    move.w  #2,d0
    move.w  #2,d1

    move.w  #DEBUG_PIPELINE_STAGE,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit

    move.w  #8,d0
    move.w  prof_lines_drawn,d3
    move.w  d3,d2
    lsr.w   #8,d2
    lsr.w   #4,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit
    move.w  #12,d0
    move.w  d3,d2
    lsr.w   #8,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit
    move.w  #16,d0
    move.w  d3,d2
    lsr.w   #4,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit
    move.w  #20,d0
    move.w  d3,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit

    move.w  #28,d0
    move.w  visible_face_count,d3
    move.w  d3,d2
    lsr.w   #4,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit
    move.w  #32,d0
    move.w  d3,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit

    move.w  #38,d0
    move.w  debug_last_tri_flags,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit

    move.w  #42,d0
    move.w  debug_last_tri_color,d2
    andi.w  #$000F,d2
    bsr     overlay_draw_hex_digit

    movem.l (sp)+,d0-d7/a0
    rts

; In: d0=x, d1=y, d2=nibble(0..15), d4=color.
overlay_draw_hex_digit:
    movem.l d0-d3/d5-d7/a0,-(sp)
    move.w  d2,d7
    move.w  d0,d2
    move.w  d1,d3

    andi.w  #$000F,d7
    mulu.w  #5,d7
    lea     overlay_hex_3x5,a0
    adda.w  d7,a0
    moveq   #14,d7

    moveq   #0,d5
.row_loop:
    cmpi.w  #5,d5
    bge.s   .done

    move.b  (a0,d5.w),d6

    btst    #2,d6
    beq.s   .skip_col0
    move.w  d2,d0
    move.w  d3,d1
    add.w   d5,d1
    move.w  d7,d4
    bsr     plot_pixel
.skip_col0:
    btst    #1,d6
    beq.s   .skip_col1
    move.w  d2,d0
    addq.w  #1,d0
    move.w  d3,d1
    add.w   d5,d1
    move.w  d7,d4
    bsr     plot_pixel
.skip_col1:
    btst    #0,d6
    beq.s   .next_row
    move.w  d2,d0
    addq.w  #2,d0
    move.w  d3,d1
    add.w   d5,d1
    move.w  d7,d4
    bsr     plot_pixel

.next_row:
    addq.w  #1,d5
    bra.s   .row_loop

.done:
    movem.l (sp)+,d0-d3/d5-d7/a0
    rts

overlay_hex_3x5:
    ; 0
    dc.b %111,%101,%101,%101,%111
    ; 1
    dc.b %010,%110,%010,%010,%111
    ; 2
    dc.b %111,%001,%111,%100,%111
    ; 3
    dc.b %111,%001,%111,%001,%111
    ; 4
    dc.b %101,%101,%111,%001,%001
    ; 5
    dc.b %111,%100,%111,%001,%111
    ; 6
    dc.b %111,%100,%111,%101,%111
    ; 7
    dc.b %111,%001,%001,%001,%001
    ; 8
    dc.b %111,%101,%111,%101,%111
    ; 9
    dc.b %111,%101,%111,%001,%111
    ; A
    dc.b %111,%101,%111,%101,%101
    ; B
    dc.b %110,%101,%110,%101,%110
    ; C
    dc.b %111,%100,%100,%100,%111
    ; D
    dc.b %110,%101,%101,%101,%110
    ; E
    dc.b %111,%100,%111,%100,%111
    ; F
    dc.b %111,%100,%111,%100,%100
