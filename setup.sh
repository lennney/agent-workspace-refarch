#!/bin/bash
# Agent Workspace Reference Architecture — 一键初始化
# 在已有 workspace 中初始化模板结构
# 用法: bash setup.sh /path/to/workspace [project-dirs...] [--type js|python]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="${1:-.}"
shift 2>/dev/null || true

# Parse --type flag
TEMPLATE_TYPE="python"  # default
POSITIONAL_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --type)
      TEMPLATE_TYPE="$2"
      shift 2
      ;;
    *)
      POSITIONAL_ARGS+=("$1")
      shift
      ;;
  esac
done

mkdir -p "$TARGET"
WORKSPACE_DIR="$(cd "$TARGET" && pwd)"

echo "==> 初始化 Agent Workspace: $WORKSPACE_DIR (type=$TEMPLATE_TYPE)"

# Pick templates based on type
if [ "$TEMPLATE_TYPE" = "node" ] || [ "$TEMPLATE_TYPE" = "js" ]; then
  ROOT_AGENTS_TEMPLATE="$SCRIPT_DIR/template-root/AGENTS.node.md"
  PROJ_AGENTS_TEMPLATE="$SCRIPT_DIR/template-project/AGENTS.node.md"
else
  ROOT_AGENTS_TEMPLATE="$SCRIPT_DIR/template-root/AGENTS.md"
  PROJ_AGENTS_TEMPLATE="$SCRIPT_DIR/template-project/AGENTS.md"
fi

# Fallback to default if template file doesn't exist
[ ! -f "$ROOT_AGENTS_TEMPLATE" ] && ROOT_AGENTS_TEMPLATE="$SCRIPT_DIR/template-root/AGENTS.md"
[ ! -f "$PROJ_AGENTS_TEMPLATE" ] && PROJ_AGENTS_TEMPLATE="$SCRIPT_DIR/template-project/AGENTS.md"

# ——— 拷贝外层模板 ———
echo "==> 创建 workspace 层模板..."
if [ ! -f "$WORKSPACE_DIR/AGENTS.md" ]; then
  cp "$ROOT_AGENTS_TEMPLATE" "$WORKSPACE_DIR/AGENTS.md"
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

# ——— 子项目初始化 ———
for PROJ in "${POSITIONAL_ARGS[@]}"; do
  PROJ_DIR="$WORKSPACE_DIR/$PROJ"
  if [ ! -d "$PROJ_DIR" ]; then
    echo "  ⚠ 目录 $PROJ_DIR 不存在，跳过"
    continue
  fi
  echo "==> 初始化子项目: $PROJ"

  if [ ! -f "$PROJ_DIR/AGENTS.md" ]; then
    cp "$PROJ_AGENTS_TEMPLATE" "$PROJ_DIR/AGENTS.md"
    echo "  ✓ AGENTS.md（项目内）"
  else
    echo "  - AGENTS.md 已存在，跳过"
  fi
  if [ ! -f "$PROJ_DIR/HANDOVER.md" ]; then
    cp "$SCRIPT_DIR/template-project/HANDOVER.md" "$PROJ_DIR/HANDOVER.md"
    echo "  ✓ HANDOVER.md"
  fi
  if [ ! -f "$PROJ_DIR/LEARNINGS.md" ]; then
    cp "$SCRIPT_DIR/template-project/LEARNINGS.md" "$PROJ_DIR/LEARNINGS.md"
    echo "  ✓ LEARNINGS.md"
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

# ——— 工作区级 CLAUDE.md 符号链接（带备份） ———
if [ ! -L "$WORKSPACE_DIR/CLAUDE.md" ]; then
  if [ -f "$WORKSPACE_DIR/CLAUDE.md" ]; then
    # 已有真实 CLAUDE.md，备份后再创建链接
    BAK_DIR="$WORKSPACE_DIR/.claude"
    mkdir -p "$BAK_DIR"
    cp "$WORKSPACE_DIR/CLAUDE.md" "$BAK_DIR/CLAUDE.md.bak"
    echo "  ✓ CLAUDE.md 已备份到 .claude/CLAUDE.md.bak"
  fi
  ln -sf AGENTS.md "$WORKSPACE_DIR/CLAUDE.md"
  echo "  ✓ CLAUDE.md → AGENTS.md（外层）"
fi

# ——— .gitignore 更新：忽略 CLAUDE.md ———
GITIGNORE_FILE="$WORKSPACE_DIR/.gitignore"
if [ -f "$GITIGNORE_FILE" ]; then
  if ! grep -q "^CLAUDE\.md$" "$GITIGNORE_FILE" 2>/dev/null; then
    {
      echo ""
      echo "# CLAUDE.md 是 AGENTS.md 的符号链接，由 setup.sh 自动管理"
      echo "CLAUDE.md"
    } >> "$GITIGNORE_FILE"
    echo "  ✓ CLAUDE.md → .gitignore"
  fi
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
