    include "src/core/config.inc"
    include "src/core/types.inc"

    xdef build_visible_face_list
    xdef visible_face_count

    xref mesh_cube_faces
    xref proj_vertices
    xref cam_vertices
    xref visible_faces

; Build visible face list with back-face culling.
; Uses screen-space cross product to reject back faces.
; Stores visible faces with depth sum for painter sort.
build_visible_face_list:
    movem.l d2-d7/a0-a3,-(sp)

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

    move.w  d0,d3
    lsl.w   #3,d3
    move.w  d1,d4
    lsl.w   #3,d4
    move.w  d2,d5
    lsl.w   #3,d5

    move.w  VERT2_X(a1,d3.w),d0   ; x0
    move.w  VERT2_Y(a1,d3.w),d1   ; y0
    move.w  VERT2_X(a1,d4.w),d2   ; x1
    move.w  VERT2_Y(a1,d4.w),d3   ; y1
    move.w  VERT2_X(a1,d5.w),d4   ; x2
    move.w  VERT2_Y(a1,d5.w),d5   ; y2

    sub.w   d0,d2                 ; dx01
    sub.w   d1,d3                 ; dy01
    sub.w   d0,d4                 ; dx02
    sub.w   d1,d5                 ; dy02

    muls.w  d5,d2
    muls.w  d4,d3
    sub.l   d3,d2

    ; Y-down screen convention: front faces arrive with cross < 0.
    tst.l   d2
    bge.s   .skip_face

    ; Recompute cam offsets from indices for depth sum.
    move.w  FACE_I0(a0),d0
    move.w  FACE_I1(a0),d1
    move.w  FACE_I2(a0),d2

    move.w  d0,d3
    lsl.w   #3,d3
    move.w  d0,d4
    lsl.w   #2,d4
    add.w   d4,d3

    move.w  d1,d4
    lsl.w   #3,d4
    move.w  d1,d5
    lsl.w   #2,d5
    add.w   d5,d4

    move.w  d2,d5
    lsl.w   #3,d5
    move.w  d2,d0
    lsl.w   #2,d0
    add.w   d0,d5

    move.l  VERT3_Z(a2,d3.w),d0
    add.l   VERT3_Z(a2,d4.w),d0
    add.l   VERT3_Z(a2,d5.w),d0

    move.w  FACE_I0(a0),VFACE_I0(a3)
    move.w  FACE_I1(a0),VFACE_I1(a3)
    move.w  FACE_I2(a0),VFACE_I2(a3)
    move.l  d0,VFACE_DEPTH(a3)
    move.w  FACE_COLOR(a0),VFACE_COLOR(a3)

    lea     VFACE_SIZE(a3),a3
    addq.w  #1,d6

.skip_face:
    lea     FACE_SIZE(a0),a0
    dbra    d7,.loop

    move.w  d6,visible_face_count
    movem.l (sp)+,d2-d7/a0-a3
    rts
