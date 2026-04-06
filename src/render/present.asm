    include "src/core/config.inc"
    include "src/core/memory_map.inc"
    include "src/hw/vdp.inc"

    xdef present_frame
    xdef present_fill_debug_tiles
    xdef present_fill_debug_pattern_tiles
    xdef present_pack_full_frame_4bpp_to_tiles
    xdef present_build_linear_name_table
    xdef present_upload_minimal_cpu
    xdef present_frame_debug_pattern

    xref color_buffer
    xref present_tile_buffer
    xref present_name_table
    xref vdp_upload_words_cpu

; v4.6
; O present agora fecha um caminho mínimo de CPU -> tile buffer -> name table -> VRAM.
; Continua sem DMA e sem validação final em emulador, então deve ser lido como um
; bring-up plausível e não como etapa já confirmada.
present_frame:
    bsr     present_pack_full_frame_4bpp_to_tiles
    bsr     present_build_linear_name_table
    bsr     present_upload_minimal_cpu
    rts

present_frame_debug_pattern:
    bsr     present_fill_debug_pattern_tiles
    bsr     present_build_linear_name_table
    bsr     present_upload_minimal_cpu
    rts

; Debug fill: set all tile bytes to $FF so the visible area should turn solid white.
present_fill_debug_tiles:
    movem.l d0-d2/a0,-(sp)
    lea     present_tile_buffer,a0
    move.w  #(PRESENT_TILE_BYTES/4)-1,d0
    move.l  #$FFFFFFFF,d1
.loop:
    move.l  d1,(a0)+
    dbra    d0,.loop
    movem.l (sp)+,d0-d2/a0
    rts

; Deterministic tile pattern for BizHawk VRAM/name-table validation.
; Each tile receives a unique solid color nibble derived from its tile index.
present_fill_debug_pattern_tiles:
    movem.l d0-d4/a0,-(sp)
    lea     present_tile_buffer,a0
    moveq   #0,d0
.tile_loop:
    cmpi.w  #PRESENT_TILE_COUNT,d0
    bge.s   .done

    move.w  d0,d1
    andi.w  #$000F,d1
    bne.s   .color_ok
    moveq   #1,d1
.color_ok:
    move.w  d1,d2
    lsl.w   #4,d2
    or.b    d2,d1

    moveq   #32-1,d3
.byte_loop:
    move.b  d1,(a0)+
    dbra    d3,.byte_loop

    addq.w  #1,d0
    bra.s   .tile_loop
.done:
    movem.l (sp)+,d0-d4/a0
    rts

present_pack_full_frame_4bpp_to_tiles:
    movem.l d2-d7/a0-a2,-(sp)
    lea     color_buffer,a0
    lea     present_tile_buffer,a1

    moveq   #0,d7
.ty_loop:
    cmpi.w  #PRESENT_TILE_H,d7
    bge.s   .done

    moveq   #0,d6
.tx_loop:
    cmpi.w  #PRESENT_TILE_W,d6
    bge.s   .next_ty

    move.w  d7,d0
    mulu.w  #PRESENT_TILE_W,d0
    add.w   d6,d0
    lsl.w   #5,d0
    lea     present_tile_buffer,a1
    adda.w  d0,a1

    moveq   #0,d5
.row_loop:
    cmpi.w  #8,d5
    bge.s   .next_tx

    move.w  d7,d0
    lsl.w   #3,d0
    add.w   d5,d0
    mulu.w  #(RENDER_W/2),d0
    move.w  d6,d1
    lsl.w   #2,d1
    add.w   d1,d0

    lea     color_buffer,a2
    adda.w  d0,a2

    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+
    move.b  (a2)+,(a1)+

    addq.w  #1,d5
    bra.s   .row_loop

.next_tx:
    addq.w  #1,d6
    bra.s   .tx_loop
.next_ty:
    addq.w  #1,d7
    bra.s   .ty_loop
.done:
    movem.l (sp)+,d2-d7/a0-a2
    rts

present_build_linear_name_table:
    movem.l d2-d4/a0,-(sp)
    lea     present_name_table,a0
    ; clear full 32x28 plane
    move.w  #(PRESENT_PLANE_W*28)-1,d1
.clr:
    move.w  #0,(a0)+
    dbra    d1,.clr
    ; fill render area at (PRESENT_OFF_X, PRESENT_OFF_Y)
    lea     present_name_table,a0
    move.w  #(PRESENT_OFF_Y*PRESENT_PLANE_W+PRESENT_OFF_X),d1
    lsl.w   #1,d1
    adda.w  d1,a0
    move.w  #PRESENT_TILE_BASE,d0
    move.w  #PRESENT_TILE_H-1,d3
.row:
    move.w  #PRESENT_TILE_W-1,d2
.col:
    move.w  d0,(a0)+
    addq.w  #1,d0
    dbra    d2,.col
    adda.w  #((PRESENT_PLANE_W-PRESENT_TILE_W)*2),a0
    dbra    d3,.row
    movem.l (sp)+,d2-d4/a0
    rts

; Upload mínimo por CPU.
; - tiles temporários vão para a base definida em PRESENT_TILE_BASE
; - name table linear vai para Plane A @ $C000
; É simples e deliberadamente caro: serve para o primeiro pixel útil aparecer.
present_upload_minimal_cpu:
    movem.l d0-d2/a0,-(sp)

    lea     present_tile_buffer,a0
    move.w  #(VDP_VRAM_FRAME_TILES + (PRESENT_TILE_BASE*32)),d0
    move.w  #(PRESENT_TILE_BYTES/2),d1
    bsr     vdp_upload_words_cpu

    lea     present_name_table,a0
    move.w  #VDP_VRAM_PLANEA,d0
    move.w  #(PRESENT_PLANE_W*28),d1
    bsr     vdp_upload_words_cpu

    movem.l (sp)+,d0-d2/a0
    rts
