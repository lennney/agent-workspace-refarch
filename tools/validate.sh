#!/bin/bash
# validate.sh — 校验工作区上下文文件质量
# 用法: bash validate.sh /path/to/workspace
# 返回码: 0=通过, 1=警告, 2=错误

set -euo pipefail

TARGET="${1:-.}"
WORKSPACE_DIR="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"
ERRORS=0
WARNINGS=0

red()   { echo -e "\033[31m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
yellow(){ echo -e "\033[33m$1\033[0m"; }

echo "==> 校验工作区: $WORKSPACE_DIR"
echo ""

# ——— 1. 根 AGENTS.md ———
check_root_agents() {
  local file="$WORKSPACE_DIR/AGENTS.md"
  echo "--- 1. 根 AGENTS.md ---"
  if [ ! -f "$file" ]; then
    red "  ✗ 缺失根 AGENTS.md"
    ERRORS=$((ERRORS + 1))
    return
  fi
  green "  ✓ 存在"
  local lines
  lines=$(wc -l < "$file")
  if [ "$lines" -gt 80 ]; then
    yellow "  ⚠ 建议 ≤60 行，当前 $lines 行"
    WARNINGS=$((WARNINGS + 1))
  else
    green "  ✓ 行数 ($lines)"
  fi
  # 检查是否包含命令块
  if ! grep -qE '```(bash|sh)' "$file" 2>/dev/null; then
    yellow '  ⚠ 缺少命令示例（```bash）'
    WARNINGS=$((WARNINGS + 1))
  else
    green "  ✓ 包含命令块"
  fi
}

# ——— 2. 子项目 AGENTS.md ———
check_project_agents() {
  echo "--- 2. 子项目 AGENTS.md ---"
  local found=0
  while IFS= read -r -d '' file; do
    local dir
    dir="$(dirname "$file")"
    local rel
    rel="${dir#$WORKSPACE_DIR/}"
    if [ "$dir" = "$WORKSPACE_DIR" ]; then
      continue
    fi
    found=1
    local lines
    lines=$(wc -l < "$file")
    if [ "$lines" -gt 180 ]; then
      yellow "  ⚠ $rel/AGENTS.md 建议 ≤150 行，当前 $lines 行"
      WARNINGS=$((WARNINGS + 1))
    else
      green "  ✓ $rel/AGENTS.md ($lines 行)"
    fi
    # 检查约束优先级
    if ! grep -qE '^[0-9]+\.' "$file" 2>/dev/null; then
      yellow "  ⚠ $rel/AGENTS.md 缺少编号约束（建议 1. 2. 3.）"
      WARNINGS=$((WARNINGS + 1))
    fi
  done < <(find "$WORKSPACE_DIR" -name "AGENTS.md" -not -path "*/node_modules/*" -not -path "*/.git/*" -print0)
  if [ "$found" -eq 0 ]; then
    yellow "  ⚠ 未发现子项目 AGENTS.md（纯单项目工作区可忽略）"
    WARNINGS=$((WARNINGS + 1))
  fi
}

# ——— 3. HANDOVER.md 时效性 ———
check_handover() {
  echo "--- 3. HANDOVER.md 时效性 ---"
  local found=0
  while IFS= read -r -d '' file; do
    found=1
    local dir
    dir="$(dirname "$file")"
    local rel
    rel="${dir#$WORKSPACE_DIR/}"
    if [ ! -s "$file" ]; then
      yellow "  ⚠ $rel/HANDOVER.md 为空（模板待填充）"
      WARNINGS=$((WARNINGS + 1))
      continue
    fi
    # 检查上次更新时间（检查文件修改时间）
    local mtime
    mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || echo 0)
    local now
    now=$(date +%s)
    local days_old=$(( (now - mtime) / 86400 ))
    if [ "$days_old" -gt 30 ]; then
      yellow "  ⚠ $rel/HANDOVER.md 已 $days_old 天未更新（可能过期）"
      WARNINGS=$((WARNINGS + 1))
    else
      green "  ✓ $rel/HANDOVER.md ($days_old 天前更新)"
    fi
  done < <(find "$WORKSPACE_DIR" -name "HANDOVER.md" -not -path "*/node_modules/*" -not -path "*/.git/*" -print0)
  if [ "$found" -eq 0 ]; then
    yellow "  ⚠ 未发现 HANDOVER.md"
    WARNINGS=$((WARNINGS + 1))
  fi
}

# ——— 4. .workspace.yaml 格式 ———
check_workspace_yaml() {
  echo "--- 4. .workspace.yaml ---"
  local file="$WORKSPACE_DIR/.workspace.yaml"
  if [ ! -f "$file" ]; then
    yellow "  ⚠ 缺失 .workspace.yaml（Hermes 需要，其他工具可忽略）"
    WARNINGS=$((WARNINGS + 1))
    return
  fi
  # 尝试用 python 检查 YAML 格式
  if python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
    green "  ✓ YAML 格式正确"
  else
    red "  ✗ YAML 格式错误"
    ERRORS=$((ERRORS + 1))
  fi
}

# ——— 5. AGENTS.md 不被 gitignore ———
check_gitignore() {
  echo "--- 5. AGENTS.md 不被 gitignore ---"
  if [ -f "$WORKSPACE_DIR/.gitignore" ]; then
    if grep -qE '^AGENTS\.md$' "$WORKSPACE_DIR/.gitignore" 2>/dev/null; then
      red "  ✗ .gitignore 排除了 AGENTS.md（agent 读不到）"
      ERRORS=$((ERRORS + 1))
    else
      green "  ✓ AGENTS.md 未被排除"
    fi
  else
    green "  ✓ 无 .gitignore（无需检查）"
  fi
}

# ——— 运行检查 ———
check_root_agents
echo ""
check_project_agents
echo ""
check_handover
echo ""
check_workspace_yaml
echo ""
check_gitignore
echo ""

# ——— 汇总 ———
echo "=============================="
if [ "$ERRORS" -gt 0 ] || [ "$WARNINGS" -gt 0 ]; then
  [ "$ERRORS" -gt 0 ] && red "  错误: $ERRORS"
  [ "$WARNINGS" -gt 0 ] && yellow "  警告: $WARNINGS"
  [ "$ERRORS" -gt 0 ] && exit 2 || exit 1
else
  green "  ✅ 全部通过"
  exit 0
fi
