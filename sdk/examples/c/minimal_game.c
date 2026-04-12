#include "m3dk.h"

extern const M3DKMesh mesh_cube;

static M3DKRotation g_rotation = {0, 0, 0};
static M3DKCamera g_camera = {4194304, 327680};

void game_init(void) {
    m3dk_init();
    m3dk_set_camera_values(g_camera.projection_distance, g_camera.camera_z_bias);
    m3dk_use_mesh(&mesh_cube);
    m3dk_set_rotation_xyz(g_rotation.x, g_rotation.y, g_rotation.z);
}

void game_frame(void) {
    g_rotation.y = (int16_t)(g_rotation.y + 24);
    m3dk_set_rotation_xyz(g_rotation.x, g_rotation.y, g_rotation.z);
    m3dk_frame();
}
