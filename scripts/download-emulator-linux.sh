#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/emulators"
cd "$ROOT/emulators"
URL="https://www.retrodev.com/blastem/nightlies/blastem64.tar.gz"
curl -L "$URL" -o blastem.tar.gz || {
  echo "falha no download automático do BlastEm; ajuste a URL no script" >&2
  exit 1
}
tar -xf blastem.tar.gz --strip-components=1 || true
chmod +x blastem* || true
