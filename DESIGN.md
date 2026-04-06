# DESIGN v4.7

## pipeline wireframe atual
1. `wait_vblank`
2. `pad_read`
3. `scene_bench_update`
4. `clear_color_buffer`
5. `transform_mesh_vertices`
6. `draw_scene_wire`
7. `present_frame`
8. `debug_overlay_draw`

## foco desta versão
O objetivo da v4.7 é deixar o bring-up do primeiro frame mais confiável:
- paleta inicial em CRAM
- base de tiles coerente
- boot sem símbolo solto de stack
- caminho mínimo de VDP mais concentrado

## present_frame na v4.7
1. `present_pack_full_frame_4bpp_to_tiles`
2. `present_build_linear_name_table`
3. `present_upload_minimal_cpu`

## pontos de bring-up que ficaram melhores
- `PRESENT_TILE_BASE` e upload agora batem
- o VDP já sobe uma paleta visível no init
- helpers de VRAM e CRAM foram separados

## pontos ainda sensíveis
- polling de VBlank continua simples
- o comando de write do VDP ainda depende de validação prática
- o `present` ainda é full-frame e caro
