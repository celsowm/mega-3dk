    include "src/core/config.inc"
    xdef fixed_mul_16_16
    xdef fixed_from_int
    xdef fixed_to_int

; d0 = int -> 16.16
fixed_from_int:
    swap    d0
    clr.w   d0
    rts

; d0 = 16.16 -> integer word sign-extended in d0
fixed_to_int:
    swap    d0
    ext.l   d0
    rts

; d0 = a, d1 = b, retorna d0 = a*b em 16.16
; Accurate enough for the 3D pipeline on 68000.
; (a/256) * (b/256) = (a*b)/65536
fixed_mul_16_16:
    asr.l   #8,d0
    asr.l   #8,d1
    muls.w  d1,d0
    rts
