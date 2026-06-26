#!/bin/bash
# pre-commit hook — commit 前校验上下文文件
# 用法: 复制到 .git/hooks/pre-commit

set -euo pipefail

echo "==> [pre-commit] 校验上下文文件..."

# ——— 检查 AGENTS.md 未被 gitignore ———
if [ -f .gitignore ] && grep -qE '^AGENTS\.md$' .gitignore 2>/dev/null; then
  echo "✗ .gitignore 排除了 AGENTS.md（agent 读不到）"
  exit 1
fi

# ——— 运行 agents-lint（如果安装了） ———
if command -v npx &>/dev/null && npx --yes agents-lint --version &>/dev/null; then
  npx agents-lint --max-warnings 5 || {
    echo "✗ AGENTS.md 存在过期内容，请修复后重试"
    exit 1
  }
fi

# ——— CLAUDE.md 符号链接 ———
if [ -f AGENTS.md ] && [ ! -L CLAUDE.md ]; then
  echo "⚠ 缺少 CLAUDE.md → AGENTS.md 符号链接"
  echo "  运行: ln -sf AGENTS.md CLAUDE.md"
fi

# ——— HANDOVER.md 时效 ———
if [ -f HANDOVER.md ]; then
  mtime=$(stat -c %Y HANDOVER.md 2>/dev/null || stat -f %m HANDOVER.md 2>/dev/null || echo 0)
  now=$(date +%s)
  days_old=$(( (now - mtime) / 86400 ))
  if [ "$days_old" -gt 30 ]; then
    echo "⚠ HANDOVER.md 已 $days_old 天未更新"
  fi
fi

echo "==> ✓ 上下文文件检查通过"
