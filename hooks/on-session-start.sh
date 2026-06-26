#!/bin/bash
# on-session-start.sh
# SessionStart hook: 自动加载 handover + 检查环境
# 运行时机: 每次 session 启动时
# 输入: 无
# 退出: 0 = 环境就绪, 1 = 环境问题

set -euo pipefail

HANDOVER_FILE="HANDOVER.md"
AGENTS_FILE="AGENTS.md"

echo "==> [hook] SessionStart: 初始化工作区..."

# 1. 检查 AGENTS.md 存在
if [ ! -f "$AGENTS_FILE" ]; then
  echo "⚠ 未找到 AGENTS.md，请运行 setup.sh 初始化"
  exit 1
fi

# 2. 检查 HANDOVER.md 存在并显示状态
if [ -f "$HANDOVER_FILE" ]; then
  CURRENT_GOAL=$(grep -m1 '当前目标' "$HANDOVER_FILE" 2>/dev/null || echo "未设置")
  echo "当前目标: $CURRENT_GOAL"
else
  echo "⚠ 未找到 HANDOVER.md，将创建"
  echo "# HANDOVER" > "$HANDOVER_FILE"
  echo "# 当前目标" >> "$HANDOVER_FILE"
  echo "[待设置]" >> "$HANDOVER_FILE"
fi

# 3. 检查 CLAUDE.md 符号链接
if [ ! -L "CLAUDE.md" ]; then
  echo "⚠ 缺少 CLAUDE.md 符号链接，创建中..."
  ln -sf AGENTS.md CLAUDE.md
fi

# 4. 检查上次 session 时间（避免过久的手账）
if [ -f "$HANDOVER_FILE" ]; then
  MTIME=$(stat -c %Y "$HANDOVER_FILE" 2>/dev/null || echo "0")
  NOW=$(date +%s)
  DAYS_OLD=$(( (NOW - MTIME) / 86400 ))
  if [ "$DAYS_OLD" -gt 14 ]; then
    echo "⚠ 上次更新是 $DAYS_OLD 天前，请确认 HANDOVER.md 是否仍有效"
  fi
fi

# 5. 确认 CodeGraph/GitNexus MCP 可用（如果在 AGENTS.md 声明了）
if grep -q "CodeGraph\|codegraph" "$AGENTS_FILE" 2>/dev/null; then
  echo "CodeGraph 已声明"
fi

echo "==> ✓ 环境就绪"
exit 0
