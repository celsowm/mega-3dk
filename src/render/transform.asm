    include "src/core/config.inc"
    include "src/core/types.inc"

    xdef transform_mesh_vertices

    xref scene_active_mesh
    xref scene_rot_x
    xref scene_rot_y
    xref scene_rot_z
    xref proj_vertices
    xref cam_vertices

    xref lut_sin
    xref lut_cos
    xref lut_recip
    xref fixed_mul_16_16
    xref fixed_to_int

    xdef tr_sx
    xdef tr_cx
    xdef tr_sy
    xdef tr_cy
    xdef tr_sz
    xdef tr_cz

; v4.3: implementação orientada ao cubo unitário.
; Preenche proj_vertices para o mesh ativo assumindo vertices +/-1.0.
; Isso destrava o caminho do wireframe antes da generalização total.
transform_mesh_vertices:
    movem.l d2-d7/a0-a4,-(sp)

    move.w  scene_rot_x,d0
    bsr     lut_sin
    move.l  d0,tr_sx
    move.w  scene_rot_x,d0
    bsr     lut_cos
    move.l  d0,tr_cx

    move.w  scene_rot_y,d0
    bsr     lut_sin
    move.l  d0,tr_sy
    move.w  scene_rot_y,d0
    bsr     lut_cos
    move.l  d0,tr_cy

    move.w  scene_rot_z,d0
    bsr     lut_sin
    move.l  d0,tr_sz
    move.w  scene_rot_z,d0
    bsr     lut_cos
    move.l  d0,tr_cz

    move.l  scene_active_mesh,a0
    move.l  (a0),a1                ; vertex ptr
    move.w  8(a0),d7               ; vertex count
    subq.w  #1,d7
    lea     proj_vertices,a2
    lea     cam_vertices,a3

.vloop:
    ; x,z after Y rotation
    move.l  tr_cy,d0
    tst.l   VERT3_X(a1)
    bpl.s   .x_pos_1
    neg.l   d0
.x_pos_1:
    move.l  tr_sy,d1
    tst.l   VERT3_Z(a1)
    bpl.s   .z_pos_1
    neg.l   d1
.z_pos_1:
    add.l   d1,d0                  ; x1

    move.l  tr_sy,d2
    tst.l   VERT3_X(a1)
    bpl.s   .x_pos_2
    neg.l   d2
.x_pos_2:
    neg.l   d2
    move.l  tr_cy,d3
    tst.l   VERT3_Z(a1)
    bpl.s   .z_pos_2
    neg.l   d3
.z_pos_2:
    add.l   d3,d2                  ; z1

    ; y2 = y*cx - z1*sx
    move.l  tr_cx,d3
    tst.l   VERT3_Y(a1)
    bpl.s   .y_pos_1
    neg.l   d3
.y_pos_1:
    move.l  d2,d4
    move.l  tr_sx,d1
    move.l  d4,d0
    bsr     fixed_mul_16_16
    sub.l   d0,d3                  ; y2

    ; z2 = y*sx + z1*cx
    move.l  tr_sx,d4
    tst.l   VERT3_Y(a1)
    bpl.s   .y_pos_2
    neg.l   d4
.y_pos_2:
    move.l  d2,d0
    move.l  tr_cx,d1
    bsr     fixed_mul_16_16
    add.l   d4,d0
    add.l   #CAMERA_Z_BIAS,d0      ; z2 final in d0

    ; store camera-space (rough)
    move.l  d0,VERT3_Z(a3)
    move.l  d3,VERT3_Y(a3)
    move.l  d2,VERT3_X(a3)

    ; projection scale = PROJ_DISTANCE * recip(z_int)
    move.l  d0,d1
    swap    d1
    ext.l   d1
    move.w  d1,d0
    bsr     lut_recip
    move.l  d0,d1
    move.l  #PROJ_DISTANCE,d0
    bsr     fixed_mul_16_16        ; d0 = scale 16.16
    move.l  d0,a4                  ; save scale in a4

    ; project x using x1 in d2? actually x1 was d0 earlier, so rebuild quickly
    move.l  tr_cy,d0
    tst.l   VERT3_X(a1)
    bpl.s   .x_pos_3
    neg.l   d0
.x_pos_3:
    move.l  tr_sy,d1
    tst.l   VERT3_Z(a1)
    bpl.s   .z_pos_3
    neg.l   d1
.z_pos_3:
    add.l   d1,d0                  ; x1 rebuilt
    move.l  a4,d1
    bsr     fixed_mul_16_16
    bsr     fixed_to_int
    addi.w  #SCREEN_CENTER_X,d0
    move.w  d0,VERT2_X(a2)

    ; project y using y2 still in d3
    move.l  d3,d0
    move.l  a4,d1
    bsr     fixed_mul_16_16
    bsr     fixed_to_int
    neg.w   d0
    addi.w  #SCREEN_CENTER_Y,d0
    move.w  d0,VERT2_Y(a2)

    move.l  d1,d1                  ; preserve flags noop-ish
    move.l  VERT3_Z(a3),d6
    move.l  d6,VERT2_Z(a2)

    adda.w  #VERT3_SIZE,a1
    adda.w  #VERT3_SIZE,a3
    adda.w  #VERT2_SIZE,a2
    dbra    d7,.vloop

    movem.l (sp)+,d2-d7/a0-a4
    rts

tr_sx:  ds.l 1
tr_cx:  ds.l 1
tr_sy:  ds.l 1
tr_cy:  ds.l 1
tr_sz:  ds.l 1
tr_cz:  ds.l 1
