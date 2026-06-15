#!/bin/bash
# Build Eguzkilore and Eguzki UCI engines for macOS and install into bin/OS/darwin/Engines/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
LINUX_ENGINES="$ROOT/bin/OS/linux/Engines"
DARWIN_ENGINES="$ROOT/bin/OS/darwin/Engines"
BUILD_ROOT="${TMPDIR:-/tmp}/lucaschess-eguz-build"

SOURCES=(
  attacks bitboard book data draw eval evaleguzki evalelo evallore gen init legal main
  movedo moveundo next quiesce search setboard swap test timer trans uci util
)

compile_eguz() {
  local name="$1"
  local build_dir="$BUILD_ROOT/$name"
  local linux_dir="$LINUX_ENGINES/$name"
  local dest="$DARWIN_ENGINES/$name"

  rm -rf "$build_dir"
  mkdir -p "$build_dir"
  bsdtar -xf "$linux_dir/src.7z" -C "$build_dir"

  (
    cd "$build_dir/src"
    rm -f *.o "$name"
    for f in "${SOURCES[@]}"; do
      clang++ -Wall -O3 -c "${f}.cpp" -o "${f}.o" -DNDEBUG
    done
    clang++ -O3 -o "$name" *.o -DNDEBUG
    chmod +x "$name"
  )

  mkdir -p "$dest"
  cp "$build_dir/src/$name" "$dest/$name"
  cp "$linux_dir/${name}.bin" "$dest/${name}.bin"
  chmod +x "$dest/$name"

  echo -e "uci\nisready\nquit" | "$dest/$name" | grep -E '^(id name|uciok|readyok)$'
  file "$dest/$name"
  echo "Installed: $dest"
}

echo "Building Eguzkilore for macOS..."
compile_eguz eguzkilore

echo
echo "Building Eguzki for macOS..."
compile_eguz eguzki
