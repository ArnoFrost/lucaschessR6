#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/bin"
LOG_FILE="$ROOT/UserData/launch.log"
mkdir -p "$ROOT/UserData"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

log "=== launch pid=$$ pwd=$(pwd) argv=$* ==="
trap 'log "shell exit code=$?"' EXIT

find_python312() {
  local found
  if command -v python3.12 &>/dev/null; then
    command -v python3.12
    return 0
  fi
  if [[ -x "${HOME}/miniforge3/bin/python3.12" ]]; then
    echo "${HOME}/miniforge3/bin/python3.12"
    return 0
  fi
  if [[ -x "/opt/homebrew/bin/python3.12" ]]; then
    echo "/opt/homebrew/bin/python3.12"
    return 0
  fi
  if [[ -x "/usr/local/bin/python3.12" ]]; then
    echo "/usr/local/bin/python3.12"
    return 0
  fi
  if command -v uv &>/dev/null; then
    found="$(uv python find 3.12 2>/dev/null || true)"
    if [[ -n "$found" ]]; then
      echo "$found"
      return 0
    fi
  fi
  log "ERROR python3.12 not found"
  echo "python3.12 not found. Try: brew install python@3.12  or  uv python install 3.12" >&2
  exit 1
}

python_runnable() {
  local py="$1"
  local rc=0
  [[ -n "$py" && -x "$py" ]] || return 1
  "$py" -c "import sys" 2>/dev/null || rc=$?
  if [[ "$rc" -ne 0 ]]; then
    log "python not runnable: $py (exit $rc)"
  fi
  [[ "$rc" -eq 0 ]]
}

app_fallback_python() {
  local py
  for py in /opt/homebrew/bin/python3.12 /usr/local/bin/python3.12 "${HOME}/miniforge3/bin/python3.12"; do
    if python_runnable "$py"; then
      export VIRTUAL_ENV="$ROOT/venv"
      export PATH="$ROOT/venv/bin:$(dirname "$py"):$PATH"
      log "app fallback python: $py (VIRTUAL_ENV=$ROOT/venv)"
      echo "$py"
      return 0
    fi
  done
  return 1
}

clear_app_launch_quarantine() {
  [[ "${LUCASCHESS_FROM_APP:-}" == 1 ]] || return 0
  xattr -cr "$ROOT/bin/run_mac.sh" "$ROOT/venv/bin" 2>/dev/null || true
  chmod +x "$ROOT/bin/run_mac.sh" 2>/dev/null || true
}

venv_deps_ok() {
  "$ROOT/venv/bin/python" -c "from PySide6 import QtMultimedia" 2>/dev/null
}

install_venv_deps() {
  log "pip install -r requirements.txt (PySide6 ~450MB, may take 1-2 min)"
  if ! "$ROOT/venv/bin/pip" install -r "$ROOT/requirements.txt" >> "$LOG_FILE" 2>&1; then
    log "ERROR pip install failed"
    return 1
  fi
  if ! venv_deps_ok; then
    log "ERROR PySide6 QtMultimedia missing after pip install"
    return 1
  fi
  log "pip install OK"
  return 0
}

ensure_venv() {
  clear_app_launch_quarantine
  if [[ "${LUCASCHESS_FROM_APP:-}" == 1 ]] && [[ -d "$ROOT/venv" ]]; then
    if [[ -L "$ROOT/venv/bin/python" || -L "$ROOT/venv/bin/python3.12" ]]; then
      log "app launch: migrating venv to --copies (Finder cannot use symlinked python)"
      /usr/bin/osascript -e 'display notification "首次从 .app 启动，正在重建 Python 环境（约 1–2 分钟）…" with title "Lucas Chess"' 2>/dev/null || true
      rm -rf "$ROOT/venv"
    fi
  fi
  if [[ -d "$ROOT/venv" ]] && python_runnable "$ROOT/venv/bin/python" && venv_deps_ok; then
    return 0
  fi
  if [[ -d "$ROOT/venv" ]] && python_runnable "$ROOT/venv/bin/python"; then
    log "WARN venv deps incomplete (e.g. PySide6); reinstalling"
    install_venv_deps || { rm -rf "$ROOT/venv"; }
  fi
  if [[ -d "$ROOT/venv" ]] && python_runnable "$ROOT/venv/bin/python" && venv_deps_ok; then
    return 0
  fi
  if [[ -d "$ROOT/venv" ]]; then
    log "WARN venv python not runnable (exit 126?); recreating with --copies"
    rm -rf "$ROOT/venv"
  else
    log "creating venv"
    echo "Creating venv..."
  fi
  PYTHON312="$(find_python312)"
  "$PYTHON312" -m venv --copies "$ROOT/venv"
  install_venv_deps || exit 1
  if ! python_runnable "$ROOT/venv/bin/python"; then
    if [[ "${LUCASCHESS_FROM_APP:-}" == 1 ]] && app_fallback_python >/dev/null; then
      log "WARN venv python not runnable from .app; will use system python3.12"
      return 0
    fi
    log "ERROR venv python still not runnable after --copies recreate"
    exit 126
  fi
}

pick_launch_python() {
  ensure_venv
  local py="$ROOT/venv/bin/python"
  if python_runnable "$py"; then
    echo "$py"
    return 0
  fi
  if [[ "${LUCASCHESS_FROM_APP:-}" == 1 ]]; then
    py="$(app_fallback_python || true)"
    if [[ -n "$py" ]]; then
      echo "$py"
      return 0
    fi
  fi
  local fallback
  fallback="$(find_python312)"
  log "WARN using fallback python with VIRTUAL_ENV: $fallback"
  export VIRTUAL_ENV="$ROOT/venv"
  export PATH="$ROOT/venv/bin:$PATH"
  echo "$fallback"
}

if [[ ! -f "$ROOT/bin/OS/darwin/FasterCode.cpython-312-darwin.so" ]]; then
  log "building FasterCode"
  echo "Building FasterCode..."
  ensure_venv
  PYTHON="$ROOT/venv/bin/python" "$ROOT/venv/bin/pip" install -q cython setuptools
  PYTHON="$ROOT/venv/bin/python" "$ROOT/bin/_fastercode/fastercode_darwin.sh"
fi
STOCKFISH="$ROOT/bin/OS/darwin/Engines/stockfish/stockfish"
if [[ ! -x "$STOCKFISH" ]] && [[ ! -L "$STOCKFISH" ]]; then
  log "ERROR stockfish missing at $STOCKFISH"
  echo "Stockfish not found at $STOCKFISH" >&2
  echo "Install: brew install stockfish" >&2
  exit 1
fi
if [[ -L "$STOCKFISH" ]] && [[ ! -e "$STOCKFISH" ]]; then
  log "ERROR stockfish symlink broken"
  echo "Stockfish symlink broken (Homebrew not installed?). Try: brew install stockfish" >&2
  exit 1
fi
LAUNCH_PYTHON="$(pick_launch_python)"
log "starting python LucasR.py via $LAUNCH_PYTHON $*"
"$LAUNCH_PYTHON" LucasR.py "$@" 2>> "$LOG_FILE"
code=$?
if [[ "$code" -eq 126 && "${LUCASCHESS_FROM_APP:-}" == 1 ]]; then
  FALLBACK="$(app_fallback_python || true)"
  if [[ -n "$FALLBACK" && "$FALLBACK" != "$LAUNCH_PYTHON" ]]; then
    log "retry LucasR.py via $FALLBACK after exit 126"
    "$FALLBACK" LucasR.py "$@" 2>> "$LOG_FILE"
    code=$?
  fi
fi
log "python exit code=$code"
exit "$code"
