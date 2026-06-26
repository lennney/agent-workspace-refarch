#!/bin/bash
# on-precompact.sh
# PreCompact hook: 上下文压缩前保存 session 状态
# 运行时机: Claude Code 即将压缩上下文时
# 效果: 保存当前状态到 .claude/session_state/，压缩后可根据此恢复

set -euo pipefail

STATE_DIR=".claude/session_state"
mkdir -p "$STATE_DIR"

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
STATE_FILE="$STATE_DIR/$TIMESTAMP.json"

# 保存当前会话摘要
cat > "$STATE_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "type": "precompact",
  "files_modified": $(git diff --name-only 2>/dev/null | jq -R -s -c 'split("\n")[:-1]' 2>/dev/null || echo "[]"),
  "branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')"
}
EOF

# 保留最近 10 个状态
ls -t "$STATE_DIR"/*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true

exit 0
