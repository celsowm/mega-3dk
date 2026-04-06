    include "src/core/config.inc"
    xdef fixed_mul_16_16
    xdef fixed_from_int
    xdef fixed_to_int

; d0 = int -> 16.16
fixed_from_int:
    lsl.l   #FIX_SHIFT,d0
    rts

; d0 = 16.16 -> integer word sign-extended in d0
fixed_to_int:
    asr.l   #FIX_SHIFT,d0
    rts

; d0 = a, d1 = b, retorna d0 = a*b em 16.16
; aproximação suficiente para a fase wireframe:
; (a>>8)*(b>>8) preserva escala 16.16 para valores pequenos/moderados.
fixed_mul_16_16:
    asr.l   #8,d0
    asr.l   #8,d1
    move.w  d0,d0
    move.w  d1,d1
    muls.w  d1,d0
    rts
