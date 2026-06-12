#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/bin"
if [[ ! -x "$ROOT/venv/bin/python" ]]; then
  echo "Creating venv..."
  python3.12 -m venv "$ROOT/venv"
  "$ROOT/venv/bin/pip" install -q -r "$ROOT/requirements.txt"
fi
if [[ ! -f "$ROOT/bin/OS/darwin/FasterCode.cpython-312-darwin.so" ]]; then
  echo "Building FasterCode..."
  PYTHON="$ROOT/venv/bin/python" "$ROOT/venv/bin/pip" install -q cython setuptools
  PYTHON="$ROOT/venv/bin/python" "$ROOT/bin/_fastercode/fastercode_darwin.sh"
fi
exec "$ROOT/venv/bin/python" LucasR.py "$@"
