# Claude Code Hooks — Agent Workspace 自动维护

> Claude Code 支持 PreToolUse / PostToolUse hooks。
> 以下配置自动维护 AGENTS.md 和 HANDOVER.md 的一致性。

## 用法

在项目根目录创建 `.claude/hooks/` 目录，放入以下脚本。

### PostToolUse: 文件修改后自动更新 HANDOVER.md

`.claude/hooks/post_tool_use.sh`：

```bash
#!/bin/bash
# 每次文件写入后检查是否需要更新 HANDOVER.md
# 检测是否有非文档文件被修改
CHANGED_FILES=$(git diff --name-only 2>/dev/null || echo "")
if [ -n "$CHANGED_FILES" ]; then
  # 排除 HANDOVER.md 自身和 docs/ 目录的修改循环
  if ! echo "$CHANGED_FILES" | grep -q "HANDOVER.md"; then
    echo "⚠ 检测到文件修改。请记得在 session 结束时更新 HANDOVER.md"
  fi
fi
```

### PostToolUse: 命令执行后自动校验 AGENTS.md

`.claude/hooks/post_tool_use.sh`（扩展版）：

```bash
#!/bin/bash
# 执行 tests/build 命令后，验证 AGENTS.md 中的命令是否仍有效
COMMAND="$HERMES_TOOL_INPUT"  # 从环境变量获取
if echo "$COMMAND" | grep -qE "(pytest|npm test|go test)"; then
  echo "✓ 运行了测试命令"
fi
```

### PreToolUse: 多文件修改前查 CodeGraph

`.claude/hooks/pre_tool_use.sh`：

```bash
#!/bin/bash
# 如果要写 2+ 文件，提醒查询 CodeGraph
if [ "${HERMES_TOOL_NAME}" = "write_file" ] || [ "${HERMES_TOOL_NAME}" = "patch" ]; then
  # 统计当前 session 的文件修改数
  MOD_COUNT=$(git diff --name-only 2>/dev/null | wc -l)
  if [ "$MOD_COUNT" -gt 2 ]; then
    echo "⚠ 已修改 $MOD_COUNT 个文件。建议调用 CodeGraph 检查影响范围。"
  fi
fi
```

## 批处理模式（cron job）

如果 Hermes Agent 的 cron 在运行，可以加一个每日检查：

```yaml
# cron: 每日检查 HANDOVER.md 时效性
schedule: "0 9 * * *"
prompt: "检查 workspace 下所有 HANDOVER.md 文件。列出超过 7 天未更新的文件。"
workdir: /path/to/workspace
```
