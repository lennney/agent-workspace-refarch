#!/bin/bash
# on-session-end.sh
# SessionEnd hook: 自动写 HANDOVER.md 的变更记录
# 运行时机: session 正常结束时
# 效果: 从 git log + 编辑记录 生成变更摘要，追加到 HANDOVER.md

set -euo pipefail

HANDOVER_FILE="HANDOVER.md"
EDIT_LOG=".claude/hooks/recent_edits.log"

echo "==> [hook] SessionEnd: 更新 session 记录..."

# 如果 HANDOVER.md 不存在，跳过
[ ! -f "$HANDOVER_FILE" ] && echo "⚠ 无 HANDOVER.md，跳过" && exit 0

# 1. 从 git diff 提取变更摘要
GIT_SUMMARY=$(git diff --stat HEAD 2>/dev/null || echo "")
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# 2. 检查是否有未提交的修改
UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l || echo "0")

# 3. 写出 session 脚注
{
  echo ""
  echo "---"
  echo "## Session End: $(date '+%Y-%m-%d %H:%M')"
  echo "- 分支: $GIT_BRANCH"
  echo "- 未提交文件数: $UNCOMMITTED"
  if [ -n "$GIT_SUMMARY" ]; then
    echo "- 本次修改:"
    echo "\`\`\`"
    echo "$GIT_SUMMARY"
    echo "\`\`\`"
  fi
  echo ""
  echo "*如果此 session 有显著进展或决策，请更新上方表格*"
} >> "$HANDOVER_FILE"

# 4. 清理编辑日志
rm -f "$EDIT_LOG"

echo "==> ✓ Session 已记录到 $HANDOVER_FILE"
exit 0
