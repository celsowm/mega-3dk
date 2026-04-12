#include "m3dk.h"

static const int32_t g_vertices[] = {
    -65536, -65536, -65536,
     65536, -65536, -65536,
     65536,  65536, -65536,
    -65536,  65536, -65536,
    -65536, -65536,  65536,
     65536, -65536,  65536,
     65536,  65536,  65536,
    -65536,  65536,  65536
};

static const uint16_t g_faces[] = {
    0, 1, 2, 2,
    0, 2, 3, 2,
    4, 6, 5, 3,
    4, 7, 6, 3,
    0, 5, 1, 4,
    0, 4, 5, 4,
    3, 2, 6, 5,
    3, 6, 7, 5,
    1, 5, 6, 6,
    1, 6, 2, 6,
    0, 3, 7, 7,
    0, 7, 4, 7
};

static const uint16_t g_edges[] = {
    0, 1, 1, 2, 2, 3, 3, 0,
    4, 5, 5, 6, 6, 7, 7, 4,
    0, 4, 1, 5, 2, 6, 3, 7
};

static const M3DKMesh g_mesh = {
    g_vertices,
    g_faces,
    8,
    12,
    g_edges,
    12
};

static M3DKRotation g_rotation = {0, 0, 0};
static M3DKCamera g_camera = {4194304, 327680};

void game_init(void) {
    m3dk_init();
    m3dk_set_camera_values(g_camera.projection_distance, g_camera.camera_z_bias);
    m3dk_use_mesh(&g_mesh);
    m3dk_set_rotation_xyz(g_rotation.x, g_rotation.y, g_rotation.z);
}

void game_frame(void) {
    g_rotation.y = (int16_t)(g_rotation.y + 20);
    m3dk_set_rotation_xyz(g_rotation.x, g_rotation.y, g_rotation.z);
    m3dk_frame();
}
