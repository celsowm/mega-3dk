    xdef profiler_reset
    xdef prof_lines_drawn

profiler_reset:
    clr.l prof_lines_drawn
    rts

prof_lines_drawn:
    ds.l 1
