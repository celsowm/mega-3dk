    include "../core/memory_map.inc"
    include "vdp.inc"

    xdef vdp_init
    xdef wait_vblank
    xdef vdp_set_vram_write
    xdef vdp_set_cram_write
    xdef vdp_upload_words_cpu
    xdef vdp_upload_cram_words_cpu
    xdef vdp_init_default_palette

    xref palette_flat16

; v4.7
; Bring-up mais auditável:
; - init mínimo do VDP
; - paleta padrão subida logo no init
; - helpers separados para VRAM e CRAM
; - polling de VBlank ainda simples, mas concentrado aqui
vdp_init:
    move.w  #VDP_REG_MODE1,VDP_CTRL
    move.w  #VDP_REG_MODE2,VDP_CTRL
    move.w  #VDP_REG_PLANEA,VDP_CTRL
    move.w  #VDP_REG_WINDOW,VDP_CTRL
    move.w  #VDP_REG_PLANEB,VDP_CTRL
    move.w  #VDP_REG_SAT,VDP_CTRL
    move.w  #VDP_REG_BGCOLOR,VDP_CTRL
    move.w  #VDP_REG_MODE3,VDP_CTRL
    move.w  #VDP_REG_MODE4,VDP_CTRL
    move.w  #VDP_REG_HSCROLL,VDP_CTRL
    move.w  #VDP_REG_AUTOINC2,VDP_CTRL
    move.w  #VDP_REG_PLANESIZE,VDP_CTRL
    bsr     vdp_clear_tile0
    bsr     vdp_init_default_palette
    rts

wait_vblank:
.wait_off:
    move.w  VDP_CTRL,d0
    btst    #VDP_STATUS_VBLANK,d0
    bne.s   .wait_off
.wait_on:
    move.w  VDP_CTRL,d0
    btst    #VDP_STATUS_VBLANK,d0
    beq.s   .wait_on
    rts

; d0 = endereço VRAM 0..$FFFF
; Encode the Genesis VDP control word explicitly:
;   01xxxxxx xxxxxxxx xxxxxx..  (VRAM write)
vdp_set_vram_write:
    movem.l d1-d2,-(sp)
    move.w  d0,d1
    andi.w  #$3FFF,d1
    swap    d1
    move.w  d0,d2
    andi.w  #$C000,d2
    lsr.w   #8,d2
    lsr.w   #6,d2
    or.w    d2,d1
    ori.l   #$40000000,d1
    move.l  d1,VDP_CTRL
    movem.l (sp)+,d1-d2
    rts

; d0 = endereço CRAM word
vdp_set_cram_write:
    movem.l d1,-(sp)
    move.l  d0,d1
    andi.l  #$0000007F,d1
    swap    d1
    ori.l   #$C0000000,d1
    move.l  d1,VDP_CTRL
    movem.l (sp)+,d1
    rts

; a0 = src, d0 = endereço VRAM, d1 = número de words
vdp_upload_words_cpu:
    movem.l d2,-(sp)
    bsr     vdp_set_vram_write
    move.w  d1,d2
    subq.w  #1,d2
    bmi.s   .done
.loop:
    move.w  (a0)+,VDP_DATA
    dbra    d2,.loop
.done:
    movem.l (sp)+,d2
    rts

; a0 = src, d0 = offset em CRAM words, d1 = número de words
vdp_upload_cram_words_cpu:
    movem.l d2,-(sp)
    bsr     vdp_set_cram_write
    move.w  d1,d2
    subq.w  #1,d2
    bmi.s   .done
.loop:
    move.w  (a0)+,VDP_DATA
    dbra    d2,.loop
.done:
    movem.l (sp)+,d2
    rts

; Clear VRAM tile 0 (32 bytes = 16 words) so blank name-table entries show nothing.
vdp_clear_tile0:
    movem.l d0-d1,-(sp)
    moveq   #0,d0
    bsr     vdp_set_vram_write
    moveq   #16-1,d0
.ct0:
    move.w  #0,VDP_DATA
    dbra    d0,.ct0
    movem.l (sp)+,d0-d1
    rts

vdp_init_default_palette:
    lea     palette_flat16,a0
    moveq   #0,d0
    moveq   #16,d1
    bsr     vdp_upload_cram_words_cpu
    rts
