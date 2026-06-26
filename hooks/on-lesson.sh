#!/bin/bash
# on-lesson.sh — 踩坑后自动记录到 LEARNINGS.md
# 运行时机: Agent 踩到新坑或发现架构洞察时
# 用法: bash on-lesson.sh <lesson_text> [category]
# category: 踩坑 (默认) / 发现 / 规则

set -euo pipefail

LESSON="${1:?Usage: on-lesson.sh <lesson_text> [category]}"
CATEGORY="${2:-踩坑}"
DATE=$(date '+%Y-%m-%d')
LEARNINGS_FILE="LEARNINGS.md"

# 如果 LEARNINGS.md 不存在，从模板创建
if [ ! -f "$LEARNINGS_FILE" ]; then
  cat > "$LEARNINGS_FILE" << 'EOF'
# LEARNINGS.md

> Agent 每次踩坑后自动追加，不需要手动维护。

## 踩坑记录

## 架构发现

EOF
  echo "  ✓ 创建 $LEARNINGS_FILE"
fi

# 选择目标 section
case "$CATEGORY" in
  踩坑|坑|bug|issue)     SECTION="## 踩坑记录" ;;
  发现|insight|pattern)  SECTION="## 架构发现" ;;
  规则|rule|convention)  SECTION="## 踩坑记录" ;;  # 规则也归到踩坑，附带规则行
  *)                      SECTION="## 踩坑记录" ;;
esac

# 格式化条目
ENTRY="### $DATE: $LESSON"

# 插入到对应 section
if grep -q "^$SECTION" "$LEARNINGS_FILE"; then
  sed -i "/^$SECTION/a\\
\\
$ENTRY" "$LEARNINGS_FILE"
else
  echo -e "\n$SECTION\n\n$ENTRY" >> "$LEARNINGS_FILE"
fi

# 如果超过 30 条，提示归档
COUNT=$(grep -c "^### " "$LEARNINGS_FILE" 2>/dev/null || echo "0")
if [ "$COUNT" -gt 30 ]; then
  echo "⚠️  LEARNINGS.md 已有 $COUNT 条，建议归档旧记录到 docs/history/"
fi

echo "✅ 已记录到 LEARNINGS.md: $ENTRY"
