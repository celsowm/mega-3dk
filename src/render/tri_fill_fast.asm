    include "src/core/config.inc"
    include "src/core/types.inc"
    include "src/core/memory_map.inc"
    include "src/render/renderer.inc"

    xdef tri_fill_fast

    xref color_buffer
    xref tri_tmp_vertices
    xref tri_setup_state

; Register usage in main loops:
; d0: x_long (16.8 fixed)
; d1: x_short (16.8 fixed)
; d2: dx_long (16.8 fixed)
; d3: dx_short (16.8 fixed)
; d4: y_counter
; d5: y_current
; d7: packed color (8 bits: 4|4)
; a1: tri_tmp_vertices base

tri_fill_fast:
    lea     tri_tmp_vertices,a1
    
    ; 1. Initial Height Check
    move.w  18(a1),d4
    sub.w   2(a1),d4               ; y_total = y2 - y0
    ble.w   .done                  ; Zero or negative height

    ; 2. Setup Packed Color
    move.w  tri_setup_state+TS_COLOR,d7
    andi.w  #$000F,d7
    move.w  d7,d6
    lsl.w   #4,d6
    or.b    d6,d7

    ; 3. Calculate dx_long (v0 -> v2)
    move.w  16(a1),d0
    sub.w   (a1),d0                ; dx_long_int = x2 - x0
    move.w  18(a1),d1
    sub.w   2(a1),d1               ; dy_long_int = y2 - y0
    bsr     .calc_step             ; d0 = dx_long (16.8)
    move.l  d0,d2                  ; d2 = dx_long

    ; 4. Prepare Top Half (v0 -> v1)
    move.w  10(a1),d4
    sub.w   2(a1),d4               ; dy_top = y1 - y0
    
    ; Initial X positions
    move.w  (a1),d0
    ext.l   d0
    asl.l   #8,d0                  ; x_long = x0 (16.8)
    move.l  d0,d1                  ; x_short = x0 (16.8)
    
    move.w  2(a1),d5               ; y_current = y0

    tst.w   d4
    beq.s   .skip_top              ; Flat top triangle

    ; Calculate dx_short for top half
    movem.l d0-d1,-(sp)            ; Preserve current X positions
    move.w  8(a1),d0
    sub.w   (a1),d0                ; dx_top_int = x1 - x0
    move.w  d4,d1                  ; dy_top
    bsr     .calc_step             ; d0 = dx_short
    move.l  d0,d3
    movem.l (sp)+,d0-d1            ; Restore x_long, x_short

.top_loop:
    bsr     .draw_span
    add.l   d2,d0                  ; x_long += dx_long
    add.l   d3,d1                  ; x_short += dx_short
    addq.w  #1,d5                  ; y_current++
    subq.w  #1,d4
    bgt.s   .top_loop

.skip_top:
    ; 5. Prepare Bottom Half (v1 -> v2)
    move.w  18(a1),d4
    sub.w   10(a1),d4              ; dy_bot = y2 - y1
    ble.s   .done

    ; Reset x_short to v1.x (x_long continues from where it was)
    move.w  8(a1),d1
    ext.l   d1
    asl.l   #8,d1                  ; x_short = x1 (16.8)

    ; Calculate dx_short for bottom half
    movem.l d0-d1,-(sp)            ; Preserve x_long and x_short
    move.w  16(a1),d0
    sub.w   8(a1),d0               ; dx_bot_int = x2 - x1
    move.w  d4,d1                  ; dy_bot
    bsr     .calc_step             ; d0 = dx_short
    move.l  d0,d3
    movem.l (sp)+,d0-d1            ; Restore x_long and x_short

.bot_loop:
    bsr     .draw_span
    add.l   d2,d0                  ; x_long += dx_long
    add.l   d3,d1                  ; x_short += dx_short
    addq.w  #1,d5                  ; y_current++
    subq.w  #1,d4
    bgt.s   .bot_loop

.done:
    rts

; --- Subroutines ---

; In: d0=dx (word), d1=dy (word). Out: d0=step (16.8, long)
.calc_step:
    tst.w   d1
    beq.s   .cs_zero
    ext.l   d0
    asl.l   #8,d0
    divs.w  d1,d0
    ext.l   d0                     ; sign-extend quotient to long
    rts
.cs_zero:
    moveq   #0,d0
    rts

; In: d0=x_long, d1=x_short, d7=packed_color, d5=y_current
.draw_span:
    ; Y Clipping
    cmpi.w  #0,d5
    blt.w   .ds_done
    cmpi.w  #RENDER_H,d5
    bge.w   .ds_done

    movem.l d0-d6/a0/a2,-(sp)

    lea     color_buffer,a0
    move.w  d5,d6
    mulu.w  #(RENDER_W/2),d6
    adda.l  d6,a0

    ; Pick left/right
    move.l  d0,d2
    move.l  d1,d3
    cmp.l   d3,d2
    ble.s   .ordered
    exg     d2,d3
.ordered:
    asr.l   #8,d2                  ; d2 = x_left
    asr.l   #8,d3                  ; d3 = x_right

    ; X Clipping
    cmpi.w  #0,d2
    bge.s   .x0_ok
    moveq   #0,d2
.x0_ok:
    cmpi.w  #RENDER_W-1,d3
    ble.s   .x1_ok
    move.w  #RENDER_W-1,d3
.x1_ok:
    ; Exclusive right edge: skip if x_left >= x_right
    cmp.w   d3,d2
    bge.w   .ds_pop_done           ; Nothing to draw
    subq.w  #1,d3                  ; End pixel is exclusive

    move.w  d2,d6
    lsr.w   #1,d6                  ; byte offset
    lea     0(a0,d6.w),a2
    
    move.w  d3,-(sp)               ; Save x_end
    lsr.w   #1,d3
    move.w  d3,d4                  ; end byte index
    
    cmp.w   d4,d6
    beq.s   .ds_same_byte

    ; Multi-byte span
    btst    #0,d2
    beq.s   .ds_first_full
    ; Odd start
    move.b  (a2),d1
    andi.b  #$F0,d1
    move.b  d7,d0
    andi.b  #$0F,d0
    or.b    d0,d1
    move.b  d1,(a2)+
    addq.w  #1,d6
    bra.s   .ds_mid_check
.ds_first_full:
    move.b  d7,(a2)+
    addq.w  #1,d6

.ds_mid_check:
    move.w  d4,d1
    sub.w   d6,d1
    subq.w  #2,d1
    blt.s   .ds_last_byte
.ds_mid_loop:
    move.b  d7,(a2)+
    dbra    d1,.ds_mid_loop

.ds_last_byte:
    move.w  (sp)+,d4
    btst    #0,d4
    beq.s   .ds_last_high
    move.b  d7,(a2)
    bra.s   .ds_pop_done
.ds_last_high:
    move.b  (a2),d1
    andi.b  #$0F,d1
    move.b  d7,d0
    andi.b  #$F0,d0
    or.b    d0,d1
    move.b  d1,(a2)
    bra.s   .ds_pop_done

.ds_same_byte:
    move.w  (sp)+,d4
    btst    #0,d2
    beq.s   .ds_sb_even
    ; Odd start in same byte
    move.b  (a2),d1
    andi.b  #$F0,d1
    move.b  d7,d0
    andi.b  #$0F,d0
    or.b    d0,d1
    move.b  d1,(a2)
    bra.s   .ds_pop_done
.ds_sb_even:
    btst    #0,d4
    beq.s   .ds_sb_even_high
    ; Full byte
    move.b  d7,(a2)
    bra.s   .ds_pop_done
.ds_sb_even_high:
    ; High nibble only
    move.b  (a2),d1
    andi.b  #$0F,d1
    move.b  d7,d0
    andi.b  #$F0,d0
    or.b    d0,d1
    move.b  d1,(a2)

.ds_pop_done:
    movem.l (sp)+,d0-d6/a0/a2
.ds_done:
    rts
