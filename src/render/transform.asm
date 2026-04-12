    include "src/core/config.inc"
    include "src/core/memory_map.inc"
    include "src/core/types.inc"

    xdef transform_mesh_vertices

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
    ; Y Rotation:
    ; x1 = x*cy + z*sy
    ; z1 = -x*sy + z*cy
    move.l  VERT3_X(a1),d0
    move.l  tr_cy,d1
    bsr     fixed_mul_16_16
    move.l  d0,d4                  ; d4 = x*cy

    move.l  VERT3_Z(a1),d0
    move.l  tr_sy,d1
    bsr     fixed_mul_16_16
    add.l   d0,d4                  ; d4 = x1 = x*cy + z*sy

    move.l  VERT3_X(a1),d0
    move.l  tr_sy,d1
    bsr     fixed_mul_16_16
    neg.l   d0
    move.l  d0,d2                  ; d2 = -x*sy

    move.l  VERT3_Z(a1),d0
    move.l  tr_cy,d1
    bsr     fixed_mul_16_16
    add.l   d0,d2                  ; d2 = z1 = -x*sy + z*cy

    ; X Rotation:
    ; y2 = y*cx - z1*sx
    ; z2 = y*sx + z1*cx
    move.l  VERT3_Y(a1),d0
    move.l  tr_cx,d1
    bsr     fixed_mul_16_16
    move.l  d0,d3                  ; d3 = y*cx

    move.l  d2,d0                  ; z1
    move.l  tr_sx,d1
    bsr     fixed_mul_16_16
    sub.l   d0,d3                  ; d3 = y2 = y*cx - z1*sx

    move.l  VERT3_Y(a1),d0
    move.l  tr_sx,d1
    bsr     fixed_mul_16_16
    move.l  d0,d5                  ; d5 = y*sx

    move.l  d2,d0                  ; z1
    move.l  tr_cx,d1
    bsr     fixed_mul_16_16
    add.l   d5,d0
    add.l   camera_z_bias,d0       ; d0 = z2 final

    ; Z Rotation:
    ; x3 = x1*cz - y2*sz
    ; y3 = x1*sz + y2*cz
    move.l  d0,d5                  ; save z2

    move.l  d4,d0                  ; x1
    move.l  tr_cz,d1
    bsr     fixed_mul_16_16
    move.l  d0,d2                  ; d2 = x1*cz

    move.l  d3,d0                  ; y2
    move.l  tr_sz,d1
    bsr     fixed_mul_16_16
    sub.l   d0,d2                  ; d2 = x3 = x1*cz - y2*sz

    move.l  d4,d0                  ; x1
    move.l  tr_sz,d1
    bsr     fixed_mul_16_16
    move.l  d0,d4                  ; d4 = x1*sz (temp)

    move.l  d3,d0                  ; y2
    move.l  tr_cz,d1
    bsr     fixed_mul_16_16
    add.l   d4,d0                  ; d0 = y3 = x1*sz + y2*cz

    move.l  d0,d3                  ; d3 = y3
    move.l  d2,d4                  ; d4 = x3
    move.l  d5,d0                  ; restore z2

    ; store camera-space
    move.l  d0,VERT3_Z(a3)
    move.l  d3,VERT3_Y(a3)
    move.l  d4,VERT3_X(a3)

    ; projection scale = PROJ_DISTANCE * recip(z_int)
    swap    d0
    ext.l   d0
    tst.l   d0
    bgt.s   .z_ok
    moveq   #1,d0
.z_ok:
    bsr     lut_recip
    move.l  d0,d1
    move.l  camera_proj_distance,d0
    bsr     fixed_mul_16_16        ; d0 = scale 16.16
    move.l  d0,a4                  ; save scale in a4

    ; project x using saved x1 (d4)
    move.l  d4,d0
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
