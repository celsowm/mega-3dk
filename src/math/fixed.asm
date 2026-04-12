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

; d0 = a (s16.16), d1 = b (s16.16), retorna d0 = a*b em 16.16
; Full-precision 68000 multiply using sign-magnitude decomposition.
;   |A|*|B| >> 16 = Ah*Bh<<16 + Ah*Bl + Al*Bh + (Al*Bl>>16)
; Destroys: d1
fixed_mul_16_16:
    movem.l d2-d6,-(sp)

    ; ---- compute sign into d6, make both operands positive ----
    move.l  d0,d6
    eor.l   d1,d6           ; sign of result in bit 31 of d6

    tst.l   d0
    bpl.s   .a_pos
    neg.l   d0
.a_pos:
    tst.l   d1
    bpl.s   .b_pos
    neg.l   d1
.b_pos:

    ; ---- split: d0 = Ah:Al, d1 = Bh:Bl ----
    move.w  d0,d2           ; d2 = Al (unsigned frac)
    swap    d0              ; d0.w = Ah (unsigned int)
    move.w  d1,d3           ; d3 = Bl
    swap    d1              ; d1.w = Bh

    ; term 0: Al * Bl >> 16
    move.w  d2,d4
    mulu.w  d3,d4           ; d4 = Al * Bl (32-bit)
    clr.w   d4
    swap    d4              ; d4 = Al * Bl >> 16

    ; term 1: Ah * Bl
    move.w  d0,d5
    mulu.w  d3,d5           ; d5 = Ah * Bl
    add.l   d5,d4

    ; term 2: Al * Bh
    mulu.w  d1,d2           ; d2 = Al * Bh
    add.l   d2,d4

    ; term 3: Ah * Bh << 16
    mulu.w  d1,d0           ; d0 = Ah * Bh
    swap    d0
    clr.w   d0              ; d0 = Ah * Bh << 16

    add.l   d4,d0           ; d0 = full result

    ; ---- apply sign ----
    tst.l   d6
    bpl.s   .done
    neg.l   d0
.done:
    movem.l (sp)+,d2-d6
    rts
