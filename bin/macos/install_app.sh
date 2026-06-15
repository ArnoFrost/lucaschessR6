#!/bin/bash
# Build LucasChess.app, clear quarantine, and open it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
"$ROOT/bin/macos/build_app.sh"
xattr -cr "$ROOT/LucasChess.app" 2>/dev/null || true
chmod +x "$ROOT/LucasChess.app/Contents/MacOS/LucasChess"
codesign --force -s - "$ROOT/LucasChess.app/Contents/MacOS/LucasChess" 2>/dev/null || true
echo "已安装 LucasChess.app → $ROOT/LucasChess.app"
echo "若 Finder 双击无反应：在 .app 上右键 → 打开（首次需确认）"
open "$ROOT/LucasChess.app"
