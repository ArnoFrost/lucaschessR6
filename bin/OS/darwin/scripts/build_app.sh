#!/bin/bash
# Build LucasChess.app at repository root (calls bin/OS/darwin/scripts/run.sh; venv stays external).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
SCRIPTS_DIR="$ROOT/bin/OS/darwin/scripts"
BUILD_DIR="$SCRIPTS_DIR/.icon-build"
ICONSET="$BUILD_DIR/LucasChess.iconset"
APP="$ROOT/LucasChess.app"
PYTHON="${ROOT}/venv/bin/python"

if [[ ! -x "$PYTHON" ]]; then
  echo "venv not found. Run bin/OS/darwin/scripts/run.sh once to create it." >&2
  exit 1
fi

rm -rf "$BUILD_DIR" "$APP"
mkdir -p "$BUILD_DIR" "$ICONSET"

"$PYTHON" "$SCRIPTS_DIR/export_icon.py" "$BUILD_DIR"

cp "$BUILD_DIR/icon_16x16.png" "$ICONSET/icon_16x16.png"
cp "$BUILD_DIR/icon_32x32.png" "$ICONSET/icon_16x16@2x.png"
cp "$BUILD_DIR/icon_32x32.png" "$ICONSET/icon_32x32.png"
cp "$BUILD_DIR/icon_64x64.png" "$ICONSET/icon_32x32@2x.png"
cp "$BUILD_DIR/icon_128x128.png" "$ICONSET/icon_128x128.png"
cp "$BUILD_DIR/icon_256x256.png" "$ICONSET/icon_128x128@2x.png"
cp "$BUILD_DIR/icon_256x256.png" "$ICONSET/icon_256x256.png"
cp "$BUILD_DIR/icon_512x512.png" "$ICONSET/icon_256x256@2x.png"
cp "$BUILD_DIR/icon_512x512.png" "$ICONSET/icon_512x512.png"
cp "$BUILD_DIR/icon_1024x1024.png" "$ICONSET/icon_512x512@2x.png"

ICNS="$BUILD_DIR/LucasChess.icns"
iconutil -c icns "$ICONSET" -o "$ICNS"

mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ICNS" "$APP/Contents/Resources/LucasChess.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>LucasChess</string>
  <key>CFBundleIconFile</key>
  <string>LucasChess</string>
  <key>CFBundleIdentifier</key>
  <string>com.arnofrost.lucaschess</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Lucas Chess</string>
  <key>CFBundleDisplayName</key>
  <string>Lucas Chess</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>6.0.0</string>
  <key>CFBundleVersion</key>
  <string>6.0.0</string>
  <key>LSMinimumSystemVersion</key>
  <string>11.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>LSUIElement</key>
  <false/>
  <key>LSBackgroundOnly</key>
  <false/>
  <key>CFBundleDocumentTypes</key>
  <array>
    <dict>
      <key>CFBundleTypeExtensions</key>
      <array>
        <string>pgn</string>
      </array>
      <key>CFBundleTypeName</key>
      <string>Portable Game Notation</string>
      <key>CFBundleTypeRole</key>
      <string>Viewer</string>
    </dict>
  </array>
</dict>
</plist>
PLIST

cat > "$APP/Contents/MacOS/LucasChess" <<'LAUNCHER'
#!/bin/bash
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
LOG="$ROOT/UserData/launch.log"
BUG="$ROOT/bin/bug.log"
RUN="$ROOT/bin/OS/darwin/scripts/run.sh"
mkdir -p "$ROOT/UserData"
export LUCASCHESS_FROM_APP=1
export HOME="${HOME:-$(eval echo ~$(id -u))}"
export PATH="/opt/homebrew/bin:/usr/local/bin:${HOME}/miniforge3/bin:${ROOT}/venv/bin:/usr/bin:/bin:/usr/sbin:/sbin"
echo "$(date '+%Y-%m-%d %H:%M:%S') app launcher pid=$$ root=$ROOT" >> "$LOG"
xattr -cr "$RUN" "$ROOT/bin/run_mac.sh" "$ROOT/venv/bin" 2>/dev/null || true
chmod +x "$RUN" "$ROOT/bin/run_mac.sh" 2>/dev/null || true
/usr/bin/osascript -e 'display notification "正在启动，请稍候…" with title "Lucas Chess"' 2>/dev/null || true
/bin/bash "$RUN" "$@"
code=$?
if [[ "$code" -ne 0 ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') app launcher exit code=$code" >> "$LOG"
  msg="启动失败 (exit $code)。请查看: $LOG 和 $BUG"
  /usr/bin/osascript -e "display alert \"Lucas Chess\" message \"$msg\" as critical" 2>/dev/null || true
fi
exit "$code"
LAUNCHER
chmod +x "$APP/Contents/MacOS/LucasChess"

xattr -cr "$APP" 2>/dev/null || true
# Ad-hoc sign launcher only; --deep can block running external venv/python (exit 126).
codesign --force -s - "$APP/Contents/MacOS/LucasChess" 2>/dev/null || true

echo "Built $APP"
echo "Drag to Applications or Dock to use."
