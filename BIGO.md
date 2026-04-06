# Big-O do pipeline v4.7

## wireframe atual
- `pad/update`: **O(1)**
- `clear_color_buffer`: **O(W*H)**
- `transform_mesh_vertices`: **O(V)**
- `draw_scene_wire`: **O(E*L)**
- `present_pack_full_frame_4bpp_to_tiles`: **O(W*H)**
- `present_build_linear_name_table`: **O(T)**
- `present_upload_minimal_cpu`: **O(B)**

Onde:
- `V` = número de vértices
- `E` = número de arestas
- `L` = comprimento médio das linhas
- `W*H` = área do framebuffer interno
- `T` = número de tiles do frame
- `B` = bytes enviados ao VDP

## revisão prática
O ponto principal continua sendo este:
- matemática e transformação são lineares e relativamente baratas para meshes pequenas
- o custo estrutural do wireframe está em **limpar, empacotar e subir o frame**

Em outras palavras, o gargalo mais provável da arquitetura atual é:
**`clear + pack + upload`**, não a rotação do cubo.

## bugs de bring-up e Big-O
A v4.7 corrigiu um problema que não muda a Big-O, mas muda tudo no resultado: a incoerência entre a base dos tiles e o upload. Isso é um bom exemplo de como, em console antigo, a corretude do layout pesa tanto quanto o custo assintótico.
