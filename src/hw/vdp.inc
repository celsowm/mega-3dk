    ifnd MEGA3DK_VDP_INC
MEGA3DK_VDP_INC         equ 1

VDP_REG_MODE1           equ $8004
VDP_REG_MODE2           equ $8174
VDP_REG_MODE2_OFF       equ $8134      ; display OFF, VBlank IRQ off, DMA off, V28
VDP_REG_PLANEA          equ $8230      ; plane A @ $C000
VDP_REG_WINDOW          equ $8336      ; window table @ $D800 (unused VRAM, away from frame tiles)
VDP_REG_PLANEB          equ $8407      ; plane B @ $E000
VDP_REG_SAT             equ $857C      ; sprite table @ $F800
VDP_REG_BGCOLOR         equ $8700
VDP_REG_MODE3           equ $8B00
VDP_REG_MODE4           equ $8C81      ; H40
VDP_REG_HSCROLL         equ $8D3F
VDP_REG_AUTOINC2        equ $8F02
VDP_REG_PLANESIZE       equ $9000      ; 32x32

VDP_VRAM_PLANEA         equ $C000
VDP_VRAM_PLANEB         equ $E000
VDP_VRAM_SAT            equ $F800
VDP_VRAM_FRAME_TILES    equ $0000

VDP_STATUS_VBLANK       equ 3

VDP_CRAM_BASE            equ $0000

    endif
