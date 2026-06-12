#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/src"
OS_DARWIN="$(cd "$ROOT/../OS/darwin" && pwd)"

echo ""
echo ":: Building FasterCode (macOS)"
echo ""

cd "$SRC/irina"
gcc -Wall -O2 -fPIC -fno-strict-aliasing \
    -c lc.c board.c data.c eval.c hash.c loop.c makemove.c movegen.c movegen_piece_to.c search.c util.c pgn.c parser.c polyglot.c -DNDEBUG
ar rcs libirina.a lc.o board.o data.o eval.o hash.o loop.o makemove.o movegen.o movegen_piece_to.o search.o util.o pgn.o parser.o polyglot.o
mv libirina.a ..
rm -f *.o
cd ..

cat Faster_Irina.pyx Faster_Polyglot.pyx > FasterCode.pyx

PYTHON="${PYTHON:-python3.12}"
"$PYTHON" setup_darwin.py build_ext --inplace --verbose

SO=$(ls -1 FasterCode*.so | head -1)
cp "$SO" "$OS_DARWIN/$SO"

echo ""
echo ":: Installed $SO -> $OS_DARWIN"
echo ":: Building Complete"
echo ""
