    include "src/core/memory_map.inc"
    include "src/hw/pad.inc"

    xdef pad_init
    xdef pad_read
    xdef pad_prev
    xdef pad_cur
    xdef pad_press
    xdef pad_rel
    xdef pad_ext_cur
    xdef pad_ext_press

pad_init:
    ; Configure port 1 TH pin as output and default high.
    move.b #$40,PAD1_CTRL
    move.b #$40,PAD1_DATA
    clr.w pad_prev
    clr.w pad_cur
    clr.w pad_press
    clr.w pad_rel
    clr.w pad_ext_cur
    clr.w pad_ext_press
    rts

pad_read:
    ; 3-button pad read sequence:
    ; TH=1 -> U,D,L,R,B,C
    ; TH=0 -> U,D,0,0,A,START
    move.w pad_cur,pad_prev

    move.b #$40,PAD1_DATA
    nop
    nop
    move.b PAD1_DATA,d0

    move.b #$00,PAD1_DATA
    nop
    nop
    move.b PAD1_DATA,d1

    not.b  d0
    not.b  d1
    andi.b #$3F,d0
    andi.b #$3F,d1

    clr.w  d2

    btst   #0,d0
    beq.s  .no_up
    ori.w  #PAD_UP,d2
.no_up:
    btst   #1,d0
    beq.s  .no_down
    ori.w  #PAD_DOWN,d2
.no_down:
    btst   #2,d0
    beq.s  .no_left
    ori.w  #PAD_LEFT,d2
.no_left:
    btst   #3,d0
    beq.s  .no_right
    ori.w  #PAD_RIGHT,d2
.no_right:
    btst   #4,d0
    beq.s  .no_b
    ori.w  #PAD_B,d2
.no_b:
    btst   #5,d0
    beq.s  .no_c
    ori.w  #PAD_C,d2
.no_c:
    btst   #4,d1
    beq.s  .no_a
    ori.w  #PAD_A,d2
.no_a:
    btst   #5,d1
    beq.s  .no_start
    ori.w  #PAD_START,d2
.no_start:

    move.w d2,pad_cur

    move.w pad_cur,d0
    move.w pad_prev,d1
    eor.w  d1,d0
    move.w d0,d1
    and.w  pad_cur,d1
    move.w d1,pad_press
    move.w d0,d1
    and.w  pad_prev,d1
    move.w d1,pad_rel

    ; 6-button extension: cycles 3-7.
    ; Cycle 3: TH high (same data as cycle 1, skip)
    move.b #$40,PAD1_DATA
    nop
    nop
    ; Cycle 4: TH low (same data as cycle 2, skip)
    move.b #$00,PAD1_DATA
    nop
    nop
    ; Cycle 5: TH high (skip)
    move.b #$40,PAD1_DATA
    nop
    nop
    ; Cycle 6: TH low (skip)
    move.b #$00,PAD1_DATA
    nop
    nop
    ; Cycle 7: TH high -> X/Y/Z/Mode in low nibble
    move.b #$40,PAD1_DATA
    nop
    nop
    move.b PAD1_DATA,d0
    not.b  d0
    andi.w #$000F,d0

    ; Restore TH low then high to reset 6-button counter.
    move.b #$00,PAD1_DATA
    nop
    nop
    move.b #$40,PAD1_DATA

    ; Compute ext press (newly pressed).
    move.w pad_ext_cur,d1
    move.w d0,pad_ext_cur
    eor.w  d1,d0
    and.w  pad_ext_cur,d0
    move.w d0,pad_ext_press
    rts
