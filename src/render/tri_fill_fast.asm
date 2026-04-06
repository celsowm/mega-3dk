    include "src/core/config.inc"
    include "src/core/types.inc"
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
    moveq   #0,d0
    move.w  (a1),d0
    lsl.l   #8,d0                  ; x_long = x0 (16.8)
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
    moveq   #0,d1
    move.w  8(a1),d1
    lsl.l   #8,d1                  ; x_short = x1 (16.8)

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
; Robust 68000 division with overflow protection.
.calc_step:
    tst.w   d1
    beq.s   .cs_zero
    
    move.l  d1,-(sp)               ; Save divisor
    move.l  d0,-(sp)               ; Save original dx for sign
    
    ext.l   d0
    bpl.s   .cs_pos
    neg.l   d0                     ; d0 = abs(dx)
.cs_pos:
    lsl.l   #8,d0                  ; d0 = dx << 8
    
    ; Overflow check: if (dividend >> 16) >= divisor
    move.l  d0,d6
    swap    d6
    andi.w  #$FFFF,d6              ; d6 = dividend >> 16
    move.w  4(sp),d1               ; d1 = divisor
    cmp.w   d1,d6
    bhs.s   .cs_overflow
    
    divu.w  d1,d0
    andi.l  #$FFFF,d0
    bra.s   .cs_apply_sign

.cs_overflow:
    move.l  #$0000FFFF,d0

.cs_apply_sign:
    move.l  (sp)+,d1               ; original dx
    tst.l   d1
    bpl.s   .cs_sign_done
    neg.l   d0
.cs_sign_done:
    move.l  (sp)+,d1               ; restore divisor
    rts

.cs_zero:
    moveq   #0,d0
    rts

; In: d0=x_long, d1=x_short, d7=packed_color, d5=y_current
; Preserves all main loop registers.
.draw_span:
    ; Y Clipping
    cmpi.w  #0,d5
    blt.w   .ds_done
    cmpi.w  #RENDER_H,d5
    bge.w   .ds_done

    movem.l d0-d6/a0/a2,-(sp)

    ; Line Base Address
    lea     color_buffer,a0
    move.w  d5,d6
    mulu.w  #(RENDER_W/2),d6
    adda.l  d6,a0

    ; Convert 16.8 to Integer
    move.l  d0,d6
    asr.l   #8,d6                  ; d6 = x_long_int
    move.l  d1,d2
    asr.l   #8,d2                  ; d2 = x_short_int
    
    ; Decide left/right based on TS_FLAGS
    tst.w   tri_setup_state+TS_FLAGS
    beq.s   .ds_short_right
    ; Flag=1: Short edge is LEFT (d2=left, d6=right)
    move.w  d6,d3                  ; d3 = x_right (long)
    bra.s   .ds_clip_x
.ds_short_right:
    ; Flag=0: Short edge is RIGHT (d6=left, d2=right)
    move.w  d2,d3                  ; d3 = x_right (short)
    move.w  d6,d2                  ; d2 = x_left (long)

.ds_clip_x:
    ; X Clipping
    cmpi.w  #0,d2
    bge.s   .ds_x0_ok
    moveq   #0,d2
.ds_x0_ok:
    cmpi.w  #RENDER_W-1,d3
    ble.s   .ds_x1_ok
    move.w  #RENDER_W-1,d3
.ds_x1_ok:
    cmp.w   d3,d2
    bgt.w   .ds_pop_done           ; Nothing to draw

    ; Setup pointers
    move.w  d2,d1                  ; x_start
    move.w  d2,d6
    lsr.w   #1,d6                  ; byte offset
    lea     0(a0,d6.w),a2          ; a2 = current byte
    
    move.w  d3,-(sp)               ; Save x_end
    lsr.w   #1,d3                  ; d3 = end byte offset
    move.w  d3,d4                  ; d4 = end byte index
    
    cmp.w   d4,d6
    beq.s   .ds_same_byte

    ; Multi-byte span
    btst    #0,d1                  ; Check if x_start is odd
    beq.s   .ds_first_full
    ; Odd start: paint low nibble, move to next byte
    move.b  (a2),d2
    andi.b  #$F0,d2
    move.b  d7,d0
    andi.b  #$0F,d0
    or.b    d0,d2
    move.b  d2,(a2)+
    addq.w  #1,d6
    bra.s   .ds_mid_check
.ds_first_full:
    move.b  d7,(a2)+
    addq.w  #1,d6

.ds_mid_check:
    move.w  d4,d2
    sub.w   d6,d2                  ; Bytes remaining
    blt.s   .ds_last_byte
.ds_mid_loop:
    move.b  d7,(a2)+
    dbra    d2,.ds_mid_loop

.ds_last_byte:
    move.w  (sp)+,d4               ; Restore x_end
    btst    #0,d4
    beq.s   .ds_last_high          ; x_end even -> only high nibble
    move.b  d7,(a2)
    bra.s   .ds_pop_done
.ds_last_high:
    move.b  (a2),d2
    andi.b  #$0F,d2
    move.b  d7,d0
    andi.b  #$F0,d0
    or.b    d0,d2
    move.b  d2,(a2)
    bra.s   .ds_pop_done

.ds_same_byte:
    move.w  (sp)+,d4               ; Restore x_end
    btst    #0,d1                  ; x_start
    beq.s   .ds_sb_even
    ; Odd start in same byte
    move.b  (a2),d2
    andi.b  #$F0,d2
    move.b  d7,d0
    andi.b  #$0F,d0
    or.b    d0,d2
    move.b  d2,(a2)
    bra.s   .ds_pop_done
.ds_sb_even:
    btst    #0,d4                  ; x_end
    beq.s   .ds_sb_even_high
    ; Full byte
    move.b  d7,(a2)
    bra.s   .ds_pop_done
.ds_sb_even_high:
    ; High nibble only
    move.b  (a2),d2
    andi.b  #$0F,d2
    move.b  d7,d0
    andi.b  #$F0,d0
    or.b    d0,d2
    move.b  d2,(a2)

.ds_pop_done:
    movem.l (sp)+,d0-d6/a0/a2
.ds_done:
    rts
