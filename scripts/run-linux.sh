#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EMU="$(find "$ROOT/emulators" -maxdepth 1 -type f \( -name 'blastem' -o -name 'blastem64' \) | head -n 1)"
ROM="$ROOT/build/rom/mega-3dk.bin"
[ -x "$EMU" ] || { echo "BlastEm não encontrado" >&2; exit 1; }
[ -f "$ROM" ] || { echo "ROM não encontrada" >&2; exit 1; }
exec "$EMU" "$ROM"
