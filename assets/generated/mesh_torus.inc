    xdef mesh_torus_vertices
    xdef mesh_torus_faces
    xdef mesh_torus_edges
    xdef mesh_torus_edge_count
    xdef mesh_torus

; Torus primitive: 6 major segments x 4 minor segments = 24 quads = 48 triangles.
; Major radius = 1.10, minor radius = 0.55, in 16.16 fixed-point.
mesh_torus_vertices:
    dc.l  108134,      0,      0
    dc.l   72090,  36045,      0
    dc.l   36045,      0,      0
    dc.l   72090, -36045,      0
    dc.l   54067,      0,  93647
    dc.l   36045,  36045,  62431
    dc.l   18022,      0,  31216
    dc.l   36045, -36045,  62431
    dc.l  -54067,      0,  93647
    dc.l  -36045,  36045,  62431
    dc.l  -18022,      0,  31216
    dc.l  -36045, -36045,  62431
    dc.l -108134,      0,      0
    dc.l  -72090,  36045,      0
    dc.l  -36045,      0,      0
    dc.l  -72090, -36045,      0
    dc.l  -54067,      0, -93647
    dc.l  -36045,  36045, -62431
    dc.l  -18022,      0, -31216
    dc.l  -36045, -36045, -62431
    dc.l   54067,      0, -93647
    dc.l   36045,  36045, -62431
    dc.l   18022,      0, -31216
    dc.l   36045, -36045, -62431
mesh_torus_faces:
    dc.w 0,4,5,15
    dc.w 0,5,1,15
    dc.w 1,5,6,15
    dc.w 1,6,2,15
    dc.w 2,6,7,8
    dc.w 2,7,3,8
    dc.w 3,7,4,8
    dc.w 3,4,0,8
    dc.w 4,8,9,15
    dc.w 4,9,5,15
    dc.w 5,9,10,15
    dc.w 5,10,6,15
    dc.w 6,10,11,8
    dc.w 6,11,7,8
    dc.w 7,11,8,8
    dc.w 7,8,4,8
    dc.w 8,12,13,15
    dc.w 8,13,9,15
    dc.w 9,13,14,15
    dc.w 9,14,10,15
    dc.w 10,14,15,8
    dc.w 10,15,11,8
    dc.w 11,15,12,8
    dc.w 11,12,8,8
    dc.w 12,16,17,15
    dc.w 12,17,13,15
    dc.w 13,17,18,15
    dc.w 13,18,14,15
    dc.w 14,18,19,8
    dc.w 14,19,15,8
    dc.w 15,19,16,8
    dc.w 15,16,12,8
    dc.w 16,20,21,15
    dc.w 16,21,17,15
    dc.w 17,21,22,15
    dc.w 17,22,18,15
    dc.w 18,22,23,8
    dc.w 18,23,19,8
    dc.w 19,23,20,8
    dc.w 19,20,16,8
    dc.w 20,0,1,15
    dc.w 20,1,21,15
    dc.w 21,1,2,15
    dc.w 21,2,22,15
    dc.w 22,2,3,8
    dc.w 22,3,23,8
    dc.w 23,3,0,8
    dc.w 23,0,20,8
mesh_torus_edges:
    dc.w 0,1
    dc.w 0,3
    dc.w 0,4
    dc.w 0,5
    dc.w 0,20
    dc.w 0,23
    dc.w 1,2
    dc.w 1,5
    dc.w 1,6
    dc.w 1,20
    dc.w 1,21
    dc.w 2,3
    dc.w 2,6
    dc.w 2,7
    dc.w 2,21
    dc.w 2,22
    dc.w 3,4
    dc.w 3,7
    dc.w 3,22
    dc.w 3,23
    dc.w 4,5
    dc.w 4,7
    dc.w 4,8
    dc.w 4,9
    dc.w 5,6
    dc.w 5,9
    dc.w 5,10
    dc.w 6,7
    dc.w 6,10
    dc.w 6,11
    dc.w 7,8
    dc.w 7,11
    dc.w 8,9
    dc.w 8,11
    dc.w 8,12
    dc.w 8,13
    dc.w 9,10
    dc.w 9,13
    dc.w 9,14
    dc.w 10,11
    dc.w 10,14
    dc.w 10,15
    dc.w 11,12
    dc.w 11,15
    dc.w 12,13
    dc.w 12,15
    dc.w 12,16
    dc.w 12,17
    dc.w 13,14
    dc.w 13,17
    dc.w 13,18
    dc.w 14,15
    dc.w 14,18
    dc.w 14,19
    dc.w 15,16
    dc.w 15,19
    dc.w 16,17
    dc.w 16,19
    dc.w 16,20
    dc.w 16,21
    dc.w 17,18
    dc.w 17,21
    dc.w 17,22
    dc.w 18,19
    dc.w 18,22
    dc.w 18,23
    dc.w 19,20
    dc.w 19,23
    dc.w 20,21
    dc.w 20,23
    dc.w 21,22
    dc.w 22,23
mesh_torus_edge_count:
    dc.w 72
mesh_torus:
    dc.l mesh_torus_vertices
    dc.l mesh_torus_faces
    dc.w 24
    dc.w 48
    dc.l mesh_torus_edges
    dc.w 72
