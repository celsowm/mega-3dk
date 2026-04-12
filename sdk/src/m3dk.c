#include "m3dk.h"

void m3dk_use_mesh(const M3DKMesh *mesh) {
    m3dk_set_active_mesh(mesh);
}

void m3dk_set_rotation_xyz(int16_t x, int16_t y, int16_t z) {
    M3DKRotation rotation;
    rotation.x = x;
    rotation.y = y;
    rotation.z = z;
    m3dk_set_scene_rotation(&rotation);
}

void m3dk_set_camera_values(int32_t projection_distance, int32_t camera_z_bias) {
    M3DKCamera camera;
    camera.projection_distance = projection_distance;
    camera.camera_z_bias = camera_z_bias;
    m3dk_set_camera(&camera);
}

void m3dk_frame(void) {
    m3dk_frame_begin();
    m3dk_clear_frame();
    m3dk_transform_scene();
    m3dk_render_scene();
    m3dk_frame_end();
}
