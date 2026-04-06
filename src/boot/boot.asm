    include "vectors.asm"
    include "header.asm"
    org $000200
    include "../core/main.asm"
    include "../core/loop.asm"
    include "../hw/vdp.asm"
    include "../hw/pad.asm"
    include "../core/profiler.asm"
    include "../scene/mesh_cube.asm"
    include "../data/palette.asm"
    include "../data/luts.asm"
    include "../math/lut.asm"
    include "../math/fixed.asm"
    include "../scene/scene_bench.asm"
    include "../render/clear.asm"
    include "../render/transform.asm"
    include "../render/wire.asm"
    include "../render/present.asm"
    include "../debug/overlay.asm"
Reset:
    move    #$2700,sr
    lea     stack_end,sp
    jsr     main_init
main_forever:
    jsr     main_loop
    bra     main_forever
stack_space:
    ds.b    1024
stack_end:
EndROM:
