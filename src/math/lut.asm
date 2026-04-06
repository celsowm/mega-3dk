    include "src/math/lut.inc"
    xdef lut_sin
    xdef lut_cos
    xdef lut_recip

    xref sin_lut
    xref recip_lut

; d0 = angle 0..1023 -> d0 = sin(angle) 16.16
lut_sin:
    andi.w  #SIN_LUT_COUNT-1,d0
    lsl.w   #2,d0
    lea     sin_lut,a0
    move.l  0(a0,d0.w),d0
    rts

; d0 = angle 0..1023 -> d0 = cos(angle) 16.16
lut_cos:
    addi.w  #256,d0
    bra     lut_sin

; d0 = n -> d0 = recip[n] 16.16, n clamped to 1..1023
lut_recip:
    tst.w   d0
    bgt.s   .ok
    moveq   #1,d0
.ok:
    cmpi.w  #RECIP_LUT_COUNT-1,d0
    ble.s   .inrange
    move.w  #RECIP_LUT_COUNT-1,d0
.inrange:
    lsl.w   #2,d0
    lea     recip_lut,a0
    move.l  0(a0,d0.w),d0
    rts
