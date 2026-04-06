    xdef tri_sort_vertices_by_y

; Sort 3 vertices by Y ascending in registers.
; In:  d0=x0 d1=y0 d2=x1 d3=y1 d4=x2 d5=y2
; Out: d0=x_top d1=y_top d2=x_mid d3=y_mid d4=x_bot d5=y_bot
;      (y_top <= y_mid <= y_bot)
tri_sort_vertices_by_y:
    ; 3-element sorting network: compare-swap (0,1), (1,2), (0,1)
    cmp.w   d3,d1
    blt.s   .s1
    bgt.s   .swap01
    cmp.w   d2,d0
    ble.s   .s1
.swap01:
    exg     d0,d2
    exg     d1,d3
.s1:
    cmp.w   d5,d3
    blt.s   .s2
    bgt.s   .swap12
    cmp.w   d4,d2
    ble.s   .s2
.swap12:
    exg     d2,d4
    exg     d3,d5
.s2:
    cmp.w   d3,d1
    blt.s   .s3
    bgt.s   .swap01b
    cmp.w   d2,d0
    ble.s   .s3
.swap01b:
    exg     d0,d2
    exg     d1,d3
.s3:
    rts
