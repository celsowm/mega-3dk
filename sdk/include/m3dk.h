#ifndef M3DK_H
#define M3DK_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct M3DKMesh {
    const int32_t *vertices;
    const uint16_t *faces;
    uint16_t vertex_count;
    uint16_t face_count;
    const uint16_t *edges;
    uint16_t edge_count;
} M3DKMesh;

typedef struct M3DKRotation {
    int16_t x;
    int16_t y;
    int16_t z;
} M3DKRotation;

typedef struct M3DKCamera {
    int32_t projection_distance;
    int32_t camera_z_bias;
} M3DKCamera;

enum M3DKPadButton {
    M3DK_PAD_UP = 0x0001,
    M3DK_PAD_DOWN = 0x0002,
    M3DK_PAD_LEFT = 0x0004,
    M3DK_PAD_RIGHT = 0x0008,
    M3DK_PAD_B = 0x0010,
    M3DK_PAD_C = 0x0020,
    M3DK_PAD_A = 0x0040,
    M3DK_PAD_START = 0x0080
};

void m3dk_init(void);
void m3dk_frame_begin(void);
void m3dk_frame_end(void);
void m3dk_present_frame(void);
void m3dk_clear_frame(void);
void m3dk_transform_scene(void);
void m3dk_render_scene(void);
void m3dk_draw_wireframe(void);
void m3dk_draw_visible_wireframe(void);
void m3dk_draw_solid(void);
void m3dk_set_active_mesh(const M3DKMesh *mesh);
const M3DKMesh *m3dk_get_active_mesh(void);
void m3dk_set_scene_rotation(const M3DKRotation *rotation);
void m3dk_set_camera(const M3DKCamera *camera);
uint16_t m3dk_get_pad_cur(void);
uint16_t m3dk_get_pad_press(void);
uint16_t m3dk_get_pad_ext_cur(void);
uint16_t m3dk_get_pad_ext_press(void);

/* C-friendly helpers layered on top of the assembly API. */
void m3dk_use_mesh(const M3DKMesh *mesh);
void m3dk_set_rotation_xyz(int16_t x, int16_t y, int16_t z);
void m3dk_set_camera_values(int32_t projection_distance, int32_t camera_z_bias);
void m3dk_frame(void);

#ifdef __cplusplus
}
#endif

#endif
