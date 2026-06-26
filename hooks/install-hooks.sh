#!/bin/bash
# install-hooks.sh — 将 hooks 包安装到目标项目
# 用法: bash install-hooks.sh /path/to/project
# 效果: 创建 .claude/hooks/ + .claude/settings.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
PROJ_DIR="$(cd "$TARGET" 2>/dev/null && pwd || { echo "目录 $TARGET 不存在"; exit 1; })"

echo "==> 安装 hooks 到: $PROJ_DIR"

# 创建 .claude 目录
CLAUDE_DIR="$PROJ_DIR/.claude"
mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/session_state"

# 复制 settings.json（不覆盖已有）
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
  echo "  ✓ .claude/settings.json"
else
  echo "  - .claude/settings.json 已存在，跳过"
fi

# 复制 hook 脚本
for HOOK_SCRIPT in on-session-start.sh on-pretooluse.sh on-posttooluse.sh on-precompact.sh on-session-end.sh; do
  if [ ! -f "$CLAUDE_DIR/hooks/$HOOK_SCRIPT" ]; then
    cp "$SCRIPT_DIR/$HOOK_SCRIPT" "$CLAUDE_DIR/hooks/$HOOK_SCRIPT"
    chmod +x "$CLAUDE_DIR/hooks/$HOOK_SCRIPT"
  fi
done
echo "  ✓ .claude/hooks/ (5 个脚本)"

# 复制 handover 命令脚本
if [ ! -f "$PROJ_DIR/handover.sh" ]; then
  cp "$SCRIPT_DIR/handover.sh" "$PROJ_DIR/handover.sh"
  chmod +x "$PROJ_DIR/handover.sh"
  echo "  ✓ handover.sh (用于 /handover 命令)"
fi

# 创建 .gitignore 条目（如果不存在）
GITIGNORE="$PROJ_DIR/.gitignore"
if ! grep -q "\.claude/hooks" "$GITIGNORE" 2>/dev/null; then
  {
    echo ""
    echo "# Claude Code hooks (不要提交到 repo, 因为路径可能不同)"
    echo ".claude/hooks/"
    echo ".claude/session_state/"
  } >> "$GITIGNORE"
  echo "  ✓ .gitignore 更新"
fi

echo ""
echo "==> ✅ hooks 安装完成！"
echo "下次启动 Claude Code 时自动生效。"
echo "在 session 中调用 /handover 查看进度摘要。"
