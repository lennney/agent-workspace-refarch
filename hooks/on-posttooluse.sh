#!/bin/bash
# on-posttooluse.sh
# PostToolUse hook: 文件写完后记录变更、触发校验
# 运行时机: Write/Edit/Patch 工具执行后
# 输入: stdin 接收 JSON{tool, tool_input, result}

set -euo pipefail

# 记录最近修改的文件到 .claude/last_edit
mkdir -p .claude/hooks
echo "$(date '+%Y-%m-%d %H:%M'): $*" >> .claude/hooks/recent_edits.log

# 仅保留最近 50 条
tail -50 .claude/hooks/recent_edits.log > .claude/hooks/recent_edits.log.tmp
mv .claude/hooks/recent_edits.log.tmp .claude/hooks/recent_edits.log

exit 0
