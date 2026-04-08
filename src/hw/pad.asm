    include "src/core/memory_map.inc"

    xdef pad_init
    xdef pad_read
    xdef pad_prev
    xdef pad_cur
    xdef pad_press
    xdef pad_rel

PAD_UP      equ $0001
PAD_DOWN    equ $0002
PAD_LEFT    equ $0004
PAD_RIGHT   equ $0008
PAD_B       equ $0010
PAD_C       equ $0020
PAD_A       equ $0040
PAD_START   equ $0080

pad_init:
    ; Configure port 1 TH pin as output and default high.
    move.b #$40,PAD1_CTRL
    move.b #$40,PAD1_DATA
    clr.w pad_prev
    clr.w pad_cur
    clr.w pad_press
    clr.w pad_rel
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

    ; Restore TH high for next frame.
    move.b #$40,PAD1_DATA

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
    rts
