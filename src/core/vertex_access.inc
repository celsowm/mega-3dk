    ifnd MEGA3DK_VERTEX_ACCESS_INC
MEGA3DK_VERTEX_ACCESS_INC equ 1

; Compute byte offset for a VERT3 (12 bytes) from a vertex index.
; Usage: VERT3_OFFSET idxReg,outReg,tmpReg
; Clobbers: outReg, tmpReg
VERT3_OFFSET macro
    move.w  \1,\2
    lsl.w   #3,\2
    move.w  \1,\3
    lsl.w   #2,\3
    add.w   \3,\2
    endm

    endif
