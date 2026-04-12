    xdef mesh_dodeca_vertices
    xdef mesh_dodeca_faces
    xdef mesh_dodeca_edges
    xdef mesh_dodeca_edge_count
    xdef mesh_dodeca

mesh_dodeca_vertices:
    dc.l -40503,-40503,-40503   ;  0
    dc.l  40503,-40503,-40503   ;  1
    dc.l  40503, 40503,-40503   ;  2
    dc.l -40503, 40503,-40503   ;  3
    dc.l -40503,-40503, 40503   ;  4
    dc.l  40503,-40503, 40503   ;  5
    dc.l  40503, 40503, 40503   ;  6
    dc.l -40503, 40503, 40503   ;  7
    dc.l      0,-25033,-65536   ;  8
    dc.l      0, 25033,-65536   ;  9
    dc.l      0,-25033, 65536   ; 10
    dc.l      0, 25033, 65536   ; 11
    dc.l -25033,-65536,     0   ; 12
    dc.l  25033,-65536,     0   ; 13
    dc.l -25033, 65536,     0   ; 14
    dc.l  25033, 65536,     0   ; 15
    dc.l -65536,     0,-25033   ; 16
    dc.l  65536,     0,-25033   ; 17
    dc.l -65536,     0, 25033   ; 18
    dc.l  65536,     0, 25033   ; 19
mesh_dodeca_faces:
    dc.w 0,8,1,2
    dc.w 0,1,13,2
    dc.w 0,13,12,2
    dc.w 0,12,4,3
    dc.w 0,4,18,3
    dc.w 0,18,16,3
    dc.w 0,16,3,4
    dc.w 0,3,9,4
    dc.w 0,9,8,4
    dc.w 1,8,9,5
    dc.w 1,9,2,5
    dc.w 1,2,17,5
    dc.w 1,17,19,6
    dc.w 1,19,5,6
    dc.w 1,5,13,6
    dc.w 2,9,3,7
    dc.w 2,3,14,7
    dc.w 2,14,15,7
    dc.w 2,15,6,8
    dc.w 2,6,19,8
    dc.w 2,19,17,8
    dc.w 3,16,18,9
    dc.w 3,18,7,9
    dc.w 3,7,14,9
    dc.w 4,12,13,10
    dc.w 4,13,5,10
    dc.w 4,5,10,10
    dc.w 4,10,11,11
    dc.w 4,11,7,11
    dc.w 4,7,18,11
    dc.w 5,19,6,12
    dc.w 5,6,11,12
    dc.w 5,11,10,12
    dc.w 6,15,14,13
    dc.w 6,14,7,13
    dc.w 6,7,11,13
mesh_dodeca_edges:
    dc.w 0,8
    dc.w 0,12
    dc.w 0,16
    dc.w 1,8
    dc.w 1,13
    dc.w 1,17
    dc.w 2,9
    dc.w 2,15
    dc.w 2,17
    dc.w 3,9
    dc.w 3,14
    dc.w 3,16
    dc.w 4,10
    dc.w 4,12
    dc.w 4,18
    dc.w 5,10
    dc.w 5,13
    dc.w 5,19
    dc.w 6,11
    dc.w 6,15
    dc.w 6,19
    dc.w 7,11
    dc.w 7,14
    dc.w 7,18
    dc.w 8,9
    dc.w 10,11
    dc.w 12,13
    dc.w 14,15
    dc.w 16,18
    dc.w 17,19
mesh_dodeca_edge_count:
    dc.w 30
mesh_dodeca:
    dc.l mesh_dodeca_vertices
    dc.l mesh_dodeca_faces
    dc.w 20
    dc.w 36
    dc.l mesh_dodeca_edges
    dc.w 30
