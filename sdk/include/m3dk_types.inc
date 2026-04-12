    ifnd MEGA3DK_PUBLIC_TYPES_INC
MEGA3DK_PUBLIC_TYPES_INC equ 1

M3DK_VERSION_MAJOR   equ 4
M3DK_VERSION_MINOR   equ 7
M3DK_VERSION_PATCH   equ 0

M3DK_FIXED_SHIFT     equ 16
M3DK_FIXED_ONE       equ 65536
M3DK_ROTATION_UNITS  equ 1024

M3DK_MESH_VERT_PTR   equ 0
M3DK_MESH_FACE_PTR   equ 4
M3DK_MESH_VERT_COUNT equ 8
M3DK_MESH_FACE_COUNT equ 10
M3DK_MESH_EDGE_PTR   equ 12
M3DK_MESH_EDGE_COUNT equ 16
M3DK_MESH_SIZE       equ 18

M3DK_ROT_X           equ 0
M3DK_ROT_Y           equ 2
M3DK_ROT_Z           equ 4
M3DK_ROT_SIZE        equ 6

M3DK_CAMERA_PROJ_DISTANCE equ 0
M3DK_CAMERA_Z_BIAS        equ 4
M3DK_CAMERA_SIZE          equ 8

M3DK_VERTEX3_X       equ 0
M3DK_VERTEX3_Y       equ 4
M3DK_VERTEX3_Z       equ 8
M3DK_VERTEX3_SIZE    equ 12

M3DK_VERTEX2_X       equ 0
M3DK_VERTEX2_Y       equ 2
M3DK_VERTEX2_Z       equ 4
M3DK_VERTEX2_SIZE    equ 8

M3DK_FACE_I0         equ 0
M3DK_FACE_I1         equ 2
M3DK_FACE_I2         equ 4
M3DK_FACE_COLOR      equ 6
M3DK_FACE_SIZE       equ 8

M3DK_EDGE_I0         equ 0
M3DK_EDGE_I1         equ 2
M3DK_EDGE_SIZE       equ 4

M3DK_PAD_UP          equ $0001
M3DK_PAD_DOWN        equ $0002
M3DK_PAD_LEFT        equ $0004
M3DK_PAD_RIGHT       equ $0008
M3DK_PAD_B           equ $0010
M3DK_PAD_C           equ $0020
M3DK_PAD_A           equ $0040
M3DK_PAD_START       equ $0080

M3DK_PAD_X           equ $0001
M3DK_PAD_Y           equ $0002
M3DK_PAD_Z           equ $0004
M3DK_PAD_MODE        equ $0008
    endif
