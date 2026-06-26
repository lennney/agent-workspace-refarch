#!/bin/bash
# on-pretooluse.sh
# PreToolUse hook: 多文件写操作前检查影响范围
# 运行时机: Write/Edit/Patch 工具执行前
# 输入: stdin 接收 JSON {tool, tool_input, ...}
# 退出: 0 = 允许, 1 = 阻止

set -euo pipefail

# 如果 AGENTS.md 声明了 CodeGraph，自动调用影响分析
if grep -q "CodeGraph\|codegraph" "AGENTS.md" 2>/dev/null; then
  # 检查是否是批量文件修改
  INPUT_FILE=$(echo "$1" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")
  if [ -n "$INPUT_FILE" ] && [ -f "$INPUT_FILE" ]; then
    echo "ℹ 修改文件: $INPUT_FILE"
    # 提示 agent 调用 CodeGraph（无法直接调用 MCP from shell hook）
    echo "  建议: 调用 codegraph.affected('$INPUT_FILE') 检查影响范围"
  fi
fi

# 阻止对 .env 的直接写入
if echo "$*" | grep -q "\.env"; then
  echo "⚠ 检测到 .env 文件操作。确认不包含密钥？"
fi

exit 0
