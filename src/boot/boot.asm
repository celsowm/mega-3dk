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
    include "../render/cull.asm"
    include "../render/painter.asm"
    include "../render/tri_sort_y.asm"
    include "../render/tri_setup.asm"
    include "../render/tri_fill_fast.asm"
    include "../render/solid.asm"
    include "../render/present.asm"
    include "../debug/overlay.asm"
BootEntry:
    move    #$2700,sr
    move.l  #STACK_TOP,sp
    jsr     main_init
main_forever:
    jsr     main_loop
    bra     main_forever
EndROM:
