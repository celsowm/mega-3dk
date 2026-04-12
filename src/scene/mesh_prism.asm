    xdef mesh_prism_vertices
    xdef mesh_prism_faces
    xdef mesh_prism_edges
    xdef mesh_prism_edge_count
    xdef mesh_prism

mesh_prism_vertices:
    dc.l  0, 65536,-65536       ; 0  top front
    dc.l -65536,-65536,-65536   ; 1  bottom-left front
    dc.l  65536,-65536,-65536   ; 2  bottom-right front
    dc.l  0, 65536, 65536       ; 3  top back
    dc.l -65536,-65536, 65536   ; 4  bottom-left back
    dc.l  65536,-65536, 65536   ; 5  bottom-right back
mesh_prism_faces:
    dc.w 0,2,1,1                ; front triangle
    dc.w 3,4,5,2                ; back triangle
    dc.w 1,2,5,3                ; bottom quad tri 1
    dc.w 1,5,4,3                ; bottom quad tri 2
    dc.w 0,1,4,4                ; left quad tri 1
    dc.w 0,4,3,4                ; left quad tri 2
    dc.w 0,3,5,5                ; right quad tri 1
    dc.w 0,5,2,5                ; right quad tri 2
mesh_prism_edges:
    dc.w 0,1
    dc.w 1,2
    dc.w 2,0
    dc.w 3,4
    dc.w 4,5
    dc.w 5,3
    dc.w 0,3
    dc.w 1,4
    dc.w 2,5
mesh_prism_edge_count:
    dc.w 9
mesh_prism:
    dc.l mesh_prism_vertices
    dc.l mesh_prism_faces
    dc.w 6
    dc.w 8
    dc.l mesh_prism_edges
    dc.w 9
