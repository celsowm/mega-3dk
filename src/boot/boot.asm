    include "../core/config.inc"
    include "vectors.asm"
    include "header.asm"
    include "../core/main.asm"
Reset:
    move    #$2700,sr
    lea     stack_end,sp
    bsr     main_init
main_forever:
    bsr     main_loop
    bra     main_forever
stack_space:
    ds.b    1024
stack_end:
EndROM:
