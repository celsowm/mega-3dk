#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/bootstrap-linux.sh"
"$ROOT/scripts/download-emulator-linux.sh" || true
"$ROOT/scripts/build-linux.sh"
"$ROOT/scripts/run-linux.sh"
