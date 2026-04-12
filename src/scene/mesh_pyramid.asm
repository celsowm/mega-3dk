    xdef mesh_pyramid_vertices
    xdef mesh_pyramid_faces
    xdef mesh_pyramid_edges
    xdef mesh_pyramid_edge_count
    xdef mesh_pyramid

mesh_pyramid_vertices:
    dc.l -65536,-65536,-65536
    dc.l  65536,-65536,-65536
    dc.l  65536,-65536, 65536
    dc.l -65536,-65536, 65536
    dc.l  0,65536,0
mesh_pyramid_faces:
    dc.w 0,1,4,1
    dc.w 1,2,4,2
    dc.w 2,3,4,3
    dc.w 3,0,4,4
    dc.w 0,2,1,5
    dc.w 0,3,2,5
mesh_pyramid_edges:
    dc.w 0,1
    dc.w 1,2
    dc.w 2,3
    dc.w 3,0
    dc.w 0,4
    dc.w 1,4
    dc.w 2,4
    dc.w 3,4
mesh_pyramid_edge_count:
    dc.w 8
mesh_pyramid:
    dc.l mesh_pyramid_vertices
    dc.l mesh_pyramid_faces
    dc.w 5
    dc.w 6
    dc.l mesh_pyramid_edges
    dc.w 8
