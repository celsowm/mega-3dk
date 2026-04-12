    xdef mesh_star_vertices
    xdef mesh_star_faces
    xdef mesh_star_edges
    xdef mesh_star_edge_count
    xdef mesh_star

mesh_star_vertices:
    ; Front perimeter (Z = -16384)
    dc.l      0, 65536,-16384   ;  0  outer top
    dc.l -62326, 20266,-16384   ;  1  outer left
    dc.l -38521,-52996,-16384   ;  2  outer bottom-left
    dc.l  38521,-52996,-16384   ;  3  outer bottom-right
    dc.l  62326, 20266,-16384   ;  4  outer right
    dc.l -14716, 20251,-16384   ;  5  inner upper-left
    dc.l -23807, -7737,-16384   ;  6  inner lower-left
    dc.l      0,-25033,-16384   ;  7  inner bottom
    dc.l  23807, -7737,-16384   ;  8  inner lower-right
    dc.l  14716, 20251,-16384   ;  9  inner upper-right
    ; Back perimeter (Z = +16384)
    dc.l      0, 65536, 16384   ; 10
    dc.l -62326, 20266, 16384   ; 11
    dc.l -38521,-52996, 16384   ; 12
    dc.l  38521,-52996, 16384   ; 13
    dc.l  62326, 20266, 16384   ; 14
    dc.l -14716, 20251, 16384   ; 15
    dc.l -23807, -7737, 16384   ; 16
    dc.l      0,-25033, 16384   ; 17
    dc.l  23807, -7737, 16384   ; 18
    dc.l  14716, 20251, 16384   ; 19
    ; Centers
    dc.l      0,     0,-16384   ; 20  front center
    dc.l      0,     0, 16384   ; 21  back center
mesh_star_faces:
    ; Front cap (normal -Z)
    dc.w 20,5,0,1
    dc.w 20,1,5,1
    dc.w 20,6,1,1
    dc.w 20,2,6,1
    dc.w 20,7,2,1
    dc.w 20,3,7,1
    dc.w 20,8,3,1
    dc.w 20,4,8,1
    dc.w 20,9,4,1
    dc.w 20,0,9,1
    ; Back cap (normal +Z)
    dc.w 21,10,15,2
    dc.w 21,15,11,2
    dc.w 21,11,16,2
    dc.w 21,16,12,2
    dc.w 21,12,17,2
    dc.w 21,17,13,2
    dc.w 21,13,18,2
    dc.w 21,18,14,2
    dc.w 21,14,19,2
    dc.w 21,19,10,2
    ; Sides — spike 0 (top-left)
    dc.w 0,5,15,3
    dc.w 0,15,10,3
    dc.w 5,1,11,3
    dc.w 5,11,15,3
    ; Sides — spike 1 (left)
    dc.w 1,6,16,4
    dc.w 1,16,11,4
    dc.w 6,2,12,4
    dc.w 6,12,16,4
    ; Sides — spike 2 (bottom-left)
    dc.w 2,7,17,5
    dc.w 2,17,12,5
    dc.w 7,3,13,5
    dc.w 7,13,17,5
    ; Sides — spike 3 (bottom-right)
    dc.w 3,8,18,6
    dc.w 3,18,13,6
    dc.w 8,4,14,6
    dc.w 8,14,18,6
    ; Sides — spike 4 (right)
    dc.w 4,9,19,7
    dc.w 4,19,14,7
    dc.w 9,0,10,7
    dc.w 9,10,19,7
mesh_star_edges:
    ; Front perimeter
    dc.w 0,5
    dc.w 5,1
    dc.w 1,6
    dc.w 6,2
    dc.w 2,7
    dc.w 7,3
    dc.w 3,8
    dc.w 8,4
    dc.w 4,9
    dc.w 9,0
    ; Back perimeter
    dc.w 10,15
    dc.w 15,11
    dc.w 11,16
    dc.w 16,12
    dc.w 12,17
    dc.w 17,13
    dc.w 13,18
    dc.w 18,14
    dc.w 14,19
    dc.w 19,10
    ; Connecting
    dc.w 0,10
    dc.w 1,11
    dc.w 2,12
    dc.w 3,13
    dc.w 4,14
    dc.w 5,15
    dc.w 6,16
    dc.w 7,17
    dc.w 8,18
    dc.w 9,19
mesh_star_edge_count:
    dc.w 30
mesh_star:
    dc.l mesh_star_vertices
    dc.l mesh_star_faces
    dc.w 22
    dc.w 40
    dc.l mesh_star_edges
    dc.w 30
