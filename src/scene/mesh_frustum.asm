    xdef mesh_frustum_vertices
    xdef mesh_frustum_faces
    xdef mesh_frustum_edges
    xdef mesh_frustum_edge_count
    xdef mesh_frustum

mesh_frustum_vertices:
    dc.l -65536,-65536,-65536   ; 0  bottom-left-front
    dc.l  65536,-65536,-65536   ; 1  bottom-right-front
    dc.l  65536,-65536, 65536   ; 2  bottom-right-back
    dc.l -65536,-65536, 65536   ; 3  bottom-left-back
    dc.l -26214, 65536,-26214   ; 4  top-left-front
    dc.l  26214, 65536,-26214   ; 5  top-right-front
    dc.l  26214, 65536, 26214   ; 6  top-right-back
    dc.l -26214, 65536, 26214   ; 7  top-left-back
mesh_frustum_faces:
    dc.w 0,1,5,2                ; front tri 1
    dc.w 0,5,4,2                ; front tri 2
    dc.w 2,3,7,3                ; back tri 1
    dc.w 2,7,6,3                ; back tri 2
    dc.w 3,0,4,4                ; left tri 1
    dc.w 3,4,7,4                ; left tri 2
    dc.w 1,2,6,5                ; right tri 1
    dc.w 1,6,5,5                ; right tri 2
    dc.w 4,5,6,6                ; top tri 1
    dc.w 4,6,7,6                ; top tri 2
    dc.w 0,3,2,7                ; bottom tri 1
    dc.w 0,2,1,7                ; bottom tri 2
mesh_frustum_edges:
    dc.w 0,1
    dc.w 1,2
    dc.w 2,3
    dc.w 3,0
    dc.w 4,5
    dc.w 5,6
    dc.w 6,7
    dc.w 7,4
    dc.w 0,4
    dc.w 1,5
    dc.w 2,6
    dc.w 3,7
mesh_frustum_edge_count:
    dc.w 12
mesh_frustum:
    dc.l mesh_frustum_vertices
    dc.l mesh_frustum_faces
    dc.w 8
    dc.w 12
    dc.l mesh_frustum_edges
    dc.w 12
