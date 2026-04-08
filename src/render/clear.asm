    include "src/core/config.inc"
    xdef clear_color_buffer
clear_color_buffer:
    lea color_buffer,a0
    move.w #((RENDER_W*RENDER_H)/2)/4-1,d0
    move.l #0,d1
.loop:
    move.l d1,(a0)+
    dbra d0,.loop
    rts
