    include "src/core/config.inc"
    include "src/core/types.inc"

    xdef draw_scene_solid
    xdef draw_scene_visible_wire

    xref build_visible_face_list
    xref painter_sort_faces
    xref visible_faces
    xref visible_face_count
    xref proj_vertices
    xref tri_setup
    xref draw_scene_wire
    xref draw_line

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
    beq.w   .fallback_wire
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

.fallback_wire:
    bsr     draw_scene_wire
    bra.w   .done

; Build the full cube face list for solid rendering.
; Solid mode does not need back-face culling to produce a correct cube, and
; keeping all faces here avoids coupling fill bring-up to culling polarity.
build_solid_face_list:
    movem.l d0-d7/a0-a3,-(sp)

    lea     mesh_cube_faces,a0
    lea     proj_vertices,a1
    lea     cam_vertices,a2
    lea     visible_faces,a3
    moveq   #0,d6
    moveq   #12-1,d7

.loop:
    move.w  FACE_I0(a0),d0
    move.w  FACE_I1(a0),d1
    move.w  FACE_I2(a0),d2

    move.w  FACE_I0(a0),VFACE_I0(a3)
    move.w  FACE_I1(a0),VFACE_I1(a3)
    move.w  FACE_I2(a0),VFACE_I2(a3)
    move.w  FACE_COLOR(a0),VFACE_COLOR(a3)

    move.w  FACE_I0(a0),d0
    lsl.w   #3,d0
    move.w  FACE_I0(a0),d3
    lsl.w   #2,d3
    add.w   d3,d0
    move.w  FACE_I1(a0),d1
    lsl.w   #3,d1
    move.w  FACE_I1(a0),d4
    lsl.w   #2,d4
    add.w   d4,d1
    move.w  FACE_I2(a0),d2
    lsl.w   #3,d2
    move.w  FACE_I2(a0),d5
    lsl.w   #2,d5
    add.w   d5,d2

    move.l  VERT3_Z(a2,d0.w),d3
    add.l   VERT3_Z(a2,d1.w),d3
    add.l   VERT3_Z(a2,d2.w),d3
    move.l  d3,VFACE_DEPTH(a3)

    lea     VFACE_SIZE(a3),a3
    addq.w  #1,d6
    lea     FACE_SIZE(a0),a0
    dbra    d7,.loop

    move.w  d6,visible_face_count
    movem.l (sp)+,d0-d7/a0-a3
    rts
