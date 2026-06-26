#!/bin/bash
# Agent Workspace Reference Architecture — 一键初始化
# 在已有 workspace 中初始化模板结构
# 用法: bash setup.sh /path/to/workspace

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
mkdir -p "$TARGET"
WORKSPACE_DIR="$(cd "$TARGET" && pwd)"

echo "==> 初始化 Agent Workspace: $WORKSPACE_DIR"

# ——— 拷贝外层模板 ———
echo "==> 创建 workspace 层模板..."
if [ ! -f "$WORKSPACE_DIR/AGENTS.md" ]; then
  cp "$SCRIPT_DIR/template-root/AGENTS.md" "$WORKSPACE_DIR/AGENTS.md"
  echo "  ✓ AGENTS.md（外层）"
else
  echo "  - AGENTS.md 已存在，跳过"
fi

if [ ! -f "$WORKSPACE_DIR/.workspace.yaml" ]; then
  cp "$SCRIPT_DIR/template-root/.workspace.yaml" "$WORKSPACE_DIR/.workspace.yaml"
  echo "  ✓ .workspace.yaml"
else
  echo "  - .workspace.yaml 已存在，跳过"
fi

if [ ! -d "$WORKSPACE_DIR/shared" ]; then
  mkdir -p "$WORKSPACE_DIR/shared"
  cp "$SCRIPT_DIR/template-root/shared/"*.md "$WORKSPACE_DIR/shared/" 2>/dev/null || true
  echo "  ✓ shared/（跨项目文档）"
else
  echo "  - shared/ 已存在，跳过"
fi

# ——— 子项目初始化（如果传了子项目参数） ———
shift 2>/dev/null || true
if [ $# -gt 0 ]; then
  for PROJ in "$@"; do
    PROJ_DIR="$WORKSPACE_DIR/$PROJ"
    if [ ! -d "$PROJ_DIR" ]; then
      echo "  ⚠ 目录 $PROJ_DIR 不存在，跳过"
      continue
    fi
    echo "==> 初始化子项目: $PROJ"

    if [ ! -f "$PROJ_DIR/AGENTS.md" ]; then
      cp "$SCRIPT_DIR/template-project/AGENTS.md" "$PROJ_DIR/AGENTS.md"
      echo "  ✓ AGENTS.md（项目内）"
    fi
    if [ ! -f "$PROJ_DIR/HANDOVER.md" ]; then
      cp "$SCRIPT_DIR/template-project/HANDOVER.md" "$PROJ_DIR/HANDOVER.md"
      echo "  ✓ HANDOVER.md"
    fi
    if [ ! -d "$PROJ_DIR/docs" ]; then
      mkdir -p "$PROJ_DIR/docs/decisions" "$PROJ_DIR/docs/history"
      # 复制 docs/ 下所有文件
      cp "$SCRIPT_DIR/template-project/docs/"*.md "$PROJ_DIR/docs/" 2>/dev/null || true
      cp "$SCRIPT_DIR/template-project/docs/decisions/"*.md "$PROJ_DIR/docs/decisions/" 2>/dev/null || true
      cp "$SCRIPT_DIR/template-project/docs/history/.gitkeep" "$PROJ_DIR/docs/history/" 2>/dev/null || true
      echo "  ✓ docs/（架构+规范+陷阱+决策+索引+历史）"
    else
      # 只增量补充缺失的文件和子目录
      [ ! -d "$PROJ_DIR/docs/decisions" ] && mkdir -p "$PROJ_DIR/docs/decisions"
      [ ! -d "$PROJ_DIR/docs/history" ] && mkdir -p "$PROJ_DIR/docs/history"
      cp "$SCRIPT_DIR/template-project/docs/decisions/"*.md "$PROJ_DIR/docs/decisions/" 2>/dev/null || true
      # 增量补充缺失的模板文件（不覆盖已有）
      for f in index.md active_plan.md known_issues.md; do
        [ ! -f "$PROJ_DIR/docs/$f" ] && cp "$SCRIPT_DIR/template-project/docs/$f" "$PROJ_DIR/docs/" 2>/dev/null || true
      done
      echo "  ✓ docs/（增量补充）"
    fi

    # ——— CLAUDE.md 符号链接 ———
    if [ ! -L "$PROJ_DIR/CLAUDE.md" ]; then
      ln -sf AGENTS.md "$PROJ_DIR/CLAUDE.md"
      echo "  ✓ CLAUDE.md → AGENTS.md"
    fi

    # ——— pre-commit hook ———
    HOOK_DIR="$PROJ_DIR/.git/hooks"
    if [ -d "$HOOK_DIR" ] && [ ! -f "$HOOK_DIR/pre-commit" ]; then
      cp "$SCRIPT_DIR/tools/pre-commit.sh" "$HOOK_DIR/pre-commit"
      chmod +x "$HOOK_DIR/pre-commit"
      echo "  ✓ pre-commit hook"
    fi

    # ——— .agents-lint.json ———
    if [ ! -f "$PROJ_DIR/.agents-lint.json" ]; then
      echo '{}' > "$PROJ_DIR/.agents-lint.json"
      echo "  ✓ .agents-lint.json"
    fi
  done
fi

# ——— 工作区级 CLAUDE.md ———
if [ ! -L "$WORKSPACE_DIR/CLAUDE.md" ]; then
  ln -sf AGENTS.md "$WORKSPACE_DIR/CLAUDE.md"
  echo "  ✓ CLAUDE.md → AGENTS.md（外层）"
fi

# ——— 可选：安装 hooks ———
# 使用 INSTALL_HOOKS=y bash setup.sh ... 激活
if [ "${INSTALL_HOOKS:-}" = "y" ] || [ "${INSTALL_HOOKS:-}" = "Y" ]; then
  bash "$SCRIPT_DIR/hooks/install-hooks.sh" "$WORKSPACE_DIR"
fi

echo ""
echo "==> ✅ 初始化完成！"
echo ""
echo "下一步："
echo "  1. 编辑外层 AGENTS.md：填写项目地图和依赖关系"
echo "  2. 编辑各子项目 AGENTS.md：填写技术栈和命令"
echo "  3. 安装 pre-commit hook: cp tools/pre-commit.sh .git/hooks/pre-commit"
echo "  4. 安装 agents-lint: npx agents-lint --fix"
echo "  5. 开始第一个 session 前先写 HANDOVER.md 的当前目标"
echo "  6. 设置 CLAUDE.md 符号链接（已完成）"
echo ""
echo "详细文档见: $SCRIPT_DIR/architecture.md"

# End of setup.sh
