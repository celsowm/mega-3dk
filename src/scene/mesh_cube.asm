    xdef mesh_cube_vertices
    xdef mesh_cube_faces
    xdef mesh_cube_edges
    xdef mesh_cube_edge_count
    xdef mesh_cube

mesh_cube_vertices:
    dc.l -65536,-65536,-65536
    dc.l  65536,-65536,-65536
    dc.l  65536, 65536,-65536
    dc.l -65536, 65536,-65536
    dc.l -65536,-65536, 65536
    dc.l  65536,-65536, 65536
    dc.l  65536, 65536, 65536
    dc.l -65536, 65536, 65536
mesh_cube_faces:
    dc.w 0,2,1,2
    dc.w 0,3,2,2
    dc.w 4,5,6,3
    dc.w 4,6,7,3
    dc.w 0,5,4,4
    dc.w 0,1,5,4
    dc.w 3,6,2,5
    dc.w 3,7,6,5
    dc.w 1,6,5,6
    dc.w 1,2,6,6
    dc.w 0,7,3,7
    dc.w 0,4,7,7
mesh_cube_edges:
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
mesh_cube_edge_count:
    dc.w 12
mesh_cube:
    dc.l mesh_cube_vertices
    dc.l mesh_cube_faces
    dc.w 8
    dc.w 12
