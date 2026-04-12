    include "src/core/config.inc"
    include "src/core/types.inc"
    include "src/scene/mesh.inc"

    xdef draw_scene_wire

; Percorre as arestas do mesh ativo e liga os vértices projetados.
draw_scene_wire:
    movem.l d2-d7/a0-a1,-(sp)
    move.l  scene_active_mesh,a0
    move.l  MESH_EDGE_PTR(a0),a0
    move.l  scene_active_mesh,a1
    move.w  MESH_EDGE_COUNT(a1),d7
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
