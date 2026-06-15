#!/bin/bash
cd "$(dirname "$0")"
ROOT="$(pwd)"
LOG="$ROOT/UserData/launch.log"
BUG="$ROOT/bin/bug.log"

echo "Lucas Chess 启动中…"
echo "若未见窗口，请按 ⌘Tab 切换到 Python 或 Lucas Chess。"
echo ""

/bin/bash ./bin/run_mac.sh "$@"
code=$?

if [[ "$code" -ne 0 ]]; then
  echo ""
  echo "Lucas Chess 启动失败 (exit $code)"
  echo "  启动日志: $LOG"
  echo "  应用日志: $BUG"
  echo ""
  tail -30 "$LOG" 2>/dev/null || true
  echo ""
  read -r -p "按 Enter 关闭此窗口..."
  exit "$code"
fi
