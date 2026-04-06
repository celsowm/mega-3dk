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
    clr.w pad_prev
    clr.w pad_cur
    clr.w pad_press
    clr.w pad_rel
    rts

pad_read:
    ; TODO v4.3: leitura real do pad via I/O do Mega Drive.
    ; v4.2 mantém a API estável e permite que a cena use pad_cur/pad_press.
    move.w pad_cur,pad_prev
    clr.w  pad_cur
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

pad_prev:   ds.w 1
pad_cur:    ds.w 1
pad_press:  ds.w 1
pad_rel:    ds.w 1
