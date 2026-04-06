    ifnd MEGA3DK_CONFIG_INC
MEGA3DK_CONFIG_INC   equ 1

RENDER_W             equ 160
RENDER_H             equ 112
RENDER_COLOR_BG      equ 0
RENDER_COLOR_FG      equ 15
RENDER_PIPELINE_MODE equ 2      ; 0=wire, 1=visible-face wire, 2=solid fill

SCREEN_CENTER_X      equ 80
SCREEN_CENTER_Y      equ 56

FIX_SHIFT            equ 16
FIX_ONE              equ 65536

PROJ_DISTANCE        equ 4194304     ; 64.0 em 16.16
CAMERA_Z_BIAS        equ 327680      ; 5.0 em 16.16

PRESENT_TILE_W       equ (RENDER_W/8)
PRESENT_TILE_H       equ (RENDER_H/8)
PRESENT_TILE_COUNT   equ (PRESENT_TILE_W*PRESENT_TILE_H)
PRESENT_TILE_BYTES   equ (PRESENT_TILE_COUNT*32)
PRESENT_NAME_BYTES   equ (PRESENT_TILE_COUNT*2)
PRESENT_TILE_BASE    equ 0
PRESENT_PLANE_W      equ 32
PRESENT_OFF_X        equ ((40-PRESENT_TILE_W)/2)
PRESENT_OFF_Y        equ ((28-PRESENT_TILE_H)/2)

MAX_VERTICES         equ 128
MAX_FACES            equ 256
MAX_VISIBLE_FACES    equ 32

; Mega Drive work RAM is at $FF0000-$FFFFFF; keep the stack near the top.
STACK_TOP            equ $00FFFFFC
    endif
