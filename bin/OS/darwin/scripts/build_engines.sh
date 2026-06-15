#!/bin/bash
# Build or refresh macOS-native chess engines bundled with this fork.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SCRIPTS_DIR="$ROOT/bin/OS/darwin/scripts"

echo "=== Lucas Chess macOS engines ==="

"$SCRIPTS_DIR/build_irina.sh"

echo
"$SCRIPTS_DIR/build_eguz.sh"

echo
echo "Stockfish: link Homebrew binary if missing."
STOCKFISH_DIR="$ROOT/bin/OS/darwin/Engines/stockfish"
mkdir -p "$STOCKFISH_DIR"
if [[ ! -x "$STOCKFISH_DIR/stockfish" ]]; then
  for candidate in /opt/homebrew/bin/stockfish /usr/local/bin/stockfish; do
    if [[ -x "$candidate" ]]; then
      ln -sf "$candidate" "$STOCKFISH_DIR/stockfish"
      echo "Linked $candidate -> $STOCKFISH_DIR/stockfish"
      break
    fi
  done
fi
if [[ ! -x "$STOCKFISH_DIR/stockfish" ]]; then
  echo "Stockfish not found. Install with: brew install stockfish" >&2
  exit 1
fi

echo
echo "Done. Engines in $ROOT/bin/OS/darwin/Engines/"
