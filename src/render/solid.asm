    include "src/core/config.inc"
    include "src/core/types.inc"
    include "src/scene/mesh.inc"

    xdef draw_scene_solid
    xdef draw_scene_visible_wire

draw_scene_visible_wire:
    movem.l d2-d7/a0-a2,-(sp)

    bsr     build_visible_face_list
    bsr     painter_sort_faces

    lea     visible_faces,a0
    move.w  visible_face_count,d7
    beq.w   .vw_fallback_wire
    subq.w  #1,d7
    blt.w   .vw_done

.vw_face_loop:
    lea     proj_vertices,a1

    move.w  VFACE_I0(a0),d2
    lsl.w   #3,d2
    move.w  VERT2_X(a1,d2.w),d0
    move.w  VERT2_Y(a1,d2.w),d1
    move.w  VFACE_I1(a0),d3
    lsl.w   #3,d3
    move.w  VERT2_X(a1,d3.w),d2
    move.w  VERT2_Y(a1,d3.w),d3
    move.w  VFACE_COLOR(a0),d4
    andi.w  #$000F,d4
    movem.l d7/a0,-(sp)
    bsr     draw_line
    movem.l (sp)+,d7/a0

    lea     proj_vertices,a1
    move.w  VFACE_I1(a0),d2
    lsl.w   #3,d2
    move.w  VERT2_X(a1,d2.w),d0
    move.w  VERT2_Y(a1,d2.w),d1
    move.w  VFACE_I2(a0),d3
    lsl.w   #3,d3
    move.w  VERT2_X(a1,d3.w),d2
    move.w  VERT2_Y(a1,d3.w),d3
    move.w  VFACE_COLOR(a0),d4
    andi.w  #$000F,d4
    movem.l d7/a0,-(sp)
    bsr     draw_line
    movem.l (sp)+,d7/a0

    lea     proj_vertices,a1
    move.w  VFACE_I2(a0),d2
    lsl.w   #3,d2
    move.w  VERT2_X(a1,d2.w),d0
    move.w  VERT2_Y(a1,d2.w),d1
    move.w  VFACE_I0(a0),d3
    lsl.w   #3,d3
    move.w  VERT2_X(a1,d3.w),d2
    move.w  VERT2_Y(a1,d3.w),d3
    move.w  VFACE_COLOR(a0),d4
    andi.w  #$000F,d4
    movem.l d7/a0,-(sp)
    bsr     draw_line
    movem.l (sp)+,d7/a0

    lea     VFACE_SIZE(a0),a0
    dbra    d7,.vw_face_loop

.vw_done:
    movem.l (sp)+,d2-d7/a0-a2
    rts

.vw_fallback_wire:
    bsr     draw_scene_wire
    bra.w   .vw_done

draw_scene_solid:
    movem.l d2-d7/a0-a3,-(sp)

    bsr     build_solid_face_list
    bsr     painter_sort_faces

    lea     visible_faces,a0
    move.w  visible_face_count,d0
    beq.w   .done
    subq.w  #1,d0
    move.w  d0,d7

.face_loop:
    lea     proj_vertices,a1

    move.w  VFACE_I0(a0),d3
    lsl.w   #3,d3
    move.w  VERT2_X(a1,d3.w),d0
    move.w  VERT2_Y(a1,d3.w),d1

    move.w  VFACE_I1(a0),d4
    lsl.w   #3,d4
    move.w  VERT2_X(a1,d4.w),d2
    move.w  VERT2_Y(a1,d4.w),d3

    move.w  VFACE_I2(a0),d5
    lsl.w   #3,d5
    move.w  VERT2_X(a1,d5.w),d4
    move.w  VERT2_Y(a1,d5.w),d5

    move.w  VFACE_COLOR(a0),d6

    movem.l d7/a0,-(sp)
    bsr     tri_setup
    movem.l (sp)+,d7/a0

    lea     VFACE_SIZE(a0),a0
    dbra    d7,.face_loop

.done:
    movem.l (sp)+,d2-d7/a0-a3
    rts
