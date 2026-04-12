    ifnd MEGA3DK_MEMORY_MAP_INC
MEGA3DK_MEMORY_MAP_INC equ 1

VDP_DATA         equ $C00000
VDP_CTRL         equ $C00004
PAD1_DATA        equ $A10003
PAD1_CTRL        equ $A10009

; Work RAM layout. These are absolute addresses in the Mega Drive 64 KB RAM
; window at $FF0000-$FFFFFF, not storage in the ROM image.
WRAM_BASE            equ $00FF0000

pad_prev             equ WRAM_BASE+$0000
pad_cur              equ WRAM_BASE+$0002
pad_press            equ WRAM_BASE+$0004
pad_rel              equ WRAM_BASE+$0006

pad_ext_cur          equ WRAM_BASE+$0008
pad_ext_press        equ WRAM_BASE+$000A

prof_lines_drawn     equ WRAM_BASE+$000C
                                            ; $000E unused (2 bytes)
scene_active_mesh    equ WRAM_BASE+$0010
scene_rot_x          equ WRAM_BASE+$0014
scene_rot_y          equ WRAM_BASE+$0016
scene_rot_z          equ WRAM_BASE+$0018

line_x1              equ WRAM_BASE+$001A
line_y1              equ WRAM_BASE+$001C
line_dx              equ WRAM_BASE+$001E
line_dy              equ WRAM_BASE+$0020
line_sx              equ WRAM_BASE+$0022
line_sy              equ WRAM_BASE+$0024
line_err             equ WRAM_BASE+$0026
line_e2              equ WRAM_BASE+$0028

tr_sx                equ WRAM_BASE+$002C
tr_cx                equ WRAM_BASE+$0030
tr_sy                equ WRAM_BASE+$0034
tr_cy                equ WRAM_BASE+$0038
tr_sz                equ WRAM_BASE+$003C
tr_cz                equ WRAM_BASE+$0040

color_buffer         equ WRAM_BASE+$0044
cam_vertices         equ WRAM_BASE+$2344
proj_vertices        equ WRAM_BASE+$2944
visible_face_count   equ WRAM_BASE+$2F42
visible_faces        equ WRAM_BASE+$2F44
tri_tmp_vertices     equ WRAM_BASE+$3944
tri_setup_state      equ WRAM_BASE+$395C
present_tile_buffer  equ WRAM_BASE+$399C
present_name_table   equ WRAM_BASE+$5ECC
debug_last_span_y    equ WRAM_BASE+$65CC
debug_last_span_x0   equ WRAM_BASE+$65CE
debug_last_span_x1   equ WRAM_BASE+$65D0
debug_last_tri_flags equ WRAM_BASE+$65D2
debug_last_tri_color equ WRAM_BASE+$65D4
debug_last_tri_v0x   equ WRAM_BASE+$65D6
debug_last_tri_v0y   equ WRAM_BASE+$65D8
debug_last_tri_v1x   equ WRAM_BASE+$65DA
debug_last_tri_v1y   equ WRAM_BASE+$65DC
debug_last_tri_v2x   equ WRAM_BASE+$65DE
debug_last_tri_v2y   equ WRAM_BASE+$65E0
    endif
