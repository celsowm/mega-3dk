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

prof_lines_drawn     equ WRAM_BASE+$0008

scene_active_mesh    equ WRAM_BASE+$000C
scene_rot_x          equ WRAM_BASE+$0010
scene_rot_y          equ WRAM_BASE+$0012
scene_rot_z          equ WRAM_BASE+$0014

line_x1              equ WRAM_BASE+$0018
line_y1              equ WRAM_BASE+$001A
line_dx              equ WRAM_BASE+$001C
line_dy              equ WRAM_BASE+$001E
line_sx              equ WRAM_BASE+$0020
line_sy              equ WRAM_BASE+$0022
line_err             equ WRAM_BASE+$0024
line_e2              equ WRAM_BASE+$0026

tr_sx                equ WRAM_BASE+$0028
tr_cx                equ WRAM_BASE+$002C
tr_sy                equ WRAM_BASE+$0030
tr_cy                equ WRAM_BASE+$0034
tr_sz                equ WRAM_BASE+$0038
tr_cz                equ WRAM_BASE+$003C

color_buffer         equ WRAM_BASE+$0040
cam_vertices         equ WRAM_BASE+$2340
proj_vertices        equ WRAM_BASE+$2940
visible_faces        equ WRAM_BASE+$2D40
tri_tmp_vertices     equ WRAM_BASE+$3940
tri_setup_state      equ WRAM_BASE+$3958
present_tile_buffer  equ WRAM_BASE+$3998
present_name_table   equ WRAM_BASE+$5EC8
    endif
