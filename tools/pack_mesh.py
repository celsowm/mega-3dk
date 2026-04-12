#!/usr/bin/env python3
from pathlib import Path
import math

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / 'assets' / 'generated'


def write_mesh_cube_placeholder() -> None:
    out = OUT_DIR / 'mesh_cube.inc'
    out.write_text('; placeholder generated mesh include\n', encoding='utf-8')


def torus_vertices(major_segments: int, minor_segments: int, major_radius: float, minor_radius: float):
    scale = 65536
    vertices = []
    for i in range(major_segments):
        theta = 2.0 * math.pi * i / major_segments
        ct = math.cos(theta)
        st = math.sin(theta)
        for j in range(minor_segments):
            phi = 2.0 * math.pi * j / minor_segments
            cp = math.cos(phi)
            sp = math.sin(phi)
            ring = major_radius + minor_radius * cp
            x = round(ring * ct * scale)
            y = round(minor_radius * sp * scale)
            z = round(ring * st * scale)
            vertices.append((x, y, z))
    return vertices


def torus_faces_and_edges(vertices, major_segments: int, minor_segments: int):
    faces = []
    edges = set()
    light_color = 15
    dark_color = 8
    for i in range(major_segments):
        inext = (i + 1) % major_segments
        for j in range(minor_segments):
            jnext = (j + 1) % minor_segments
            a = i * minor_segments + j
            b = inext * minor_segments + j
            c = inext * minor_segments + jnext
            d = i * minor_segments + jnext
            ay = vertices[a][1]
            by = vertices[b][1]
            cy = vertices[c][1]
            # Split the torus into a bright half and a dark half using face height.
            face_y = ay + by + cy
            color = light_color if face_y >= 0 else dark_color
            faces.append((a, b, c, color))
            faces.append((a, c, d, color))
            for edge in ((a, b), (b, c), (c, a), (a, d), (d, c)):
                edges.add(tuple(sorted(edge)))
    return faces, sorted(edges)


def write_mesh_torus_include() -> None:
    major_segments = 6
    minor_segments = 4
    major_radius = 1.10
    minor_radius = 0.55

    vertices = torus_vertices(major_segments, minor_segments, major_radius, minor_radius)
    faces, edges = torus_faces_and_edges(vertices, major_segments, minor_segments)

    out = OUT_DIR / 'mesh_torus.inc'
    lines = []
    lines.append('    xdef mesh_torus_vertices')
    lines.append('    xdef mesh_torus_faces')
    lines.append('    xdef mesh_torus_edges')
    lines.append('    xdef mesh_torus_edge_count')
    lines.append('    xdef mesh_torus')
    lines.append('')
    tri_count = len(faces)
    quad_count = major_segments * minor_segments
    lines.append(f'; Torus primitive: {major_segments} major segments x {minor_segments} minor segments = {quad_count} quads = {tri_count} triangles.')
    lines.append('; Major radius = 1.10, minor radius = 0.55, in 16.16 fixed-point.')
    lines.append('mesh_torus_vertices:')
    for x, y, z in vertices:
        lines.append(f'    dc.l {x:>7d},{y:>7d},{z:>7d}')
    lines.append('mesh_torus_faces:')
    for a, b, c, color in faces:
        lines.append(f'    dc.w {a},{b},{c},{color}')
    lines.append('mesh_torus_edges:')
    for a, b in edges:
        lines.append(f'    dc.w {a},{b}')
    lines.append('mesh_torus_edge_count:')
    lines.append(f'    dc.w {len(edges)}')
    lines.append('mesh_torus:')
    lines.append('    dc.l mesh_torus_vertices')
    lines.append('    dc.l mesh_torus_faces')
    lines.append(f'    dc.w {len(vertices)}')
    lines.append(f'    dc.w {len(faces)}')
    lines.append('    dc.l mesh_torus_edges')
    lines.append(f'    dc.w {len(edges)}')
    out.write_text('\n'.join(lines) + '\n', encoding='utf-8')


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    write_mesh_cube_placeholder()
    write_mesh_torus_include()
    print('generated mesh includes: mesh_cube.inc, mesh_torus.inc')


if __name__ == '__main__':
    main()
