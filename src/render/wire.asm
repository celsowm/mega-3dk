    include "src/core/config.inc"
    include "src/core/types.inc"

    xdef plot_pixel
    xdef draw_line
    xdef draw_scene_wire

    xdef line_x1
    xdef line_y1
    xdef line_dx
    xdef line_dy
    xdef line_sx
    xdef line_sy

; d0=x d1=y d4=color(0..15)
plot_pixel:
    cmpi.w  #0,d0
    blt.s   .out
    cmpi.w  #RENDER_W,d0
    bge.s   .out
    cmpi.w  #0,d1
    blt.s   .out
    cmpi.w  #RENDER_H,d1
    bge.s   .out

    movem.l d2-d3/a0-a1,-(sp)
    lea     y_offset_lut,a1
    add.w   d1,d1
    move.w  (a1,d1.w),d2
    lea     color_buffer,a0
    adda.w  d2,a0

    move.w  d0,d3
    lsr.w   #1,d3
    adda.w  d3,a0

    move.b  (a0),d2
    btst    #0,d0
    bne.s   .odd
    .even:
    andi.b  #$0F,d2
    andi.w  #$000F,d4
    lsl.b   #4,d4
    or.b    d4,d2
    move.b  d2,(a0)
    bra.s   .done
    .odd:
    andi.b  #$F0,d2
    andi.w  #$000F,d4
    or.b    d4,d2
    move.b  d2,(a0)
    .done:
    movem.l (sp)+,d2-d3/a0-a1
    .out:
    rts

    ; d0=x0 d1=y d2=x1 d4=color
    ; Optimized horizontal span filler.
    draw_span_fast:
    ; Clipping
    cmpi.w  #0,d1
    blt.w   .out
    cmpi.w  #RENDER_H,d1
    bge.w   .out

    ; Ensure x0 <= x1
    cmp.w   d2,d0
    ble.s   .x_ok
    exg     d0,d2
    .x_ok:
    cmpi.w  #0,d2
    blt.w   .out
    cmpi.w  #RENDER_W,d0
    bge.w   .out

    ; Clip X
    tst.w   d0
    bge.s   .x0_clip_ok
    moveq   #0,d0
    .x0_clip_ok:
    cmpi.w  #RENDER_W-1,d2
    ble.s   .x1_clip_ok
    move.w  #RENDER_W-1,d2
    .x1_clip_ok:

    movem.l d3-d7/a0-a1,-(sp)

    ; row address
    lea     y_offset_lut,a1
    move.w  d1,d3
    add.w   d3,d3
    move.w  (a1,d3.w),d3
    lea     color_buffer,a0
    adda.w  d3,a0

    ; prep color nibbles
    andi.b  #$0F,d4
    move.b  d4,d5
    lsl.b   #4,d5
    or.b    d4,d5       ; d5 = CC (both nibbles)

    .pixel_loop:
    cmp.w   d2,d0
    bgt.s   .done

    move.w  d0,d3
    lsr.w   #1,d3
    move.b  (a0,d3.w),d6

    btst    #0,d0
    bne.s   .odd
    .even:
    andi.b  #$0F,d6
    move.b  d5,d7
    andi.b  #$F0,d7
    or.b    d7,d6
    move.b  d6,(a0,d3.w)
    bra.s   .next
    .odd:
    andi.b  #$F0,d6
    move.b  d5,d7
    andi.b  #$0F,d7
    or.b    d7,d6
    move.b  d6,(a0,d3.w)

    .next:
    addq.w  #1,d0
    bra.s   .pixel_loop

    .done:
    movem.l (sp)+,d3-d7/a0-a1
    .out:
    rts

    ; d0=x0 d1=y0 d2=x1 d3=y1 d4=color

; v4.3: Bresenham inteiro em versão legível, usando estado temporário em bss.
draw_line:
    movem.l d5-d7,-(sp)
    addq.l  #1,prof_lines_drawn
    move.w  d2,line_x1
    move.w  d3,line_y1
    move.w  d4,d7

    move.w  d2,d5
    sub.w   d0,d5
    bpl.s   .dx_ok
    neg.w   d5
.dx_ok:
    move.w  d5,line_dx

    move.w  d3,d6
    sub.w   d1,d6
    bpl.s   .dy_abs
    neg.w   d6
.dy_abs:
    neg.w   d6
    move.w  d6,line_dy

    move.w  #1,line_sx
    cmp.w   d2,d0
    ble.s   .sx_ok
    move.w  #-1,line_sx
.sx_ok:

    move.w  #1,line_sy
    cmp.w   d3,d1
    ble.s   .sy_ok
    move.w  #-1,line_sy
.sy_ok:

    move.w  line_dx,d5
    add.w   line_dy,d5
    move.w  d5,line_err

.loop:
    move.w  d7,d4
    bsr     plot_pixel

    cmp.w   line_x1,d0
    bne.s   .step
    cmp.w   line_y1,d1
    beq.s   .done
.step:
    move.w  line_err,d5
    add.w   d5,d5
    move.w  d5,line_e2

    cmp.w   line_dy,d5
    blt.s   .skip_x
    move.w  line_err,d6
    add.w   line_dy,d6
    move.w  d6,line_err
    add.w   line_sx,d0
.skip_x:
    move.w  line_e2,d5
    cmp.w   line_dx,d5
    bgt.s   .skip_y
    move.w  line_err,d6
    add.w   line_dx,d6
    move.w  d6,line_err
    add.w   line_sy,d1
.skip_y:
    bra.s   .loop
.done:
    movem.l (sp)+,d5-d7
    rts

; Percorre as 12 arestas do cubo e liga os vértices projetados.
draw_scene_wire:
    movem.l d2-d7/a0-a1,-(sp)
    lea     mesh_cube_edges,a0
    move.w  mesh_cube_edge_count,d7
    subq.w  #1,d7
.edge_loop:
    move.w  (a0)+,d5
    move.w  (a0)+,d6

    lea     proj_vertices,a1

    move.w  d5,d0
    lsl.w   #3,d0
    move.w  VERT2_Y(a1,d0.w),d1
    move.w  VERT2_X(a1,d0.w),d0

    move.w  d6,d2
    lsl.w   #3,d2
    move.w  VERT2_Y(a1,d2.w),d3
    move.w  VERT2_X(a1,d2.w),d2

    moveq   #RENDER_COLOR_FG,d4
    bsr     draw_line
    dbra    d7,.edge_loop

    movem.l (sp)+,d2-d7/a0-a1
    rts
