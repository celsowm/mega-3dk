# mega-3dk v4.7

Base de engine 3D em 68000 para Mega Drive, organizada para crescer de **wireframe** para **flat-shaded triangles**.

## foco desta v4.7
- reduzir os pontos obscuros do bring-up
- corrigir o desalinhamento entre `tile base` e upload dos tiles
- subir uma paleta padrão logo no `vdp_init`
- deixar o caminho `framebuffer -> tiles -> name table -> VRAM` mais auditável

## correções importantes desta versão
- `PRESENT_TILE_BASE` agora é **0**, alinhado com o upload dos tiles
- `vdp_init` agora chama `vdp_init_default_palette`
- entrou suporte separado para escrita em **CRAM**
- o `present_upload_minimal_cpu` agora documenta e usa a base de tiles de forma coerente
- `STACK_TOP` foi definido em `config.inc`, eliminando uma lacuna do boot

## estado real
Esta v4.7 ainda é um **bring-up técnico sério**, não uma demo confirmada no emulador. Mas o trecho crítico agora ficou mais curto e com menos inconsistências óbvias.

## o que já está mais concreto
- buffer interno 160x112 em 4bpp
- `plot_pixel(x,y,color)` em nibble alto/baixo
- Bresenham inteiro em `draw_line`
- cubo descrito por arestas
- transformação `cube-first`
- packing do framebuffer em tiles 8x8
- name table linear 20x14
- upload mínimo para VRAM por CPU
- paleta padrão em CRAM no init

## o que ainda falta para chamar de demo pronta
- validar o primeiro frame no emulador
- conferir o comando exato do VDP se aparecer tela preta ou layout incorreto
- leitura real do controle 3-button
- revisar o `present` para DMA depois do primeiro frame validado

## marcos seguintes
- v4.8: primeiro frame visual validado
- v4.9: backface culling + faces visíveis
- v5.0: flat-shaded triangles
