#!/bin/bash
# Build Irina UCI engine for macOS (arm64) and install into bin/OS/darwin/Engines/irina/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SCRIPTS_DIR="$ROOT/bin/OS/darwin/scripts"
BUILD_DIR="${TMPDIR:-/tmp}/lucaschess-irina-build"
SRC_DIR="$BUILD_DIR/src"
DEST="$ROOT/bin/OS/darwin/Engines/irina"
LINUX_IRINA="$ROOT/bin/OS/linux/Engines/irina"
IRINA_REPO="${IRINA_REPO:-https://github.com/lukasmonk/irina.git}"

SOURCES=(
  main loop board data util movegen makemove perft eval evalst search person hash tt book
)

clone_source() {
  rm -rf "$BUILD_DIR"
  git clone --depth 1 "$IRINA_REPO" "$BUILD_DIR"
}

compile_irina() {
  rm -rf "$SRC_DIR/build" "$SRC_DIR/irina"
  mkdir -p "$SRC_DIR/build"
  for f in "${SOURCES[@]}"; do
    clang -Wall -O3 -c "${f}.c" -o "build/${f}.o" -DNDEBUG
  done
  clang -O3 -o irina build/*.o -DNDEBUG
  chmod +x irina
}

install_irina() {
  mkdir -p "$DEST"
  cp "$SRC_DIR/irina" "$DEST/irina"
  if [[ -f "$LINUX_IRINA/irina.bin" ]]; then
    cp "$LINUX_IRINA/irina.bin" "$DEST/irina.bin"
  elif [[ ! -f "$DEST/irina.bin" ]]; then
    echo "Missing irina.bin. Expected at $LINUX_IRINA/irina.bin" >&2
    exit 1
  fi
  if [[ -f "$LINUX_IRINA/logo.info" ]]; then
    cp "$LINUX_IRINA/logo.info" "$DEST/logo.info"
  fi
  chmod +x "$DEST/irina"
}

echo "Building Irina for macOS..."
clone_source
(
  cd "$SRC_DIR"
  compile_irina
)
install_irina

echo -e "uci\nisready\nquit" | "$DEST/irina" | grep -E '^(id name|uciok|readyok)$'
file "$DEST/irina"
echo "Installed: $DEST"
