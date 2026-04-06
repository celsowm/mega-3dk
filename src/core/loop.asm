    xdef main_loop
main_loop:
.frame:
    bsr main_frame
    bra .frame
