#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/toolchain/vasm-src" "$ROOT/toolchain/vasm"
cd "$ROOT/toolchain"
if [ ! -f vasm.tar.gz ]; then
  curl -L "http://sun.hasenbraten.de/vasm/release/vasm.tar.gz" -o vasm.tar.gz
fi
tar -xf vasm.tar.gz -C vasm-src --strip-components=1
cd vasm-src
make CPU=m68k SYNTAX=mot
cp vasmm68k_mot vobjdump "$ROOT/toolchain/vasm/"
echo "toolchain pronta em $ROOT/toolchain/vasm"
