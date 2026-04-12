    include "src/core/config.inc"
    include "src/core/types.inc"
    include "src/core/vertex_access.inc"
    include "src/scene/mesh.inc"

    xdef build_visible_face_list
    xdef build_solid_face_list
    xdef visible_face_count

; Build visible face list: test each triangle in camera space
; and append the front-facing ones.
build_visible_face_list:
    movem.l d2-d7/a0-a5,-(sp)

    move.l  scene_active_mesh,a5
    move.l  MESH_FACE_PTR(a5),a0
    move.w  MESH_FACE_COUNT(a5),d7
    subq.w  #1,d7
    lea     cam_vertices,a4
    lea     visible_faces,a2
    moveq   #0,d6

.loop:
    move.w  FACE_I0(a0),d0
    move.w  FACE_I1(a0),d1
    move.w  FACE_I2(a0),d2

    bsr     .tri_front_facing
    beq.s   .skip_face

    move.w  FACE_I0(a0),d3
    move.w  FACE_I1(a0),d4
    move.w  FACE_I2(a0),d5

    ; Use summed camera-space Z for painter ordering.
    moveq   #0,d0
    move.w  d3,d1
    bsr     .add_vertex_z
    move.w  d4,d1
    bsr     .add_vertex_z
    move.w  d5,d1
    bsr     .add_vertex_z

    move.w  FACE_I0(a0),VFACE_I0(a2)
    move.w  FACE_I1(a0),VFACE_I1(a2)
    move.w  FACE_I2(a0),VFACE_I2(a2)
    move.l  d0,VFACE_DEPTH(a2)
    move.w  FACE_COLOR(a0),VFACE_COLOR(a2)

    lea     VFACE_SIZE(a2),a2
    addq.w  #1,d6

.skip_face:
    lea     FACE_SIZE(a0),a0
    dbra    d7,.loop

    move.w  d6,visible_face_count
    movem.l (sp)+,d2-d7/a0-a5
    rts

; In: d0/d1/d2 = face vertex indices.
; Out: d0 = 1 when front-facing, 0 otherwise.
.tri_front_facing:
    movem.l d1-d7/a3,-(sp)
    move.w  d2,a3

    VERT3_OFFSET d0,d6,d7
    move.l  VERT3_X(a4,d6.w),d3
    swap    d3
    ext.l   d3
    move.l  VERT3_Y(a4,d6.w),d4
    swap    d4
    ext.l   d4
    move.l  VERT3_Z(a4,d6.w),d5
    swap    d5
    ext.l   d5

    move.w  d3,-(sp)
    move.w  d4,-(sp)
    move.w  d5,-(sp)

    VERT3_OFFSET d1,d6,d7
    move.l  VERT3_X(a4,d6.w),d0
    swap    d0
    ext.l   d0
    move.l  VERT3_Y(a4,d6.w),d1
    swap    d1
    ext.l   d1
    move.l  VERT3_Z(a4,d6.w),d2
    swap    d2
    ext.l   d2

    sub.w   4(sp),d0
    sub.w   2(sp),d1
    sub.w   (sp),d2

    VERT3_OFFSET a3,d6,d7
    move.l  VERT3_X(a4,d6.w),d3
    swap    d3
    ext.l   d3
    move.l  VERT3_Y(a4,d6.w),d7
    swap    d7
    ext.l   d7
    move.l  VERT3_Z(a4,d6.w),d5
    swap    d5
    ext.l   d5

    move.w  d3,d6
    sub.w   4(sp),d6
    sub.w   2(sp),d7
    sub.w   (sp),d5

    move.w  d1,d3
    muls.w  d5,d3
    move.w  d2,d4
    muls.w  d7,d4
    sub.l   d4,d3

    move.w  d0,d4
    muls.w  d7,d4
    move.w  d1,d1
    muls.w  d6,d1
    sub.l   d1,d4

    move.w  d2,d1
    muls.w  d6,d1
    move.w  d0,d7
    muls.w  d5,d7
    sub.l   d7,d1

    move.w  4(sp),d0
    muls.w  d0,d3
    move.w  2(sp),d0
    muls.w  d0,d1
    add.l   d1,d3
    move.w  (sp),d0
    muls.w  d0,d4
    add.l   d4,d3

    addq.l  #6,sp

    moveq   #0,d1
    tst.l   d3
    blt.s   .tf_front
    bra.s   .tf_done
.tf_front:
    moveq   #1,d1
.tf_done:
    move.w  d1,d0
    movem.l (sp)+,d1-d7/a3
    rts

; In: d1 = vertex index.
; In/out: d0 = accumulated Z.
.add_vertex_z:
    VERT3_OFFSET d1,d3,d4
    add.l   VERT3_Z(a4,d3.w),d0
    rts

; Build the full face list for solid rendering (no back-face culling).
build_solid_face_list:
    movem.l d0-d7/a0-a4,-(sp)

    move.l  scene_active_mesh,a4
    move.l  MESH_FACE_PTR(a4),a0
    move.w  MESH_FACE_COUNT(a4),d7
    subq.w  #1,d7
    lea     proj_vertices,a1
    lea     cam_vertices,a2
    lea     visible_faces,a3
    moveq   #0,d6

.s_loop:
    move.w  FACE_I0(a0),VFACE_I0(a3)
    move.w  FACE_I1(a0),VFACE_I1(a3)
    move.w  FACE_I2(a0),VFACE_I2(a3)
    move.w  FACE_COLOR(a0),VFACE_COLOR(a3)

    move.w  FACE_I0(a0),d0
    VERT3_OFFSET d0,d0,d3
    move.w  FACE_I1(a0),d1
    VERT3_OFFSET d1,d1,d4
    move.w  FACE_I2(a0),d2
    VERT3_OFFSET d2,d2,d5

    move.l  VERT3_Z(a2,d0.w),d3
    add.l   VERT3_Z(a2,d1.w),d3
    add.l   VERT3_Z(a2,d2.w),d3
    move.l  d3,VFACE_DEPTH(a3)

    lea     VFACE_SIZE(a3),a3
    addq.w  #1,d6
    lea     FACE_SIZE(a0),a0
    dbra    d7,.s_loop

    move.w  d6,visible_face_count
    movem.l (sp)+,d0-d7/a0-a4
    rts
